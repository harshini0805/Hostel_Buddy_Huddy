// main.dart - Enhanced Beacon Attendance System with History
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/face_verification_screen.dart';
import 'screens/face_registration_screen.dart';
import 'package:camera/camera.dart';
import 'services/face_storage_service.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beacon Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      home: const AttendancePage(),
    );
  }
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final LocalAuthentication auth = LocalAuthentication();
  final String targetBeaconAddress = "44:8C:00:A6:D7:42";
  bool _faceRegistered = false;
  bool _isScanning = false;
  bool _beaconInRange = false;
  bool _isAuthenticated = false;
  bool _attendanceMarked = false;
  String _statusMessage = "Searching for beacon...";
  List<ScanResult> _scanResults = [];
  List<DateTime> _attendanceDates = [];
  late List<CameraDescription> _cameras;
  late CameraController? _cameraController;
  bool _camerasInitialized = false;

  void _showBluetoothDevicesDialog() {
  if (_scanResults.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No devices discovered yet. Scanning...'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bluetooth, color: Colors.indigo),
            SizedBox(width: 10),
            Text('Discovered Devices'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _scanResults.length,
            itemBuilder: (context, index) {
              final result = _scanResults[index];
              final device = result.device;
              final String name = device.platformName.isNotEmpty
                  ? device.platformName
                  : 'Unknown Device';
              final String mac = device.remoteId.toString();

              // Highlight your target beacon
              final bool isTargetBeacon = mac == targetBeaconAddress;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: isTargetBeacon ? Colors.indigo[50] : null,
                child: ListTile(
                  leading: Icon(
                    isTargetBeacon ? Icons.my_location : Icons.bluetooth,
                    color: isTargetBeacon ? Colors.indigo : Colors.grey,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    mac,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${result.rssi} dBm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: result.rssi > -70 ? Colors.green : Colors.red,
                        ),
                      ),
                      if (isTargetBeacon)
                        const Text(
                          'Target',
                          style: TextStyle(color: Colors.indigo, fontSize: 12),
                        ),
                    ],
                  ),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: mac));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied: $mac')),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
  
  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
    _checkTodayAttendance();
    _requestPermissions();
    _initializeCameras();
    _loadFaceRegistrationStatus();
  }

  Future<void> _loadFaceRegistrationStatus() async {
  final bool registered = await FaceStorageService.hasFaceRegistered();
  if (mounted) {
    setState(() {
      _faceRegistered = registered;
    });
  }
}

  Future<void> _initializeCameras() async {
  try {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _cameraController = CameraController(
        _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        ),
        ResolutionPreset.high,
      );
      await _cameraController?.initialize();
    }
    if (mounted) {
      setState(() {
        _camerasInitialized = true;
      });
    }
  } catch (e) {
    debugPrint('Camera initialization error: $e');
  }
}

  // Load attendance history from storage
  Future<void> _loadAttendanceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? datesJson = prefs.getString('attendance_dates');
    if (datesJson != null) {
      final List<dynamic> datesList = json.decode(datesJson);
      setState(() {
        _attendanceDates = datesList.map((d) => DateTime.parse(d)).toList();
      });
    }
  }

  // Save attendance history
  Future<void> _saveAttendanceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String datesJson = json.encode(
      _attendanceDates.map((d) => d.toIso8601String()).toList()
    );
    await prefs.setString('attendance_dates', datesJson);
  }

  // Check if attendance already marked today
  void _checkTodayAttendance() {
    final today = DateTime.now();
    final markedToday = _attendanceDates.any((date) =>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day
    );
    
    if (markedToday) {
      setState(() {
        _attendanceMarked = true;
        _statusMessage = "✓ Attendance already marked today!";
      });
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    
    bool allGranted = statuses.values.every((status) => status.isGranted);
    
    if (allGranted) {
      _startBeaconScanning();
    } else {
      setState(() {
        _statusMessage = "Permissions denied. Please enable Bluetooth and Location.";
      });
    }
  }

  Future<void> _startBeaconScanning() async {
    setState(() {
      _isScanning = true;
      _statusMessage = "Scanning for beacon...";
    });

    try {
      var adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        setState(() {
          _statusMessage = "Please turn on Bluetooth";
          _isScanning = false;
        });
        return;
      }

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _scanResults = results;
        });
        
        bool foundBeacon = results.any((result) => 
          result.device.remoteId.toString() == targetBeaconAddress ||
          result.device.platformName.toLowerCase().contains('beacon')
        );

        setState(() {
        _beaconInRange = foundBeacon;
        if (_attendanceMarked) {
          _statusMessage = "✓ Attendance already marked today!";
        } else if (foundBeacon) {
          _statusMessage = "✓ Beacon detected! Tap to authenticate.";
        } else {
          _statusMessage = "✗ Beacon not in range. Move closer.";
        }
      });
      });

      FlutterBluePlus.isScanning.listen((scanning) {
        if (!scanning && !_attendanceMarked) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && !_attendanceMarked) {
              FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
            }
          });
        }
      });

    } catch (e) {
      setState(() {
        _statusMessage = "Error scanning: $e";
        _isScanning = false;
      });
    }
  }

 Future<void> _authenticate() async {
  // Check if beacon is in range
  if (!_beaconInRange) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ You must be near the beacon to authenticate!'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Ensure cameras are initialized
  if (!_camerasInitialized || _cameras.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Camera not available. Please restart the app.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // STEP 1: Face Verification
  bool faceVerified = false;
  try {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FaceVerificationScreen(
          cameras: _cameras, // ← Now passing the required parameter
        ),
      ),
    );

    if (result == true) {
      faceVerified = true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Face verification failed or cancelled'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  } catch (e) {
    debugPrint('Face verification error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Face verification error: $e'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // STEP 2: Fingerprint Verification (only if face passed)
  bool fingerprintAuthenticated = false;
  try {
    fingerprintAuthenticated = await auth.authenticate(
      localizedReason: 'Scan fingerprint to complete attendance',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  } on PlatformException catch (e) {
    debugPrint('Fingerprint error: ${e.code} - ${e.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Fingerprint error: ${e.message ?? 'Unknown'}'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  } catch (e) {
    debugPrint('Authentication error: $e');
    return;
  }

  if (!mounted) return;

  // STEP 3: Mark Attendance if both succeeded
  if (faceVerified && fingerprintAuthenticated) {
    setState(() {
      _isAuthenticated = true;
      _attendanceMarked = true;
      _statusMessage = "✓ Attendance marked successfully!";
      FlutterBluePlus.stopScan(); // Save battery
      _attendanceDates.add(DateTime.now());
    });
    await _saveAttendanceHistory();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Face + Fingerprint verified! Attendance marked.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    _markAttendanceOnServer();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Authentication failed'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  Future<void> _markAttendanceOnServer() async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Attendance marked at: ${DateTime.now()}');
  }

  void _resetAttendance() {
    setState(() {
      _attendanceMarked = false;
      _isAuthenticated = false;
      _beaconInRange = false;
      _statusMessage = "Searching for beacon...";
    });
    _startBeaconScanning();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text('Attendance System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceHistoryPage(
                    attendanceDates: _attendanceDates,
                  ),
                ),
              );
            },
            tooltip: 'View History',
          ),
          if (_attendanceMarked)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetAttendance,
              tooltip: 'Reset (Testing)',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _attendanceMarked 
                        ? [Colors.green[400]!, Colors.green[600]!]
                        : _beaconInRange 
                          ? [Colors.indigo[400]!, Colors.indigo[600]!]
                          : [Colors.grey[400]!, Colors.grey[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (_attendanceMarked ? Colors.green : Colors.indigo).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _attendanceMarked 
                          ? Icons.check_circle_outline
                          : _beaconInRange 
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_searching,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Present Days',
                        '${_attendanceDates.length}',
                        Icons.calendar_today,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
  child: GestureDetector(
    onTap: _showBluetoothDevicesDialog,
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.devices, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              '${_scanResults.length}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Devices Found',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (_scanResults.length > 0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Tap to view list',
                  style: TextStyle(fontSize: 10, color: Colors.indigo),
                ),
              ),
          ],
        ),
      ),
    ),
  ),
),
                  ],
                ),
                const SizedBox(height: 24),

                // Beacon Status Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connection Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatusRow(
                          'Beacon',
                          _beaconInRange ? 'In Range' : 'Out of Range',
                          _beaconInRange ? Colors.green : Colors.red,
                        ),
                        const Divider(height: 24),
                        _buildStatusRow(
                          'Today\'s Attendance',
                          _attendanceMarked ? 'Marked' : 'Not Marked',
                          _attendanceMarked ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Authenticate Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _beaconInRange && !_attendanceMarked ? _authenticate : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _beaconInRange && !_attendanceMarked 
                        ? Colors.indigo 
                        : Colors.grey[300],
                      foregroundColor: Colors.white,
                      elevation: _beaconInRange && !_attendanceMarked ? 8 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint,
                          size: 28,
                          color: _beaconInRange && !_attendanceMarked 
                            ? Colors.white 
                            : Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _attendanceMarked 
                            ? 'Already Marked Today'
                            : 'Authenticate & Mark Present',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _beaconInRange && !_attendanceMarked 
                              ? Colors.white 
                              : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ← ADD YOUR NEW CODE HERE ↓↓↓
                if (!_faceRegistered)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final bool? success = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FaceRegistrationScreen(cameras: _cameras),
                        ),
                      );

                      if (success == true) {
                        setState(() {
                          _faceRegistered = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Face registered successfully! You can now mark attendance.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.face),
                    label: const Text('Register Your Face (First Time Setup)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),

                const SizedBox(height: 16),
                // Info Text
                Text(
                  _beaconInRange && !_attendanceMarked
                    ? 'Tap the button above to scan your fingerprint'
                    : _attendanceMarked
                      ? 'You\'re all set for today!'
                      : 'Move closer to the beacon to enable authentication',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// Attendance History Page
class AttendanceHistoryPage extends StatelessWidget {
  final List<DateTime> attendanceDates;

  const AttendanceHistoryPage({super.key, required this.attendanceDates});

  @override
  Widget build(BuildContext context) {
    // Calculate absent dates (last 30 days)
    final now = DateTime.now();
    final last30Days = List.generate(30, (i) => now.subtract(Duration(days: i)));
    
    final absentDates = last30Days.where((date) {
      return !attendanceDates.any((attended) =>
        attended.year == date.year &&
        attended.month == date.month &&
        attended.day == date.day
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text('Attendance History'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        'Present',
                        '${attendanceDates.length}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildSummaryItem(
                        'Absent (30d)',
                        '${absentDates.length}',
                        Icons.cancel,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Absent Dates Section
              const Text(
                'Absent Days (Last 30 Days)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: absentDates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.celebration, size: 80, color: Colors.green[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Perfect Attendance!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No absences in the last 30 days',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: absentDates.length,
                      itemBuilder: (context, index) {
                        final date = absentDates[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.cancel, color: Colors.red[400]),
                            ),
                            title: Text(
                              _formatDate(date),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              _getDayOfWeek(date),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: Text(
                              _getDaysAgo(date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDayOfWeek(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday',
                  'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _getDaysAgo(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }
}