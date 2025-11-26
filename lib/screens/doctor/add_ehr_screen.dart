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
import '../../l10n/app_localizations.dart';

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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseFillAllMedicationFields),
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

    final l10n = AppLocalizations.of(context)!;
    
    // Validate patient ID
    if (widget.patientId.isEmpty || widget.patientId == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient first'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      context.pop(); // Go back to patient selection
      return;
    }
    
    if (_isPrescriptionMode && _medicationItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseAddAtLeastOneMedication),
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

          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.recordUpdatedSuccessfully),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          context.pop();
        } else if (mounted) {
          // Show error if update failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ehrProvider.errorMessage ?? 'Failed to update record'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
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
              debugPrint('Failed to create prescription record: $e');
              // Continue anyway since EHR was saved successfully
            }
          }

          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.recordSaved),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          context.pop();
        } else if (mounted) {
          // Show error if save failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ehrProvider.errorMessage ?? 'Failed to save record'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('EHR Save Error: $e');
      debugPrint('EHR Provider Error: ${ehrProvider.errorMessage}');
      if (mounted) {
        final errorMsg = ehrProvider.errorMessage ?? e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save record: $errorMsg'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 5),
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
    final l10n = AppLocalizations.of(context)!;
    return DoctorScaffold(
      title: _isEditMode
          ? (_isPrescriptionMode ? l10n.editEhrRecord : l10n.editEhrRecord)
          : (_isPrescriptionMode ? l10n.addPrescription : l10n.addEhrRecord),
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
                decoration: InputDecoration(
                  labelText: l10n.diagnosisLabel,
                  border: const OutlineInputBorder(),
                  hintText: l10n.diagnosisLabel,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterDiagnosis;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!_isPrescriptionMode) ...[
                TextFormField(
                  controller: _prescriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.prescriptionLabel,
                    border: const OutlineInputBorder(),
                    hintText: l10n.prescriptionLabel,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterPrescription;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ] else ...[
                Text(
                  '${l10n.medications}:',
                  style: const TextStyle(
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
                          decoration: InputDecoration(
                            labelText: l10n.medicationName,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dosageController,
                                decoration: InputDecoration(
                                  labelText: l10n.dosage,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _frequencyController,
                                decoration: InputDecoration(
                                  labelText: l10n.frequency,
                                  border: const OutlineInputBorder(),
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
                                decoration: InputDecoration(
                                  labelText: l10n.duration,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _instructionsController,
                                decoration: InputDecoration(
                                  labelText: l10n.instructions,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _addMedicationItem,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addMedication),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _prescriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.prescriptionSummary,
                    border: const OutlineInputBorder(),
                    hintText: l10n.additionalPrescriptionNotes,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.notesLabel,
                  border: const OutlineInputBorder(),
                  hintText: l10n.notesLabel,
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
                        _isEditMode ? l10n.updateRecord : l10n.saveRecord,
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
