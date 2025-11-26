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

class BookAppointmentDetailScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String availabilityId;
  final String date;
  final String startTime;
  final String endTime;

  const BookAppointmentDetailScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.availabilityId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<BookAppointmentDetailScreen> createState() =>
      _BookAppointmentDetailScreenState();
}

class _BookAppointmentDetailScreenState
    extends State<BookAppointmentDetailScreen> {
  ConsultationType _selectedType = ConsultationType.video;
  String? _selectedTime;
  bool _isLoading = false;
  final List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
    // Format time to remove seconds if present (HH:MM:SS -> HH:MM)
    String formatTime(String timeStr) {
      if (timeStr.split(':').length == 3) {
        return timeStr.substring(0, 5); // Take only HH:MM
      }
      return timeStr;
    }
    _selectedTime = formatTime(widget.startTime);
  }

  void _generateTimeSlots() {
    final slots = <String>[];
    final start = _parseTime(widget.startTime);
    final end = _parseTime(widget.endTime);

    var current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      slots.add(_formatTime(current));
      current = current.add(const Duration(minutes: 30));
    }

    setState(() {
      _timeSlots.addAll(slots);
    });
  }

  DateTime _parseTime(String time) {
    // Handle both HH:MM and HH:MM:SS formats
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      parts.length > 1 ? int.parse(parts[1]) : 0,
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _bookAppointment() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);

      final appointmentDate = DateTime.parse(widget.date);

      final success = await appointmentProvider.bookAppointment(
        patientId: authProvider.user!.id,
        patientName: authProvider.user!.fullName,
        doctorId: widget.doctorId,
        doctorName: widget.doctorName,
        appointmentSlotId: widget.availabilityId,
        appointment_date: appointmentDate,
        time: _selectedTime!,
        type: _selectedType,
        consultationFee: 50.0,
        patientEmail: authProvider.user!.email,
      );

      if (success && mounted) {
        _showPaymentOptionsDialog();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                appointmentProvider.errorMessage ?? 'Failed to book appointment'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPaymentOptionsDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.paymentOptions),
        content: Text(l10n.appointmentBookedSuccessfully),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close payment options dialog
              context.go('/patient/appointments');
            },
            child: Text(l10n.payLater),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close payment options dialog
              // Navigate to payment screen
              final appointmentProvider =
                  Provider.of<AppointmentProvider>(context, listen: false);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

              final patientAppointments = appointmentProvider.appointments
                  .where((apt) => apt.patientId == authProvider.user!.id)
                  .toList();

              if (patientAppointments.isNotEmpty) {
                patientAppointments
                    .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                final latestAppointment = patientAppointments.first;
                context.go(
                    '/patient/payment?appointmentId=${latestAppointment.id}');
              } else {
                context.go('/patient/payment');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
            ),
            child: Text(l10n.payNow),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appointmentDate = DateTime.parse(widget.date);

    return PatientScaffold(
      title: l10n.bookAppointment,
      currentRoute: '/patient/book-appointment',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Doctor Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Doctor Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.doctorName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Appointment Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appointmentDetails,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          '${l10n.date}: ${DateFormat('MMMM dd, yyyy').format(appointmentDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Time Selection
                    Text(
                      l10n.time,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTime,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _timeSlots.map((time) {
                        return DropdownMenuItem(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTime = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Consultation Type
                    Text(
                      l10n.consultationType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<ConsultationType>(
                      title: Text(l10n.videoCall),
                      value: ConsultationType.video,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    RadioListTile<ConsultationType>(
                      title: Text(l10n.voiceCall),
                      value: ConsultationType.voice,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Consultation Fee
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.consultationFee,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            'KES 50.00',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Book Button
            ElevatedButton(
              onPressed: _isLoading ? null : _bookAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
                  child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.confirm,
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

