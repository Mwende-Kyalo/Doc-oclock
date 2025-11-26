import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/doctor_scaffold.dart';
import '../../l10n/app_localizations.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      appointmentProvider.loadAppointments(
        authProvider.user!.id,
        isDoctor: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DoctorScaffold(
      title: l10n.upcomingAppointments,
      currentRoute: '/doctor/dashboard',
      body: RefreshIndicator(
        onRefresh: () async {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          final appointmentProvider =
              Provider.of<AppointmentProvider>(context, listen: false);
          await appointmentProvider.loadAppointments(
            authProvider.user!.id,
            isDoctor: true,
          );
        },
        child: Consumer<AppointmentProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter appointments for this doctor and get upcoming ones
            final doctorAppointments = provider.appointments
                .where((apt) =>
                    apt.doctorId ==
                    Provider.of<AuthProvider>(context, listen: false).user!.id)
                .where((apt) =>
                    apt.status == AppointmentStatus.booked ||
                    apt.status == AppointmentStatus.rescheduled)
                .toList();

            // Sort by date and time
            doctorAppointments.sort((a, b) {
              final dateCompare =
                  a.appointment_date.compareTo(b.appointment_date);
              if (dateCompare != 0) return dateCompare;
              return a.time.compareTo(b.time);
            });

            if (doctorAppointments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noUpcomingAppointments,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: doctorAppointments.length,
              itemBuilder: (context, index) {
                final appointment = doctorAppointments[index];
                return _buildAppointmentCard(context, appointment);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, AppointmentModel appointment) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.primaryBlue,
          child: Text(
            appointment.patientName.isNotEmpty
                ? appointment.patientName.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          appointment.patientName,
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
              '${l10n.dateLabel}: ${DateFormat('MMMM dd, yyyy').format(appointment.appointment_date)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              '${l10n.timeLabel}: ${appointment.time}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              '${l10n.appointmentType}: ${appointment.type == ConsultationType.video ? l10n.videoCall : l10n.voiceCallTitle}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: appointment.status == AppointmentStatus.booked
                        ? AppTheme.primaryBlue
                        : AppTheme.successGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: appointment.paymentMade
                        ? AppTheme.successGreen.withOpacity(0.1)
                        : AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.paymentMade ? l10n.paid : l10n.notPaid,
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
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => context.go('/doctor/appointment/${appointment.id}'),
        ),
        onTap: () => context.go('/doctor/patient/${appointment.patientId}'),
      ),
    );
  }
}
