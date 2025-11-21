import 'api_service.dart';

class EhrService {
  static Future<Map<String, dynamic>> getEhr(String patientId) async {
    return await ApiService.viewEhr(patientId);
  }
}
