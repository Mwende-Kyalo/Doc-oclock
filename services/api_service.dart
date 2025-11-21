import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🌐 Base URL of your backend
  static const String baseUrl = 'http://192.168.100.31/USSD/application_backend/api/'; 
  // ↑ Replace with your local IP or ngrok public link
  static String? authToken;

  // -------------------------------
  // 🔹 Generic HTTP Methods
  // -------------------------------

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // -------------------------------
  // 🔑 Authentication Endpoints
  // -------------------------------

  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    return post('auth/verify_otp.php', {'email': email, 'otp': otp});
  }

  // -------------------------------
  // 📅 Appointment Endpoints
  // -------------------------------

  static Future<Map<String, dynamic>> updateAppointment(
      int appointmentId, String status) async {
    return post('appointments/update.php',
        {'appointment_id': appointmentId, 'status': status});
  }

  // -------------------------------
  // 💬 Messaging Endpoints
  // -------------------------------

  static Future<Map<String, dynamic>> getMessages(String chatId) async {
    return get('messages/get.php?chat_id=$chatId');
  }

  static Future<Map<String, dynamic>> sendMessage(
      String chatId, String senderId, String message) async {
    return post('messages/send.php', {
      'chat_id': chatId,
      'sender_id': senderId,
      'message': message,
    });
  }

  // -------------------------------
  // 💊 Prescription Endpoints
  // -------------------------------

  static Future<Map<String, dynamic>> createPrescription(
      String patientId, String doctorId, String details) async {
    return post('prescriptions/create.php', {
      'patient_id': patientId,
      'doctor_id': doctorId,
      'details': details,
    });
  }

  static Future<Map<String, dynamic>> listPrescriptions(
      String patientId) async {
    return get('prescriptions/list.php?patient_id=$patientId');
  }

  // -------------------------------
  // 💳 Payment Endpoints
  // -------------------------------

  static Future<Map<String, dynamic>> confirmPayment(
      String transactionId) async {
    return post('payments/confirm.php', {'transaction_id': transactionId});
  }

  // -------------------------------
  // 🧾 EHR Endpoints
  // -------------------------------

  static Future<Map<String, dynamic>> viewEhr(String patientId) async {
    return get('ehr/view.php?patient_id=$patientId');
  }

  // -------------------------------
  // 🔒 JWT Utility
  // -------------------------------

  static Future<Map<String, dynamic>> validateJwt(String token) async {
    return post('utils/jwt_helper.php', {'token': token});
  }

  // -------------------------------
  // ⚙️ Helper Methods
  // -------------------------------

  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid JSON response: ${response.body}');
      }
    } else {
      throw Exception(
          'API error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  static void setAuthToken(String token) {
    authToken = token;
  }

  static void clearAuthToken() {
    authToken = null;
  }
}
