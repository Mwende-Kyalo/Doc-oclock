import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/ehr_provider.dart';
import '../../providers/auth_provider.dart';
// ...existing code...
import '../../widgets/patient_scaffold.dart';
import '../../l10n/app_localizations.dart';

class EhrViewScreen extends StatefulWidget {
  const EhrViewScreen({super.key});

  @override
  State<EhrViewScreen> createState() => _EhrViewScreenState();
}

class _EhrViewScreenState extends State<EhrViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ehrProvider = Provider.of<EhrProvider>(context, listen: false);
      ehrProvider.loadEhrRecords(authProvider.user!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PatientScaffold(
      title: l10n.medicalRecordsEhr,
      currentRoute: '/patient/ehr',
      body: Consumer<EhrProvider>(
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
                  Text(
                    l10n.noMedicalRecordsFound,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await provider.refreshEhrRecords(authProvider.user!.id);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.ehrRecords.length,
              itemBuilder: (context, index) {
                final ehr = provider.ehrRecords[index];
                return _buildEhrCard(ehr);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEhrCard(ehr) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.dateLabel}: ${DateFormat('MMMM dd, yyyy').format(ehr.date)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.diagnosis}: ${ehr.diagnosis}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.prescription}: ${ehr.prescription}',
              style: const TextStyle(fontSize: 14),
            ),
            if (ehr.notes != null && ehr.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.notes}: ${ehr.notes}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${l10n.doctorLabel}: ${ehr.doctorName}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
