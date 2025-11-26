class PrescriptionModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String diagnosis;
  final List<PrescriptionItem> items;
  final String? notes;
  final bool isOrdered;
  final DateTime createdAt;

  PrescriptionModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.diagnosis,
    required this.items,
    this.notes,
    this.isOrdered = false,
    required this.createdAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      diagnosis: json['diagnosis'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => PrescriptionItem.fromJson(item))
              .toList() ??
          [],
      notes: json['notes'],
      isOrdered: json['isOrdered'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': date.toIso8601String(),
      'diagnosis': diagnosis,
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
      'isOrdered': isOrdered,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PrescriptionItem {
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;

  PrescriptionItem({
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      medicationName: json['medicationName'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }
}

