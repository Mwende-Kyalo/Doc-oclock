import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/doctor_model.dart';
import '../../models/availability_model.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/doctor_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/patient_scaffold.dart';
import '../../l10n/app_localizations.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  List<DoctorModel> _doctors = [];
  Map<String, List<AvailabilityModel>> _doctorAvailabilities = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doctors = await DoctorService.getDoctors();
      final Map<String, List<AvailabilityModel>> availabilities = {};

      // Get only available slots (not yet booked) for each doctor
      for (var doctor in doctors) {
        final availableSlots = await DoctorService.getAvailableSlots(doctor.id);
        availabilities[doctor.id] = availableSlots;
      }

      setState(() {
        _doctors = doctors;
        _doctorAvailabilities = availabilities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _bookAppointment({
    required String doctorId,
    required String doctorName,
    required String appointmentSlotId, // The availability slot ID
    required DateTime appointment_date,
    required String time,
    required ConsultationType type,
    required VoidCallback onSuccess,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);

    final success = await appointmentProvider.bookAppointment(
      patientId: authProvider.user!.id,
      patientName: authProvider.user!.fullName,
      doctorId: doctorId,
      doctorName: doctorName,
      appointmentSlotId: appointmentSlotId, // Pass the slot ID
      appointment_date: appointment_date,
      time: time,
      type: type,
      consultationFee: 50.0,
      patientEmail: authProvider.user!.email, // Pass email for notifications
      googleAccessToken:
          null, // TODO: Get from Google Sign-In if user has connected
    );

    if (success && mounted) {
      // Reload doctors to update availability
      _loadDoctors();
      onSuccess();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appointmentProvider.errorMessage ?? 'Booking failed'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PatientScaffold(
      title: l10n.bookAppointment,
      currentRoute: '/patient/book-appointment',
      body: _isLoading
          ? Center(child: Text(l10n.loading))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${l10n.error}: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDoctors,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDoctors,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _doctors[index];
                      final availabilities =
                          _doctorAvailabilities[doctor.id] ?? [];
                      return _buildDoctorCard(doctor, availabilities);
                    },
                  ),
                ),
    );
  }

  Widget _buildDoctorCard(
      DoctorModel doctor, List<AvailabilityModel> availabilities) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryBlue,
                  child: Text(
                    doctor.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (doctor.specialization != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialization!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (doctor.rating != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                return Text(
                                  '${doctor.rating} (${doctor.reviewCount ?? 0} ${l10n.reviews})',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (doctor.bio != null) ...[
              const SizedBox(height: 12),
              Text(
                doctor.bio!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return OutlinedButton.icon(
                  onPressed: () {
                    context.go(
                        '/patient/reviews/${doctor.id}?doctorName=${Uri.encodeComponent(doctor.fullName)}');
                  },
                  icon: const Icon(Icons.rate_review, size: 18),
                  label: Text(l10n.viewAllReviews),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.availableDatesTimes,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (availabilities.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(l10n.noAvailability),
                      )
                  ],
                );
              },
            ),
            if (availabilities.isNotEmpty)
              ...availabilities.map((availability) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${DateFormat('MMM dd, yyyy').format(availability.date)} - ${availability.startTime} to ${availability.endTime}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to dedicated booking screen
                          context.push(
                            '/patient/book-appointment-detail?doctorId=${doctor.id}&doctorName=${Uri.encodeComponent(doctor.fullName)}&availabilityId=${availability.id}&date=${availability.date.toIso8601String().split('T')[0]}&startTime=${Uri.encodeComponent(availability.startTime)}&endTime=${Uri.encodeComponent(availability.endTime)}',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightBlue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Text(l10n.bookNow);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(DoctorModel doctor, AvailabilityModel availability) {
    final l10n = AppLocalizations.of(context)!;
    ConsultationType selectedType = ConsultationType.video;
    // Format time to remove seconds if present (HH:MM:SS -> HH:MM)
    String formatTimeForDropdown(String timeStr) {
      if (timeStr.split(':').length == 3) {
        return timeStr.substring(0, 5); // Take only HH:MM
      }
      return timeStr;
    }

    String selectedTime = formatTimeForDropdown(availability.startTime);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${l10n.bookAppointmentWith} ${doctor.fullName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${l10n.date}: ${DateFormat('MMMM dd, yyyy').format(availability.date)}'),
                const SizedBox(height: 16),
                Text(l10n.time),
                DropdownButton<String>(
                  value: selectedTime,
                  isExpanded: true,
                  items: _getTimeSlots(
                          availability.startTime, availability.endTime)
                      .map((time) => DropdownMenuItem(
                            value: time,
                            child: Text(time),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(l10n.consultationType),
                RadioListTile<ConsultationType>(
                  title: Text(l10n.video),
                  value: ConsultationType.video,
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                RadioListTile<ConsultationType>(
                  title: Text(l10n.voice),
                  value: ConsultationType.voice,
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorRed,
              ),
              child: Text(l10n.delete),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close booking dialog
                // Show confirmation dialog
                _showConfirmationDialog(
                  doctor: doctor,
                  availability: availability,
                  selectedTime: selectedTime,
                  selectedType: selectedType,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
              ),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getTimeSlots(String startTime, String endTime) {
    // Generate time slots between start and end time (30-minute intervals)
    final slots = <String>[];
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    var current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      slots.add(_formatTime(current));
      current = current.add(const Duration(minutes: 30));
    }

    return slots;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showConfirmationDialog({
    required DoctorModel doctor,
    required AvailabilityModel availability,
    required String selectedTime,
    required ConsultationType selectedType,
  }) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmAppointment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pleaseConfirmDetails,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildConfirmationRow(l10n.doctorName, doctor.fullName),
            _buildConfirmationRow(
              l10n.date,
              DateFormat('MMMM dd, yyyy').format(availability.date),
            ),
            _buildConfirmationRow(l10n.time, selectedTime),
            _buildConfirmationRow(
              l10n.consultationType,
              selectedType == ConsultationType.video
                  ? l10n.videoCall
                  : l10n.voiceCall,
            ),
            _buildConfirmationRow(l10n.consultationFee, 'KES 50.00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppTheme.errorRed),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog

              // Book the appointment
              await _bookAppointment(
                doctorId: doctor.id,
                doctorName: doctor.fullName,
                appointmentSlotId: availability.id,
                appointment_date: availability.date,
                time: selectedTime,
                type: selectedType,
                onSuccess: () {
                  // Show payment options after successful booking
                  _showPaymentOptionsDialog();
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
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
              // Navigate to appointments view (pay later)
              context.go('/patient/appointments');
            },
            child: Text(l10n.payLater),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close payment options dialog
              // Navigate to payment screen (pay now)
              // Get the latest appointment ID from provider
              final appointmentProvider =
                  Provider.of<AppointmentProvider>(context, listen: false);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

              // Get the most recent appointment for this patient
              final patientAppointments = appointmentProvider.appointments
                  .where((apt) => apt.patientId == authProvider.user!.id)
                  .toList();

              if (patientAppointments.isNotEmpty) {
                // Sort by created date, most recent first
                patientAppointments
                    .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                final latestAppointment = patientAppointments.first;

                // Navigate to payment screen with appointment ID
                context.go(
                    '/patient/payment?appointmentId=${latestAppointment.id}');
              } else {
                // Fallback to payment screen without appointment ID
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
}
