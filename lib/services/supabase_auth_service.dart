import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

// Bcrypt import - if this fails, update passwords to plain text in database
// ignore: uri_does_not_exist
import 'package:bcrypt/bcrypt.dart' show BCrypt;

class SupabaseAuthService {
  final supabase = Supabase.instance.client;

  /// Sign up a patient
  Future<AuthResponse> signUpPatient({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    // Create auth user
    // Note: Supabase may require email confirmation depending on settings
    final response = await supabase.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      // Optionally disable email confirmation (if enabled in Supabase settings)
      // data: {'email_confirm': true}, // This won't work - email confirmation is server-side
    );

    if (response.user != null) {
      // Store additional user info in 'users' table
      // Note: users table uses user_id (int4) as PK, not id (UUID)
      // We'll use email to link Supabase Auth user to database user
      try {
        final insertResult = await supabase
            .from('users')
            .insert({
              'email': email,
              'full_name': fullName,
              'phone_number': phoneNumber,
              'role': 'patient',
              'created_at': DateTime.now().toIso8601String(),
            })
            .select('user_id')
            .single();

        // Verify insert was successful
        if (insertResult['user_id'] == null) {
          throw Exception('Failed to create user record');
        }
      } catch (e) {
        // Provide clearer error message for RLS policy violations
        final errorString = e.toString();
        if (errorString.contains('row-level security') ||
            errorString.contains('42501') ||
            errorString.contains('RLS') ||
            errorString.contains('policy')) {
          throw Exception(
              'Database policy error: Please contact administrator. The sign-up process requires database configuration. See SUPABASE_RLS_FIX.md for details.');
        }
        // For other errors, provide a more user-friendly message
        if (errorString.contains('duplicate') ||
            errorString.contains('unique')) {
          throw Exception('An account with this email already exists.');
        }
        throw Exception(
            'Failed to create account: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
    return response;
  }

  /// Sign up a doctor
  Future<AuthResponse> signUpDoctor({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? specialization,
    String? bio,
    String? licenseNumber,
  }) async {
    // Create auth user
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      // Store additional doctor info in 'doctor_accounts' table
      try {
        await supabase.from('doctor_accounts').insert({
          'email': email,
          'fullname': fullName,
          'mobile': phoneNumber,
          'password': password, // Note: In production, this should be hashed
          'role': 'doctor',
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Provide clearer error message for RLS policy violations
        final errorString = e.toString();
        if (errorString.contains('row-level security') ||
            errorString.contains('42501') ||
            errorString.contains('RLS') ||
            errorString.contains('policy')) {
          throw Exception(
              'Database policy error: Please contact administrator. Doctor sign-up requires database configuration.');
        }
        // For other errors, provide a more user-friendly message
        if (errorString.contains('duplicate') ||
            errorString.contains('unique')) {
          throw Exception('A doctor account with this email already exists.');
        }
        throw Exception(
            'Failed to create doctor account: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
    return response;
  }

  /// Sign in a patient
  Future<UserModel?> signInPatient(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    // Debug logging
    debugPrint('Patient Sign-In Debug:');
    debugPrint('  Email: $normalizedEmail');
    debugPrint('  Password length: ${password.length}');

    try {
      final response = await supabase.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      debugPrint(
          '  Auth response: user=${response.user != null}, session=${response.session != null}');

      if (response.user != null) {
        // Read user details from 'users' table using email to link
        try {
          final userData = await supabase
              .from('users')
              .select(
                  'user_id, full_name, email, phone_number, role, created_at')
              .eq('email', normalizedEmail)
              .single();

          debugPrint('  User data found: ${userData['full_name']}');

          return UserModel(
            id: userData['user_id']?.toString() ?? response.user!.id,
            fullName: userData['full_name'] ?? '',
            email: userData['email'] ?? email,
            phoneNumber: userData['phone_number'] ?? '',
            role: (userData['role'] == 'doctor')
                ? UserRole.doctor
                : UserRole.patient,
            createdAt: userData['created_at'] != null
                ? DateTime.parse(userData['created_at'])
                : DateTime.now(),
          );
        } catch (e) {
          // If user not found in users table, log and throw
          debugPrint('Error fetching user data from users table: $e');
          debugPrint('  User exists in auth.users but not in users table');
          throw Exception(
              'User account found but profile data is missing. Please contact administrator.');
        }
      }
      return null;
    } catch (e) {
      final errorString = e.toString();

      debugPrint('Patient Sign-In Error: $errorString');

      // Handle email confirmation error
      if (errorString.contains('email_not_confirmed') ||
          errorString.contains('Email not confirmed')) {
        throw Exception(
            'Please check your email and click the confirmation link before signing in. If you haven\'t received the email, check your spam folder or request a new confirmation email.');
      }

      // Handle invalid credentials
      if (errorString.contains('Invalid login credentials') ||
          errorString.contains('invalid_credentials')) {
        throw Exception(
            'Invalid email or password. Please check your credentials. If you just signed up, make sure email confirmation is disabled or confirm your email first.');
      }

      // Re-throw other errors
      rethrow;
    }
  }

  /// Sign in a doctor
  /// Only allows doctors registered in doctor_accounts table by administrators
  Future<UserModel?> signInDoctor(String email, String password) async {
    // Only check doctor_accounts table for email and password
    try {
      // First, try to query the table to check for RLS errors
      // Explicitly select password field to ensure it's included
      final doctorData = await supabase
          .from('doctor_accounts')
          .select('id, fullname, email, mobile, password, created_at')
          .eq(
              'email',
              email
                  .toLowerCase()
                  .trim()) // Normalize email (lowercase and trim)
          .maybeSingle();

      // Debug: Check if password field is accessible
      debugPrint('Doctor Data Retrieved:');
      debugPrint('  Email searched: ${email.toLowerCase().trim()}');
      debugPrint('  Has data: ${doctorData != null}');
      if (doctorData != null) {
        debugPrint('  Keys: ${doctorData.keys.toList()}');
        debugPrint('  Has password key: ${doctorData.containsKey('password')}');
        debugPrint(
            '  Password value type: ${doctorData['password']?.runtimeType}');
      } else {
        debugPrint('  ⚠️ No doctor data found. Possible causes:');
        debugPrint('    1. RLS policy blocking access');
        debugPrint('    2. Email mismatch (check case/whitespace)');
        debugPrint('    3. Account does not exist in doctor_accounts table');
      }

      // If null, it could be either no account or RLS blocking
      // Try a different approach: use single() to get better error messages
      if (doctorData == null) {
        debugPrint('  Attempting to diagnose issue...');
        // Try with single() to see if we get an RLS error
        try {
          final testQuery = await supabase
              .from('doctor_accounts')
              .select('id')
              .eq('email', email.toLowerCase().trim())
              .single();
          debugPrint('  Test query succeeded: $testQuery');
          // If we get here, the account exists but maybeSingle() returned null
          // This shouldn't happen, but handle it
          throw Exception(
              'Doctor account not found. Please contact administrator.');
        } catch (singleError) {
          final singleErrorMsg = singleError.toString();
          debugPrint('  Test query error: $singleErrorMsg');
          // Check if it's an RLS error
          if (singleErrorMsg.contains('row-level security') ||
              singleErrorMsg.contains('42501') ||
              singleErrorMsg.contains('RLS') ||
              singleErrorMsg.contains('policy') ||
              singleErrorMsg.contains('permission denied') ||
              singleErrorMsg.contains('PGRST')) {
            throw Exception(
                'Database policy error: Row Level Security (RLS) is blocking access to doctor accounts. Please contact administrator to configure RLS policies. See FIX_DOCTOR_ACCOUNTS_RLS.sql for details.');
          }
          // If it's a "not found" error, that's expected
          if (singleErrorMsg.contains('not found') ||
              singleErrorMsg.contains('No rows') ||
              singleErrorMsg.contains('null value')) {
            throw Exception(
                'Doctor account not found. Please verify your email address or contact administrator to create your account.');
          }
          // Re-throw other errors
          throw Exception(
              'Doctor account not found. Please contact administrator.');
        }
      }

      // Check password - database stores bcrypt hash
      final dbPasswordHash = doctorData['password']?.toString().trim() ?? '';
      final inputPassword = password.trim();

      // Debug logging
      debugPrint('Doctor Sign-In Debug:');
      debugPrint('  Email: $email');
      debugPrint('  DB Password type: ${doctorData['password'].runtimeType}');
      debugPrint('  DB Password is null: ${doctorData['password'] == null}');
      debugPrint('  DB Password hash length: ${dbPasswordHash.length}');
      debugPrint('  Input Password length: ${inputPassword.length}');
      debugPrint('  Is bcrypt hash: ${dbPasswordHash.startsWith('\$2')}');

      if (dbPasswordHash.isEmpty) {
        throw Exception(
            'Password not found in database. Please contact administrator.');
      }

      // Verify password
      // Support both bcrypt hashed and plain text passwords
      bool passwordMatches = false;

      if (dbPasswordHash.startsWith('\$2')) {
        // Password is bcrypt hashed - verify using bcrypt
        try {
          passwordMatches = BCrypt.checkpw(inputPassword, dbPasswordHash);
          debugPrint('  Password verification (bcrypt): $passwordMatches');
        } catch (e) {
          debugPrint('  Bcrypt verification error: $e');
          passwordMatches = false;
        }
      } else {
        // Plain text comparison (for development)
        passwordMatches = (dbPasswordHash == inputPassword);
        debugPrint('  Password verification (plain text): $passwordMatches');
      }

      if (!passwordMatches) {
        throw Exception('Invalid password. Please check your credentials.');
      }

      return UserModel(
        id: doctorData['id']?.toString() ?? '',
        fullName: doctorData['fullname'] ?? '',
        email: doctorData['email'] ?? email,
        phoneNumber: doctorData['mobile'] ?? '',
        role: UserRole.doctor,
        createdAt: doctorData['created_at'] != null
            ? DateTime.parse(doctorData['created_at'])
            : DateTime.now(),
      );
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');

      // Check for RLS/policy errors in the outer catch
      if (errorMsg.contains('row-level security') ||
          errorMsg.contains('42501') ||
          errorMsg.contains('RLS') ||
          errorMsg.contains('policy') ||
          errorMsg.contains('permission denied') ||
          errorMsg.contains('PGRST')) {
        throw Exception(
            'Database policy error: Row Level Security (RLS) is blocking access to doctor accounts. Please contact administrator to configure RLS policies. See FIX_SIGNUP_SIGNIN_ERRORS.md for details.');
      }

      // Re-throw the original error message
      throw Exception(errorMsg);
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Resend email confirmation
  /// Sends a new confirmation email to the user
  Future<void> resendConfirmationEmail(String email) async {
    try {
      await supabase.auth.resend(
        type: OtpType.signup,
        email: email.trim().toLowerCase(),
      );
    } catch (e) {
      throw Exception('Failed to resend confirmation email: ${e.toString()}');
    }
  }

  /// Verify OTP (if needed for email verification)
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  /// Resend OTP
  Future<void> resendOtp(String email) async {
    await supabase.auth.resend(
      type: OtpType.email,
      email: email,
    );
  }

  // ==========================================
  // Multi-Factor Authentication (MFA) Methods
  // ==========================================

  /// Check if MFA is enabled for the current user
  Future<bool> isMfaEnabled() async {
    try {
      final response = await supabase.auth.mfa.listFactors();
      // Check if user has any verified MFA factors
      return response.all.isNotEmpty &&
          response.all.any((factor) => factor.status == FactorStatus.verified);
    } catch (e) {
      debugPrint('Error checking MFA status: $e');
      return false;
    }
  }

  /// Enroll in MFA (email-based)
  /// Returns the challenge ID that needs to be verified
  Future<String?> enrollMfa() async {
    try {
      // Start MFA enrollment - Supabase will send an email OTP
      final response = await supabase.auth.mfa.enroll(
        factorType: FactorType.totp, // TOTP for email-based MFA
      );
      return response.id;
    } catch (e) {
      debugPrint('Error enrolling MFA: $e');
      rethrow;
    }
  }

  /// Verify MFA enrollment with OTP code from email
  Future<bool> verifyMfaEnrollment({
    required String factorId,
    required String code,
    String? challengeId,
  }) async {
    try {
      // For enrollment verification, we need challengeId if available
      if (challengeId != null) {
        await supabase.auth.mfa.verify(
          factorId: factorId,
          challengeId: challengeId,
          code: code,
        );
      } else {
        // For enrollment, we might need to get a challenge first
        // Or use a different verification method
        // Note: This is a workaround - you may need to adjust based on Supabase MFA setup
        try {
          // Try to challenge first, then verify
          final challengeResponse =
              await supabase.auth.mfa.challenge(factorId: factorId);
          await supabase.auth.mfa.verify(
            factorId: factorId,
            challengeId: challengeResponse.id,
            code: code,
          );
        } catch (e) {
          // If challenge fails, the factor might already be verified
          // or enrollment verification works differently
          debugPrint('Error in MFA enrollment verification flow: $e');
          rethrow;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error verifying MFA enrollment: $e');
      return false;
    }
  }

  /// Unenroll from MFA (disable MFA)
  Future<bool> unenrollMfa(String factorId) async {
    try {
      await supabase.auth.mfa.unenroll(factorId);
      return true;
    } catch (e) {
      debugPrint('Error unenrolling MFA: $e');
      return false;
    }
  }

  /// Get all MFA factors for the current user
  Future<List<Factor>> getMfaFactors() async {
    try {
      final response = await supabase.auth.mfa.listFactors();
      return response.all;
    } catch (e) {
      debugPrint('Error getting MFA factors: $e');
      return [];
    }
  }

  /// Challenge MFA (used during sign-in when MFA is enabled)
  /// Returns the challenge ID
  Future<String?> challengeMfa(String factorId) async {
    try {
      final response = await supabase.auth.mfa.challenge(factorId: factorId);
      return response.id;
    } catch (e) {
      debugPrint('Error challenging MFA: $e');
      rethrow;
    }
  }

  /// Verify MFA challenge (used during sign-in)
  /// Returns the MFA verify response which contains the session
  Future<AuthMFAVerifyResponse> verifyMfaChallenge({
    required String challengeId,
    required String code,
    required String factorId,
  }) async {
    try {
      final response = await supabase.auth.mfa.verify(
        factorId: factorId,
        challengeId: challengeId,
        code: code,
      );
      // The response contains the session if verification succeeds
      return response;
    } catch (e) {
      debugPrint('Error verifying MFA challenge: $e');
      rethrow;
    }
  }
}
