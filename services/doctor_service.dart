import '../models/doctor_model.dart';
import '../models/availability_model.dart';
import 'api_service.dart';
// ...existing code...

class DoctorService {
  // Get all doctors
  static Future<List<DoctorModel>> getDoctors() async {
    try {
      final response = await ApiService.get('doctors/list.php');
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => DoctorModel.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  // Get doctor availability
  static Future<List<AvailabilityModel>> getDoctorAvailability(
      String doctorId) async {
    try {
      final response =
          await ApiService.get('doctors/availability.php?doctor_id=$doctorId');
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => AvailabilityModel.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch doctor availability: $e');
    }
  }

  // Get doctor by ID
  static Future<DoctorModel> getDoctorById(String doctorId) async {
    try {
      final response =
          await ApiService.get('doctors/get.php?doctor_id=$doctorId');
      if (response['data'] != null) {
        return DoctorModel.fromJson(response['data']);
      } else {
        throw Exception('Doctor not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch doctor: $e');
    }
  }
}
