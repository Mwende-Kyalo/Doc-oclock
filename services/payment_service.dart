import 'api_service.dart';

class PaymentService {
  static Future<Map<String, dynamic>> confirmPayment(
      String transactionId) async {
    return await ApiService.confirmPayment(transactionId);
  }
}
