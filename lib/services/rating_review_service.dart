import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rating_review_model.dart';

class RatingReviewService {
  static final _supabase = Supabase.instance.client;

  /// Get all reviews for a specific doctor
  static Future<List<RatingReviewModel>> getDoctorReviews(
      String doctorId) async {
    try {
      // Convert doctorId to int for querying
      final doctorIdInt = int.tryParse(doctorId) ?? 0;

      // Select only from ratings_reviews table without joins to avoid schema issues
      final response = await _supabase
          .from('ratings_reviews')
          .select(
              'id, doctor_id, patient_id, appointment_id, rating, review_text, is_anonymous, is_verified, is_approved, created_at, updated_at, deleted_at')
          .eq('doctor_id', doctorIdInt)
          .eq('is_approved', true)
          .order('created_at', ascending: false);

      // Fetch patient names separately if needed
      final reviews = <RatingReviewModel>[];
      for (var json in (response as List)) {
        // Filter out deleted reviews
        if (json['deleted_at'] != null) {
          continue;
        }
        
        String? patientName;
        String? patientEmail;
        
        // Skip patient info lookup to avoid RLS permission issues
        // Patient names can be added later if needed via a different approach
        
        final model = RatingReviewModel.fromJson(json as Map<String, dynamic>);
        reviews.add(model.copyWith(
          patientName: patientName,
          patientEmail: patientEmail,
        ));
      }

      return reviews;
    } catch (e) {
      throw Exception('Failed to fetch doctor reviews: $e');
    }
  }

  /// Get reviews written by a specific patient
  static Future<List<RatingReviewModel>> getPatientReviews(
      String patientId) async {
    try {
      final response = await _supabase
          .from('ratings_reviews')
          .select('*')
          .eq('patient_id', int.tryParse(patientId) ?? 0)
          .order('created_at', ascending: false);

      // .select() returns a non-nullable List (can be empty)

      return (response as List)
          .map((json) =>
              RatingReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch patient reviews: $e');
    }
  }

  /// Get rating summary for a doctor
  /// Calculates from ratings_reviews table
  static Future<DoctorRatingSummary?> getDoctorRatingSummary(
      String doctorId) async {
    try {
      final doctorIdInt = int.tryParse(doctorId) ?? 0;
      // Calculate summary from ratings_reviews table
      final response = await _supabase
          .from('ratings_reviews')
          .select('rating, created_at, deleted_at')
          .eq('doctor_id', doctorIdInt)
          .eq('is_approved', true);

      // .select() returns a non-nullable List
      // Filter out deleted reviews
      final reviews = (response as List)
          .where((r) => r['deleted_at'] == null)
          .toList();
      
      if (reviews.isEmpty) {
        return null;
      }

      final ratings = reviews.map((r) => r['rating'] as int).toList();
      final totalReviews = ratings.length;
      final averageRating = ratings.reduce((a, b) => a + b) / totalReviews;

      // Get latest review date
      DateTime? latestReviewDate;
      if (reviews.isNotEmpty) {
        final dates = reviews
            .map((r) => DateTime.parse(r['created_at'] as String))
            .toList();
        dates.sort((a, b) => b.compareTo(a));
        latestReviewDate = dates.first;
      }

      return DoctorRatingSummary(
        doctorId: doctorId,
        totalReviews: totalReviews,
        averageRating: averageRating,
        fiveStar: ratings.where((r) => r == 5).length,
        fourStar: ratings.where((r) => r == 4).length,
        threeStar: ratings.where((r) => r == 3).length,
        twoStar: ratings.where((r) => r == 2).length,
        oneStar: ratings.where((r) => r == 1).length,
        latestReviewDate: latestReviewDate,
      );
    } catch (e) {
      // If no reviews exist, return null
      return null;
    }
  }

  /// Create a new review
  static Future<RatingReviewModel> createReview({
    required String doctorId,
    required String patientId,
    required int rating,
    String? reviewText,
    String? appointmentId,
    bool isAnonymous = false,
  }) async {
    try {
      // Validate rating
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      // Convert IDs to integers for database
      final doctorIdInt = int.tryParse(doctorId) ?? 0;
      final patientIdInt = int.tryParse(patientId) ?? 0;
      final appointmentIdInt = appointmentId != null ? int.tryParse(appointmentId) : null;

      final reviewData = {
        'doctor_id': doctorIdInt,
        'patient_id': patientIdInt,
        'rating': rating,
        'review_text': reviewText,
        'appointment_id': appointmentIdInt,
        'is_anonymous': isAnonymous,
        'is_verified': appointmentId != null,
      };

      final response = await _supabase
          .from('ratings_reviews')
          .insert(reviewData)
          .select()
          .single();

      return RatingReviewModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  /// Update an existing review
  static Future<RatingReviewModel> updateReview({
    required String reviewId,
    required String patientId,
    int? rating,
    String? reviewText,
    bool? isAnonymous,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (rating != null) {
        if (rating < 1 || rating > 5) {
          throw Exception('Rating must be between 1 and 5');
        }
        updateData['rating'] = rating;
      }

      if (reviewText != null) {
        updateData['review_text'] = reviewText;
      }

      if (isAnonymous != null) {
        updateData['is_anonymous'] = isAnonymous;
      }

      // Convert IDs to integers for database
      final reviewIdInt = int.tryParse(reviewId) ?? 0;
      final patientIdInt = int.tryParse(patientId) ?? 0;

      final response = await _supabase
          .from('ratings_reviews')
          .update(updateData)
          .eq('id', reviewIdInt)
          .eq('patient_id', patientIdInt) // Ensure patient owns the review
          .select()
          .single();
      
      // Filter out deleted reviews in application code
      if (response['deleted_at'] != null) {
        throw Exception('Review not found or has been deleted');
      }

      return RatingReviewModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  /// Delete a review (soft delete)
  static Future<void> deleteReview({
    required String reviewId,
    required String patientId,
  }) async {
    try {
      // Convert IDs to integers for database
      final reviewIdInt = int.tryParse(reviewId) ?? 0;
      final patientIdInt = int.tryParse(patientId) ?? 0;

      await _supabase
          .from('ratings_reviews')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', reviewIdInt)
          .eq('patient_id', patientIdInt); // Ensure patient owns the review
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  /// Check if patient has already reviewed a doctor for a specific appointment
  static Future<bool> hasPatientReviewedAppointment(
      String appointmentId) async {
    try {
      final appointmentIdInt = int.tryParse(appointmentId) ?? 0;
      final response = await _supabase
          .from('ratings_reviews')
          .select('id, deleted_at')
          .eq('appointment_id', appointmentIdInt)
          .limit(1);

      // Filter out deleted reviews in application code
      final reviews = (response as List).where((r) => r['deleted_at'] == null).toList();
      return reviews.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get review by appointment ID
  static Future<RatingReviewModel?> getReviewByAppointment(
      String appointmentId) async {
    try {
      final appointmentIdInt = int.tryParse(appointmentId) ?? 0;
      final response = await _supabase
          .from('ratings_reviews')
          .select('*')
          .eq('appointment_id', appointmentIdInt)
          .maybeSingle();

      if (response == null || response['deleted_at'] != null) return null;
      return RatingReviewModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
