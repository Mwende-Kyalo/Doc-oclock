import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../models/payment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/doctor_scaffold.dart';

class DoctorPaymentScreen extends StatefulWidget {
  const DoctorPaymentScreen({super.key});

  @override
  State<DoctorPaymentScreen> createState() => _DoctorPaymentScreenState();
}

class _DoctorPaymentScreenState extends State<DoctorPaymentScreen> {
  List<PaymentModel> _payments = [];
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _filterStatus = 'all'; // 'all', 'paid', 'unpaid', 'pending', 'failed'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);

      // Load appointments and payments in parallel
      final futures = await Future.wait([
        appointmentProvider.loadAppointments(authProvider.user!.id, isDoctor: true),
        PaymentService.getPaymentHistory(authProvider.user!.id, isDoctor: true),
      ]);

      setState(() {
        _appointments = appointmentProvider.appointments;
        _payments = futures[1] as List<PaymentModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<PaymentModel> get _filteredPayments {
    switch (_filterStatus) {
      case 'paid':
        return _payments.where((p) => p.status == PaymentStatus.completed).toList();
      case 'unpaid':
        final paidAppointmentIds = _payments
            .where((p) => p.status == PaymentStatus.completed)
            .map((p) => p.appointmentId)
            .toSet();
        final unpaidAppointments = _appointments
            .where((apt) => !paidAppointmentIds.contains(apt.id))
            .map((apt) => apt.id)
            .toSet();
        return _payments
            .where((p) => unpaidAppointments.contains(p.appointmentId))
            .toList();
      case 'pending':
        return _payments.where((p) => p.status == PaymentStatus.pending).toList();
      case 'failed':
        return _payments.where((p) => p.status == PaymentStatus.failed).toList();
      default:
        return _payments;
    }
  }

  Map<String, dynamic> _getAppointmentForPayment(PaymentModel payment) {
    try {
      final appointment = _appointments.firstWhere(
        (apt) => apt.id == payment.appointmentId,
      );
      return {
        'appointment': appointment,
        'found': true,
      };
    } catch (e) {
      return {
        'appointment': null,
        'found': false,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoctorScaffold(
      title: 'Payments',
      currentRoute: '/doctor/payments',
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Paid', 'paid'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Unpaid', 'unpaid'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Failed', 'failed'),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $_errorMessage'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredPayments.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredPayments.length,
                              itemBuilder: (context, index) {
                                final payment = _filteredPayments[index];
                                final appointmentData = _getAppointmentForPayment(payment);
                                return _buildPaymentCard(payment, appointmentData);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterStatus = value;
          });
        }
      },
      selectedColor: AppTheme.lightBlue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_filterStatus) {
      case 'paid':
        message = 'No completed payments yet';
        icon = Icons.payment;
        break;
      case 'unpaid':
        message = 'No unpaid payments found';
        icon = Icons.payment_outlined;
        break;
      case 'pending':
        message = 'No pending payments';
        icon = Icons.pending;
        break;
      case 'failed':
        message = 'No failed payments';
        icon = Icons.error_outline;
        break;
      default:
        message = 'No payments found';
        icon = Icons.payment;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment, Map<String, dynamic> appointmentData) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (payment.status) {
      case PaymentStatus.completed:
        statusColor = AppTheme.successGreen;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case PaymentStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      case PaymentStatus.failed:
        statusColor = AppTheme.errorRed;
        statusIcon = Icons.error;
        statusText = 'Failed';
        break;
      case PaymentStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
    }

    final appointment = appointmentData['appointment'] as AppointmentModel?;
    final appointmentFound = appointmentData['found'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with amount and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KES ${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            const SizedBox(height: 12),
            // Appointment details
            if (appointmentFound && appointment != null) ...[
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    appointment.patientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(appointment.appointment_date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    appointment.time,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Appointment ID: ${payment.appointmentId}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
            const Divider(height: 24),
            // Payment method and date
            Row(
              children: [
                Icon(
                  payment.paymentMethod == PaymentMethod.mpesa
                      ? Icons.phone_android
                      : Icons.credit_card,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  payment.paymentMethod == PaymentMethod.mpesa
                      ? 'M-Pesa'
                      : 'Card Payment',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(payment.paidAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            if (payment.transactionId != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Transaction ID: ${payment.transactionId}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

