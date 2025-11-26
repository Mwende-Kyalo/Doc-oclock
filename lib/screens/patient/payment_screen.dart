import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/appointment_model.dart';
import '../../models/payment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../services/tinypesa_service.dart';
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
  List<PaymentModel> _paymentHistory = [];
  bool _isLoadingPayments = true;
  String? _paymentError;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      _isLoadingPayments = true;
      _paymentError = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final payments =
          await PaymentService.getPaymentHistory(authProvider.user!.id);
      setState(() {
        _paymentHistory = payments;
        _isLoadingPayments = false;
      });
    } catch (e) {
      setState(() {
        _paymentError = e.toString().replaceAll('Exception: ', '');
        _isLoadingPayments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: PatientScaffold(
        title: l10n.payments,
        currentRoute: '/patient/payment',
        body: Column(
          children: [
            TabBar(
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: l10n.paymentHistory),
                Tab(text: l10n.makePayment),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPaymentHistory(),
                  _buildMakePayment(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory() {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoadingPayments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_paymentError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${l10n.error}: $_paymentError'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPaymentHistory,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_paymentHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noPaymentsMadeYet,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.yourPaymentHistoryWillAppear,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPaymentHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _paymentHistory.length,
        itemBuilder: (context, index) {
          final payment = _paymentHistory[index];
          return _buildPaymentCard(payment);
        },
      ),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (payment.status) {
      case PaymentStatus.completed:
        statusColor = AppTheme.successGreen;
        statusIcon = Icons.check_circle;
        statusText = l10n.completed;
        break;
      case PaymentStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = l10n.pending;
        break;
      case PaymentStatus.failed:
        statusColor = AppTheme.errorRed;
        statusIcon = Icons.error;
        statusText = l10n.failed;
        break;
      case PaymentStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
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
                Text(
                  'KES ${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      ? l10n.mpesa
                      : l10n.cardPayment,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(payment.paidAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            if (payment.transactionId != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.transactionId}: ${payment.transactionId}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMakePayment() {
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, child) {
        final l10n = AppLocalizations.of(context)!;
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
                    Text(
                      l10n.paymentAlreadyMade,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.thisAppointmentPaid,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/patient/appointments'),
                      child: Text(l10n.backToAppointments),
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
                  Text(
                    l10n.appointmentNotFound,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/patient/appointments'),
                    child: Text(l10n.backToAppointments),
                  ),
                ],
              ),
            );
          }
        }

        // Show list of unpaid appointments
        return _buildUnpaidAppointmentsList(appointmentProvider);
      },
    );
  }

  Widget _buildUnpaidAppointmentsList(AppointmentProvider appointmentProvider) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final unpaidAppointments = appointmentProvider.appointments
        .where(
            (apt) => apt.patientId == authProvider.user!.id && !apt.paymentMade)
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
            Text(
              l10n.noUnpaidAppointments,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.allAppointmentsPaid,
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
              subtitle: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                          '${l10n.date}: ${DateFormat('MMMM dd, yyyy').format(appointment.appointment_date)}'),
                      Text('${l10n.time}: ${appointment.time}'),
                      Text(
                          '${l10n.consultationMethod}: ${appointment.type == ConsultationType.video ? l10n.video : l10n.voice}'),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.amount}: KES ${appointment.consultationFee.toStringAsFixed(2)}',
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
                        child: Text(
                          l10n.notPaid,
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              trailing: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return ElevatedButton(
                    onPressed: () {
                      context.go(
                          '/patient/payment?appointmentId=${appointment.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                    ),
                    child: Text(l10n.payNow),
                  );
                },
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
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
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
                          _buildDetailRow(
                              l10n.doctorName, appointment.doctorName),
                          _buildDetailRow(
                            l10n.date,
                            DateFormat('MMMM dd, yyyy')
                                .format(appointment.appointment_date),
                          ),
                          _buildDetailRow(l10n.time, appointment.time),
                          _buildDetailRow(
                            l10n.consultationMethod,
                            appointment.type == ConsultationType.video
                                ? l10n.videoCall
                                : l10n.voiceCall,
                          ),
                          const Divider(),
                          _buildDetailRow(
                            l10n.consultationFee,
                            'KES ${appointment.consultationFee.toStringAsFixed(2)}',
                            isBold: true,
                            color: AppTheme.primaryBlue,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.selectPaymentMethod,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: RadioListTile<String>(
                      title: Text(l10n.mpesa),
                      subtitle: Text(l10n.payViaMpesa),
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
                      title: Text(l10n.card),
                      subtitle: Text(l10n.payViaCard),
                      value: 'card',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                _isProcessing ? null : () => _processPayment(appointment),
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
                : Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        l10n.proceedToPayment,
                        style: const TextStyle(fontSize: 18),
                      );
                    },
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
      // Show processing indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      try {
        // Initiate STK Push via TinyPesa
        final result = await TinyPesaService.initiateStkPush(
          phoneNumber: phoneController.text,
          amount: appointment.consultationFee,
          accountReference: appointment.id,
          transactionDesc:
              'Payment for appointment with Dr. ${appointment.doctorName}',
        );

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
        }

        if (result['success'] == true) {
          // Payment request sent successfully
          final checkoutRequestId = result['checkoutRequestId'];
          final l10n = AppLocalizations.of(context);
          final message = result['message'] ??
              (l10n?.pleaseCheckPhoneForMpesa ??
                  'Please check your phone for M-Pesa prompt');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppTheme.successGreen,
                duration: const Duration(seconds: 5),
              ),
            );

            // Poll for payment status (or wait for webhook callback)
            // For now, create payment record as pending
            await PaymentService.createPayment(
              appointmentId: appointment.id,
              patientId: appointment.patientId,
              doctorId: appointment.doctorId,
              amount: appointment.consultationFee,
              paymentMethod: PaymentMethod.mpesa,
              transactionId: checkoutRequestId,
              phoneNumber: phoneController.text,
            );

            // Note: In production, payment status should be updated via webhook callback
            // For now, you can poll or update manually after verification
            // TODO: Implement webhook handler or polling mechanism
          }
        } else {
          // Payment request failed
          if (mounted) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ??
                    (l10n?.paymentRequestFailed ?? 'Payment request failed')),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n?.paymentFailed ?? 'Payment failed'}: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
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
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(l10n.cardPayment);
          },
        ),
        content: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.amount}: KES ${appointment.consultationFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cardController,
                    decoration: InputDecoration(
                      labelText: l10n.cardNumber,
                      hintText: '1234 5678 9012 3456',
                      border: const OutlineInputBorder(),
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
                          decoration: InputDecoration(
                            labelText: '${l10n.expiry} (MM/YY)',
                            hintText: '12/25',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: cvvController,
                          decoration: InputDecoration(
                            labelText: l10n.cvv,
                            hintText: '123',
                            border: const OutlineInputBorder(),
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
            );
          },
        ),
        actions: [
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Column(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (cardController.text.isNotEmpty &&
                          expiryController.text.isNotEmpty &&
                          cvvController.text.isNotEmpty) {
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.pleaseFillCardDetails),
                            backgroundColor: AppTheme.errorRed,
                          ),
                        );
                      }
                    },
                    child: Text(l10n.payNow),
                  ),
                ],
              );
            },
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.paymentSuccessful ?? 'Payment successful!'),
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
