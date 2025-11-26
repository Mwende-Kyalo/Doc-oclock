import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/rating_review_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/rating_review_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/patient_scaffold.dart';

class RateDoctorScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String? appointmentId;

  const RateDoctorScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    this.appointmentId,
  });

  @override
  State<RateDoctorScreen> createState() => _RateDoctorScreenState();
}

class _RateDoctorScreenState extends State<RateDoctorScreen> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  RatingReviewModel? _existingReview;

  @override
  void initState() {
    super.initState();
    if (widget.appointmentId != null) {
      _loadExistingReview();
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingReview() async {
    try {
      final review = await RatingReviewService.getReviewByAppointment(
        widget.appointmentId!,
      );
      if (review != null && mounted) {
        setState(() {
          _existingReview = review;
          _selectedRating = review.rating;
          _reviewController.text = review.reviewText ?? '';
          _isAnonymous = review.isAnonymous;
        });
      }
    } catch (e) {
      // Review doesn't exist yet, that's fine
    }
  }

  Future<void> _submitReview() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectRating),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final patientId = authProvider.user!.id;

      if (_existingReview != null) {
        // Update existing review
        await RatingReviewService.updateReview(
          reviewId: _existingReview!.id,
          patientId: patientId,
          rating: _selectedRating,
          reviewText: _reviewController.text.trim().isEmpty 
              ? null 
              : _reviewController.text.trim(),
          isAnonymous: _isAnonymous,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.reviewUpdated),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          context.pop(true); // Return true to indicate update
        }
      } else {
        // Create new review
        await RatingReviewService.createReview(
          doctorId: widget.doctorId,
          patientId: patientId,
          rating: _selectedRating,
          reviewText: _reviewController.text.trim().isEmpty 
              ? null 
              : _reviewController.text.trim(),
          appointmentId: widget.appointmentId,
          isAnonymous: _isAnonymous,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.reviewSubmitted),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          context.pop(true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PatientScaffold(
      title: l10n.rateDoctor,
      currentRoute: '/patient/rate-doctor',
      body: SingleChildScrollView(
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
                      '${l10n.rateDoctor}: ${widget.doctorName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.appointmentId != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.verifiedPatient,
                        style: const TextStyle(
                          color: AppTheme.successGreen,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.yourRating,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final rating = index + 1;
                return IconButton(
                  iconSize: 48,
                  icon: Icon(
                    rating <= _selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    color: rating <= _selectedRating
                        ? Colors.amber
                        : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = rating;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.writeReview,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: l10n.reviewTextPlaceholder,
                border: const OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: Text(l10n.anonymous),
              subtitle: const Text('Your name will be hidden'),
              value: _isAnonymous,
              onChanged: (value) {
                setState(() {
                  _isAnonymous = value ?? false;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _existingReview != null 
                            ? l10n.updateReview 
                            : l10n.submitReview,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

