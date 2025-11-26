import 'package:flutter/foundation.dart';
import '../models/ehr_model.dart';
import '../services/ehr_service.dart';

class EhrProvider with ChangeNotifier {
  List<EhrModel> _ehrRecords = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EhrModel> get ehrRecords => _ehrRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEhrRecords(String patientId, {bool refresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch EHR records from Supabase
      // Changes made by doctors will automatically reflect here since it's reading from the same database
      _ehrRecords = await EhrService.getPatientEhrRecords(patientId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh EHR records to ensure latest changes are visible
  Future<void> refreshEhrRecords(String patientId) async {
    await loadEhrRecords(patientId, refresh: true);
  }

  Future<bool> addEhrRecord({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String diagnosis,
    required String prescription,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ehrRecord = await EhrService.createEhrRecord(
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
        diagnosis: diagnosis,
        prescription: prescription,
        notes: notes,
      );

      _ehrRecords.insert(0, ehrRecord); // Add at the beginning
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEhrRecord(EhrModel ehrRecord) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await EhrService.updateEhrRecord(ehrRecord);

      final index = _ehrRecords.indexWhere((e) => e.id == ehrRecord.id);
      if (index != -1) {
        _ehrRecords[index] = updated;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEhrRecord(String ehrId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await EhrService.deleteEhrRecord(ehrId);

      if (success) {
        _ehrRecords.removeWhere((e) => e.id == ehrId);
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
