import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/rating_review_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/rating_review_service.dart';
import '../../services/doctor_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/patient_scaffold.dart';

class RatingsReviewsScreen extends StatefulWidget {
  const RatingsReviewsScreen({super.key});

  @override
  State<RatingsReviewsScreen> createState() => _RatingsReviewsScreenState();
}

class _RatingsReviewsScreenState extends State<RatingsReviewsScreen> {
  List<RatingReviewModel> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final patientId = authProvider.user!.id;
      final reviews = await RatingReviewService.getPatientReviews(patientId);
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReview),
        content: Text(l10n.areYouSureDeleteReview),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final patientId = authProvider.user!.id;
        await RatingReviewService.deleteReview(
          reviewId: reviewId,
          patientId: patientId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.reviewDeleted),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          _loadReviews();
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PatientScaffold(
      title: l10n.myReviews,
      currentRoute: '/patient/ratings-reviews',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${l10n.error}: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReviews,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReviews,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.myReviews,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                // Show dialog to select doctor
                                final doctors = await DoctorService.getDoctors();
                                if (mounted && doctors.isNotEmpty) {
                                  final selectedDoctor = await showDialog<Map<String, String>>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Select Doctor'),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: doctors.length,
                                          itemBuilder: (context, index) {
                                            final doctor = doctors[index];
                                            return ListTile(
                                              title: Text(doctor.fullName),
                                              subtitle: Text(doctor.specialization ?? ''),
                                              onTap: () => Navigator.pop(context, {
                                                'id': doctor.id,
                                                'name': doctor.fullName,
                                              }),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                  if (selectedDoctor != null && mounted) {
                                    context.push(
                                      '/patient/rate-doctor?doctorId=${selectedDoctor['id']}&doctorName=${Uri.encodeComponent(selectedDoctor['name']!)}',
                                    ).then((_) => _loadReviews());
                                  }
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Review'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_reviews.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.rate_review_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.noReviewsYet,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._reviews.map((review) => _buildReviewCard(review, l10n)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildReviewCard(RatingReviewModel review, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doctor ID: ${review.doctorId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.edit),
                        ],
                      ),
                      onTap: () async {
                        // Navigate to edit review
                        await Future.delayed(const Duration(milliseconds: 100));
                        if (mounted) {
                          context.push(
                            '/patient/rate-doctor?doctorId=${review.doctorId}&reviewId=${review.id}',
                          ).then((_) => _loadReviews());
                        }
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: AppTheme.errorRed),
                          const SizedBox(width: 8),
                          Text(l10n.delete, style: const TextStyle(color: AppTheme.errorRed)),
                        ],
                      ),
                      onTap: () {
                        _deleteReview(review.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
            if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.reviewText!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              DateFormat('MMMM dd, yyyy').format(review.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

