class AvailabilityModel {
  final String id;
  final String doctorId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final DateTime createdAt;

  AvailabilityModel({
    required this.id,
    required this.doctorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] ?? '',
      doctorId: json['doctorId'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AvailabilityModel copyWith({
    String? id,
    String? doctorId,
    DateTime? date,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
  }) {
    return AvailabilityModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

