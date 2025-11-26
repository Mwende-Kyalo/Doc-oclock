import 'package:supabase_flutter/supabase_flutter.dart';

class PatientService {
  static final supabase = Supabase.instance.client;

  /// Get all patients from appointment table (using denormalized data)
  /// This fetches all patients that have appointments with the doctor
  /// Avoids querying users table which has RLS restrictions
  static Future<List<Map<String, dynamic>>> getPatientsForDoctor(
      String doctorId) async {
    try {
      // Get unique patients from appointment table using denormalized patient_name
      // This avoids querying the users table which has RLS restrictions
      final appointmentsResponse = await supabase
          .from('appointment')
          .select('patient_id, patient_name, doctor_id')
          .eq('doctor_id', int.tryParse(doctorId) ?? 0)
          .not('patient_id', 'is', null);

      if (appointmentsResponse.isEmpty) {
        return [];
      }

      // Extract unique patients (by patient_id)
      final patientMap = <String, Map<String, dynamic>>{};
      for (var appointment in appointmentsResponse) {
        final patientId = appointment['patient_id']?.toString();
        if (patientId != null && patientId != '0' && !patientMap.containsKey(patientId)) {
          patientMap[patientId] = {
            'id': patientId,
            'name': appointment['patient_name'] ?? 'Unknown Patient',
            'email': '', // Not available from appointment table
            'phone': '', // Not available from appointment table
          };
        }
      }

      return patientMap.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch patients: $e');
    }
  }

  /// Get a single patient by ID from users table
  static Future<Map<String, dynamic>?> getPatientById(String patientId) async {
    try {
      final response = await supabase
          .from('users')
          .select('user_id, full_name, email, phone_number, role, created_at')
          .eq('user_id', int.tryParse(patientId) ?? 0)
          .eq('role', 'patient')
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return {
        'id': response['user_id']?.toString(),
        'name': response['full_name'] ?? response['name'] ?? '',
        'email': response['email'] ?? '',
        'phone': response['phone_number'] ?? '',
      };
    } catch (e) {
      throw Exception('Failed to fetch patient: $e');
    }
  }

  /// Update patient profile in users table
  static Future<bool> updatePatientProfile({
    required String userId,
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (fullName != null) updateData['full_name'] = fullName;
      if (email != null) updateData['email'] = email;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;

      if (updateData.isEmpty) {
        return true; // Nothing to update
      }

      await supabase
          .from('users')
          .update(updateData)
          .eq('user_id', int.tryParse(userId) ?? 0);

      return true;
    } catch (e) {
      throw Exception('Failed to update patient profile: $e');
    }
  }
}
