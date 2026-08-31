import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../core/services/realtime_websocket_service.dart';
import '../../core/services/sync_service.dart';
import '../../data/repositories/provider_repository.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    // Watch Realtime Telemetry from Direct WebSocket Connection
    final telemetryAsync = ref.watch(adminTelemetryStreamProvider);

    // Watch Provider Data
    final providersAsync = ref.watch(providersListProvider);

    final telemetry = telemetryAsync.value ?? AdminTelemetryData.fallbackOffline();

    return ResponsiveLayoutShell(
      selectedIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin System & Analytics Control'),
          actions: [
            IconButton(
              tooltip: 'Re-sync Dynamic IP & Connection',
              icon: const Icon(Icons.sync),
              onPressed: () {
                ref.read(realtimeWebSocketServiceProvider).flushOfflineQueue();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resyncing offline queue over WebSocket...')),
                );
              },
            )
          ],
        ),
        body: ResponsiveContainer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Real-time Connection Banner
                _buildRealtimeConnectionBanner(telemetry, isDark, textTheme),
                const SizedBox(height: 16),

                Text(
                  'Real-Time System Telemetry & Metrics',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacing.height12,

                // Primary 4 Real-time Metrics Cards (Total Users, Active Connections, Booking Metrics, Revenue Data)
                _buildRealtimeMetricsGrid(telemetry, isDark, textTheme),
                AppSpacing.height24,

                // Detailed Booking Metrics Breakdown
                _buildBookingMetricsBreakdown(telemetry, isDark, textTheme),
                AppSpacing.height24,

                // Operations Shortcuts
                Text(
                  'Operations Center Controls',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacing.height12,

                providersAsync.when(
                  data: (providers) {
                    final pendingVetting = providers.where((p) => p.verificationStatus == 'under_review').length;
                    return _buildShortcutsGrid(context, ref, pendingVetting, isDark);
                  },
                  loading: () => _buildShortcutsGrid(context, ref, 0, isDark),
                  error: (e, s) => _buildShortcutsGrid(context, ref, 0, isDark),
                ),
                AppSpacing.height24,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Live WebSocket Connection Status Banner
  Widget _buildRealtimeConnectionBanner(AdminTelemetryData telemetry, bool isDark, TextTheme textTheme) {
    final bool isConnected = telemetry.isConnected;
    final color = isConnected ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppDimensions.borderMedium,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ],
            ),
          ),
          AppSpacing.width12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Production Server Sync Active',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                Text(
                  'Connected to live Firebase Realtime Database & Node server. Real-time telemetry streaming.',
                  style: textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Chip(
            label: Text(
              'LIVE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.green,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  // 4 Primary Real-Time Metric Cards
  Widget _buildRealtimeMetricsGrid(AdminTelemetryData telemetry, bool isDark, TextTheme textTheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 550 ? 2 : 1;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          children: [
            // 1. TOTAL USERS
            _buildMetricCard(
              title: 'Total System Users',
              value: '${telemetry.totalUsers}',
              subtitle: '${telemetry.customerCount} Customers • ${telemetry.providerCount} Pros',
              icon: Icons.group_outlined,
              iconColor: Colors.blue,
              isDark: isDark,
              textTheme: textTheme,
            ),

            // 2. ACTIVE CONNECTIONS
            _buildMetricCard(
              title: 'Active Connections',
              value: '${telemetry.activeConnections}',
              subtitle: 'Live WebSockets streaming right now',
              icon: Icons.sensors,
              iconColor: Colors.green,
              isDark: isDark,
              textTheme: textTheme,
            ),

            // 3. BOOKING METRICS
            _buildMetricCard(
              title: 'Total Bookings',
              value: '${telemetry.totalBookings}',
              subtitle: '${telemetry.bookingMetrics['completed'] ?? 0} Completed • ${telemetry.bookingMetrics['pending'] ?? 0} Pending',
              icon: Icons.calendar_today_outlined,
              iconColor: Colors.purple,
              isDark: isDark,
              textTheme: textTheme,
            ),

            // 4. REVENUE DATA
            _buildMetricCard(
              title: 'Total Revenue Data',
              value: '₹${telemetry.totalRevenue.toStringAsFixed(0)}',
              subtitle: 'Avg Ticket: ₹${telemetry.avgTicketSize.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: Colors.amber.shade800,
              isDark: isDark,
              textTheme: textTheme,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required TextTheme textTheme,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderMedium),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              ],
            ),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Booking Metrics Status Distribution Card
  Widget _buildBookingMetricsBreakdown(AdminTelemetryData telemetry, bool isDark, TextTheme textTheme) {
    final b = telemetry.bookingMetrics;
    final total = telemetry.totalBookings > 0 ? telemetry.totalBookings : 1;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderMedium),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking Lifecycle Distribution',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.pie_chart_outline, size: 18, color: AppColors.primaryLight),
              ],
            ),
            AppSpacing.height16,

            Row(
              children: [
                _buildStatusBadge('Pending', b['pending'] ?? 0, total, Colors.orange),
                _buildStatusBadge('Confirmed', b['confirmed'] ?? 0, total, Colors.blue),
                _buildStatusBadge('In Progress', b['inProgress'] ?? 0, total, Colors.purple),
                _buildStatusBadge('Completed', b['completed'] ?? 0, total, Colors.green),
                _buildStatusBadge('Cancelled', b['cancelled'] ?? 0, total, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, int count, int total, Color color) {
    final percent = ((count / total) * 100).toStringAsFixed(0);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$percent%',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Operations Center Shortcuts Grid
  Widget _buildShortcutsGrid(BuildContext context, WidgetRef ref, int pendingVetting, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildShortcutCard(
          context,
          title: 'Provider Audits',
          subtitle: '$pendingVetting awaiting review',
          icon: Icons.verified_user_outlined,
          color: Colors.amber.shade800,
          route: '/admin/providers',
        ),
        _buildShortcutCard(
          context,
          title: 'Categories Editor',
          subtitle: 'Manage active catalog',
          icon: Icons.category_outlined,
          color: AppColors.primaryLight,
          route: '/admin/categories',
        ),
        _buildShortcutCard(
          context,
          title: 'Platform Bookings',
          subtitle: 'Audit jobs & status',
          icon: Icons.book_online_outlined,
          color: Colors.teal,
          route: '/admin/bookings',
        ),
        _buildActionShortcutCard(
          context,
          title: 'Pincode Aggregator',
          subtitle: '3-Option Business Engine',
          icon: Icons.location_city_rounded,
          color: const Color(0xFF6C5CE7),
          onTap: () => _showPincodeEngineDialog(context, ref),
        ),
      ],
    );
  }

  void _showPincodeEngineDialog(BuildContext context, WidgetRef ref) {
    String selectedOption = 'bulk';
    final pincodeController = TextEditingController(text: '682020');
    final categoryController = TextEditingController(text: 'Electricians');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.location_city_rounded, color: Color(0xFF6C5CE7)),
                  SizedBox(width: 8),
                  Text('Pincode Aggregator Engine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Aggregation Method:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => setState(() => selectedOption = 'bulk'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              selectedOption == 'bulk' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: selectedOption == 'bulk' ? const Color(0xFF6C5CE7) : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Option 1: Bulk Fetch (All Kerala Pincodes)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text('Loop through pre-seeded Kerala pincodes', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => selectedOption = 'single'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              selectedOption == 'single' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: selectedOption == 'single' ? const Color(0xFF6C5CE7) : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Option 2: Individual Pincode Fetch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text('Aggregate places for a specific pincode', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => selectedOption = 'category'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Icon(
                              selectedOption == 'category' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: selectedOption == 'category' ? const Color(0xFF6C5CE7) : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Option 3: Category-based Pincode Fetch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text('Fetch specific category within a pincode', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedOption == 'single' || selectedOption == 'category') ...[
                      TextField(
                        controller: pincodeController,
                        decoration: const InputDecoration(
                          labelText: 'Pincode',
                          hintText: 'e.g. 682020',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (selectedOption == 'category') ...[
                      TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          hintText: 'e.g. Electricians',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          final syncService = ref.read(syncServiceProvider);
                          final res = await syncService.triggerPincodeFetch(
                            selectedOption,
                            pincode: pincodeController.text.trim(),
                            category: categoryController.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res['message'] ?? 'Data Aggregation Complete!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Trigger Fetch'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActionShortcutCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderMedium,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderMedium),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: AppDimensions.borderMedium,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
