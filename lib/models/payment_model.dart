enum PaymentMethod {
  mpesa,
  card,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class PaymentModel {
  final String id;
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final double amount;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final String? transactionId;
  final String? phoneNumber; // For M-Pesa
  final DateTime paidAt;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.phoneNumber,
    required this.paidAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    // Schema uses user_id instead of patient_id/doctor_id
    // For backward compatibility, map user_id to patientId
    final userId = json['user_id']?.toString() ?? json['patient_id']?.toString() ?? json['patientId'] ?? '';
    
    return PaymentModel(
      id: json['id'] ?? json['payment_id']?.toString() ?? '',
      appointmentId: json['appointment_id']?.toString() ?? json['appointmentId'] ?? '',
      patientId: userId, // Map user_id to patientId for UI compatibility
      doctorId: json['doctor_id']?.toString() ?? json['doctorId'] ?? '', // May need to fetch from appointment
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] == 'card' || json['paymentMethod'] == 'card'
          ? PaymentMethod.card
          : PaymentMethod.mpesa,
      status: _parseStatus(json['status'] ?? 'pending'),
      transactionId: json['transaction_id']?.toString() ?? json['transactionId'],
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'])
          : json['paidAt'] != null
              ? DateTime.parse(json['paidAt'])
              : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }

  static PaymentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return PaymentStatus.completed;
      case 'failed':
      case 'failure':
        return PaymentStatus.failed;
      case 'cancelled':
      case 'canceled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'amount': amount,
      'payment_method': paymentMethod == PaymentMethod.card ? 'card' : 'mpesa',
      'status': status.toString().split('.').last,
      'transaction_id': transactionId,
      'phone_number': phoneNumber,
      'paid_at': paidAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
