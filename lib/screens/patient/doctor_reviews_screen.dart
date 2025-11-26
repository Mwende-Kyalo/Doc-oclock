import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/rating_review_model.dart';
import '../../services/rating_review_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/patient_scaffold.dart';

class DoctorReviewsScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const DoctorReviewsScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<DoctorReviewsScreen> createState() => _DoctorReviewsScreenState();
}

class _DoctorReviewsScreenState extends State<DoctorReviewsScreen> {
  List<RatingReviewModel> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;
  DoctorRatingSummary? _ratingSummary;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _loadRatingSummary();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reviews =
          await RatingReviewService.getDoctorReviews(widget.doctorId);
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

  Future<void> _loadRatingSummary() async {
    try {
      final summary =
          await RatingReviewService.getDoctorRatingSummary(widget.doctorId);
      if (mounted) {
        setState(() {
          _ratingSummary = summary;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PatientScaffold(
      title: '${l10n.patientReviews} - ${widget.doctorName}',
      currentRoute: '/patient/reviews',
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
                        if (_ratingSummary != null) _buildRatingSummary(l10n),
                        const SizedBox(height: 24),
                        Text(
                          l10n.patientReviews,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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
                          ..._reviews
                              .map((review) => _buildReviewCard(review, l10n)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildRatingSummary(AppLocalizations l10n) {
    if (_ratingSummary == null) return const SizedBox.shrink();

    return Card(
      color: AppTheme.primaryBlue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 48),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ratingSummary!.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_ratingSummary!.totalReviews} ${l10n.totalReviews}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStarBreakdown(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildStarBreakdown(AppLocalizations l10n) {
    final total = _ratingSummary!.totalReviews;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      children: [
        _buildStarBar(5, _ratingSummary!.fiveStar, total, l10n),
        _buildStarBar(4, _ratingSummary!.fourStar, total, l10n),
        _buildStarBar(3, _ratingSummary!.threeStar, total, l10n),
        _buildStarBar(2, _ratingSummary!.twoStar, total, l10n),
        _buildStarBar(1, _ratingSummary!.oneStar, total, l10n),
      ],
    );
  }

  Widget _buildStarBar(int stars, int count, int total, AppLocalizations l10n) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$stars ${l10n.rating}:'),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                stars >= 4
                    ? Colors.green
                    : stars >= 3
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count'),
        ],
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
                CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue,
                  child: Text(
                    (review.isAnonymous
                        ? 'A'
                        : (review.patientName ?? 'P')[0].toUpperCase()),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.isAnonymous
                            ? l10n.anonymous
                            : review.patientName ?? l10n.patient,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (review.isVerified)
                        Text(
                          l10n.verifiedPatient,
                          style: const TextStyle(
                            color: AppTheme.successGreen,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
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
