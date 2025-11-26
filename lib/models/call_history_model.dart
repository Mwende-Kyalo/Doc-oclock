class CallHistoryModel {
  final String id;
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final CallType type; // 'video' or 'voice'
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final CallStatus status; // 'completed', 'missed', 'cancelled'
  final bool isIncoming; // true if call was received, false if initiated

  CallHistoryModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.status,
    this.isIncoming = false,
  });

  factory CallHistoryModel.fromJson(Map<String, dynamic> json) {
    return CallHistoryModel(
      id: json['id']?.toString() ?? '',
      appointmentId: json['appointment_id']?.toString() ?? json['appointmentId']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? json['patientId']?.toString() ?? '',
      patientName: json['patient_name'] ?? json['patientName'] ?? '',
      doctorId: json['doctor_id']?.toString() ?? json['doctorId']?.toString() ?? '',
      doctorName: json['doctor_name'] ?? json['doctorName'] ?? '',
      type: json['type'] == 'video' ? CallType.video : CallType.voice,
      startTime: DateTime.parse(json['start_time'] ?? json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: json['end_time'] != null || json['endTime'] != null
          ? DateTime.parse(json['end_time'] ?? json['endTime'])
          : null,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] is int ? json['duration'] : int.tryParse(json['duration'].toString()) ?? 0)
          : Duration.zero,
      status: _parseStatus(json['status'] ?? 'completed'),
      isIncoming: json['is_incoming'] ?? json['isIncoming'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'patient_name': patientName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'type': type == CallType.video ? 'video' : 'voice',
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration': duration.inSeconds,
      'status': status.toString().split('.').last,
      'is_incoming': isIncoming,
    };
  }

  static CallStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return CallStatus.completed;
      case 'missed':
        return CallStatus.missed;
      case 'cancelled':
        return CallStatus.cancelled;
      default:
        return CallStatus.completed;
    }
  }
}

enum CallType {
  video,
  voice,
}

enum CallStatus {
  completed,
  missed,
  cancelled,
}

