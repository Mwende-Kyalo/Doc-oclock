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

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  AppointmentStatus? _selectedStatus;

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
      title: l10n.myAppointments,
      currentRoute: '/doctor/appointments',
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<AppointmentModel> appointments = provider.appointments;

          // Filter by status if selected
          if (_selectedStatus != null) {
            appointments = appointments
                .where((apt) => apt.status == _selectedStatus)
                .toList();
          }

          // Sort by date and time (upcoming first)
          appointments.sort((a, b) {
            final dateCompare =
                a.appointment_date.compareTo(b.appointment_date);
            if (dateCompare != 0) return dateCompare;
            return a.time.compareTo(b.time);
          });

          if (appointments.isEmpty) {
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
                ],
              ),
            );
          }

          return Column(
            children: [
              // Status filter chips
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text(l10n.all),
                        selected: _selectedStatus == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...AppointmentStatus.values.map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              status.toString().split('.').last.toUpperCase(),
                            ),
                            selected: _selectedStatus == status,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = selected ? status : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              // Appointments list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    await provider.loadAppointments(
                      authProvider.user!.id,
                      isDoctor: true,
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return _buildAppointmentCard(context, appointment);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, AppointmentModel appointment) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    // Parse time string to DateTime for formatting
    DateTime? appointmentDateTime;
    try {
      if (appointment.time.isNotEmpty) {
        final timeParts = appointment.time.split(':');
        if (timeParts.length >= 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          appointmentDateTime = DateTime(
            appointment.appointment_date.year,
            appointment.appointment_date.month,
            appointment.appointment_date.day,
            hour,
            minute,
          );
        }
      }
    } catch (e) {
      // Use default if parsing fails
    }

    Color statusColor;
    switch (appointment.status) {
      case AppointmentStatus.booked:
        statusColor = AppTheme.primaryBlue;
        break;
      case AppointmentStatus.completed:
        statusColor = AppTheme.successGreen;
        break;
      case AppointmentStatus.cancelled:
        statusColor = AppTheme.errorRed;
        break;
      case AppointmentStatus.rescheduled:
        statusColor = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.go('/doctor/appointment/${appointment.id}'),
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
                          appointment.patientName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(appointment.appointment_date),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              appointmentDateTime != null
                                  ? timeFormat.format(appointmentDateTime)
                                  : appointment.time,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.status
                          .toString()
                          .split('.')
                          .last
                          .toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    appointment.type == ConsultationType.video
                        ? Icons.video_call
                        : Icons.phone,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appointment.type == ConsultationType.video
                        ? l10n.videoCall
                        : l10n.voiceCall,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  if (appointment.paymentMade)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.paid,
                        style: const TextStyle(
                          color: AppTheme.successGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
