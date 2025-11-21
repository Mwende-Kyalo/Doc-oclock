import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/patient_scaffold.dart';
class PaymentScreen extends StatefulWidget {
  final String? appointmentId;

  const PaymentScreen({
    super.key,
    this.appointmentId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'mpesa'; // 'mpesa' or 'card'
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return PatientScaffold(
      title: 'Make Payment',
      currentRoute: '/patient/payment',
      body: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          // If appointmentId is provided, show payment for that specific appointment
          if (widget.appointmentId != null) {
            try {
              final appointment = appointmentProvider.appointments.firstWhere(
                (apt) => apt.id == widget.appointmentId,
              );

              if (appointment.paymentMade) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: AppTheme.successGreen,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Payment Already Made',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This appointment has already been paid for.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/patient/appointments'),
                        child: const Text('Back to Appointments'),
                      ),
                    ],
                  ),
                );
              }

              return _buildPaymentForm(appointment);
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
                      onPressed: () => context.go('/patient/appointments'),
                      child: const Text('Back to Appointments'),
                    ),
                  ],
                ),
              );
            }
          }

          // Show list of unpaid appointments
          return _buildUnpaidAppointmentsList(appointmentProvider);
        },
      ),
    );
  }

  Widget _buildUnpaidAppointmentsList(AppointmentProvider appointmentProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final unpaidAppointments = appointmentProvider.appointments
        .where((apt) =>
            apt.patientId == authProvider.user!.id && !apt.paymentMade)
        .toList();

    if (appointmentProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (unpaidAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Unpaid Appointments',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'All your appointments have been paid for.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await appointmentProvider.loadAppointments(
          authProvider.user!.id,
          isDoctor: false,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: unpaidAppointments.length,
        itemBuilder: (context, index) {
          final appointment = unpaidAppointments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                'Dr. ${appointment.doctorName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${DateFormat('MMMM dd, yyyy').format(appointment.date)}',
                  ),
                  Text('Time: ${appointment.time}'),
                  Text(
                    'Type: ${appointment.type == ConsultationType.video ? 'Video' : 'Voice'}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amount: KES ${appointment.consultationFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Not Paid',
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  context.go('/patient/payment?appointmentId=${appointment.id}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                ),
                child: const Text('Pay Now'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentForm(AppointmentModel appointment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Doctor', appointment.doctorName),
                  _buildDetailRow(
                    'Date',
                    DateFormat('MMMM dd, yyyy').format(appointment.date),
                  ),
                  _buildDetailRow('Time', appointment.time),
                  _buildDetailRow(
                    'Type',
                    appointment.type == ConsultationType.video
                        ? 'Video Call'
                        : 'Voice Call',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Consultation Fee',
                    'KES ${appointment.consultationFee.toStringAsFixed(2)}',
                    isBold: true,
                    color: AppTheme.primaryBlue,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: RadioListTile<String>(
              title: const Text('M-Pesa'),
              subtitle: const Text('Pay via M-Pesa mobile money'),
              value: 'mpesa',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              title: const Text('Card'),
              subtitle: const Text('Pay via debit/credit card'),
              value: 'card',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isProcessing ? null : () => _processPayment(appointment),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Proceed to Payment',
                    style: TextStyle(fontSize: 18),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(AppointmentModel appointment) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Show payment method specific dialog
      if (_selectedPaymentMethod == 'mpesa') {
        await _showMpesaPaymentDialog(appointment);
      } else {
        await _showCardPaymentDialog(appointment);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _showMpesaPaymentDialog(AppointmentModel appointment) async {
    final phoneController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('M-Pesa Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Amount: KES ${appointment.consultationFee.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'M-Pesa Phone Number',
                hintText: '07XXXXXXXX',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            const SizedBox(height: 8),
            const Text(
              'You will receive an M-Pesa prompt to enter your PIN.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.length == 10) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid phone number'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Integrate with M-Pesa API
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final success = await appointmentProvider.markPaymentMade(appointment.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        await appointmentProvider.loadAppointments(
          Provider.of<AuthProvider>(context, listen: false).user!.id,
          isDoctor: false,
        );
        if (mounted) {
          context.go('/patient/appointments');
        }
      }
    }
  }

  Future<void> _showCardPaymentDialog(AppointmentModel appointment) async {
    final cardController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Card Payment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Amount: KES ${appointment.consultationFee.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cardController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 19,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        hintText: '12/25',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (cardController.text.isNotEmpty &&
                  expiryController.text.isNotEmpty &&
                  cvvController.text.isNotEmpty) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all card details'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Integrate with card payment API (e.g., Stripe, Paystack)
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      final appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      final success = await appointmentProvider.markPaymentMade(appointment.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        await appointmentProvider.loadAppointments(
          Provider.of<AuthProvider>(context, listen: false).user!.id,
          isDoctor: false,
        );
        if (mounted) {
          context.go('/patient/appointments');
        }
      }
    }
  }
}

