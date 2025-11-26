import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/patient_scaffold.dart';
import '../../l10n/app_localizations.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      appointmentProvider.loadAppointments(
        authProvider.user!.id,
        isDoctor: false,
      );
    });
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAppointment),
        content: Text(l10n.areYouSureDeleteAppointment),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final success =
          await appointmentProvider.deleteAppointment(appointmentId);
      final l10n = AppLocalizations.of(context)!;
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appointmentDeleted),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appointmentProvider.errorMessage ??
                l10n.failedToDeleteAppointment),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _rescheduleAppointment(AppointmentModel appointment) async {
    final l10n = AppLocalizations.of(context)!;
    DateTime? newDate;
    String? newTime;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.reschedule),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: appointment.appointment_date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      newDate = date;
                    });
                  }
                },
                child: Text(newDate == null
                    ? l10n.selectNewDate
                    : DateFormat('dd/MM/yyyy').format(newDate!)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final time = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.selectTime),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 24,
                          itemBuilder: (context, index) {
                            final hour = index.toString().padLeft(2, '0');
                            return ListTile(
                              title: Text('$hour:00'),
                              onTap: () => Navigator.pop(context, '$hour:00'),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                  if (time != null) {
                    setState(() {
                      newTime = time;
                    });
                  }
                },
                child: Text(newTime ?? l10n.selectNewTime),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: (newDate != null && newTime != null)
                  ? () =>
                      Navigator.pop(context, {'date': newDate, 'time': newTime})
                  : null,
              child: Text(l10n.reschedule),
            ),
          ],
        ),
      ),
    );

    if (result != null && result['date'] != null && result['time'] != null) {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final success = await appointmentProvider.rescheduleAppointment(
        appointment.id,
        result['date'],
        result['time'],
      );

      final l10n = AppLocalizations.of(context)!;
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appointmentRescheduled),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appointmentProvider.errorMessage ??
                l10n.failedToRescheduleAppointment),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PatientScaffold(
      title: l10n.myAppointments,
      currentRoute: '/patient/appointments',
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noAppointments,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/patient/book-appointment'),
                    child: Text(l10n.bookAppointment),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await provider.loadAppointments(
                authProvider.user!.id,
                isDoctor: false,
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.appointments.length,
              itemBuilder: (context, index) {
                final appointment = provider.appointments[index];
                return _buildAppointmentCard(context, appointment);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, AppointmentModel appointment) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.doctorLabel}: ${appointment.doctorName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.dateLabel}: ${DateFormat('dd/MM/yyyy').format(appointment.appointment_date)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${l10n.timeLabel}: ${appointment.time}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${l10n.appointmentType}: ${appointment.type == ConsultationType.video ? l10n.video : l10n.voice}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Status: ${appointment.status.toString().split('.').last}',
                            style: TextStyle(
                              fontSize: 14,
                              color: appointment.status ==
                                      AppointmentStatus.completed
                                  ? AppTheme.successGreen
                                  : appointment.status ==
                                          AppointmentStatus.cancelled
                                      ? AppTheme.errorRed
                                      : AppTheme.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: appointment.paymentMade
                                  ? AppTheme.successGreen.withOpacity(0.1)
                                  : AppTheme.errorRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              appointment.paymentMade
                                  ? l10n.paid
                                  : l10n.notPaid,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: appointment.paymentMade
                                    ? AppTheme.successGreen
                                    : AppTheme.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      context.go('/patient/appointment/${appointment.id}'),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(l10n.edit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _deleteAppointment(appointment.id),
                  icon: const Icon(Icons.delete, size: 16),
                  label: Text(l10n.delete),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _rescheduleAppointment(appointment),
                  icon: const Icon(Icons.schedule, size: 16),
                  label: Text(l10n.reschedule),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                if (!appointment.paymentMade) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(
                          '/patient/payment?appointmentId=${appointment.id}');
                    },
                    icon: const Icon(Icons.payment, size: 16),
                    label: Text(l10n.payNow),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
                if (appointment.status == AppointmentStatus.booked &&
                    appointment.paymentMade) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle chat
                    },
                    icon: const Icon(Icons.chat, size: 16),
                    label: Text(l10n.messages),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle video call
                    },
                    icon: const Icon(Icons.video_call, size: 16),
                    label: Text(l10n.videoCall),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
