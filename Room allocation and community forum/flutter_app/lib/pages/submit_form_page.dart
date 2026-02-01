// lib/submit_form_page.dart
import 'package:flutter/material.dart';
import 'api_service.dart';

class SubmitFormPage extends StatefulWidget {
  const SubmitFormPage({super.key});

  @override
  State<SubmitFormPage> createState() => _SubmitFormPageState();
}

class _SubmitFormPageState extends State<SubmitFormPage> {
  final _formKey = GlobalKey<FormState>();
  final studentIdController = TextEditingController();
  final nameController = TextEditingController();
  final yearController = TextEditingController();
  final attendanceController = TextEditingController();
  final homeLatController = TextEditingController();
  final homeLonController = TextEditingController();

  String? _firstPreference;
  String? _secondPreference;
  String? _thirdPreference;

  String message = "";
  bool isSubmitting = false;

  final Map<String, String> roomTypeLabels = {
    'THREE_SHARING_AC': '3 Sharing AC',
    'THREE_SHARING_NON_AC': '3 Sharing Non-AC',
    'SINGLE_AC': 'Single AC',
    'SINGLE_NON_AC': 'Single Non-AC',
  };

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_firstPreference == null) {
      setState(() {
        message = "Please select at least first preference";
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      message = "";
    });

    try {
      final preferences = <String>[];
      if (_firstPreference != null) preferences.add(_firstPreference!);
      if (_secondPreference != null && _secondPreference != _firstPreference) {
        preferences.add(_secondPreference!);
      }
      if (_thirdPreference != null &&
          _thirdPreference != _firstPreference &&
          _thirdPreference != _secondPreference) {
        preferences.add(_thirdPreference!);
      }

      final response = await ApiService.submitForm(
        studentId: studentIdController.text,
        name: nameController.text,
        year: int.parse(yearController.text),
        attendancePercentage: double.parse(attendanceController.text),
        homeLat: double.parse(homeLatController.text),
        homeLon: double.parse(homeLonController.text),
        preferences: preferences,
      );

      setState(() {
        message = response['message'] ?? "Form submitted successfully!";
        isSubmitting = false;
      });

      // Clear form
      _formKey.currentState!.reset();
      studentIdController.clear();
      nameController.clear();
      yearController.clear();
      attendanceController.clear();
      homeLatController.clear();
      homeLonController.clear();
      _firstPreference = null;
      _secondPreference = null;
      _thirdPreference = null;
    } catch (e) {
      setState(() {
        message = "Error: $e";
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Room Allocation Form"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Student Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: studentIdController,
                decoration: const InputDecoration(
                  labelText: "Student ID",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter student ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: yearController,
                decoration: const InputDecoration(
                  labelText: "Year (1-4)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter year';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1 || year > 4) {
                    return 'Enter valid year (1-4)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: attendanceController,
                decoration: const InputDecoration(
                  labelText: "Attendance Percentage (0-100)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter attendance';
                  }
                  final attendance = double.tryParse(value);
                  if (attendance == null || attendance < 0 || attendance > 100) {
                    return 'Enter valid percentage (0-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: homeLatController,
                decoration: const InputDecoration(
                  labelText: "Home Latitude",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  helperText: "Example: 12.9716",
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter home latitude';
                  }
                  final lat = double.tryParse(value);
                  if (lat == null || lat < -90 || lat > 90) {
                    return 'Enter valid latitude (-90 to 90)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: homeLonController,
                decoration: const InputDecoration(
                  labelText: "Home Longitude",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  helperText: "Example: 77.5946",
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter home longitude';
                  }
                  final lon = double.tryParse(value);
                  if (lon == null || lon < -180 || lon > 180) {
                    return 'Enter valid longitude (-180 to 180)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),
              const Text(
                "Room Preferences (in order)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _firstPreference,
                decoration: const InputDecoration(
                  labelText: "First Preference *",
                  border: OutlineInputBorder(),
                ),
                items: roomTypeLabels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _firstPreference = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'First preference is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _secondPreference,
                decoration: const InputDecoration(
                  labelText: "Second Preference (Optional)",
                  border: OutlineInputBorder(),
                ),
                items: roomTypeLabels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _secondPreference = value;
                  });
                },
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _thirdPreference,
                decoration: const InputDecoration(
                  labelText: "Third Preference (Optional)",
                  border: OutlineInputBorder(),
                ),
                items: roomTypeLabels.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _thirdPreference = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: isSubmitting ? null : submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Form",
                        style: TextStyle(fontSize: 16),
                      ),
              ),

              const SizedBox(height: 20),

              if (message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.contains("Error")
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: message.contains("Error")
                          ? Colors.red.shade900
                          : Colors.green.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    studentIdController.dispose();
    nameController.dispose();
    yearController.dispose();
    attendanceController.dispose();
    homeLatController.dispose();
    homeLonController.dispose();
    super.dispose();
  }
}