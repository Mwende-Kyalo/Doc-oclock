import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment_model.dart';

/// Service for sending email notifications
///
/// Options:
/// 1. Use Supabase Edge Functions (recommended for Supabase users)
/// 2. Use a dedicated email service (Resend, SendGrid, etc.)
/// 3. Use Supabase built-in email if configured
class EmailNotificationService {
  static final supabase = Supabase.instance.client;

  /// Send appointment confirmation email
  ///
  /// This uses Supabase Edge Functions to send emails
  /// You need to create an Edge Function that handles email sending
  static Future<bool> sendAppointmentConfirmationEmail({
    required AppointmentModel appointment,
    required String patientEmail,
    required String patientName,
  }) async {
    try {
      // Option 1: Use Supabase Edge Function (recommended)
      final response = await supabase.functions.invoke(
        'send-appointment-email',
        body: {
          'to': patientEmail,
          'subject': 'Appointment Confirmed - Dr. ${appointment.doctorName}',
          'template': 'appointment_confirmation',
          'data': {
            'patientName': patientName,
            'doctorName': appointment.doctorName,
            'appointment_date': appointment.appointment_date.toIso8601String(),
            'time': appointment.time,
            'type': appointment.type.toString().split('.').last,
            'fee': appointment.consultationFee,
            'appointmentId': appointment.id,
          },
        },
      );

      return response.status == 200;
    } catch (e) {
      // If Edge Function doesn't exist, fall back to alternative method
      debugPrint('Error sending email via Edge Function: $e');
      return await _sendEmailAlternative(
        appointment: appointment,
        patientEmail: patientEmail,
        patientName: patientName,
      );
    }
  }

  /// Alternative email sending method using a direct email service
  ///
  /// You can use services like Resend, SendGrid, or Mailgun
  /// For now, this shows the structure - you'll need to implement based on your email provider
  static Future<bool> _sendEmailAlternative({
    required AppointmentModel appointment,
    required String patientEmail,
    required String patientName,
  }) async {
    try {
      // Option 2: Use a third-party email service
      // Example with Resend API (you'll need to add resend_api package)
      final emailBody = _buildConfirmationEmailBody(
        appointment: appointment,
        patientName: patientName,
      );

      // This is a placeholder - implement based on your email provider
      // For Resend: https://pub.dev/packages/resend_api
      // For SendGrid: https://pub.dev/packages/sendgrid_mailer

      debugPrint('Would send email to $patientEmail');
      debugPrint(
          'Subject: Appointment Confirmed - Dr. ${appointment.doctorName}');
      debugPrint('Body: $emailBody');

      // Return false for now - implement actual email sending
      return false;
    } catch (e) {
      debugPrint('Error sending email: $e');
      return false;
    }
  }

  /// Build HTML email body for appointment confirmation
  static String _buildConfirmationEmailBody({
    required AppointmentModel appointment,
    required String patientName,
  }) {
    // Use appointment date directly (it's already a DateTime)
    final appointmentDate = appointment.appointment_date;
    final formattedDate =
        '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: #1E3A5F; color: white; padding: 20px; text-align: center; }
    .content { padding: 20px; background-color: #f5f5f5; }
    .appointment-details { background-color: white; padding: 15px; margin: 20px 0; border-radius: 5px; }
    .detail-row { margin: 10px 0; }
    .label { font-weight: bold; color: #1E3A5F; }
    .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
    .button { display: inline-block; padding: 10px 20px; background-color: #4A90E2; color: white; text-decoration: none; border-radius: 5px; margin: 10px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Appointment Confirmed!</h1>
    </div>
    <div class="content">
      <p>Dear $patientName,</p>
      <p>Your appointment has been successfully booked. Please find the details below:</p>
      
      <div class="appointment-details">
        <div class="detail-row">
          <span class="label">Doctor:</span> ${appointment.doctorName}
        </div>
        <div class="detail-row">
          <span class="label">Date:</span> $formattedDate
        </div>
        <div class="detail-row">
          <span class="label">Time:</span> ${appointment.time}
        </div>
        <div class="detail-row">
          <span class="label">Type:</span> ${appointment.type.toString().split('.').last.toUpperCase()} Consultation
        </div>
        <div class="detail-row">
          <span class="label">Fee:</span> KES ${appointment.consultationFee.toStringAsFixed(2)}
        </div>
        <div class="detail-row">
          <span class="label">Status:</span> ${appointment.status.toString().split('.').last.toUpperCase()}
        </div>
      </div>
      
      <p><strong>Important Reminders:</strong></p>
      <ul>
        <li>Ensure you have a stable internet connection for your ${appointment.type == ConsultationType.video ? 'video' : 'voice'} consultation</li>
        <li>Complete payment before the appointment date</li>
        <li>You will receive a reminder 24 hours and 1 hour before your appointment</li>
        <li>If added to Google Calendar, check your calendar for the event</li>
      </ul>
      
      <p>If you need to reschedule or cancel, please contact us through the app.</p>
      
      <p>Thank you for choosing Doc O'Clock!</p>
    </div>
    <div class="footer">
      <p>This is an automated email. Please do not reply to this message.</p>
      <p>&copy; ${DateTime.now().year} Doc O'Clock Telemedicine App</p>
    </div>
  </div>
</body>
</html>
''';
  }

  /// Send appointment reminder email (24 hours before)
  static Future<bool> sendAppointmentReminder({
    required AppointmentModel appointment,
    required String patientEmail,
    required String patientName,
  }) async {
    try {
      // Use same method as confirmation email
      final response = await supabase.functions.invoke(
        'send-appointment-email',
        body: {
          'to': patientEmail,
          'subject':
              'Reminder: Appointment Tomorrow - Dr. ${appointment.doctorName}',
          'template': 'appointment_reminder',
          'data': {
            'patientName': patientName,
            'doctorName': appointment.doctorName,
            'appointment_date': appointment.appointment_date.toIso8601String(),
            'time': appointment.time,
            'type': appointment.type.toString().split('.').last,
          },
        },
      );

      return response.status == 200;
    } catch (e) {
      debugPrint('Error sending reminder email: $e');
      return false;
    }
  }

  /// Send appointment day-of reminder (2 hours before)
  static Future<bool> sendDayOfReminder({
    required AppointmentModel appointment,
    required String patientEmail,
    required String patientName,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'send-appointment-email',
        body: {
          'to': patientEmail,
          'subject':
              'Appointment Today in 2 Hours - Dr. ${appointment.doctorName}',
          'template': 'appointment_day_reminder',
          'data': {
            'patientName': patientName,
            'doctorName': appointment.doctorName,
            'time': appointment.time,
            'type': appointment.type.toString().split('.').last,
          },
        },
      );

      return response.status == 200;
    } catch (e) {
      debugPrint('Error sending day-of reminder: $e');
      return false;
    }
  }
}
