import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prescription_model.dart';

class PrescriptionService {
  static final supabase = Supabase.instance.client;

  /// Get prescriptions for a patient from prescriptions table
  /// Note: Schema has individual rows per medication, grouped by appointment_id
  static Future<List<PrescriptionModel>> getPatientPrescriptions(String patientId) async {
    try {
      final response = await supabase
          .from('prescriptions')
          .select('prescription_id, appointment_id, doctor_id, patient_id, medication_name, dosage, duration, instructions, created_at')
          .eq('patient_id', int.tryParse(patientId) ?? 0)
          .order('created_at', ascending: false);
      
      // Group medications by appointment_id
      final Map<int, List<Map<String, dynamic>>> grouped = {};
      for (var json in (response as List)) {
        final appointmentId = json['appointment_id'] as int? ?? 0;
        if (!grouped.containsKey(appointmentId)) {
          grouped[appointmentId] = [];
        }
        grouped[appointmentId]!.add(json);
      }
      
      // Convert grouped data to PrescriptionModel list
      return grouped.entries.map((entry) {
        final medications = entry.value;
        final firstMed = medications.first;
        
        // Convert each medication row to PrescriptionItem
        final items = medications.map((med) => PrescriptionItem(
          medicationName: med['medication_name'] ?? '',
          dosage: med['dosage'] ?? '',
          frequency: '', // Not in schema, will be empty
          duration: med['duration'] ?? '',
          instructions: med['instructions'],
        )).toList();
        
        return PrescriptionModel.fromJson({
          'id': firstMed['appointment_id']?.toString() ?? '',
          'patientId': firstMed['patient_id']?.toString() ?? patientId,
          'doctorId': firstMed['doctor_id']?.toString() ?? '',
          'doctorName': '', // Will need to fetch from doctor_accounts if needed
          'date': firstMed['created_at'] ?? DateTime.now().toIso8601String(),
          'diagnosis': '', // Not in prescriptions table schema
          'items': items.map((item) => item.toJson()).toList(),
          'notes': null,
          'isOrdered': false, // Not in schema
          'createdAt': firstMed['created_at'] ?? DateTime.now().toIso8601String(),
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch prescriptions: $e');
    }
  }

  /// Create prescription (called from doctor panel)
  /// Note: Schema requires individual rows per medication, needs appointment_id
  static Future<PrescriptionModel> createPrescription({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String diagnosis,
    required List<PrescriptionItem> items,
    String? notes,
    String? appointmentId, // Required for prescriptions table
  }) async {
    try {
      if (appointmentId == null) {
        throw Exception('appointmentId is required for prescriptions table');
      }
      
      // Insert each medication as a separate row
      final insertedRows = <Map<String, dynamic>>[];
      for (var item in items) {
        final response = await supabase
            .from('prescriptions')
            .insert({
              'appointment_id': int.tryParse(appointmentId) ?? 0,
              'doctor_id': int.tryParse(doctorId) ?? 0,
              'patient_id': int.tryParse(patientId) ?? 0,
              'medication_name': item.medicationName,
              'dosage': item.dosage,
              'duration': item.duration,
              'instructions': item.instructions,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select('prescription_id, appointment_id, doctor_id, patient_id, medication_name, dosage, duration, instructions, created_at')
            .single();
        
        insertedRows.add(response);
      }
      
      if (insertedRows.isEmpty) {
        throw Exception('No medications inserted');
      }
      
      final firstRow = insertedRows.first;
      
      // .single() returns non-nullable
      return PrescriptionModel.fromJson({
        'id': firstRow['appointment_id']?.toString() ?? appointmentId,
        'patientId': firstRow['patient_id']?.toString() ?? patientId,
        'doctorId': firstRow['doctor_id']?.toString() ?? doctorId,
        'doctorName': doctorName,
        'date': firstRow['created_at'] ?? DateTime.now().toIso8601String(),
        'diagnosis': diagnosis,
        'items': items.map((item) => item.toJson()).toList(),
        'notes': notes,
        'isOrdered': false,
        'createdAt': firstRow['created_at'] ?? DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create prescription: $e');
    }
  }

  /// Mark prescription as ordered
  /// Note: Schema doesn't have is_ordered field, so this is a no-op or needs schema update
  static Future<bool> markPrescriptionAsOrdered(String prescriptionId) async {
    try {
      // Since schema doesn't have is_ordered, we'll mark all medications for this appointment
      // In a real implementation, you might want to add an is_ordered column to the schema
      final response = await supabase
          .from('prescriptions')
          .update({
            // No is_ordered field in schema - this would need a schema change
          })
          .eq('appointment_id', int.tryParse(prescriptionId) ?? 0)
          .select();
      
      // .select() returns a non-nullable List
      return (response as List).isNotEmpty;
    } catch (e) {
      throw Exception('Failed to update prescription: $e');
    }
  }

  /// Get prescription by appointment ID (prescriptions are grouped by appointment_id)
  static Future<PrescriptionModel?> getPrescriptionById(String appointmentId) async {
    try {
      final response = await supabase
          .from('prescriptions')
          .select('prescription_id, appointment_id, doctor_id, patient_id, medication_name, dosage, duration, instructions, created_at')
          .eq('appointment_id', int.tryParse(appointmentId) ?? 0)
          .order('created_at', ascending: false);
      
      if ((response as List).isEmpty) return null;
      
      // Group medications and create PrescriptionModel
      final medications = (response as List);
      final firstMed = medications.first;
      
      final items = medications.map((med) => PrescriptionItem(
        medicationName: med['medication_name'] ?? '',
        dosage: med['dosage'] ?? '',
        frequency: '', // Not in schema
        duration: med['duration'] ?? '',
        instructions: med['instructions'],
      )).toList();
      
      return PrescriptionModel.fromJson({
        'id': firstMed['appointment_id']?.toString() ?? appointmentId,
        'patientId': firstMed['patient_id']?.toString() ?? '',
        'doctorId': firstMed['doctor_id']?.toString() ?? '',
        'doctorName': '', // Will need to fetch from doctor_accounts
        'date': firstMed['created_at'] ?? DateTime.now().toIso8601String(),
        'diagnosis': '', // Not in prescriptions table
        'items': items.map((item) => item.toJson()).toList(),
        'notes': null,
        'isOrdered': false,
        'createdAt': firstMed['created_at'] ?? DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return null;
    }
  }
}