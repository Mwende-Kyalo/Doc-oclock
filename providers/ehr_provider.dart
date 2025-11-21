import 'package:flutter/foundation.dart';
import '../models/ehr_model.dart';

class EhrProvider with ChangeNotifier {
  List<EhrModel> _ehrRecords = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EhrModel> get ehrRecords => _ehrRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mock data for demonstration
  void _initializeMockData() {
    _ehrRecords = [
      EhrModel(
        id: '1',
        patientId: 'patient_1',
        patientName: 'Jane Doe',
        doctorId: 'doctor_1',
        doctorName: 'Dr. Feelgood',
        date: DateTime(2025, 11, 11),
        diagnosis: 'Common Cold',
        prescription: 'Rest and fluids',
        notes: 'Patient should rest and stay hydrated',
        createdAt: DateTime.now(),
      ),
      EhrModel(
        id: '2',
        patientId: 'patient_1',
        patientName: 'Jane Doe',
        doctorId: 'doctor_2',
        doctorName: 'Dr. Smith',
        date: DateTime(2025, 11, 10),
        diagnosis: 'Headache',
        prescription: 'Painkillers',
        notes: null,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> loadEhrRecords(String patientId, {bool refresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      // When implemented, this will fetch EHR records from the database
      // Changes made by doctors will automatically reflect here since it's reading from the same database
      await Future.delayed(const Duration(seconds: 1));

      if (refresh || _ehrRecords.isEmpty) {
        _initializeMockData();
      }

      // Filter by patient ID - this ensures patients only see their own records
      // and doctors see records for the selected patient
      _ehrRecords = _ehrRecords.where((e) => e.patientId == patientId).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
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
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      final ehrRecord = EhrModel(
        id: 'ehr_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
        date: DateTime.now(),
        diagnosis: diagnosis,
        prescription: prescription,
        notes: notes,
        createdAt: DateTime.now(),
      );

      _ehrRecords.add(ehrRecord);
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

  Future<bool> updateEhrRecord(EhrModel ehrRecord) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _ehrRecords.indexWhere((e) => e.id == ehrRecord.id);
      if (index != -1) {
        _ehrRecords[index] = ehrRecord;
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

  Future<bool> deleteEhrRecord(String ehrId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      _ehrRecords.removeWhere((e) => e.id == ehrId);
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
}
