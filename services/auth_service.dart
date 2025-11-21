import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    return await ApiService.post('auth/login.php', {
      'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    return await ApiService.verifyOtp(email, otp);
  }

  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData) async {
    return await ApiService.post('auth/register.php', userData);
  }
}
