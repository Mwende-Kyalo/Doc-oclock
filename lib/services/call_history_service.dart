import '../models/call_history_model.dart';

/// Service for managing call history
/// Using mock data for now - can be replaced with Supabase calls later
class CallHistoryService {
  // In-memory storage for call history (mock data)
  static final List<Map<String, dynamic>> _mockCallHistory = [];

  /// Save a call to history
  static Future<void> saveCall({
    required String appointmentId,
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required CallType type,
    required DateTime startTime,
    required DateTime endTime,
    required Duration duration,
    required CallStatus status,
    bool isIncoming = false,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final callId = DateTime.now().millisecondsSinceEpoch.toString();
    
    _mockCallHistory.add({
      'id': callId,
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'patient_name': patientName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'type': type == CallType.video ? 'video' : 'voice',
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration': duration.inSeconds,
      'status': status.toString().split('.').last,
      'is_incoming': isIncoming,
    });

    // Sort by start time, most recent first
    _mockCallHistory.sort((a, b) {
      final aTime = DateTime.parse(a['start_time']);
      final bTime = DateTime.parse(b['start_time']);
      return bTime.compareTo(aTime);
    });
  }

  /// Get call history for a user (patient or doctor)
  static Future<List<CallHistoryModel>> getCallHistory(
    String userId, {
    bool isDoctor = false,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Filter calls based on user role
    final filteredCalls = _mockCallHistory.where((call) {
      if (isDoctor) {
        return call['doctor_id'] == userId;
      } else {
        return call['patient_id'] == userId;
      }
    }).toList();

    return filteredCalls.map((json) => CallHistoryModel.fromJson(json)).toList();
  }

  /// Get call history for a specific appointment
  static Future<List<CallHistoryModel>> getCallsForAppointment(
    String appointmentId,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final filteredCalls = _mockCallHistory
        .where((call) => call['appointment_id'] == appointmentId)
        .toList();

    return filteredCalls.map((json) => CallHistoryModel.fromJson(json)).toList();
  }

  /// Initialize with some mock data for testing
  static void initializeMockData() {
    if (_mockCallHistory.isNotEmpty) return; // Already initialized

    final now = DateTime.now();
    
    _mockCallHistory.addAll([
      {
        'id': '1',
        'appointment_id': '1',
        'patient_id': '1',
        'patient_name': 'John Doe',
        'doctor_id': '1',
        'doctor_name': 'Dr. Sarah Johnson',
        'type': 'video',
        'start_time': now.subtract(const Duration(days: 2, hours: 3)).toIso8601String(),
        'end_time': now.subtract(const Duration(days: 2, hours: 2, minutes: 45)).toIso8601String(),
        'duration': 15 * 60, // 15 minutes
        'status': 'completed',
        'is_incoming': false,
      },
      {
        'id': '2',
        'appointment_id': '2',
        'patient_id': '1',
        'patient_name': 'John Doe',
        'doctor_id': '2',
        'doctor_name': 'Dr. Michael Chen',
        'type': 'voice',
        'start_time': now.subtract(const Duration(days: 5, hours: 2)).toIso8601String(),
        'end_time': now.subtract(const Duration(days: 5, hours: 1, minutes: 30)).toIso8601String(),
        'duration': 30 * 60, // 30 minutes
        'status': 'completed',
        'is_incoming': true,
      },
      {
        'id': '3',
        'appointment_id': '3',
        'patient_id': '1',
        'patient_name': 'John Doe',
        'doctor_id': '3',
        'doctor_name': 'Dr. Emily Rodriguez',
        'type': 'video',
        'start_time': now.subtract(const Duration(days: 7)).toIso8601String(),
        'end_time': now.subtract(const Duration(days: 7, minutes: -20)).toIso8601String(),
        'duration': 20 * 60, // 20 minutes
        'status': 'completed',
        'is_incoming': false,
      },
    ]);
  }
}

