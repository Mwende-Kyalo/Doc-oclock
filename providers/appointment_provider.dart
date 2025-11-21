import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';

class AppointmentProvider with ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mock data for demonstration
  void _initializeMockData() {
    _appointments = [
      AppointmentModel(
        id: '1',
        patientId: 'patient_1',
        patientName: 'Jane Doe',
        doctorId: 'doctor_1',
        doctorName: 'Dr. Feelgood',
        date: DateTime(2024, 10, 22),
        time: '10:30',
        type: ConsultationType.video,
        status: AppointmentStatus.booked,
        consultationFee: 50.0,
        paymentMade: true,
        createdAt: DateTime.now(),
      ),
      AppointmentModel(
        id: '2',
        patientId: 'patient_2',
        patientName: 'John Smith',
        doctorId: 'doctor_2',
        doctorName: 'Dr. Smith',
        date: DateTime(2024, 10, 23),
        time: '11:00',
        type: ConsultationType.voice,
        status: AppointmentStatus.completed,
        consultationFee: 50.0,
        paymentMade: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> loadAppointments(String userId, {bool isDoctor = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      _initializeMockData();

      // Filter appointments based on role
      if (isDoctor) {
        _appointments =
            _appointments.where((apt) => apt.doctorId == userId).toList();
      } else {
        _appointments =
            _appointments.where((apt) => apt.patientId == userId).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bookAppointment({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required DateTime date,
    required String time,
    required ConsultationType type,
    required double consultationFee,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      final appointment = AppointmentModel(
        id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
        date: date,
        time: time,
        type: type,
        status: AppointmentStatus.booked,
        consultationFee: consultationFee,
        paymentMade: false,
        createdAt: DateTime.now(),
      );

      _appointments.add(appointment);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAppointment(AppointmentModel appointment) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _appointments.indexWhere((a) => a.id == appointment.id);
      if (index != -1) {
        _appointments[index] = appointment;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAppointment(String appointmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      _appointments.removeWhere((a) => a.id == appointmentId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

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
        date: newDate,
        time: newTime,
        status: AppointmentStatus.rescheduled,
      ),
    );
  }

  Future<bool> markPaymentMade(String appointmentId) async {
    final appointment = _appointments.firstWhere(
      (a) => a.id == appointmentId,
      orElse: () => throw Exception('Appointment not found'),
    );

    return updateAppointment(appointment.copyWith(paymentMade: true));
  }
}
