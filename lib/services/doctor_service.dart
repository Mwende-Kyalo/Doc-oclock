import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/doctor_model.dart';
import '../models/availability_model.dart';
import 'rating_review_service.dart';

class DoctorService {
  static final supabase = Supabase.instance.client;

  /// Get all doctors from doctor_accounts table
  /// Includes calculated ratings from ratings_reviews table
  static Future<List<DoctorModel>> getDoctors() async {
    try {
      final response = await supabase
          .from('doctor_accounts')
          .select('id, fullname, email, mobile, role, profile, created_at');

      final doctors = <DoctorModel>[];

      for (var json in (response as List)) {
        // Convert id to String (it might be int from database)
        final doctorId =
            (json['id']?.toString() ?? json['auth_user_id']?.toString() ?? '')
                .toString();

        // Get rating summary for this doctor
        final ratingSummary =
            await RatingReviewService.getDoctorRatingSummary(doctorId);

        // Get additional doctor details from doctors table if it exists
        String? specialization;
        String? bio;
        double? rating;

        try {
          // Convert doctorId to int for querying doctors table
          final doctorIdInt = int.tryParse(doctorId);
          if (doctorIdInt != null) {
            final doctorDetails = await supabase
                .from('doctors')
                .select('specialization, bio')
                .eq('user_id', doctorIdInt)
                .maybeSingle();

            if (doctorDetails != null) {
              specialization = doctorDetails['specialization']?.toString();
              bio = doctorDetails['bio']?.toString();
              rating = doctorDetails['rating']?.toDouble();
            }
          }
        } catch (e) {
          // If doctors table doesn't exist or query fails, continue without these fields
          debugPrint('Could not fetch doctor details: $e');
        }

        doctors.add(DoctorModel.fromJson({
          'id': doctorId,
          'fullName': json['fullname'] ?? '',
          'email': json['email'] ?? '',
          'phoneNumber': json['mobile'] ?? '',
          'specialization': specialization,
          'bio': bio,
          'rating': ratingSummary?.averageRating ?? rating,
          'reviewCount': ratingSummary?.totalReviews ?? 0,
          'profileImageUrl': json['profile'],
        }));
      }

      return doctors;
    } catch (e) {
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  /// Get doctor availability from appointment table
  /// Returns availability slots that are not yet booked (where patient_id is null or status='available')
  static Future<List<AvailabilityModel>> getDoctorAvailability(
      String doctorId) async {
    try {
      // Get availability slots from appointment table
      // These are slots where patient_id is null (not yet booked)
      // Explicitly select columns to avoid schema cache issues
      // Convert doctorId to int for database query
      final response = await supabase
          .from('appointment')
          .select('id, date, time, start_time, end_time, patient_id, doctor_id, status, created_at')
          .eq('doctor_id', int.tryParse(doctorId) ?? 0);

      final availabilities = <AvailabilityModel>[];

      // .select() returns a non-nullable List
      for (var item in response) {
        // Check if this is an availability slot (not a booked appointment)
        if (item['patient_id'] == null || item['status'] == 'available') {
          // Format time strings to remove seconds if present (HH:MM:SS -> HH:MM)
          String formatTime(String? timeStr) {
            if (timeStr == null || timeStr.isEmpty) return '';
            // If time has seconds (HH:MM:SS), remove them
            if (timeStr.split(':').length == 3) {
              return timeStr.substring(0, 5); // Take only HH:MM
            }
            return timeStr;
          }

          availabilities.add(AvailabilityModel(
            id: item['id'] ?? '',
            doctorId: item['doctor_id'] ?? doctorId,
            date: item['date'] != null
                ? DateTime.parse(item['date'])
                : DateTime.now(),
            startTime: formatTime(item['start_time'] ?? item['time'] ?? ''),
            endTime: formatTime(item['end_time'] ?? ''),
            createdAt: item['created_at'] != null
                ? DateTime.parse(item['created_at'])
                : DateTime.now(),
          ));
        }
      }

      return availabilities;
    } catch (e) {
      throw Exception('Failed to fetch doctor availability: $e');
    }
  }

  /// Get available slots for patients to book
  /// Filters out already booked appointments
  static Future<List<AvailabilityModel>> getAvailableSlots(
      String doctorId) async {
    try {
      // Get slots where patient_id is null (available)
      // Explicitly select columns to avoid schema cache issues
      // Don't filter by date in query - filter in code to handle missing date column
      final response = await supabase
          .from('appointment')
          .select('id, date, time, start_time, end_time, patient_id, doctor_id, status, created_at')
          .eq('doctor_id', int.tryParse(doctorId) ?? 0)
          .order('created_at', ascending: true);

      final availabilities = <AvailabilityModel>[];
      final now = DateTime.now();

      // .select() returns a non-nullable List
      for (var item in response) {
        // Only include slots that are not booked
        if (item['patient_id'] == null) {
          // Try to parse date from various possible column names
          DateTime? slotDate;
          if (item['date'] != null) {
            try {
              slotDate = DateTime.parse(item['date']);
            } catch (e) {
              // If date parsing fails, try to use created_at
              slotDate = item['created_at'] != null
                  ? DateTime.parse(item['created_at'])
                  : now;
            }
          } else if (item['created_at'] != null) {
            slotDate = DateTime.parse(item['created_at']);
          } else {
            slotDate = now;
          }
          
          // Only include future slots (or today's slots)
          if (slotDate.isAfter(now.subtract(const Duration(days: 1)))) {
            // Format time strings to remove seconds if present (HH:MM:SS -> HH:MM)
            String formatTime(String? timeStr) {
              if (timeStr == null || timeStr.isEmpty) return '';
              // If time has seconds (HH:MM:SS), remove them
              if (timeStr.split(':').length == 3) {
                return timeStr.substring(0, 5); // Take only HH:MM
              }
              return timeStr;
            }

            availabilities.add(AvailabilityModel(
              id: item['id']?.toString() ?? '',
              doctorId: item['doctor_id']?.toString() ?? doctorId,
              date: slotDate,
              startTime: formatTime(item['start_time'] ?? item['time'] ?? ''),
              endTime: formatTime(item['end_time'] ?? ''),
              createdAt: item['created_at'] != null
                  ? DateTime.parse(item['created_at'])
                  : now,
            ));
          }
        }
      }

      return availabilities;
    } catch (e) {
      throw Exception('Failed to fetch available slots: $e');
    }
  }

  /// Get doctor by ID
  static Future<DoctorModel> getDoctorById(String doctorId) async {
    try {
      // Convert doctorId to int for querying (database stores id as int)
      final doctorIdInt = int.tryParse(doctorId);
      if (doctorIdInt == null) {
        throw Exception('Invalid doctor ID format: $doctorId');
      }

      final response = await supabase
          .from('doctor_accounts')
          .select('id, fullname, email, mobile, role, profile, created_at')
          .eq('id', doctorIdInt)
          .single();

      // Get additional doctor details from doctors table if it exists
      String? specialization;
      String? bio;
      double? rating;

      try {
        // Convert doctorId to int for querying doctors table
        final doctorIdInt = int.tryParse(doctorId);
        if (doctorIdInt != null) {
          final doctorDetails = await supabase
              .from('doctors')
              .select('specialization, bio')
              .eq('user_id', doctorIdInt)
              .maybeSingle();

          if (doctorDetails != null) {
            specialization = doctorDetails['specialization']?.toString();
            bio = doctorDetails['bio']?.toString();
            rating = doctorDetails['rating']?.toDouble();
          }
        }
      } catch (e) {
        // If doctors table doesn't exist or query fails, continue without these fields
        debugPrint('Could not fetch doctor details: $e');
      }

      // Get rating summary for this doctor
      final ratingSummary =
          await RatingReviewService.getDoctorRatingSummary(doctorId);

      // .single() returns non-nullable
      return DoctorModel.fromJson({
        'id': (response['id']?.toString() ?? doctorId).toString(),
        'fullName': response['fullname'] ?? '',
        'email': response['email'] ?? '',
        'phoneNumber': response['mobile'] ?? '',
        'specialization': specialization,
        'bio': bio,
        'rating': ratingSummary?.averageRating ?? rating,
        'reviewCount': ratingSummary?.totalReviews ?? 0,
        'profileImageUrl': response['profile'],
      });
    } catch (e) {
      throw Exception('Failed to fetch doctor: $e');
    }
  }

  /// Add availability slot (doctor sets available time)
  /// This creates an entry in appointment table with patient_id = null
  static Future<AvailabilityModel> addAvailability({
    required String doctorId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      // Convert doctorId to integer for database
      final doctorIdInt = int.tryParse(doctorId) ?? 0;
      
      // Get doctor name for denormalization
      String doctorName = '';
      try {
        final doctorData = await supabase
            .from('doctor_accounts')
            .select('fullname')
            .eq('id', doctorIdInt)
            .maybeSingle();
        doctorName = doctorData?['fullname'] ?? '';
      } catch (e) {
        // If we can't get doctor name, continue without it
        debugPrint('Could not fetch doctor name: $e');
      }
      
      final response = await supabase
          .from('appointment')
          .insert({
            'doctor_id': doctorIdInt,
            'doctor_name': doctorName, // Required field for denormalization
            'date': date.toIso8601String().split('T')[0], // Store date only
            'start_time': startTime,
            'end_time': endTime,
            'patient_id': null, // No patient yet - this is an availability slot
            'status': 'available',
            'type': 'video', // Default type, required field
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // Convert database int IDs to strings for the model
      return AvailabilityModel(
        id: (response['id']?.toString() ?? ''),
        doctorId: (response['doctor_id']?.toString() ?? doctorId),
        date:
            response['date'] != null ? DateTime.parse(response['date']) : date,
        startTime: response['start_time']?.toString() ?? startTime,
        endTime: response['end_time']?.toString() ?? endTime,
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'])
            : DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to add availability: $e');
    }
  }

  /// Delete availability slot
  static Future<void> deleteAvailability(String availabilityId) async {
    try {
      // Convert availabilityId to int for database query
      final availabilityIdInt = int.tryParse(availabilityId) ?? 0;
      if (availabilityIdInt == 0) {
        throw Exception('Invalid availability ID format: $availabilityId');
      }
      
      // Only delete if not booked - check first
      final check = await supabase
          .from('appointment')
          .select()
          .eq('id', availabilityIdInt)
          .single();

      if (check['patient_id'] != null) {
        throw Exception(
            'Cannot delete availability - appointment already booked');
      }

      await supabase.from('appointment').delete().eq('id', availabilityIdInt);
    } catch (e) {
      throw Exception('Failed to delete availability: $e');
    }
  }
}
