// lib/check_allocation_page.dart
import 'package:flutter/material.dart';
import 'api_service.dart';

class CheckAllocationPage extends StatefulWidget {
  const CheckAllocationPage({super.key});

  @override
  State<CheckAllocationPage> createState() => _CheckAllocationPageState();
}

class _CheckAllocationPageState extends State<CheckAllocationPage> {
  final studentIdController = TextEditingController();
  Map<String, dynamic>? allocation;
  String? errorMessage;
  bool isLoading = false;

  final Map<String, String> roomTypeLabels = {
    'THREE_SHARING_AC': '3 Sharing AC',
    'THREE_SHARING_NON_AC': '3 Sharing Non-AC',
    'SINGLE_AC': 'Single AC',
    'SINGLE_NON_AC': 'Single Non-AC',
  };

  Future<void> checkAllocation() async {
    if (studentIdController.text.isEmpty) {
      setState(() {
        errorMessage = "Please enter student ID";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      allocation = null;
    });

    try {
      final result = await ApiService.getAllocation(studentIdController.text);

      if (result == null) {
        setState(() {
          errorMessage =
              "No allocation found for this student ID. Either allocation hasn't been run yet or you haven't submitted the form.";
          isLoading = false;
        });
        return;
      }

      setState(() {
        allocation = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check Room Allocation"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(
                labelText: "Enter Student ID",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : checkAllocation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Check Allocation",
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 30),

            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade900),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),

            if (allocation != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Allocation Details",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Divider(height: 30),

                      _buildInfoRow(
                        Icons.badge,
                        "Student ID",
                        allocation!['student_id'] ?? 'N/A',
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        Icons.meeting_room,
                        "Room Type",
                        roomTypeLabels[allocation!['room_type']] ??
                            allocation!['room_type'] ??
                            'N/A',
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        Icons.door_front_door,
                        "Room ID",
                        allocation!['room_id']?.toString() ?? 'N/A',
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        Icons.check_circle,
                        "Status",
                        allocation!['status'] ?? 'N/A',
                      ),

                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Congratulations! Your room has been allocated.",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    studentIdController.dispose();
    super.dispose();
  }
}