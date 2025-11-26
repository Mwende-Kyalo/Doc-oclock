import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/prescription_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/prescription_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/patient_scaffold.dart';
import '../../l10n/app_localizations.dart';

class PrescriptionsViewScreen extends StatefulWidget {
  const PrescriptionsViewScreen({super.key});

  @override
  State<PrescriptionsViewScreen> createState() =>
      _PrescriptionsViewScreenState();
}

class _PrescriptionsViewScreenState extends State<PrescriptionsViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final prescriptionProvider =
          Provider.of<PrescriptionProvider>(context, listen: false);
      prescriptionProvider.loadPrescriptions(authProvider.user!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PatientScaffold(
      title: l10n.myPrescriptions,
      currentRoute: '/patient/prescriptions-view',
      body: Consumer<PrescriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      provider.loadPrescriptions(authProvider.user!.id);
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (provider.prescriptions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.medical_services,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noPrescriptionsFound,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.prescriptionsFromDoctors,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await provider.loadPrescriptions(authProvider.user!.id);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = provider.prescriptions[index];
                return _buildPrescriptionCard(prescription);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionModel prescription) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading:
            const Icon(Icons.medical_services, color: AppTheme.primaryBlue),
        title: Text(
          'Dr. ${prescription.doctorName}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          DateFormat('MMMM dd, yyyy').format(prescription.date),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: prescription.isOrdered
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.ordered,
                  style: const TextStyle(
                    color: AppTheme.successGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(l10n.diagnosis, prescription.diagnosis),
                const SizedBox(height: 16),
                Text(
                  '${l10n.medications}:',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...prescription.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index < prescription.items.length - 1 ? 12 : 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.medicationName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildMedicationDetail(l10n.dosage, item.dosage),
                              const SizedBox(width: 16),
                              _buildMedicationDetail(
                                  l10n.frequency, item.frequency),
                              const SizedBox(width: 16),
                              _buildMedicationDetail(
                                  l10n.duration, item.duration),
                            ],
                          ),
                          if (item.instructions != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${l10n.instructions}: ${item.instructions}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                if (prescription.notes != null &&
                    prescription.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(l10n.notes, prescription.notes!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
