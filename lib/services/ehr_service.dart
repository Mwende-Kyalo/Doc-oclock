import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ehr_model.dart';

class EhrService {
  static final supabase = Supabase.instance.client;

  /// Get EHR records for a patient from ehr table
  static Future<List<EhrModel>> getPatientEhrRecords(String patientId) async {
    try {
      final response = await supabase
          .from('ehr')
          .select('record_id, patient_id, doctor_id, diagnosis, treatment, notes, created_at')
          .eq('patient_id', int.tryParse(patientId) ?? 0)
          .order('created_at', ascending: false);
      
      // .select() returns a non-nullable List (can be empty)
      return (response as List).map((json) {
        // Get patient and doctor names from their respective tables
        return EhrModel.fromJson({
          'id': json['record_id']?.toString() ?? '',
          'patientId': json['patient_id']?.toString() ?? patientId,
          'patientName': '', // Will be populated from users table if needed
          'doctorId': json['doctor_id']?.toString() ?? '',
          'doctorName': '', // Will be populated from doctor_accounts table if needed
          'date': json['created_at'] ?? DateTime.now().toIso8601String(),
          'diagnosis': json['diagnosis'] ?? '',
          'prescription': json['treatment'] ?? '', // Schema uses 'treatment' instead of 'prescription'
          'notes': json['notes'],
          'createdAt': json['created_at'] ?? DateTime.now().toIso8601String(),
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch EHR records: $e');
    }
  }

  /// Create/Add EHR record (from doctor panel)
  static Future<EhrModel> createEhrRecord({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String diagnosis,
    required String prescription,
    String? notes,
  }) async {
    try {
      final response = await supabase
          .from('ehr')
          .insert({
            'patient_id': int.tryParse(patientId) ?? 0,
            'doctor_id': int.tryParse(doctorId) ?? 0,
            'diagnosis': diagnosis,
            'treatment': prescription, // Schema uses 'treatment' instead of 'prescription'
            'notes': notes,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('record_id, patient_id, doctor_id, diagnosis, treatment, notes, created_at')
          .single();
      
      // .single() returns non-nullable
      return EhrModel.fromJson({
        'id': response['record_id']?.toString() ?? '',
        'patientId': response['patient_id']?.toString() ?? patientId,
        'patientName': patientName,
        'doctorId': response['doctor_id']?.toString() ?? doctorId,
        'doctorName': doctorName,
        'date': response['created_at'] ?? DateTime.now().toIso8601String(),
        'diagnosis': response['diagnosis'] ?? '',
        'prescription': response['treatment'] ?? '', // Map 'treatment' to 'prescription' for model
        'notes': response['notes'],
        'createdAt': response['created_at'] ?? DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create EHR record: $e');
    }
  }

  /// Update EHR record
  static Future<EhrModel> updateEhrRecord(EhrModel ehrRecord) async {
    try {
      final response = await supabase
          .from('ehr')
          .update({
            'diagnosis': ehrRecord.diagnosis,
            'treatment': ehrRecord.prescription, // Schema uses 'treatment' instead of 'prescription'
            'notes': ehrRecord.notes,
          })
          .eq('record_id', int.tryParse(ehrRecord.id) ?? 0)
          .select('record_id, patient_id, doctor_id, diagnosis, treatment, notes, created_at')
          .single();
      
      // .single() returns non-nullable
      return EhrModel.fromJson({
        'id': response['record_id']?.toString() ?? ehrRecord.id,
        'patientId': response['patient_id']?.toString() ?? ehrRecord.patientId,
        'patientName': ehrRecord.patientName,
        'doctorId': response['doctor_id']?.toString() ?? ehrRecord.doctorId,
        'doctorName': ehrRecord.doctorName,
        'date': response['created_at'] ?? ehrRecord.date.toIso8601String(),
        'diagnosis': response['diagnosis'] ?? ehrRecord.diagnosis,
        'prescription': response['treatment'] ?? ehrRecord.prescription,
        'notes': response['notes'] ?? ehrRecord.notes,
        'createdAt': response['created_at'] ?? ehrRecord.createdAt.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update EHR record: $e');
    }
  }

  /// Delete EHR record
  static Future<bool> deleteEhrRecord(String ehrId) async {
    try {
      final response = await supabase
          .from('ehr')
          .delete()
          .eq('record_id', int.tryParse(ehrId) ?? 0)
          .select();
      
      // .select() returns a non-nullable List
      return (response as List).isNotEmpty;
    } catch (e) {
      throw Exception('Failed to delete EHR record: $e');
    }
  }
}