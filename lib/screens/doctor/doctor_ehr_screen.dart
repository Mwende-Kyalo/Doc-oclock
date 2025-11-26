import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ...existing code...
import '../../theme/app_theme.dart';
import '../../widgets/doctor_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../services/patient_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class DoctorEhrScreen extends StatefulWidget {
  const DoctorEhrScreen({super.key});

  @override
  State<DoctorEhrScreen> createState() => _DoctorEhrScreenState();
}

class _DoctorEhrScreenState extends State<DoctorEhrScreen> {
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final doctorId = authProvider.user!.id;

      // Fetch patients from users table who have appointments with this doctor
      final patients = await PatientService.getPatientsForDoctor(doctorId);

      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DoctorScaffold(
      title: l10n.patientEhrs,
      currentRoute: '/doctor/ehr',
      floatingActionButton: _patients.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                // Show patient selection dialog if multiple patients
                if (_patients.length == 1) {
                  // Only one patient, go directly to add EHR
                  context.push(
                    '/doctor/add-ehr?patientId=${_patients[0]['id']}&patientName=${Uri.encodeComponent(_patients[0]['name'])}',
                  );
                } else {
                  // Multiple patients, show selection dialog
                  _showPatientSelectionDialog();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.addEhr),
              backgroundColor: AppTheme.primaryBlue,
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${l10n.error}: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPatients,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPatients,
                  child: _patients.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people_outline,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noPatientsFound,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _patients.length,
                          itemBuilder: (context, index) {
                            final patient = _patients[index];
                            return _buildPatientCard(context, patient);
                          },
                        ),
                ),
    );
  }

  void _showPatientSelectionDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Patient'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _patients.length,
            itemBuilder: (context, index) {
              final patient = _patients[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue,
                  child: Text(
                    patient['name'].substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(patient['name']),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/doctor/add-ehr?patientId=${patient['id']}&patientName=${Uri.encodeComponent(patient['name'])}',
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, Map<String, dynamic> patient) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.primaryBlue,
          child: Text(
            patient['name'].substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          patient['name'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (patient['email'] != null && patient['email'].toString().isNotEmpty)
              Text(
                '${l10n.emailLabel}: ${patient['email']}',
                style: const TextStyle(fontSize: 14),
              ),
            if (patient['phone'] != null && patient['phone'].toString().isNotEmpty)
              Text(
                '${l10n.phoneLabel}: ${patient['phone']}',
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.go(
              '/doctor/patient/${patient['id']}?patientName=${Uri.encodeComponent(patient['name'])}');
        },
      ),
    );
  }
}
