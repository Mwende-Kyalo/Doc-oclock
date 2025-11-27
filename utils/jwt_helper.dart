import 'dart:convert';
import '../services/api_service.dart';

class JwtHelper {
  static Future<bool> validateToken(String token) async {
    final response = await ApiService.validateJwt(token);
    return response['valid'] == true;
  }

  static Map<String, dynamic>? decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return jsonDecode(payload);
    } catch (e) {
      return null;
    }
  }
}
