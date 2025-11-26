import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.patientDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to profile
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/sign-in');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authProvider.user != null) {
            await appointmentProvider.loadAppointments(
              authProvider.user!.id,
              isDoctor: false,
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Text(
                          l10n.welcomeUser(
                              authProvider.user?.fullName ?? l10n.user),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authProvider.user?.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.quickActions,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  context,
                  AppLocalizations.of(context)!.bookAppointment,
                  Icons.calendar_today,
                  () => context.go('/patient/book-appointment'),
                ),
                _buildActionCard(
                  context,
                  AppLocalizations.of(context)!.myAppointments,
                  Icons.event_note,
                  () => context.go('/patient/appointments'),
                ),
                _buildActionCard(
                  context,
                  AppLocalizations.of(context)!.medicalRecords,
                  Icons.medical_information,
                  () => context.go('/patient/ehr'),
                ),
                _buildActionCard(
                  context,
                  AppLocalizations.of(context)!.profile,
                  Icons.person,
                  () {
                    // Navigate to profile
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.upcomingAppointments,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<AppointmentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final upcomingAppointments = provider.appointments
                    .where((apt) =>
                        apt.status == AppointmentStatus.booked ||
                        apt.status == AppointmentStatus.rescheduled)
                    .take(3)
                    .toList();

                if (upcomingAppointments.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                          AppLocalizations.of(context)!.noUpcomingAppointments),
                    ),
                  );
                }

                return Column(
                  children: upcomingAppointments
                      .map((appointment) =>
                          _buildAppointmentCard(context, appointment))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/patient/book-appointment'),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.bookAppointment),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppTheme.primaryBlue),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, AppointmentModel appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(appointment.doctorName),
        subtitle: Text(
            '${appointment.appointment_date.day}/${appointment.appointment_date.month}/${appointment.appointment_date.year} at ${appointment.time}'),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => context.go('/patient/appointment/${appointment.id}'),
        ),
      ),
    );
  }
}
