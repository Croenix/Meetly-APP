import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/service_item.dart';

class ServiceCard extends StatelessWidget {
  final ServiceItem service;
  final String providerName;
  final bool showBookButton;

  const ServiceCard({
    super.key,
    required this.service,
    required this.providerName,
    this.showBookButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderMedium,
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name & Price Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.name,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                AppSpacing.width12,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${service.price.toStringAsFixed(0)}',
                      style: textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      service.priceType == 'hourly' ? '/ hr' : 'fixed',
                      style: textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            AppSpacing.height8,
            
            // Description
            Text(
              service.description,
              style: textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
            
            AppSpacing.height16,
            
            // Bottom stats and CTA row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Duration & info
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.textSecondaryLight),
                    AppSpacing.width4,
                    Text(
                      service.duration,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                
                // Book Button
                if (showBookButton)
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to booking creation flow with service ID
                      context.push(
                        '/booking/create',
                        extra: {
                          'providerId': service.providerId,
                          'providerName': providerName,
                          'serviceId': service.id,
                          'serviceName': service.name,
                          'price': service.price,
                          'priceType': service.priceType,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      textStyle: textTheme.labelLarge?.copyWith(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderSmall,
                      ),
                    ),
                    child: const Text('Book'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
