import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../services/google_calendar_service.dart';
import '../services/email_notification_service.dart';

class AppointmentProvider with ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load appointments for a user (patient or doctor)
  Future<void> loadAppointments(String userId, {bool isDoctor = false}) async {
    if (_isLoading) return; // Prevent multiple simultaneous loads
    _isLoading = true;
    _errorMessage = null;
    // Use scheduleMicrotask to avoid calling notifyListeners during build
    scheduleMicrotask(() => notifyListeners());

    try {
      if (isDoctor) {
        _appointments = await AppointmentService.getDoctorAppointments(userId);
      } else {
        _appointments = await AppointmentService.getPatientAppointments(userId);
      }

      _isLoading = false;
      scheduleMicrotask(() => notifyListeners());
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      scheduleMicrotask(() => notifyListeners());
    }
  }

  /// Book an appointment
  Future<bool> bookAppointment({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String appointmentSlotId, // The availability slot ID to book
    required DateTime appointment_date,
    required String time,
    required ConsultationType type,
    required double consultationFee,
    String? patientEmail, // Optional: for email notifications
    String? googleAccessToken, // Optional: for Google Calendar integration
  }) async {
    _isLoading = true;
    _errorMessage = null;
    scheduleMicrotask(() => notifyListeners());

    try {
      final appointment = await AppointmentService.bookAppointment(
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
        appointmentSlotId: appointmentSlotId,
        appointment_date: appointment_date,
        time: time,
        consultationType: type == ConsultationType.video ? 'video' : 'voice',
        consultationFee: consultationFee,
      );

      // Add to local list
      _appointments.insert(0, appointment);

      // Send notifications (don't block on errors - log them)
      _sendBookingNotifications(appointment, patientEmail: patientEmail);

      _isLoading = false;
      scheduleMicrotask(() => notifyListeners());
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      scheduleMicrotask(() => notifyListeners());
      return false;
    }
  }

  /// Update appointment
  Future<bool> updateAppointment(AppointmentModel appointment) async {
    _isLoading = true;
    _errorMessage = null;
    scheduleMicrotask(() => notifyListeners());

    try {
      final updated = await AppointmentService.updateAppointment(appointment);

      // Update local list
      final index = _appointments.indexWhere((a) => a.id == appointment.id);
      if (index != -1) {
        _appointments[index] = updated;
      }

      _isLoading = false;
      scheduleMicrotask(() => notifyListeners());
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      scheduleMicrotask(() => notifyListeners());
      return false;
    }
  }

  /// Delete/Cancel appointment
  Future<bool> deleteAppointment(String appointmentId) async {
    _isLoading = true;
    _errorMessage = null;
    scheduleMicrotask(() => notifyListeners());

    try {
      final success = await AppointmentService.cancelAppointment(appointmentId);

      if (success) {
        _appointments.removeWhere((a) => a.id == appointmentId);
      }

      _isLoading = false;
      scheduleMicrotask(() => notifyListeners());
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      scheduleMicrotask(() => notifyListeners());
      return false;
    }
  }

  /// Reschedule appointment
  Future<bool> rescheduleAppointment(
    String appointmentId,
    DateTime newDate,
    String newTime,
  ) async {
    final appointment = _appointments.firstWhere(
      (a) => a.id == appointmentId,
      orElse: () => throw Exception('Appointment not found'),
    );

    return updateAppointment(
      appointment.copyWith(
        appointment_date: newDate,
        time: newTime,
        status: AppointmentStatus.rescheduled,
      ),
    );
  }

  /// Mark payment as made
  Future<bool> markPaymentMade(String appointmentId) async {
    try {
      final success = await AppointmentService.markPaymentMade(appointmentId);

      if (success) {
        final appointment = _appointments.firstWhere(
          (a) => a.id == appointmentId,
          orElse: () => throw Exception('Appointment not found'),
        );
        final updated = appointment.copyWith(paymentMade: true);
        final index = _appointments.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          _appointments[index] = updated;
        }
        scheduleMicrotask(() => notifyListeners());
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      scheduleMicrotask(() => notifyListeners());
      return false;
    }
  }

  /// Send booking notifications (email and calendar)
  /// This runs asynchronously and doesn't block the booking flow
  Future<void> _sendBookingNotifications(
    AppointmentModel appointment, {
    String? patientEmail,
    String? googleAccessToken,
  }) async {
    try {
      // Send email notification if email provided
      if (patientEmail != null && patientEmail.isNotEmpty) {
        try {
          await EmailNotificationService.sendAppointmentConfirmationEmail(
            appointment: appointment,
            patientEmail: patientEmail,
            patientName: appointment.patientName,
          );
          debugPrint('Appointment confirmation email sent to $patientEmail');
        } catch (e) {
          debugPrint('Failed to send email notification: $e');
          // Don't fail booking if email fails
        }
      }

      // Add to Google Calendar if access token provided
      if (googleAccessToken != null &&
          googleAccessToken.isNotEmpty &&
          patientEmail != null) {
        try {
          final eventId = await GoogleCalendarService.addAppointmentToCalendar(
            appointment: appointment,
            userEmail: patientEmail,
            accessToken: googleAccessToken,
          );
          if (eventId != null) {
            debugPrint(
                'Appointment added to Google Calendar with event ID: $eventId');
          }
        } catch (e) {
          debugPrint('Failed to add appointment to Google Calendar: $e');
          // Don't fail booking if calendar fails
        }
      }
    } catch (e) {
      debugPrint('Error sending booking notifications: $e');
      // Don't fail booking if notifications fail
    }
  }
}
