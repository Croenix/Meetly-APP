import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/booking.dart';
import '../../core/models/app_user.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/repositories/booking_repository.dart';

class AdminBookingsScreen extends ConsumerStatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  ConsumerState<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends ConsumerState<AdminBookingsScreen> {
  String _filter = 'all'; // all, pending, confirmed, completed, cancelled
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _adminCancelBooking(Booking booking) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Administrative Cancellation?'),
          content: Text(
            'Are you sure you want to cancel the booking for "${booking.serviceName}" between ${booking.customerName} and ${booking.providerName}? This action is final.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final repo = ref.read(bookingRepositoryProvider);
                await repo.updateBookingStatus(booking.id, BookingStatus.cancelled);
                
                // Refresh list
                ref.invalidate(userBookingsProvider);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking cancelled successfully by Administrator.')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.errorLight),
              child: const Text('Confirm Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Load bookings for admin
    final bookingsAsync = ref.watch(userBookingsProvider((userId: 'admin', role: UserRole.admin)));

    return ResponsiveLayoutShell(
      selectedIndex: 2, // Admin Bookings Tab Index
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Global Booking Operations'),
        ),
        body: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by client or service name...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase().trim();
                  });
                },
              ),
              AppSpacing.height16,

              // Status Filter row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filter == 'all',
                      onSelected: (val) => setState(() => _filter = 'all'),
                    ),
                    AppSpacing.width8,
                    ChoiceChip(
                      label: const Text('Pending'),
                      selected: _filter == 'pending',
                      onSelected: (val) => setState(() => _filter = 'pending'),
                    ),
                    AppSpacing.width8,
                    ChoiceChip(
                      label: const Text('Confirmed'),
                      selected: _filter == 'confirmed',
                      onSelected: (val) => setState(() => _filter = 'confirmed'),
                    ),
                    AppSpacing.width8,
                    ChoiceChip(
                      label: const Text('Completed'),
                      selected: _filter == 'completed',
                      onSelected: (val) => setState(() => _filter = 'completed'),
                    ),
                    AppSpacing.width8,
                    ChoiceChip(
                      label: const Text('Cancelled'),
                      selected: _filter == 'cancelled',
                      onSelected: (val) => setState(() => _filter = 'cancelled'),
                    ),
                  ],
                ),
              ),
              AppSpacing.height24,

              // List of Bookings
              Expanded(
                child: bookingsAsync.when(
                  data: (bookings) {
                    final filtered = bookings.where((b) {
                      // Apply Search Filter
                      if (_searchQuery.isNotEmpty) {
                        final matchesClient = b.customerName.toLowerCase().contains(_searchQuery);
                        final matchesService = b.serviceName.toLowerCase().contains(_searchQuery);
                        if (!matchesClient && !matchesService) return false;
                      }

                      // Apply Status Filter
                      if (_filter == 'pending') return b.status == BookingStatus.pending;
                      if (_filter == 'confirmed') return b.status == BookingStatus.confirmed || b.status == BookingStatus.accepted;
                      if (_filter == 'completed') return b.status == BookingStatus.completed;
                      if (_filter == 'cancelled') return b.status == BookingStatus.cancelled;
                      
                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return const EmptyState(
                        icon: Icons.calendar_today_outlined,
                        title: 'No matching bookings found',
                        description: 'Adjust filters or search parameters to find entries.',
                      );
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => AppSpacing.height16,
                      itemBuilder: (context, index) {
                        final b = filtered[index];
                        final canCancel = b.status != BookingStatus.completed && b.status != BookingStatus.cancelled;

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
                                      child: Text(
                                        b.serviceName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    StatusBadge.booking(b.status),
                                  ],
                                ),
                                AppSpacing.height12,
                                const Divider(),
                                AppSpacing.height12,

                                // Details layout
                                _buildDetailRow('Client Name', b.customerName, isDark),
                                _buildDetailRow('Professional', b.providerName, isDark),
                                _buildDetailRow('Scheduled Time', '${b.date} at ${b.time}', isDark),
                                _buildDetailRow('Commission Fee (10%)', '₹${(b.priceEstimate * 0.10).toStringAsFixed(0)}', isDark, isBold: true),
                                _buildDetailRow('Total Booking Value', '₹${b.priceEstimate.toStringAsFixed(0)}', isDark, isHighlight: true),

                                if (canCancel) ...[
                                  AppSpacing.height16,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _adminCancelBooking(b),
                                        icon: const Icon(Icons.cancel_outlined, size: 14),
                                        label: const Text('Admin Cancel', style: TextStyle(fontSize: 11)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.errorLight,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          minimumSize: Size.zero,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Error loading bookings', description: e.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {bool isBold = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold || isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight 
                  ? (isDark ? AppColors.primaryDark : AppColors.primaryLight) 
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
