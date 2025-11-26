enum ConsultationType {
  video,
  voice,
}

enum AppointmentStatus {
  booked,
  completed,
  cancelled,
  rescheduled,
}

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String time;
  final ConsultationType type;
  final AppointmentStatus status;
  final double consultationFee;
  final bool paymentMade;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
    this.consultationFee = 0.0,
    this.paymentMade = false,
    required this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      time: json['time'] ?? '',
      type: json['type'] == 'video' ? ConsultationType.video : ConsultationType.voice,
      status: _parseStatus(json['status'] ?? 'booked'),
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      paymentMade: json['paymentMade'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static AppointmentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'rescheduled':
        return AppointmentStatus.rescheduled;
      default:
        return AppointmentStatus.booked;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': date.toIso8601String(),
      'time': time,
      'type': type == ConsultationType.video ? 'video' : 'voice',
      'status': status.toString().split('.').last,
      'consultationFee': consultationFee,
      'paymentMade': paymentMade,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    DateTime? date,
    String? time,
    ConsultationType? type,
    AppointmentStatus? status,
    double? consultationFee,
    bool? paymentMade,
    DateTime? createdAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      date: date ?? this.date,
      time: time ?? this.time,
      type: type ?? this.type,
      status: status ?? this.status,
      consultationFee: consultationFee ?? this.consultationFee,
      paymentMade: paymentMade ?? this.paymentMade,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

