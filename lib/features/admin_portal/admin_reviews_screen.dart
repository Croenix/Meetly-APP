import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/provider_repository.dart';
import '../../data/repositories/review_repository.dart';

class AdminReviewsScreen extends ConsumerWidget {
  const AdminReviewsScreen({super.key});

  void _deleteReview(BuildContext context, WidgetRef ref, String reviewId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Review?'),
          content: const Text(
            'Are you sure you want to permanently remove this review? This will also affect the provider\'s overall star rating.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final repo = ref.read(reviewRepositoryProvider);
                await repo.deleteReview(reviewId);
                
                // Refresh list
                ref.invalidate(allReviewsProvider);
                ref.invalidate(providersListProvider); // refresh ratings

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review moderated and removed.')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.errorLight),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final reviewsAsync = ref.watch(allReviewsProvider);
    final providersAsync = ref.watch(providersListProvider);

    return ResponsiveLayoutShell(
      selectedIndex: 4, // Admin Reviews Tab Index
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review & Spam Moderation'),
        ),
        body: ResponsiveContainer(
          child: reviewsAsync.when(
            data: (reviews) {
              return providersAsync.when(
                data: (providers) {
                  if (reviews.isEmpty) {
                    return const EmptyState(
                      icon: Icons.rate_review_outlined,
                      title: 'No reviews to moderate',
                      description: 'Platform service reviews will appear here for audit.',
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Service Reviews (${reviews.length})',
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacing.height16,

                      Expanded(
                        child: ListView.separated(
                          itemCount: reviews.length,
                          separatorBuilder: (context, index) => AppSpacing.height16,
                          itemBuilder: (context, index) {
                            final r = reviews[index];
                            
                            // Find target provider business details
                            final providerName = providers
                                .firstWhere((p) => p.id == r.providerId,
                                    orElse: () => providers.first)
                                .businessName;

                            return Card(
                              elevation: 0.5,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppDimensions.borderMedium,
                                side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: Author & Star rating
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              r.customerName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            Text(
                                              'Left for: $providerName',
                                              style: const TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: List.generate(5, (starIdx) {
                                            return Icon(
                                              starIdx < r.rating ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                              size: 14,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    AppSpacing.height12,

                                    // Review Comment
                                    Text(
                                      r.comment,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    AppSpacing.height16,

                                    // Action footer
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Date: ${r.date}',
                                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => _deleteReview(context, ref, r.id),
                                          icon: const Icon(Icons.delete_outline, size: 14),
                                          label: const Text('Delete / Moderated', style: TextStyle(fontSize: 11)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.errorLight,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            minimumSize: Size.zero,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Error loading providers', description: e.toString()),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Error loading reviews', description: e.toString()),
          ),
        ),
      ),
    );
  }
}
