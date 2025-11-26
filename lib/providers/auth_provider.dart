import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool? _isMfaEnabled;
  bool _isMfaLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool? get isMfaEnabled => _isMfaEnabled;
  bool get isMfaLoading => _isMfaLoading;

  AuthProvider() {
    _initializeAuth();
  }

  /// Load MFA status
  Future<void> loadMfaStatus() async {
    if (_user == null) return;

    _isMfaLoading = true;
    notifyListeners();

    try {
      _isMfaEnabled = await _authService.isMfaEnabled();
    } catch (e) {
      debugPrint('Error loading MFA status: $e');
      _isMfaEnabled = false;
    } finally {
      _isMfaLoading = false;
      notifyListeners();
    }
  }

  /// Initialize auth state from Supabase session
  Future<void> _initializeAuth() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      try {
        // Try to get user from users table (patient) using email to link
        final userData = await Supabase.instance.client
            .from('users')
            .select(
                'user_id, full_name, name, email, phone_number, role, created_at')
            .eq('email', currentUser.email ?? '')
            .maybeSingle();

        if (userData != null) {
          _user = UserModel(
            id: userData['user_id']?.toString() ?? currentUser.id,
            fullName: userData['full_name'] ?? userData['name'] ?? '',
            email: userData['email'] ?? currentUser.email ?? '',
            phoneNumber: userData['phone_number'] ?? '',
            role: (userData['role'] == 'doctor')
                ? UserRole.doctor
                : UserRole.patient,
            createdAt: userData['created_at'] != null
                ? DateTime.parse(userData['created_at'])
                : DateTime.now(),
          );
        } else {
          // Try to get doctor from doctor_accounts table using email
          final doctorData = await Supabase.instance.client
              .from('doctor_accounts')
              .select('id, fullname, email, mobile, created_at')
              .eq('email', currentUser.email ?? '')
              .maybeSingle();

          if (doctorData != null) {
            _user = UserModel(
              id: doctorData['id']?.toString() ?? currentUser.id,
              fullName: doctorData['fullname'] ?? '',
              email: doctorData['email'] ?? currentUser.email ?? '',
              phoneNumber: doctorData['mobile'] ?? '',
              role: UserRole.doctor,
              createdAt: doctorData['created_at'] != null
                  ? DateTime.parse(doctorData['created_at'])
                  : DateTime.now(),
            );
          }
        }
        notifyListeners();
        // Load MFA status after user is loaded
        await loadMfaStatus();
      } catch (e) {
        debugPrint('Error initializing auth: $e');
      }
    }
  }

  /// Sign up a patient
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signUpPatient(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      if (response.user != null) {
        _user = UserModel(
          id: response.user!.id,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          role: role,
          createdAt: DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up a doctor
  Future<bool> signUpDoctor({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String? specialization,
    String? bio,
    String? licenseNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signUpDoctor(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        specialization: specialization,
        bio: bio,
        licenseNumber: licenseNumber,
      );

      if (response.user != null) {
        _user = UserModel(
          id: response.user!.id,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          role: UserRole.doctor,
          createdAt: DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create doctor account';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in a patient
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInPatient(email, password);

      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid credentials or user not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Extract clean error message
      String errorMsg = e.toString();
      // Remove "Exception: " prefix if present
      errorMsg = errorMsg.replaceAll('Exception: ', '');

      // Handle email confirmation error specifically
      if (errorMsg.contains('email_not_confirmed') ||
          errorMsg.contains('Email not confirmed') ||
          errorMsg.contains('check your email')) {
        _errorMessage = errorMsg;
      } else if (errorMsg.contains('Invalid login credentials') ||
          errorMsg.contains('invalid_credentials')) {
        _errorMessage =
            'Invalid email or password. Please check your credentials.';
      } else {
        _errorMessage = errorMsg;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in a doctor
  Future<bool> signInDoctor({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInDoctor(email, password);

      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid doctor credentials or doctor not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Extract clean error message
      String errorMsg = e.toString();
      // Remove "Exception: " prefix if present
      errorMsg = errorMsg.replaceAll('Exception: ', '');
      // Extract message from AuthApiException format if present
      if (errorMsg.contains('AuthApiException')) {
        final messageMatch = RegExp(r'message:\s*([^,]+)').firstMatch(errorMsg);
        if (messageMatch != null) {
          errorMsg =
              messageMatch.group(1)?.trim() ?? 'Invalid login credentials';
        }
      }
      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement actual OTP verification
      await Future.delayed(const Duration(seconds: 1));

      if (otp == '123456') {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Update in Supabase users table
      if (_user!.role == UserRole.patient) {
        await Supabase.instance.client.from('users').update({
          if (fullName != null) 'full_name': fullName,
          if (email != null) 'email': email,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        }).eq('user_id', int.tryParse(_user!.id) ?? 0);
      } else {
        // For doctors, update in doctor_accounts table
        await Supabase.instance.client.from('doctor_accounts').update({
          if (fullName != null) 'fullname': fullName,
          if (email != null) 'email': email,
          if (phoneNumber != null) 'mobile': phoneNumber,
        }).eq('id', int.tryParse(_user!.id) ?? 0);
      }

      // Update local user model
      _user = _user!.copyWith(
        fullName: fullName ?? _user!.fullName,
        email: email ?? _user!.email,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // Multi-Factor Authentication (MFA) Methods
  // ==========================================

  /// Enable MFA for the current user
  Future<Map<String, dynamic>> enableMfa() async {
    _isMfaLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final factorId = await _authService.enrollMfa();
      _isMfaLoading = false;
      notifyListeners();

      return {
        'success': true,
        'factorId': factorId,
        'message':
            'MFA enrollment started. Please check your email for the verification code.',
      };
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isMfaLoading = false;
      notifyListeners();
      return {
        'success': false,
        'error': _errorMessage,
      };
    }
  }

  /// Verify MFA enrollment with code from email
  Future<bool> verifyMfaEnrollment({
    required String factorId,
    required String code,
  }) async {
    _isMfaLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.verifyMfaEnrollment(
        factorId: factorId,
        code: code,
      );

      if (success) {
        _isMfaEnabled = true;
      }

      _isMfaLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isMfaLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Disable MFA for the current user
  Future<bool> disableMfa() async {
    _isMfaLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final factors = await _authService.getMfaFactors();
      if (factors.isEmpty) {
        _isMfaEnabled = false;
        _isMfaLoading = false;
        notifyListeners();
        return true;
      }

      // Unenroll all factors
      bool allSuccess = true;
      for (final factor in factors) {
        final success = await _authService.unenrollMfa(factor.id);
        if (!success) {
          allSuccess = false;
        }
      }

      if (allSuccess) {
        _isMfaEnabled = false;
      }

      _isMfaLoading = false;
      notifyListeners();
      return allSuccess;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isMfaLoading = false;
      notifyListeners();
      return false;
    }
  }
}
