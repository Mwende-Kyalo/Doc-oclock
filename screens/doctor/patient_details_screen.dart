import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// ...existing code...
import '../../providers/ehr_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/message_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/doctor_scaffold.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;
  final String? patientName;

  const PatientDetailsScreen({
    super.key,
    required this.patientId,
    this.patientName,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  int _selectedTabIndex = 0;
  String? _patientName;
  String? _patientEmail;
  String? _patientPhone;

  @override
  void initState() {
    super.initState();
    _patientName = widget.patientName;
    _loadPatientData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ehrProvider = Provider.of<EhrProvider>(context, listen: false);
      ehrProvider.loadEhrRecords(widget.patientId);
    });
  }

  Future<void> _loadPatientData() async {
    // TODO: Replace with actual API call to fetch patient data
    // For now, using mock data
    setState(() {
      _patientName = _patientName ?? 'Jane Doe';
      _patientEmail = 'jane@example.com';
      _patientPhone = '1234567890';
    });
  }

  Future<void> _deleteEhrRecord(String ehrId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete EHR Record'),
        content: const Text(
            'Are you sure you want to delete this EHR record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ehrProvider = Provider.of<EhrProvider>(context, listen: false);
      final success = await ehrProvider.deleteEhrRecord(ehrId);

      if (success && mounted) {
        // Refresh to show updated list - changes will reflect on patient side
        await ehrProvider.refreshEhrRecords(widget.patientId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'EHR record deleted successfully. Changes will be reflected on the patient\'s side.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(ehrProvider.errorMessage ?? 'Failed to delete EHR record'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _navigateToChat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final chatId = await MessageService.getOrCreateChat(
          widget.patientId, authProvider.user!.id);
      if (mounted) {
        context.push(
            '/doctor/chat/$chatId?patientName=${Uri.encodeComponent(_patientName ?? 'Patient')}&patientId=${widget.patientId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open chat: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoctorScaffold(
      title: _patientName ?? 'Patient Details',
      currentRoute: '/doctor/ehr',
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${_patientName ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${_patientEmail ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phone: ${_patientPhone ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go(
                          '/doctor/add-ehr?patientId=${widget.patientId}&patientName=${Uri.encodeComponent(_patientName ?? 'Patient')}&type=ehr');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add EHR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go(
                          '/doctor/add-ehr?patientId=${widget.patientId}&patientName=${Uri.encodeComponent(_patientName ?? 'Patient')}&type=prescription');
                    },
                    icon: const Icon(Icons.medical_services),
                    label: const Text('Add Prescription'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToChat,
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement video call
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Video call feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.video_call),
                    label: const Text('Video Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTabIndex == 0
                              ? AppTheme.primaryBlue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'Medical History',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: _selectedTabIndex == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedTabIndex == 0
                            ? AppTheme.primaryBlue
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTabIndex == 1
                              ? AppTheme.primaryBlue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'E-Prescriptions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: _selectedTabIndex == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedTabIndex == 1
                            ? AppTheme.primaryBlue
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildMedicalHistoryTab()
                : _buildEPrescriptionsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryTab() {
    return Consumer<EhrProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.ehrRecords.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.medical_information,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No medical history found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadEhrRecords(widget.patientId);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.ehrRecords.length,
            itemBuilder: (context, index) {
              final ehr = provider.ehrRecords[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    'Diagnosis: ${ehr.diagnosis}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                          'Date: ${DateFormat('MMMM dd, yyyy').format(ehr.date)}'),
                      Text('Prescription: ${ehr.prescription}'),
                      if (ehr.notes != null && ehr.notes!.isNotEmpty)
                        Text('Notes: ${ehr.notes}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.edit, color: AppTheme.primaryBlue),
                        onPressed: () {
                          context.go(
                              '/doctor/add-ehr?patientId=${widget.patientId}&patientName=${Uri.encodeComponent(_patientName ?? 'Patient')}&type=ehr&ehrId=${ehr.id}');
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete, color: AppTheme.errorRed),
                        onPressed: () => _deleteEhrRecord(ehr.id),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEPrescriptionsTab() {
    return Consumer<EhrProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter EHR records that have prescriptions
        final prescriptions = provider.ehrRecords
            .where((ehr) => ehr.prescription.isNotEmpty)
            .toList();

        if (prescriptions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.medical_services,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No e-prescriptions found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.refreshEhrRecords(widget.patientId);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final ehr = prescriptions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    'Prescription: ${ehr.prescription}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Diagnosis: ${ehr.diagnosis}'),
                      Text(
                          'Date: ${DateFormat('MMMM dd, yyyy').format(ehr.date)}'),
                      if (ehr.notes != null && ehr.notes!.isNotEmpty)
                        Text('Notes: ${ehr.notes}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.edit, color: AppTheme.primaryBlue),
                        onPressed: () {
                          context.go(
                              '/doctor/add-ehr?patientId=${widget.patientId}&patientName=${Uri.encodeComponent(_patientName ?? 'Patient')}&type=prescription&ehrId=${ehr.id}');
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete, color: AppTheme.errorRed),
                        onPressed: () => _deleteEhrRecord(ehr.id),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
