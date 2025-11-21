// ...existing code...
import 'api_service.dart';
import '../models/prescription_model.dart';
// ...existing code...

class PrescriptionService {
  // Get prescriptions for a patient
  static Future<List<PrescriptionModel>> getPatientPrescriptions(
      String patientId) async {
    try {
      final response =
          await ApiService.get('prescriptions/list.php?patient_id=$patientId');
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => PrescriptionModel.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch prescriptions: $e');
    }
  }

  // Create prescription (called when doctor adds e-prescription)
  static Future<bool> createPrescription({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String diagnosis,
    required List<PrescriptionItem> items,
    String? notes,
  }) async {
    try {
      final response = await ApiService.post('prescriptions/create.php', {
        'patient_id': patientId,
        'doctor_id': doctorId,
        'doctor_name': doctorName,
        'diagnosis': diagnosis,
        'items': items.map((item) => item.toJson()).toList(),
        'notes': notes,
      });
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to create prescription: $e');
    }
  }

  // Order prescription via MyDawa
  // Note: MyDawa doesn't have a public API, so we redirect to their website
  // The actual ordering is done on the MyDawa website
  static Future<bool> orderPrescriptionViaMyDawa(String prescriptionId) async {
    try {
      // Since MyDawa doesn't have a public API, we just return true
      // The actual redirect to MyDawa website is handled in the UI
      // Users will need to upload their prescription on MyDawa website
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      throw Exception('Failed to order prescription: $e');
    }
  }

  // Mark prescription as ordered
  static Future<bool> markPrescriptionAsOrdered(String prescriptionId) async {
    try {
      final response = await ApiService.put('prescriptions/update.php', {
        'prescription_id': prescriptionId,
        'isOrdered': true,
      });
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to update prescription: $e');
    }
  }
}
