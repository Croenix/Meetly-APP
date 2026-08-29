import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/booking.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';

class BookingsHistoryScreen extends ConsumerWidget {
  const BookingsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox();

        // Read bookings list reactively
        final bookingsAsync = ref.watch(userBookingsProvider((userId: user.id, role: user.role)));

        return ResponsiveLayoutShell(
          selectedIndex: 1, // Bookings index
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('My Bookings'),
                bottom: TabBar(
                  labelColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  indicatorColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  tabs: const [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Completed'),
                    Tab(text: 'Cancelled'),
                  ],
                ),
              ),
              body: ResponsiveContainer(
                usePadding: false,
                child: bookingsAsync.when(
                  data: (bookings) {
                    // Filter bookings into categories
                    final upcoming = bookings
                        .where((b) =>
                            b.status == BookingStatus.pending ||
                            b.status == BookingStatus.accepted ||
                            b.status == BookingStatus.confirmed ||
                            b.status == BookingStatus.onTheWay ||
                            b.status == BookingStatus.inProgress)
                        .toList();

                    final completed = bookings.where((b) => b.status == BookingStatus.completed).toList();
                    final cancelled = bookings.where((b) => b.status == BookingStatus.cancelled).toList();

                    return TabBarView(
                      children: [
                        // 1. Upcoming Tab
                        _buildBookingsList(
                          context,
                          upcoming,
                          'No upcoming bookings',
                          'Find a trusted professional for your next task or check back later.',
                          isDark,
                          textTheme,
                        ),
                        
                        // 2. Completed Tab
                        _buildBookingsList(
                          context,
                          completed,
                          'No completed jobs yet',
                          'Your completed bookings and service histories will appear here.',
                          isDark,
                          textTheme,
                        ),
                        
                        // 3. Cancelled Tab
                        _buildBookingsList(
                          context,
                          cancelled,
                          'No cancelled bookings',
                          'Cancelled bookings will be listed here.',
                          isDark,
                          textTheme,
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EmptyState(
                    icon: Icons.error_outline,
                    title: 'Error loading bookings',
                    description: e.toString(),
                  ),
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

  Widget _buildBookingsList(
    BuildContext context,
    List<Booking> list,
    String emptyTitle,
    String emptyDesc,
    bool isDark,
    TextTheme textTheme,
  ) {
    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: emptyTitle,
        description: emptyDesc,
        actionText: 'Find a Service',
        onActionPressed: () {
          context.go('/home');
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, index) => AppSpacing.height16,
      itemBuilder: (context, index) {
        final booking = list[index];
        return Card(
          elevation: 1,
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
                    Text(
                      booking.serviceName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    StatusBadge.booking(booking.status),
                  ],
                ),
                AppSpacing.height4,
                Text(
                  'Professional: ${booking.providerName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
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
                          'SCHEDULE',
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        Text(
                          '${booking.date} • ${booking.time}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/booking/${booking.id}');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.borderSmall,
                        ),
                      ),
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
