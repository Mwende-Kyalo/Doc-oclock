import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  static final supabase = Supabase.instance.client;

  /// Book an appointment (convert availability slot to booked appointment)
  static Future<AppointmentModel> bookAppointment({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String appointmentSlotId, // The availability slot ID
    required DateTime appointment_date,
    required String time,
    required String consultationType, // 'video' or 'voice'
    required double consultationFee,
  }) async {
    try {
      // First check if slot is available (patient_id is null)
      // Explicitly select columns to avoid schema cache issues
      final slotCheck = await supabase
          .from('appointment')
          .select('id, patient_id, status')
          .eq('id', int.tryParse(appointmentSlotId) ?? 0)
          .single();

      if (slotCheck['patient_id'] != null) {
        throw Exception('This appointment slot is already booked');
      }

      // Update the availability slot to a booked appointment
      // Explicitly select columns to avoid schema cache issues
      final response = await supabase
          .from('appointment')
          .update({
            'patient_id': int.tryParse(patientId) ?? 0,
            'patient_name': patientName,
            'status': 'booked',
            'time': time, // Specific time slot selected
            'type': consultationType,
            'consultation_fee': consultationFee,
            'payment_made': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', int.tryParse(appointmentSlotId) ?? 0)
          .select(
              'id, date, time, patient_id, patient_name, doctor_id, doctor_name, type, status, consultation_fee, payment_made, created_at')
          .single();

      // .single() returns non-nullable, so no null check needed
      // Convert database int IDs to strings for the model
      return AppointmentModel.fromJson({
        'id': (response['id']?.toString() ?? ''),
        'patientId': (response['patient_id']?.toString() ?? patientId),
        'patientName': response['patient_name'] ?? patientName,
        'doctorId': (response['doctor_id']?.toString() ?? doctorId),
        'doctorName': response['doctor_name'] ?? doctorName,
        'appointment_date': response['date'] ??
            appointment_date.toIso8601String().split('T')[0],
        'time': response['time']?.toString() ?? time,
        'type': response['type']?.toString() ?? consultationType,
        'status': response['status']?.toString() ?? 'booked',
        'consultationFee':
            (response['consultation_fee']?.toDouble() ?? consultationFee),
        'paymentMade': response['payment_made'] ?? false,
        'createdAt': response['created_at']?.toString() ??
            DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to book appointment: $e');
    }
  }

  /// Get appointments for a patient
  static Future<List<AppointmentModel>> getPatientAppointments(
      String patientId) async {
    try {
      // Convert patientId to int for database query
      final response = await supabase
          .from('appointment')
          .select()
          .eq('patient_id', int.tryParse(patientId) ?? 0)
          .order('date', ascending: false)
          .order('time', ascending: false);

      // .select() returns a non-nullable List (can be empty)
      return (response as List)
          .where(
              (item) => item['patient_id'] != null) // Only booked appointments
          .map((json) => AppointmentModel.fromJson({
                'id': (json['id']?.toString() ?? ''),
                'patientId': (json['patient_id']?.toString() ?? patientId),
                'patientName': json['patient_name']?.toString() ?? '',
                'doctorId': (json['doctor_id']?.toString() ?? ''),
                'doctorName': json['doctor_name']?.toString() ?? '',
                'appointment_date': json['date']?.toString() ??
                    DateTime.now().toIso8601String().split('T')[0],
                'time': json['time']?.toString() ?? '',
                'type': json['type']?.toString() ?? 'video',
                'status': json['status']?.toString() ?? 'booked',
                'consultationFee':
                    (json['consultation_fee']?.toDouble() ?? 0.0),
                'paymentMade': json['payment_made'] ?? false,
                'createdAt': json['created_at']?.toString() ??
                    DateTime.now().toIso8601String(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch patient appointments: $e');
    }
  }

  /// Get appointments for a doctor
  static Future<List<AppointmentModel>> getDoctorAppointments(
      String doctorId) async {
    try {
      // Explicitly select columns to avoid schema cache issues
      // Convert doctorId to int for database query
      final response = await supabase
          .from('appointment')
          .select(
              'id, date, time, patient_id, patient_name, doctor_id, doctor_name, type, status, consultation_fee, payment_made, created_at')
          .eq('doctor_id', int.tryParse(doctorId) ?? 0)
          // Only booked appointments - filter in code
          .order('date', ascending: false)
          .order('time', ascending: false);

      // .select() returns a non-nullable List (can be empty)
      return (response as List)
          .where(
              (json) => json['patient_id'] != null) // Only booked appointments
          .map((json) => AppointmentModel.fromJson({
                'id': (json['id']?.toString() ?? ''),
                'patientId': (json['patient_id']?.toString() ?? ''),
                'patientName': json['patient_name']?.toString() ?? '',
                'doctorId': (json['doctor_id']?.toString() ?? doctorId),
                'doctorName': json['doctor_name']?.toString() ?? '',
                'appointment_date': json['date']?.toString() ??
                    DateTime.now().toIso8601String().split('T')[0],
                'time': json['time']?.toString() ?? '',
                'type': json['type']?.toString() ?? 'video',
                'status': json['status']?.toString() ?? 'booked',
                'consultationFee':
                    (json['consultation_fee']?.toDouble() ?? 0.0),
                'paymentMade': json['payment_made'] ?? false,
                'createdAt': json['created_at']?.toString() ??
                    DateTime.now().toIso8601String(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch doctor appointments: $e');
    }
  }

  /// Update appointment status
  static Future<bool> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      // Convert appointmentId to int for database query
      final appointmentIdInt = int.tryParse(appointmentId) ?? 0;
      if (appointmentIdInt == 0) {
        throw Exception('Invalid appointment ID format: $appointmentId');
      }

      final response = await supabase
          .from('appointment')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', appointmentIdInt)
          .select();

      // .select() returns a non-nullable List
      return (response as List).isNotEmpty;
    } catch (e) {
      throw Exception('Failed to update appointment status: $e');
    }
  }

  /// Update appointment
  static Future<AppointmentModel> updateAppointment(
      AppointmentModel appointment) async {
    try {
      final response = await supabase
          .from('appointment')
          .update({
            'appointment_date':
                appointment.appointment_date.toIso8601String().split('T')[0],
            'time': appointment.time,
            'status': appointment.status.toString().split('.').last,
            'type':
                appointment.type == ConsultationType.video ? 'video' : 'voice',
            'consultation_fee': appointment.consultationFee,
            'payment_made': appointment.paymentMade,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', int.tryParse(appointment.id) ?? 0)
          .select()
          .single();

      // .single() returns non-nullable, so no null check needed
      // Convert database int IDs to strings for the model
      return AppointmentModel.fromJson({
        'id': (response['id']?.toString() ?? appointment.id),
        'patientId':
            (response['patient_id']?.toString() ?? appointment.patientId),
        'patientName':
            response['patient_name']?.toString() ?? appointment.patientName,
        'doctorId': (response['doctor_id']?.toString() ?? appointment.doctorId),
        'doctorName':
            response['doctor_name']?.toString() ?? appointment.doctorName,
        'appointment_date': response['date']?.toString() ??
            appointment.appointment_date.toIso8601String().split('T')[0],
        'time': response['time']?.toString() ?? appointment.time,
        'type': response['type']?.toString() ??
            (appointment.type == ConsultationType.video ? 'video' : 'voice'),
        'status': response['status']?.toString() ??
            appointment.status.toString().split('.').last,
        'consultationFee': (response['consultation_fee']?.toDouble() ??
            appointment.consultationFee),
        'paymentMade': response['payment_made'] ?? appointment.paymentMade,
        'createdAt': response['created_at']?.toString() ??
            appointment.createdAt.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  /// Delete/Cancel appointment
  static Future<bool> cancelAppointment(String appointmentId) async {
    try {
      // Convert appointmentId to int for database query
      final appointmentIdInt = int.tryParse(appointmentId) ?? 0;
      if (appointmentIdInt == 0) {
        throw Exception('Invalid appointment ID format: $appointmentId');
      }

      // For cancelled appointments, we might want to keep the record but update status
      // Or we could set patient_id back to null to make it available again
      final response = await supabase
          .from('appointment')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', appointmentIdInt)
          .select();

      // .select() returns a non-nullable List
      return (response as List).isNotEmpty;
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  /// Mark payment as made
  static Future<bool> markPaymentMade(String appointmentId) async {
    try {
      // Convert appointmentId to int for database query
      final appointmentIdInt = int.tryParse(appointmentId) ?? 0;
      if (appointmentIdInt == 0) {
        throw Exception('Invalid appointment ID format: $appointmentId');
      }

      final response = await supabase
          .from('appointment')
          .update({
            'payment_made': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', appointmentIdInt)
          .select();

      // .select() returns a non-nullable List
      return (response as List).isNotEmpty;
    } catch (e) {
      throw Exception('Failed to mark payment: $e');
    }
  }

  /// List appointments (backward compatibility)
  static Future<List<Map<String, dynamic>>> listAppointments(
      String doctorId) async {
    try {
      final appointments = await getDoctorAppointments(doctorId);
      return appointments.map((apt) => apt.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to list appointments: $e');
    }
  }
}
