import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/app_user.dart';
import '../../core/models/booking.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  void _handleCancelBooking(BuildContext context, WidgetRef ref, Booking booking) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Booking?'),
          content: const Text(
            'Are you sure you want to cancel this booking request? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No, keep it'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                final repo = ref.read(bookingRepositoryProvider);
                await repo.updateBookingStatus(booking.id, BookingStatus.cancelled);
                
                // Refresh listings
                ref.invalidate(bookingDetailsProvider(booking.id));
                ref.invalidate(userBookingsProvider);

                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking request cancelled successfully.')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.errorLight),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailsProvider(bookingId));
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return authState.when(
      data: (currentUser) {
        if (currentUser == null) return const SizedBox();

        final navigationIndex = currentUser.role == UserRole.provider ? 1 : 1; // Maps to bookings tab in shell

        return ResponsiveLayoutShell(
          selectedIndex: navigationIndex,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Booking Details'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (currentUser.role == UserRole.provider) {
                    context.go('/provider/bookings');
                  } else {
                    context.go('/bookings');
                  }
                },
              ),
            ),
            body: ResponsiveContainer(
              child: bookingAsync.when(
                data: (booking) {
                  if (booking == null) {
                    return const EmptyState(
                      icon: Icons.error_outline,
                      title: 'Booking not found',
                      description: 'This booking reference could not be located in our offline records.',
                    );
                  }

                  final isUpcoming = booking.status == BookingStatus.pending ||
                      booking.status == BookingStatus.accepted ||
                      booking.status == BookingStatus.confirmed ||
                      booking.status == BookingStatus.onTheWay ||
                      booking.status == BookingStatus.inProgress;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card with summary details (Status badge, price)
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          booking.serviceName,
                                          style: textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                        ),
                                        Text(
                                          'with ${booking.providerName}',
                                          style: textTheme.bodyMedium?.copyWith(
                                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                              ),
                                        ),
                                      ],
                                    ),
                                    StatusBadge.booking(booking.status),
                                  ],
                                ),
                                AppSpacing.height16,
                                const Divider(),
                                AppSpacing.height16,

                                // Detail Fields
                                _buildDetailItem(Icons.calendar_today_outlined, 'Schedule', '${booking.date} at ${booking.time}'),
                                _buildDetailItem(Icons.location_on_outlined, 'Address', booking.location),
                                _buildDetailItem(Icons.phone_outlined, 'Contact Mobile', booking.customerPhone),
                                _buildDetailItem(Icons.payments_outlined, 'Price Estimate', '₹${booking.priceEstimate.toStringAsFixed(0)}'),
                                if (booking.description.isNotEmpty)
                                  _buildDetailItem(Icons.notes_outlined, 'Requirements', booking.description),
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.height24,

                        // Status Tracking Timeline Header
                        Text(
                          'Job Progress Tracker',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppSpacing.height16,

                        // Vertical Timeline Widget
                        Card(
                          elevation: 0,
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.borderMedium,
                            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: booking.statusTimeline.length,
                              itemBuilder: (context, index) {
                                final isLast = index == booking.statusTimeline.length - 1;
                                final item = booking.statusTimeline[index];
                                final statusVal = BookingStatus.values.firstWhere((e) => e.name == item['status']);
                                final statusLabel = _getStatusLabel(statusVal);
                                final time = item['time'] ?? '';

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Bullet with line underneath
                                    Column(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: isLast ? AppColors.primaryLight : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        if (!isLast)
                                          Container(
                                            width: 2,
                                            height: 40,
                                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                          ),
                                      ],
                                    ),
                                    AppSpacing.width16,
                                    // Text status info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            statusLabel,
                                            style: TextStyle(
                                              fontWeight: isLast ? FontWeight.bold : FontWeight.w600,
                                              fontSize: 13,
                                              color: isLast ? (isDark ? AppColors.primaryDark : AppColors.primaryLight) : null,
                                            ),
                                          ),
                                          Text(
                                            time,
                                            style: textTheme.bodySmall?.copyWith(
                                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        AppSpacing.height32,

                        // Action Buttons bottom
                        Row(
                          children: [
                            // Chat shortcut
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Navigate to chat
                                  final partnerId = currentUser.role == UserRole.provider
                                      ? booking.customerId
                                      : booking.providerId;
                                  final partnerName = currentUser.role == UserRole.provider
                                      ? booking.customerName
                                      : booking.providerName;

                                  // Convert to user ID matching messaging (provider c_ vs p_)
                                  final partnerUserId = currentUser.role == UserRole.provider
                                      ? partnerId
                                      : partnerId.replaceAll('p', 'up');

                                  context.push(
                                    '/messages/$partnerUserId',
                                    extra: {
                                      'currentUserId': currentUser.id,
                                      'partnerId': partnerUserId,
                                      'partnerName': partnerName,
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Contact Partner'),
                              ),
                            ),
                            
                            // Cancellation trigger
                            if (isUpcoming && currentUser.role != UserRole.provider) ...[
                              AppSpacing.width12,
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleCancelBooking(context, ref, booking),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.errorLight,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 50),
                                  ),
                                  icon: const Icon(Icons.cancel_outlined),
                                  label: const Text('Cancel Booking'),
                                ),
                              ),
                            ],
                          ],
                        ),
                        AppSpacing.height24,
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading booking: $e')),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryLight),
          AppSpacing.width12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight, letterSpacing: 0.5),
                ),
                AppSpacing.height4,
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Booking request received by provider';
      case BookingStatus.accepted:
        return 'Request accepted. Slots allocated';
      case BookingStatus.confirmed:
        return 'Service appointment scheduled';
      case BookingStatus.onTheWay:
        return 'Provider is heading to your address';
      case BookingStatus.inProgress:
        return 'Work started at location';
      case BookingStatus.completed:
        return 'Service completed. Invoice settled';
      case BookingStatus.cancelled:
        return 'Booking request cancelled';
    }
  }
}
