import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../models/call_history_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/doctor_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../../services/call_history_service.dart';

class DoctorHistoryScreen extends StatefulWidget {
  const DoctorHistoryScreen({super.key});

  @override
  State<DoctorHistoryScreen> createState() => _DoctorHistoryScreenState();
}

class _DoctorHistoryScreenState extends State<DoctorHistoryScreen> {
  bool _isLoading = true;
  List<CallHistoryModel> _callHistory = [];

  @override
  void initState() {
    super.initState();
    // Initialize mock data
    CallHistoryService.initializeMockData();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);

      // Load appointments
      await appointmentProvider.loadAppointments(
        authProvider.user!.id,
        isDoctor: true,
      );

      // Load call history
      final callHistory = await CallHistoryService.getCallHistory(
        authProvider.user!.id,
        isDoctor: true,
      );

      setState(() {
        _callHistory = callHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<AppointmentModel> get _pastAppointments {
    final appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final now = DateTime.now();

    return appointmentProvider.appointments
        .where((apt) => apt.doctorId == authProvider.user!.id)
        .where((apt) {
      // Filter for completed or past appointments
      // Safely parse time string
      int hour = 0;
      int minute = 0;
      if (apt.time.isNotEmpty) {
        final timeParts = apt.time.split(':');
        if (timeParts.length >= 2) {
          hour = int.tryParse(timeParts[0]) ?? 0;
          minute = int.tryParse(timeParts[1]) ?? 0;
        } else if (timeParts.length == 1) {
          hour = int.tryParse(timeParts[0]) ?? 0;
        }
      }

      final appointmentDateTime = DateTime(
        apt.appointment_date.year,
        apt.appointment_date.month,
        apt.appointment_date.day,
        hour,
        minute,
      );
      return appointmentDateTime.isBefore(now) ||
          apt.status == AppointmentStatus.completed ||
          apt.status == AppointmentStatus.cancelled;
    }).toList()
      ..sort((a, b) {
        // Sort by date, most recent first
        final dateCompare = b.appointment_date.compareTo(a.appointment_date);
        if (dateCompare != 0) return dateCompare;
        return b.time.compareTo(a.time);
      });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: DoctorScaffold(
        title: l10n.history,
        currentRoute: '/doctor/history',
        body: Column(
          children: [
            TabBar(
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryBlue,
              tabs: [
                Tab(
                  text: l10n.pastAppointments,
                  icon: const Icon(Icons.event_note),
                ),
                Tab(
                  text: l10n.pastCalls,
                  icon: const Icon(Icons.call),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPastAppointmentsTab(),
                  _buildPastCallsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastAppointmentsTab() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pastAppointments = _pastAppointments;

    if (pastAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noPastAppointments,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pastAppointmentsWillAppearHere,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pastAppointments.length,
        itemBuilder: (context, index) {
          final appointment = pastAppointments[index];
          return _buildPastAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildPastCallsTab() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_callHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noPastCalls,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pastCallsWillAppearHere,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _callHistory.length,
        itemBuilder: (context, index) {
          final call = _callHistory[index];
          return _buildPastCallCard(call);
        },
      ),
    );
  }

  Widget _buildPastAppointmentCard(AppointmentModel appointment) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (appointment.status) {
      case AppointmentStatus.completed:
        statusColor = AppTheme.successGreen;
        statusIcon = Icons.check_circle;
        statusText = l10n.completed;
        break;
      case AppointmentStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
        statusText = l10n.cancelled;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = l10n.past;
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
                                  ? 'Video Call'
                                  : 'Voice Call',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMMM dd, yyyy')
                        .format(appointment.appointment_date),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    appointment.time,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              if (appointment.paymentMade) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.payment,
                        size: 16, color: AppTheme.successGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Paid: KES ${appointment.consultationFee.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPastCallCard(CallHistoryModel call) {
    final l10n = AppLocalizations.of(context)!;

    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = duration.inHours;
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      if (hours > 0) {
        return '${twoDigits(hours)}:$minutes:$seconds';
      }
      return '$minutes:$seconds';
    }

    Color statusColor;
    String statusText;
    switch (call.status) {
      case CallStatus.completed:
        statusColor = AppTheme.successGreen;
        statusText = l10n.completed;
        break;
      case CallStatus.missed:
        statusColor = Colors.orange;
        statusText = 'Missed';
        break;
      case CallStatus.cancelled:
        statusColor = Colors.grey;
        statusText = l10n.cancelled;
        break;
    }

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
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: call.type == CallType.video
                              ? AppTheme.primaryBlue
                              : AppTheme.lightBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          call.type == CallType.video
                              ? Icons.video_call
                              : Icons.phone,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              call.patientName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  call.type == CallType.video
                                      ? Icons.video_call
                                      : Icons.phone,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  call.type == CallType.video
                                      ? 'Video Call'
                                      : 'Voice Call',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (call.isIncoming) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.call_received,
                                      size: 14, color: Colors.grey[600]),
                                ] else ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.call_made,
                                      size: 14, color: Colors.grey[600]),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM dd, yyyy').format(call.startTime),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(call.startTime),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  formatDuration(call.duration),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
