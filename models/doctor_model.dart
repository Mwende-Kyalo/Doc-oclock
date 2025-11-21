class DoctorModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? specialization;
  final String? bio;
  final double? rating;
  final int? reviewCount;
  final String? profileImageUrl;

  DoctorModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.specialization,
    this.bio,
    this.rating,
    this.reviewCount,
    this.profileImageUrl,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      specialization: json['specialization'],
      bio: json['bio'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'specialization': specialization,
      'bio': bio,
      'rating': rating,
      'reviewCount': reviewCount,
      'profileImageUrl': profileImageUrl,
    };
  }
}

