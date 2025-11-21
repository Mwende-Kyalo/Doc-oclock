import 'package:flutter/material.dart';
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
// ...existing code...

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

      for (var doctor in doctors) {
        final doctorAvailabilities =
            await DoctorService.getDoctorAvailability(doctor.id);
        availabilities[doctor.id] = doctorAvailabilities;
      }

      setState(() {
        _doctors = doctors;
        _doctorAvailabilities = availabilities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _bookAppointment({
    required String doctorId,
    required String doctorName,
    required DateTime date,
    required String time,
    required ConsultationType type,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);

    final success = await appointmentProvider.bookAppointment(
      patientId: authProvider.user!.id,
      patientName: authProvider.user!.fullName,
      doctorId: doctorId,
      doctorName: doctorName,
      date: date,
      time: time,
      type: type,
      consultationFee: 50.0,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment booked successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      // Optionally navigate to appointments list
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
    return PatientScaffold(
      title: 'Book Appointment',
      currentRoute: '/patient/book-appointment',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDoctors,
                        child: const Text('Retry'),
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
                            Text(
                              '${doctor.rating} (${doctor.reviewCount ?? 0} reviews)',
                              style: const TextStyle(fontSize: 12),
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
            const SizedBox(height: 16),
            const Text(
              'Available Dates & Times:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (availabilities.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No availability at the moment'),
              )
            else
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
                        onPressed: () =>
                            _showBookingDialog(doctor, availability),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightBlue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Book Now'),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(DoctorModel doctor, AvailabilityModel availability) {
    ConsultationType selectedType = ConsultationType.video;
    String selectedTime = availability.startTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Book Appointment with ${doctor.fullName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Date: ${DateFormat('MMMM dd, yyyy').format(availability.date)}'),
                const SizedBox(height: 16),
                const Text('Time:'),
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
                const Text('Consultation Type:'),
                RadioListTile<ConsultationType>(
                  title: const Text('Video'),
                  value: ConsultationType.video,
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                RadioListTile<ConsultationType>(
                  title: const Text('Voice'),
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _bookAppointment(
                  doctorId: doctor.id,
                  doctorName: doctor.fullName,
                  date: availability.date,
                  time: selectedTime,
                  type: selectedType,
                );
              },
              child: const Text('Confirm Booking'),
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
}
