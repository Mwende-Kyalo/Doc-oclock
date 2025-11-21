import 'api_service.dart';

class AppointmentService {
  static Future<Map<String, dynamic>> listAppointments(String doctorId) async {
    return await ApiService.get('appointments/list.php?doctor_id=$doctorId');
  }

  static Future<Map<String, dynamic>> updateStatus(
      int appointmentId, String status) async {
    return await ApiService.updateAppointment(appointmentId, status);
  }
}
