import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service for handling M-Pesa payments via TinyPesa API
class TinyPesaService {
  /// Initialize STK Push (Lipa na M-Pesa)
  /// 
  /// [phoneNumber] - Customer phone number (format: 254XXXXXXXXX)
  /// [amount] - Amount to charge
  /// [accountReference] - Unique reference for the transaction (e.g., appointment ID)
  /// [transactionDesc] - Description of the transaction
  /// 
  /// Returns a map with checkoutRequestId and responseCode
  static Future<Map<String, dynamic>> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    String transactionDesc = 'Payment for appointment',
  }) async {
    try {
      // Format phone number to TinyPesa format (254XXXXXXXXX)
      String formattedPhone = _formatPhoneNumber(phoneNumber);

      final url = Uri.parse(ApiConfig.getTinypesaStkPushUrl());
      
      final body = {
        'amount': amount.toStringAsFixed(2),
        'msisdn': formattedPhone,
        'account_no': accountReference,
      };

      final response = await http.post(
        url,
        headers: ApiConfig.getTinypesaHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'checkoutRequestId': data['CheckoutRequestID'] ?? data['checkout_request_id'],
          'responseCode': data['ResponseCode'] ?? data['response_code'],
          'responseDescription': data['ResponseDescription'] ?? data['response_description'] ?? 'Request received',
          'message': data['CustomerMessage'] ?? data['customer_message'] ?? 'Please check your phone for M-Pesa prompt',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to initiate payment: ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to process payment request',
      };
    }
  }

  /// Check payment status
  /// 
  /// [checkoutRequestId] - The checkout request ID from STK push response
  /// 
  /// Returns payment status information
  static Future<Map<String, dynamic>> checkPaymentStatus(String checkoutRequestId) async {
    try {
      final url = Uri.parse(ApiConfig.getTinypesaStatusUrl(checkoutRequestId));

      final response = await http.get(
        url,
        headers: ApiConfig.getTinypesaHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // TinyPesa response structure may vary
        final resultCode = data['ResultCode'] ?? data['result_code'] ?? data['status'];
        final resultDesc = data['ResultDesc'] ?? data['result_description'] ?? data['message'];

        return {
          'success': true,
          'resultCode': resultCode,
          'resultDescription': resultDesc,
          'status': _parseStatus(resultCode, resultDesc),
          'mpesaReceiptNumber': data['MpesaReceiptNumber'] ?? data['mpesa_receipt_number'],
          'transactionDate': data['TransactionDate'] ?? data['transaction_date'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to check status: ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to check payment status',
      };
    }
  }

  /// Format phone number to TinyPesa format (254XXXXXXXXX)
  static String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // If starts with 0, replace with 254
    if (digits.startsWith('0')) {
      digits = '254${digits.substring(1)}';
    }
    
    // If doesn't start with 254, add it
    if (!digits.startsWith('254')) {
      digits = '254$digits';
    }
    
    return digits;
  }

  /// Parse payment status from result code
  static String _parseStatus(dynamic resultCode, String resultDesc) {
    if (resultCode == 0 || resultCode == '0' || resultCode == 'success') {
      return 'completed';
    } else if (resultCode == 1032 || resultCode == '1032' || resultCode == 'cancelled') {
      return 'cancelled';
    } else if (resultCode == 'pending' || resultDesc.toLowerCase().contains('pending')) {
      return 'pending';
    } else {
      return 'failed';
    }
  }

  /// Verify payment callback from TinyPesa webhook
  /// 
  /// This should be called when receiving a callback from TinyPesa
  static Map<String, dynamic> verifyCallback(Map<String, dynamic> callbackData) {
    try {
      final body = callbackData['Body'] ?? callbackData['body'] ?? callbackData;
      final stkCallback = body['stkCallback'] ?? body['StkCallback'] ?? body;

      final resultCode = stkCallback['ResultCode'] ?? stkCallback['result_code'];
      final resultDesc = stkCallback['ResultDesc'] ?? stkCallback['result_description'];
      
      final callbackMetadata = stkCallback['CallbackMetadata'] ?? 
                               stkCallback['callback_metadata'] ?? 
                               stkCallback['Item'] ?? {};

      Map<String, dynamic> paymentData = {};

      if (callbackMetadata is Map) {
        final items = callbackMetadata['Item'] ?? callbackMetadata['item'] ?? [];
        for (var item in items) {
          final name = item['Name'] ?? item['name'];
          final value = item['Value'] ?? item['value'];
          
          if (name == 'Amount' || name == 'amount') {
            paymentData['amount'] = value;
          } else if (name == 'MpesaReceiptNumber' || name == 'mpesa_receipt_number') {
            paymentData['receipt_number'] = value;
          } else if (name == 'TransactionDate' || name == 'transaction_date') {
            paymentData['transaction_date'] = value;
          } else if (name == 'PhoneNumber' || name == 'phone_number') {
            paymentData['phone_number'] = value;
          }
        }
      }

      return {
        'success': resultCode == 0 || resultCode == '0',
        'resultCode': resultCode,
        'resultDescription': resultDesc,
        'status': _parseStatus(resultCode, resultDesc ?? ''),
        'receiptNumber': paymentData['receipt_number'],
        'amount': paymentData['amount'],
        'transactionDate': paymentData['transaction_date'],
        'phoneNumber': paymentData['phone_number'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to parse callback',
      };
    }
  }
}

