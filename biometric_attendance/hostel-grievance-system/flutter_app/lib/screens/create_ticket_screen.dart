import 'package:flutter/material.dart';
import '../models/ticket_models.dart';
import '../services/ticket_service.dart';
import '../providers/student_provider.dart';
import 'package:provider/provider.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({Key? key}) : super(key: key);

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  IssueCategory? _selectedCategory;
  ImpactRadius? _selectedImpact;
  UrgencyLevel? _selectedUrgency;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null || 
        _selectedImpact == null || 
        _selectedUrgency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ticketService = TicketService();
      final request = CreateTicketRequest(
        category: _selectedCategory!,
        impactRadius: _selectedImpact!,
        urgency: _selectedUrgency!,
        description: _descriptionController.text.trim(),
        mediaUrls: [], // Empty for Phase 1
      );

      final response = await ticketService.createTicket(request);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticket created successfully! ID: ${response.id}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Clear form
      _formKey.currentState!.reset();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedImpact = null;
        _selectedUrgency = null;
      });

    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create ticket: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.student;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Ticket'),
        ),
        body: const Center(
          child: Text('Student information not available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Grievance Ticket'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Auto-filled Student Information
              _buildStudentInfoCard(student),
              const SizedBox(height: 24),

              // Issue Category Dropdown
              _buildCategoryDropdown(),
              const SizedBox(height: 20),

              // Impact Radius Radio Buttons
              _buildImpactRadioGroup(),
              const SizedBox(height: 20),

              // Urgency Level Selector
              _buildUrgencySelector(),
              const SizedBox(height: 20),

              // Description Text Field
              _buildDescriptionField(),
              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard(Student student) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow('Name', student.name),
            _buildInfoRow('Student ID', student.id),
            _buildInfoRow('Department', student.department),
            _buildInfoRow('Hostel', student.hostel),
            _buildInfoRow('Block', student.block),
            _buildInfoRow('Room', student.room),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Issue Category *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<IssueCategory>(
          value: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          hint: const Text('Select issue category'),
          items: IssueCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(_formatEnumValue(category.name)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImpactRadioGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Impact Radius *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: ImpactRadius.values.map((impact) {
              return RadioListTile<ImpactRadius>(
                title: Text(_formatEnumValue(impact.name)),
                value: impact,
                groupValue: _selectedImpact,
                onChanged: (value) {
                  setState(() {
                    _selectedImpact = value;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Urgency Level *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: UrgencyLevel.values.map((urgency) {
            final isSelected = _selectedUrgency == urgency;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedUrgency = urgency;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? _getUrgencyColor(urgency) 
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? _getUrgencyColor(urgency) 
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _formatEnumValue(urgency.name),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getUrgencyDescription(urgency),
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected 
                                ? Colors.white.withOpacity(0.9) 
                                : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Describe the issue in detail (minimum 30 characters)',
            counterText: '',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please provide a description';
            }
            if (value.trim().length < 30) {
              return 'Description must be at least 30 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _selectedCategory != null &&
        _selectedImpact != null &&
        _selectedUrgency != null &&
        !_isSubmitting;

    return ElevatedButton(
      onPressed: canSubmit ? _submitTicket : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        disabledBackgroundColor: Colors.grey.shade300,
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Submit Ticket',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  String _formatEnumValue(String value) {
    return value
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Color _getUrgencyColor(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.low:
        return Colors.green;
      case UrgencyLevel.medium:
        return Colors.orange;
      case UrgencyLevel.high:
        return Colors.red;
    }
  }

  String _getUrgencyDescription(UrgencyLevel urgency) {
    switch (urgency) {
      case UrgencyLevel.low:
        return 'Inconvenience';
      case UrgencyLevel.medium:
        return 'Disruptive';
      case UrgencyLevel.high:
        return 'Safety/Blocking';
    }
  }
}
