import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/models/service_provider.dart';
import '../../data/repositories/provider_repository.dart';

class ProviderCard extends ConsumerWidget {
  final ServiceProvider provider;

  const ProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    // Watch the favorite status of this provider
    final favListAsync = ref.watch(favoritesListProvider);
    final isFav = favListAsync.when(
      data: (list) => list.any((p) => p.id == provider.id),
      loading: () => false,
      error: (_, _) => false,
    );

    final hasImage = provider.portfolioImages.isNotEmpty;
    final imageUrl = hasImage
        ? provider.portfolioImages.first
        : 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600&auto=format&fit=crop';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Portfolio Image with Floating Fav Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 110,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, e, s) => Container(
                      width: 110,
                      height: 140,
                      color: Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.1),
                      child: const Icon(Icons.broken_image_outlined, size: 28),
                    ),
                  ),
                ),
                // Floating Fav Button
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav
                            ? AppColors.errorLight
                            : AppColors.textSecondaryLight,
                        size: 18,
                      ),
                      onPressed: () async {
                        await ref
                            .read(providerRepositoryProvider)
                            .toggleFavorite(provider.id);
                        ref.invalidate(favoritesListProvider);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Right: Details
            Expanded(
              child: SizedBox(
                height: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Tag
                        Text(
                          provider.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Business Name
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider.businessName,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: -0.2,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (provider.verified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: AppColors.accentLight,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Rating & Reviews
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.warningLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${provider.reviewCount} reviews)',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Location / Distance
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${provider.location} • ${provider.distance.toStringAsFixed(1)} km away',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Price and Action Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Starting Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'STARTING FROM',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                            ),
                            Text(
                              '₹${provider.startingPrice.toStringAsFixed(0)}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.secondaryDark
                                    : AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // CTA Action
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/provider/${provider.id}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF0D9488,
                              ), // Teal primary action
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Request Quote',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
