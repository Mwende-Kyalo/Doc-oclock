import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<AuthResponse> signUp(
      String email, String password, String name) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user != null) {
      // Store additional user info in 'users' table
      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'name': name,
      });
    }
    return response;
  }

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      // Read user details from 'users' table
      final userData = await supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();
      return userData;
    }
    return null;
  }

  Future<Map<String, dynamic>?> doctorSignIn(
      String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      // Read doctor details from 'doctor_accounts' table
      final doctorData = await supabase
          .from('doctor_accounts')
          .select()
          .eq('email', email)
          .single();
      return doctorData;
    }
    return null;
  }
}
