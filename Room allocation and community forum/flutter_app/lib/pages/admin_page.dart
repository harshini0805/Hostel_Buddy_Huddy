// lib/admin_page.dart
import 'package:flutter/material.dart';
import 'api_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String status = "";
  bool isProcessing = false;
  Map<String, dynamic> stats = {};
  List<Map<String, dynamic>> allocations = [];
  List<Map<String, dynamic>> forms = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final statsData = await ApiService.getStats();
      final allocationsData = await ApiService.getAllAllocations();
      final formsData = await ApiService.getAllForms();

      setState(() {
        stats = statsData;
        allocations = allocationsData;
        forms = formsData;
      });
    } catch (e) {
      setState(() {
        status = "Error loading data: $e";
      });
    }
  }

  Future<void> runAllocation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Run Allocation"),
        content: const Text(
          "This will run the allocation algorithm for all submitted forms. Continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Run Allocation"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isProcessing = true;
      status = "Running allocation algorithm...";
    });

    try {
      final response = await ApiService.runAllocation();

      setState(() {
        status = response['message'] ?? "Allocation completed successfully!";
        isProcessing = false;
      });

      // Reload data
      await _loadData();
    } catch (e) {
      setState(() {
        status = "Error during allocation: $e";
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomTypeLabels = {
      'THREE_SHARING_AC': '3 Sharing AC',
      'THREE_SHARING_NON_AC': '3 Sharing Non-AC',
      'SINGLE_AC': 'Single AC',
      'SINGLE_NON_AC': 'Single Non-AC',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: "Refresh Data",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "System Statistics",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20),
                    _buildStatRow(
                      "Total Forms Submitted",
                      "${stats['total_forms'] ?? forms.length}",
                    ),
                    _buildStatRow(
                      "Total Allocations",
                      "${stats['total_allocations'] ?? allocations.length}",
                    ),
                    _buildStatRow(
                      "Pending Forms",
                      "${(stats['total_forms'] ?? forms.length) - (stats['total_allocations'] ?? allocations.length)}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (stats['allocation_by_room_type'] != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Allocation by Room Type",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 20),
                      ...(stats['allocation_by_room_type'] as Map<String, dynamic>)
                          .entries
                          .map((entry) {
                        return _buildStatRow(
                          roomTypeLabels[entry.key] ?? entry.key,
                          "${entry.value} students",
                        );
                      }),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: isProcessing ? null : runAllocation,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Run Allocation Algorithm"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: isProcessing ? null : _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh Data"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            if (isProcessing)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: status.contains("Error")
                      ? Colors.red.shade100
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status.contains("Error")
                        ? Colors.red.shade900
                        : Colors.blue.shade900,
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // Submitted Forms Section
            if (forms.isNotEmpty) ...[
              const Text(
                "Submitted Forms",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: forms.length > 5 ? 5 : forms.length,
                  itemBuilder: (context, index) {
                    final form = forms[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(form['name'] ?? 'N/A'),
                      subtitle: Text('ID: ${form['student_id']}'),
                      trailing: Text(
                        '${form['attendance_percentage']?.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              if (forms.length > 5)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("All Submitted Forms"),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: forms.length,
                            itemBuilder: (context, index) {
                              final form = forms[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(form['name'] ?? 'N/A'),
                                subtitle: Text('ID: ${form['student_id']}'),
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text("View all ${forms.length} forms"),
                ),
            ],

            const SizedBox(height: 20),

            // Allocations Section
            if (allocations.isNotEmpty) ...[
              const Text(
                "Recent Allocations",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allocations.length > 5 ? 5 : allocations.length,
                  itemBuilder: (context, index) {
                    final alloc = allocations[index];
                    return ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Student: ${alloc['student_id']}'),
                      subtitle: Text(
                        roomTypeLabels[alloc['room_type']] ?? alloc['room_type'],
                      ),
                      trailing: Text(
                        'Room: ${alloc['room_id']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              if (allocations.length > 5)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("All Allocations"),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: allocations.length,
                            itemBuilder: (context, index) {
                              final alloc = allocations[index];
                              return ListTile(
                                leading: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                title: Text('Student: ${alloc['student_id']}'),
                                subtitle: Text(
                                  roomTypeLabels[alloc['room_type']] ??
                                      alloc['room_type'],
                                ),
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text("View all ${allocations.length} allocations"),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}