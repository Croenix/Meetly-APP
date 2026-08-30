import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/booking.dart';
import '../../core/models/notification_item.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/message_repository.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  void _updateStatus(BuildContext context, WidgetRef ref, String bookingId, BookingStatus nextStatus, String customerId, String serviceName) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.updateBookingStatus(bookingId, nextStatus);
    
    // Create corresponding notification for the customer
    final messageRepo = ref.read(messageRepositoryProvider);
    final statusLabel = _getStatusActionText(nextStatus);
    final notification = NotificationItem(
      id: const Uuid().v4(),
      userId: customerId,
      title: 'Booking Status Update',
      description: 'Your booking request for "$serviceName" has been updated to: $statusLabel.',
      timestamp: DateTime.now(),
      type: 'booking',
      isRead: false,
    );
    await messageRepo.createNotification(notification);

    // Refresh listings
    ref.invalidate(userBookingsProvider);
    ref.invalidate(bookingDetailsProvider(bookingId));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job progress updated to: $statusLabel')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox();

        // Fetch bookings matching this provider profile
        final bookingsAsync = ref.watch(userBookingsProvider((userId: user.id, role: user.role)));

        return ResponsiveLayoutShell(
          selectedIndex: 0, // Dashboard index for provider
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Provider Workspace'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => context.push('/notifications'),
                ),
              ],
            ),
            body: ResponsiveContainer(
              child: bookingsAsync.when(
                data: (bookings) {
                  // Filter into pending & active
                  final pending = bookings.where((b) => b.status == BookingStatus.pending).toList();
                  
                  final active = bookings
                      .where((b) =>
                          b.status == BookingStatus.accepted ||
                          b.status == BookingStatus.confirmed ||
                          b.status == BookingStatus.onTheWay ||
                          b.status == BookingStatus.inProgress)
                      .toList();

                  final completedCount = bookings.where((b) => b.status == BookingStatus.completed).length;
                  final totalEarnings = bookings
                      .where((b) => b.status == BookingStatus.completed)
                      .fold<double>(0, (sum, item) => sum + item.priceEstimate);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats summary panel
                        _buildStatsGrid(pending.length, active.length, totalEarnings, completedCount, isDark, textTheme),
                        AppSpacing.height32,

                        // Pending Booking Requests
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pending Requests (${pending.length})',
                              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        AppSpacing.height12,
                        
                        if (pending.isEmpty)
                          _buildMiniEmptyState('No pending requests', 'You are all caught up!', Icons.check_circle_outline, isDark, textTheme)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pending.length,
                            separatorBuilder: (context, index) => AppSpacing.height12,
                            itemBuilder: (context, index) {
                              final booking = pending[index];
                              return _buildRequestCard(context, ref, booking, isDark, textTheme);
                            },
                          ),
                        AppSpacing.height32,

                        // Active Jobs tracking list
                        Text(
                          'Active Jobs (${active.length})',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppSpacing.height12,

                        if (active.isEmpty)
                          _buildMiniEmptyState('No active jobs', 'Accept bookings to see tasks here.', Icons.assignment_outlined, isDark, textTheme)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: active.length,
                            separatorBuilder: (context, index) => AppSpacing.height12,
                            itemBuilder: (context, index) {
                              final booking = active[index];
                              return _buildActiveJobCard(context, ref, booking, isDark, textTheme);
                            },
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Error loading workspace',
                  description: e.toString(),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
    );
  }

  Widget _buildStatsGrid(int pending, int active, double earnings, int completed, bool isDark, TextTheme textTheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : constraints.maxWidth > 500 ? 2 : 2;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          children: [
            _buildStatCard('Pending', '$pending', Icons.hourglass_empty, isDark, textTheme),
            _buildStatCard('Active Jobs', '$active', Icons.work_history_outlined, isDark, textTheme),
            _buildStatCard('Completed', '$completed', Icons.task_alt, isDark, textTheme),
            _buildStatCard('Est. Earnings', '₹${earnings.toStringAsFixed(0)}', Icons.currency_rupee, isDark, textTheme),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isDark, TextTheme textTheme) {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            AppSpacing.height8,
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, WidgetRef ref, Booking booking, bool isDark, TextTheme textTheme) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.serviceName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '₹${booking.priceEstimate.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                ),
              ],
            ),
            AppSpacing.height4,
            Text('Client: ${booking.customerName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('Scheduled: ${booking.date} at ${booking.time}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
            if (booking.description.isNotEmpty) ...[
              AppSpacing.height8,
              Text(
                'Notes: "${booking.description}"',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ],
            AppSpacing.height16,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _updateStatus(context, ref, booking.id, BookingStatus.cancelled, booking.customerId, booking.serviceName),
                  style: TextButton.styleFrom(foregroundColor: AppColors.errorLight),
                  child: const Text('Decline'),
                ),
                AppSpacing.width12,
                ElevatedButton(
                  onPressed: () => _updateStatus(context, ref, booking.id, BookingStatus.accepted, booking.customerId, booking.serviceName),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveJobCard(BuildContext context, WidgetRef ref, Booking booking, bool isDark, TextTheme textTheme) {
    // Determine next progress state action details
    BookingStatus? nextStatus;
    String btnText = '';
    IconData btnIcon = Icons.arrow_forward;

    if (booking.status == BookingStatus.accepted) {
      nextStatus = BookingStatus.confirmed;
      btnText = 'Confirm Schedule';
      btnIcon = Icons.calendar_month;
    } else if (booking.status == BookingStatus.confirmed) {
      nextStatus = BookingStatus.onTheWay;
      btnText = 'On the Way';
      btnIcon = Icons.directions_run;
    } else if (booking.status == BookingStatus.onTheWay) {
      nextStatus = BookingStatus.inProgress;
      btnText = 'Start Work';
      btnIcon = Icons.play_arrow;
    } else if (booking.status == BookingStatus.inProgress) {
      nextStatus = BookingStatus.completed;
      btnText = 'Complete Work';
      btnIcon = Icons.check;
    }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Customer: ${booking.customerName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppSpacing.width12,
                StatusBadge.booking(booking.status),
              ],
            ),
            AppSpacing.height12,
            const Divider(),
            AppSpacing.height12,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCHEDULED FOR',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                    Text(
                      '${booking.date} at ${booking.time}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
                // Progress action button
                if (nextStatus != null)
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(context, ref, booking.id, nextStatus!, booking.customerId, booking.serviceName),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    icon: Icon(btnIcon, size: 14),
                    label: Text(btnText, style: const TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniEmptyState(String title, String desc, IconData icon, bool isDark, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
        borderRadius: AppDimensions.borderMedium,
        border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.textSecondaryLight),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(desc, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 11)),
        ],
      ),
    );
  }

  String _getStatusActionText(BookingStatus status) {
    switch (status) {
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.onTheWay:
        return 'On The Way';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Declined/Cancelled';
      default:
        return 'Updated';
    }
  }
}
