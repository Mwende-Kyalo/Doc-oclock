import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/doctor_scaffold.dart';

class DoctorAppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const DoctorAppointmentDetailScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<DoctorAppointmentDetailScreen> createState() =>
      _DoctorAppointmentDetailScreenState();
}

class _DoctorAppointmentDetailScreenState
    extends State<DoctorAppointmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      if (appointmentProvider.appointments.isEmpty) {
        appointmentProvider.loadAppointments(
          authProvider.user!.id,
          isDoctor: true,
        );
      }
    });
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content:
            const Text('Are you sure you want to delete this appointment?'),
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
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final success =
          await appointmentProvider.deleteAppointment(appointmentId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment deleted successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appointmentProvider.errorMessage ??
                'Failed to delete appointment'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _rescheduleAppointment(AppointmentModel appointment) async {
    // ...existing code...

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: appointment.date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  Navigator.pop(context, {'date': date});
                }
              },
              child: const Text('Select New Date'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final time = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Time'),
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
                  Navigator.pop(context, {'time': time});
                }
              },
              child: const Text('Select New Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null) {
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final success = await appointmentProvider.rescheduleAppointment(
        appointment.id,
        result['date'] ?? appointment.date,
        result['time'] ?? appointment.time,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment rescheduled successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appointmentProvider.errorMessage ??
                'Failed to reschedule appointment'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoctorScaffold(
      title: 'Appointment Details',
      currentRoute: '/doctor/dashboard',
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            final appointment = provider.appointments.firstWhere(
              (apt) => apt.id == widget.appointmentId,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patient: ${appointment.patientName}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Date & Time: ${DateFormat('EEEE, MMMM dd, yyyy').format(appointment.date)} at ${appointment.time}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Consultation Method: ${appointment.type == ConsultationType.video ? 'VIDEO' : 'VOICE'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Status: ${appointment.status.toString().split('.').last.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: appointment.status ==
                                          AppointmentStatus.completed
                                      ? AppTheme.successGreen
                                      : appointment.status ==
                                              AppointmentStatus.cancelled
                                          ? AppTheme.errorRed
                                          : AppTheme.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: appointment.paymentMade
                                      ? AppTheme.successGreen.withOpacity(0.1)
                                      : AppTheme.errorRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  appointment.paymentMade ? 'PAID' : 'NOT PAID',
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
                          const SizedBox(height: 8),
                          Text(
                            'Consultation Fee: KES ${appointment.consultationFee.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.go(
                            '/doctor/patient/${appointment.patientId}?patientName=${Uri.encodeComponent(appointment.patientName)}'),
                        icon: const Icon(Icons.person),
                        label: const Text('View Patient'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _rescheduleAppointment(appointment),
                        icon: const Icon(Icons.schedule),
                        label: const Text('Reschedule'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _deleteAppointment(appointment.id),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorRed,
                        ),
                      ),
                      if (appointment.status == AppointmentStatus.booked) ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            // Start video call
                          },
                          icon: const Icon(Icons.video_call),
                          label: const Text('Start Call'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          } catch (e) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Appointment not found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/doctor/dashboard'),
                    child: const Text('Back to Appointments'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
