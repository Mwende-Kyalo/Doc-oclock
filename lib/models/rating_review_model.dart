class RatingReviewModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String? appointmentId;
  final int rating; // 1-5 stars
  final String? reviewText;
  final bool isAnonymous;
  final bool isVerified;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  
  // Additional fields for display (joined from users table)
  final String? patientName;
  final String? patientEmail;
  final String? appointmentDate;

  RatingReviewModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    this.appointmentId,
    required this.rating,
    this.reviewText,
    this.isAnonymous = false,
    this.isVerified = true,
    this.isApproved = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.patientName,
    this.patientEmail,
    this.appointmentDate,
  });

  factory RatingReviewModel.fromJson(Map<String, dynamic> json) {
    // Handle both snake_case (from Supabase) and camelCase
    String parseDateTime(dynamic value) {
      if (value is String) return value;
      if (value is DateTime) return value.toIso8601String();
      throw Exception('Invalid date format: $value');
    }
    
    // Convert IDs to strings (database may return ints)
    String toStringValue(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is int) return value.toString();
      return value.toString();
    }

    return RatingReviewModel(
      id: toStringValue(json['id']),
      doctorId: toStringValue(json['doctor_id'] ?? json['doctorId']),
      patientId: toStringValue(json['patient_id'] ?? json['patientId']),
      appointmentId: json['appointment_id'] != null || json['appointmentId'] != null
          ? toStringValue(json['appointment_id'] ?? json['appointmentId'])
          : null,
      rating: json['rating'] as int,
      reviewText: json['review_text'] as String? ?? json['reviewText'] as String?,
      isAnonymous: (json['is_anonymous'] ?? json['isAnonymous'] ?? false) as bool,
      isVerified: (json['is_verified'] ?? json['isVerified'] ?? true) as bool,
      isApproved: (json['is_approved'] ?? json['isApproved'] ?? true) as bool,
      createdAt: DateTime.parse(parseDateTime(json['created_at'] ?? json['createdAt'])),
      updatedAt: DateTime.parse(parseDateTime(json['updated_at'] ?? json['updatedAt'])),
      deletedAt: json['deleted_at'] != null || json['deletedAt'] != null
          ? DateTime.parse(parseDateTime(json['deleted_at'] ?? json['deletedAt']))
          : null,
      patientName: json['patient_name'] as String? ?? json['patientName'] as String?,
      patientEmail: json['patient_email'] as String? ?? json['patientEmail'] as String?,
      appointmentDate: json['appointment_date'] as String? ?? json['appointmentDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'appointment_id': appointmentId,
      'rating': rating,
      'review_text': reviewText,
      'is_anonymous': isAnonymous,
      'is_verified': isVerified,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  RatingReviewModel copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? appointmentId,
    int? rating,
    String? reviewText,
    bool? isAnonymous,
    bool? isVerified,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? patientName,
    String? patientEmail,
    String? appointmentDate,
  }) {
    return RatingReviewModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      appointmentId: appointmentId ?? this.appointmentId,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isVerified: isVerified ?? this.isVerified,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      patientName: patientName ?? this.patientName,
      patientEmail: patientEmail ?? this.patientEmail,
      appointmentDate: appointmentDate ?? this.appointmentDate,
    );
  }
}

// Model for doctor rating summary
class DoctorRatingSummary {
  final String doctorId;
  final int totalReviews;
  final double averageRating;
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;
  final DateTime? latestReviewDate;

  DoctorRatingSummary({
    required this.doctorId,
    required this.totalReviews,
    required this.averageRating,
    required this.fiveStar,
    required this.fourStar,
    required this.threeStar,
    required this.twoStar,
    required this.oneStar,
    this.latestReviewDate,
  });

  factory DoctorRatingSummary.fromJson(Map<String, dynamic> json) {
    return DoctorRatingSummary(
      doctorId: json['doctor_id'] as String,
      totalReviews: (json['total_reviews'] ?? 0) as int,
      averageRating: (json['average_rating'] ?? 0.0) as double,
      fiveStar: (json['five_star'] ?? 0) as int,
      fourStar: (json['four_star'] ?? 0) as int,
      threeStar: (json['three_star'] ?? 0) as int,
      twoStar: (json['two_star'] ?? 0) as int,
      oneStar: (json['one_star'] ?? 0) as int,
      latestReviewDate: json['latest_review_date'] != null
          ? DateTime.parse(json['latest_review_date'] as String)
          : null,
    );
  }
}

