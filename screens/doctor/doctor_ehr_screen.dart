import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ...existing code...
import '../../theme/app_theme.dart';
import '../../widgets/doctor_scaffold.dart';

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
      // TODO: Replace with actual API call to get list of patients
      // For now, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));

      // Mock patient list - in real app, this would come from appointments or patient database
      setState(() {
        _patients = [
          {
            'id': 'patient_1',
            'name': 'Jane Doe',
            'email': 'jane@example.com',
            'phone': '1234567890',
          },
          {
            'id': 'patient_2',
            'name': 'John Smith',
            'email': 'john@example.com',
            'phone': '0987654321',
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoctorScaffold(
      title: 'Patient EHRs',
      currentRoute: '/doctor/ehr',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPatients,
                        child: const Text('Retry'),
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
                              const Text(
                                'No patients found',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _patients.length,
                          itemBuilder: (context, index) {
                            final patient = _patients[index];
                            return _buildPatientCard(patient);
                          },
                        ),
                ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
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
            Text(
              'Email: ${patient['email']}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Phone: ${patient['phone']}',
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
