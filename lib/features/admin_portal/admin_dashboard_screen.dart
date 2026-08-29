import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/booking.dart';
import '../../core/models/app_user.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/provider_repository.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    // Load platform data
    final providersAsync = ref.watch(providersListProvider);
    final bookingsAsync = ref.watch(userBookingsProvider((userId: 'admin', role: UserRole.admin)));

    return ResponsiveLayoutShell(
      selectedIndex: 0, // Admin Overview Tab Index
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Operations Control'),
        ),
        body: ResponsiveContainer(
          child: providersAsync.when(
            data: (providers) {
              return bookingsAsync.when(
                data: (bookings) {
                  // Calculate statistics
                  final totalPros = providers.length;
                  final verifiedPros = providers.where((p) => p.verificationStatus == 'verified').length;
                  final pendingVetting = providers.where((p) => p.verificationStatus == 'under_review').length;
                  
                  final totalBookings = bookings.length;
                  final completedBookings = bookings.where((b) => b.status == BookingStatus.completed).length;
                  final totalValue = bookings.fold<double>(0, (sum, b) => sum + b.priceEstimate);
                  
                  // Platform revenue (10% commission on booking values)
                  final platformCommission = totalValue * 0.10;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Performance Overview',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppSpacing.height16,

                        // Stats Grid
                        _buildStatsGrid(totalPros, pendingVetting, totalBookings, platformCommission, isDark, textTheme),
                        AppSpacing.height32,

                        // Operations Shortcuts
                        Text(
                          'Operations Center Shortcuts',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppSpacing.height12,

                        _buildShortcutsGrid(context, pendingVetting, isDark),
                        AppSpacing.height32,

                        // Recent Activity Cards
                        Text(
                          'Key Activity Insights',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppSpacing.height12,

                        Card(
                          elevation: 0.5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildActivityItem('Verified Service Professionals', '$verifiedPros / $totalPros pro accounts verified', Icons.verified, AppColors.successLight),
                                const Divider(),
                                _buildActivityItem('Platform Completed Tasks', '$completedBookings services rendered successfully', Icons.task_alt, AppColors.primaryLight),
                                const Divider(),
                                _buildActivityItem('Transaction Volume', '₹${totalValue.toStringAsFixed(0)} processed through bookings', Icons.analytics_outlined, Colors.purple),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Error loading bookings', description: e.toString()),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Error loading providers', description: e.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(int pros, int pendingVetting, int bookings, double revenue, bool isDark, TextTheme textTheme) {
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
            _buildStatCard('Total Service Pros', '$pros', Icons.groups_outlined, isDark, textTheme),
            _buildStatCard('Pending Vetting', '$pendingVetting', Icons.hourglass_top, isDark, textTheme),
            _buildStatCard('Total Bookings', '$bookings', Icons.calendar_month_outlined, isDark, textTheme),
            _buildStatCard('Est. Platform Fee', '₹${revenue.toStringAsFixed(0)}', Icons.payments_outlined, isDark, textTheme),
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

  Widget _buildShortcutsGrid(BuildContext context, int pendingAudits, bool isDark) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      children: [
        _buildShortcutCard(
          context,
          'Pro Vetting',
          pendingAudits > 0 ? '$pendingAudits pending review' : 'All clear',
          Icons.verified_user_outlined,
          '/admin/providers',
          isDark,
        ),
        _buildShortcutCard(
          context,
          'All Bookings',
          'Track transactions',
          Icons.receipt_long,
          '/admin/bookings',
          isDark,
        ),
        _buildShortcutCard(
          context,
          'Categories',
          'Configure categories',
          Icons.category,
          '/admin/categories',
          isDark,
        ),
        _buildShortcutCard(
          context,
          'Moderation',
          'Review spam filters',
          Icons.rate_review,
          '/admin/reviews',
          isDark,
        ),
      ],
    );
  }

  Widget _buildShortcutCard(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
    String route,
    bool isDark,
  ) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderMedium,
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: AppDimensions.borderMedium,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, size: 24, color: AppColors.primaryLight),
              AppSpacing.width12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withAlpha(25),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          AppSpacing.width16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
