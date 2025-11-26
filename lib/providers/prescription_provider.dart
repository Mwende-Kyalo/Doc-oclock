import 'package:flutter/foundation.dart';
import '../models/prescription_model.dart';
import '../services/prescription_service.dart';

class PrescriptionProvider with ChangeNotifier {
  List<PrescriptionModel> _prescriptions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PrescriptionModel> get prescriptions => _prescriptions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load prescriptions for a patient
  Future<void> loadPrescriptions(String patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _prescriptions = await PrescriptionService.getPatientPrescriptions(patientId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark prescription as ordered
  Future<bool> markAsOrdered(String prescriptionId) async {
    try {
      final success = await PrescriptionService.markPrescriptionAsOrdered(prescriptionId);
      
      if (success) {
        final index = _prescriptions.indexWhere((p) => p.id == prescriptionId);
        if (index != -1) {
          _prescriptions[index] = PrescriptionModel(
            id: _prescriptions[index].id,
            patientId: _prescriptions[index].patientId,
            doctorId: _prescriptions[index].doctorId,
            doctorName: _prescriptions[index].doctorName,
            date: _prescriptions[index].date,
            diagnosis: _prescriptions[index].diagnosis,
            items: _prescriptions[index].items,
            notes: _prescriptions[index].notes,
            isOrdered: true,
            createdAt: _prescriptions[index].createdAt,
          );
          notifyListeners();
        }
      }
      
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
