import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart';

class PaymentService {
  static final supabase = Supabase.instance.client;

  /// Get payment history for a user (patient or doctor)
  static Future<List<PaymentModel>> getPaymentHistory(String userId, {bool isDoctor = false}) async {
    try {
      final userIdInt = int.tryParse(userId) ?? 0;
      
      // Payments table has both user_id (patient) and doctor_id (doctor)
      // Query based on role
      final response = isDoctor
          ? await supabase
              .from('payments')
              .select('payment_id, appointment_id, user_id, doctor_id, amount, payment_method, transaction_id, status, paid_at, created_at')
              .eq('doctor_id', userIdInt)
              .order('created_at', ascending: false)
          : await supabase
              .from('payments')
              .select('payment_id, appointment_id, user_id, doctor_id, amount, payment_method, transaction_id, status, paid_at, created_at')
              .eq('user_id', userIdInt)
              .order('created_at', ascending: false);
      
      return (response as List).map((json) => PaymentModel.fromJson({
        'id': json['payment_id']?.toString() ?? '',
        'appointment_id': json['appointment_id']?.toString() ?? '',
        'user_id': json['user_id']?.toString() ?? userId,
        'doctor_id': json['doctor_id']?.toString() ?? '',
        'amount': json['amount'],
        'payment_method': json['payment_method'],
        'transaction_id': json['transaction_id'],
        'status': json['status'],
        'paid_at': json['paid_at'] ?? json['created_at'],
        'created_at': json['created_at'],
      })).toList();
    } catch (e) {
      throw Exception('Failed to fetch payment history: $e');
    }
  }

  /// Get payment by ID
  static Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final response = await supabase
          .from('payments')
          .select('payment_id, appointment_id, user_id, amount, payment_method, transaction_id, status, created_at')
          .eq('payment_id', int.tryParse(paymentId) ?? 0)
          .maybeSingle();
      
      if (response == null) return null;
      
      return PaymentModel.fromJson({
        'id': response['payment_id']?.toString() ?? paymentId,
        'appointment_id': response['appointment_id']?.toString() ?? '',
        'user_id': response['user_id']?.toString() ?? '',
        'amount': response['amount'],
        'payment_method': response['payment_method'],
        'transaction_id': response['transaction_id'],
        'status': response['status'],
        'created_at': response['created_at'],
      });
    } catch (e) {
      return null;
    }
  }

  /// Get payment by appointment ID
  static Future<PaymentModel?> getPaymentByAppointmentId(String appointmentId) async {
    try {
      final response = await supabase
          .from('payments')
          .select('payment_id, appointment_id, user_id, amount, payment_method, transaction_id, status, created_at')
          .eq('appointment_id', int.tryParse(appointmentId) ?? 0)
          .maybeSingle();
      
      if (response == null) return null;
      
      return PaymentModel.fromJson({
        'id': response['payment_id']?.toString() ?? '',
        'appointment_id': response['appointment_id']?.toString() ?? appointmentId,
        'user_id': response['user_id']?.toString() ?? '',
        'amount': response['amount'],
        'payment_method': response['payment_method'],
        'transaction_id': response['transaction_id'],
        'status': response['status'],
        'created_at': response['created_at'],
      });
    } catch (e) {
      return null;
    }
  }

  /// Create payment record
  static Future<PaymentModel> createPayment({
    required String appointmentId,
    required String patientId,
    required String doctorId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? transactionId,
    String? phoneNumber,
  }) async {
    try {
      // Get doctor_id from appointment
      int doctorIdInt = 0;
      try {
        final appointmentData = await supabase
            .from('appointment')
            .select('doctor_id')
            .eq('id', int.tryParse(appointmentId) ?? 0)
            .maybeSingle();
        doctorIdInt = appointmentData?['doctor_id'] ?? 0;
      } catch (e) {
        debugPrint('Could not fetch doctor_id from appointment: $e');
      }
      
      // Use patientId as user_id (payments table uses user_id for the payer)
      final response = await supabase
          .from('payments')
          .insert({
            'appointment_id': int.tryParse(appointmentId) ?? 0,
            'user_id': int.tryParse(patientId) ?? 0,
            'doctor_id': doctorIdInt,
            'amount': amount,
            'payment_method': paymentMethod == PaymentMethod.card ? 'card' : 'mpesa',
            'status': 'pending',
            'transaction_id': transactionId,
            'phone_number': phoneNumber,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('payment_id, appointment_id, user_id, doctor_id, amount, payment_method, transaction_id, status, paid_at, created_at')
          .single();
      
      return PaymentModel.fromJson({
        'id': response['payment_id']?.toString() ?? '',
        'appointment_id': response['appointment_id']?.toString() ?? appointmentId,
        'user_id': response['user_id']?.toString() ?? patientId,
        'doctor_id': response['doctor_id']?.toString() ?? '',
        'amount': response['amount'],
        'payment_method': response['payment_method'],
        'transaction_id': response['transaction_id'],
        'status': response['status'],
        'paid_at': response['paid_at'] ?? response['created_at'],
        'created_at': response['created_at'],
      });
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  /// Update payment status
  static Future<bool> updatePaymentStatus(String paymentId, PaymentStatus status, {String? transactionId}) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.toString().split('.').last,
      };
      
      if (transactionId != null) {
        updateData['transaction_id'] = transactionId;
      }
      
      await supabase
          .from('payments')
          .update(updateData)
          .eq('payment_id', int.tryParse(paymentId) ?? 0);
      
      return true;
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }
}