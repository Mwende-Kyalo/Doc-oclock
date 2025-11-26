import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment_model.dart';
import 'google_sign_in_service.dart';

/// Service for integrating with Google Calendar API
///
/// This service handles:
/// - Adding appointments to Google Calendar
/// - Creating calendar events with reminders
/// - OAuth2 authentication (simplified - in production, use google_sign_in package)
class GoogleCalendarService {
  // For production, use google_sign_in package for proper OAuth2 flow
  // This is a simplified version that shows the structure

  /// Add an appointment to Google Calendar
  ///
  /// Returns the created event ID or null if failed
  ///
  /// If accessToken is not provided, will attempt to get it from GoogleSignInService
  static Future<String?> addAppointmentToCalendar({
    required AppointmentModel appointment,
    required String userEmail,
    String?
        accessToken, // Google OAuth2 access token (optional - will fetch if not provided)
  }) async {
    try {
      // Use appointment date directly (it's already a DateTime)
      final appointmentDate = appointment.appointment_date;
      final timeParts = appointment.time.split(':');
      final startDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      // End time is 30 minutes after start (standard appointment duration)
      final endDateTime = startDateTime.add(const Duration(minutes: 30));

      // Format dates in RFC3339 format for Google Calendar
      final startTimeStr =
          startDateTime.toUtc().toIso8601String().replaceAll('+00:00', 'Z');
      final endTimeStr =
          endDateTime.toUtc().toIso8601String().replaceAll('+00:00', 'Z');

      // Create event object
      final event = {
        'summary': 'Appointment with Dr. ${appointment.doctorName}',
        'description': _buildEventDescription(appointment),
        'start': {
          'dateTime': startTimeStr,
          'timeZone': 'Africa/Nairobi', // Adjust to your timezone
        },
        'end': {
          'dateTime': endTimeStr,
          'timeZone': 'Africa/Nairobi',
        },
        'reminders': {
          'useDefault': false,
          'overrides': [
            {
              'method': 'email',
              'minutes': 1440, // 24 hours before
            },
            {
              'method': 'popup',
              'minutes': 60, // 1 hour before
            },
            {
              'method': 'popup',
              'minutes': 15, // 15 minutes before
            },
          ],
        },
        'attendees': [
          {'email': userEmail}, // Patient email
          // Add doctor email if available
        ],
        'colorId': '9', // Blue color for medical appointments
        'visibility': 'default',
        'guestsCanInviteOthers': false,
        'guestsCanModify': false,
      };

      // Get access token if not provided
      if (accessToken == null || accessToken.isEmpty) {
        // Try to get access token from Google Sign-In service
        accessToken = await GoogleSignInService.getAccessToken();

        // If still no token, try to sign in
        if (accessToken == null || accessToken.isEmpty) {
          accessToken = await GoogleSignInService.signInAndGetAccessToken();
        }

        if (accessToken == null || accessToken.isEmpty) {
          throw Exception(
              'Google Calendar access token required. Please sign in with Google.');
        }
      }

      // Create event via Google Calendar API
      final response = await http.post(
        Uri.parse(
            'https://www.googleapis.com/calendar/v3/calendars/primary/events'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final eventData = jsonDecode(response.body);
        return eventData['id'] as String?;
      } else {
        throw Exception(
            'Failed to create calendar event: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding appointment to Google Calendar: $e');
    }
  }

  /// Build event description from appointment details
  static String _buildEventDescription(AppointmentModel appointment) {
    return '''
Appointment Details:
- Doctor: ${appointment.doctorName}
- Type: ${appointment.type.toString().split('.').last.toUpperCase()} consultation
- Status: ${appointment.status.toString().split('.').last.toUpperCase()}
- Fee: KES ${appointment.consultationFee.toStringAsFixed(2)}

Please ensure you have:
- Stable internet connection (for ${appointment.type == ConsultationType.video ? 'video' : 'voice'} call)
- Payment completed before appointment

Booked via Doc O'Clock Telemedicine App
''';
  }

  /// Check if user has Google Calendar access token
  /// Returns true if user is signed in and has calendar permissions
  static Future<bool> hasCalendarAccess() async {
    return await GoogleSignInService.hasCalendarPermission();
  }

  /// Request calendar permissions
  /// Triggers Google OAuth2 flow to get calendar access
  /// Returns the access token if successful, null otherwise
  static Future<String?> requestCalendarAccess() async {
    try {
      return await GoogleSignInService.signInAndGetAccessToken();
    } catch (e) {
      throw Exception('Failed to request Google Calendar access: $e');
    }
  }
}
