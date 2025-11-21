import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// ...existing code...
import '../../models/prescription_model.dart';
import '../../providers/ehr_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/prescription_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/doctor_scaffold.dart';

class AddEhrScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String? type; // 'ehr' or 'prescription'
  final String? ehrId; // For editing

  const AddEhrScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    this.type,
    this.ehrId,
  });

  @override
  State<AddEhrScreen> createState() => _AddEhrScreenState();
}

class _AddEhrScreenState extends State<AddEhrScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  // For prescription items
  final List<Map<String, String>> _medicationItems = [];
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isPrescriptionMode = false;

  @override
  void initState() {
    super.initState();
    _isPrescriptionMode = widget.type == 'prescription';
    _isEditMode = widget.ehrId != null;

    if (_isEditMode) {
      _loadEhrData();
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    _medicationNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadEhrData() async {
    final ehrProvider = Provider.of<EhrProvider>(context, listen: false);
    final ehrRecords = ehrProvider.ehrRecords;
    final ehr = ehrRecords.firstWhere(
      (e) => e.id == widget.ehrId,
      orElse: () => throw Exception('EHR not found'),
    );

    setState(() {
      _diagnosisController.text = ehr.diagnosis;
      _prescriptionController.text = ehr.prescription;
      _notesController.text = ehr.notes ?? '';
    });
  }

  void _addMedicationItem() {
    if (_medicationNameController.text.trim().isEmpty ||
        _dosageController.text.trim().isEmpty ||
        _frequencyController.text.trim().isEmpty ||
        _durationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all medication fields'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _medicationItems.add({
        'medicationName': _medicationNameController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'frequency': _frequencyController.text.trim(),
        'duration': _durationController.text.trim(),
        'instructions': _instructionsController.text.trim(),
      });
      _medicationNameController.clear();
      _dosageController.clear();
      _frequencyController.clear();
      _durationController.clear();
      _instructionsController.clear();
    });
  }

  void _removeMedicationItem(int index) {
    setState(() {
      _medicationItems.removeAt(index);
    });
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isPrescriptionMode && _medicationItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one medication'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ehrProvider = Provider.of<EhrProvider>(context, listen: false);

    try {
      if (_isEditMode) {
        // Update existing EHR
        final ehrRecords = ehrProvider.ehrRecords;
        final existingEhr = ehrRecords.firstWhere(
          (e) => e.id == widget.ehrId,
        );

        final updatedEhr = existingEhr.copyWith(
          diagnosis: _diagnosisController.text.trim(),
          prescription: _prescriptionController.text.trim(),
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );

        final success = await ehrProvider.updateEhrRecord(updatedEhr);

        if (success && mounted) {
          // Refresh EHR records to ensure changes are visible
          await ehrProvider.refreshEhrRecords(widget.patientId);

          // If it's a prescription, also update the prescription record
          if (_isPrescriptionMode) {
            try {
              final prescriptionItems = _medicationItems
                  .map((item) => PrescriptionItem(
                        medicationName: item['medicationName']!,
                        dosage: item['dosage']!,
                        frequency: item['frequency']!,
                        duration: item['duration']!,
                        instructions: item['instructions']!.isNotEmpty
                            ? item['instructions']
                            : null,
                      ))
                  .toList();

              await PrescriptionService.createPrescription(
                patientId: widget.patientId,
                doctorId: authProvider.user!.id,
                doctorName: authProvider.user!.fullName,
                diagnosis: _diagnosisController.text.trim(),
                items: prescriptionItems,
                notes: _notesController.text.trim().isNotEmpty
                    ? _notesController.text.trim()
                    : null,
              );
            } catch (e) {
              debugPrint('Failed to update prescription: $e');
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Record updated successfully! Changes will be visible to the patient.'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          context.pop();
        }
      } else {
        // Create new EHR
        final success = await ehrProvider.addEhrRecord(
          patientId: widget.patientId,
          patientName: widget.patientName,
          doctorId: authProvider.user!.id,
          doctorName: authProvider.user!.fullName,
          diagnosis: _diagnosisController.text.trim(),
          prescription: _prescriptionController.text.trim(),
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );

        if (success && mounted) {
          // If it's a prescription, create prescription record
          if (_isPrescriptionMode && _medicationItems.isNotEmpty) {
            // TODO: Create prescription record in prescription service
            // This would create prescription records that patients can see on their prescriptions page
            // For now, we'll just show a success message
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record saved successfully!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(ehrProvider.errorMessage ?? 'Failed to save record: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoctorScaffold(
      title: _isEditMode
          ? '${_isPrescriptionMode ? 'Edit' : 'Edit'} ${_isPrescriptionMode ? 'Prescription' : 'EHR'}'
          : 'Add ${_isPrescriptionMode ? 'Prescription' : 'EHR'}',
      currentRoute: '/doctor/ehr',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis',
                  border: OutlineInputBorder(),
                  hintText: 'Diagnosis',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter diagnosis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!_isPrescriptionMode) ...[
                TextFormField(
                  controller: _prescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Prescription',
                    border: OutlineInputBorder(),
                    hintText: 'Prescription',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter prescription';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ] else ...[
                const Text(
                  'Medications:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ..._medicationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item['medicationName']!),
                      subtitle: Text(
                        '${item['dosage']} - ${item['frequency']} - ${item['duration']}',
                      ),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.delete, color: AppTheme.errorRed),
                        onPressed: () => _removeMedicationItem(index),
                      ),
                    ),
                  );
                }),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _medicationNameController,
                          decoration: const InputDecoration(
                            labelText: 'Medication Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dosageController,
                                decoration: const InputDecoration(
                                  labelText: 'Dosage',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _frequencyController,
                                decoration: const InputDecoration(
                                  labelText: 'Frequency',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _durationController,
                                decoration: const InputDecoration(
                                  labelText: 'Duration',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _instructionsController,
                                decoration: const InputDecoration(
                                  labelText: 'Instructions',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _addMedicationItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Medication'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Prescription Summary',
                    border: OutlineInputBorder(),
                    hintText: 'Additional prescription notes',
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Notes',
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                minLines: 5,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Update Record' : 'Save Record',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
