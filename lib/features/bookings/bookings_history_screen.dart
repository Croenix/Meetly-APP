import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/booking.dart';
import '../../core/models/app_user.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';

class BookingsHistoryScreen extends ConsumerStatefulWidget {
  const BookingsHistoryScreen({super.key});

  @override
  ConsumerState<BookingsHistoryScreen> createState() => _BookingsHistoryScreenState();
}

class _BookingsHistoryScreenState extends ConsumerState<BookingsHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF6C5CE7);

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox();

        final bookingsAsync = ref.watch(userBookingsProvider((userId: user.id, role: user.role)));

        return ResponsiveLayoutShell(
          selectedIndex: 1, // Bookings tab index
          child: Scaffold(
            body: SafeArea(
              child: ResponsiveContainer(
                usePadding: false,
                child: Column(
                  children: [
                    // Header Bar & Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
                                    user.role == UserRole.provider ? 'Job Requests' : 'My Bookings',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.role == UserRole.provider
                                        ? 'Manage incoming & active client assignments'
                                        : 'Track active bookings & service history',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: primaryColor,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Search Filter Bar
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0xFF2D2D3F) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val.trim().toLowerCase();
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search service or pro name...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                          });
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Modern Custom Segmented Tab Control
                    bookingsAsync.when(
                      data: (bookings) {
                        final upcomingCount = bookings.where((b) => _isUpcoming(b.status)).length;
                        final completedCount = bookings.where((b) => b.status == BookingStatus.completed).length;
                        final cancelledCount = bookings.where((b) => b.status == BookingStatus.cancelled).length;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: isDark ? primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            labelColor: isDark ? Colors.white : primaryColor,
                            unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Tab(text: 'Upcoming ($upcomingCount)'),
                              Tab(text: 'Completed ($completedCount)'),
                              Tab(text: 'Cancelled ($cancelledCount)'),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox(height: 40),
                      error: (e, stack) => const SizedBox(),
                    ),

                    // Tab View Content
                    Expanded(
                      child: bookingsAsync.when(
                        data: (bookings) {
                          // Apply search filter
                          final filteredBookings = bookings.where((b) {
                            if (_searchQuery.isEmpty) return true;
                            return b.serviceName.toLowerCase().contains(_searchQuery) ||
                                b.providerName.toLowerCase().contains(_searchQuery) ||
                                b.customerName.toLowerCase().contains(_searchQuery);
                          }).toList();

                          final upcoming = filteredBookings.where((b) => _isUpcoming(b.status)).toList();
                          final completed = filteredBookings.where((b) => b.status == BookingStatus.completed).toList();
                          final cancelled = filteredBookings.where((b) => b.status == BookingStatus.cancelled).toList();

                          return TabBarView(
                            controller: _tabController,
                            children: [
                              _buildBookingsList(
                                context,
                                upcoming,
                                'No Upcoming Bookings',
                                'Browse home services and book certified professionals with instant confirmation.',
                                isDark,
                                primaryColor,
                                user.role,
                              ),
                              _buildBookingsList(
                                context,
                                completed,
                                'No Completed History',
                                'Your completed appointments and receipts will automatically show up here.',
                                isDark,
                                primaryColor,
                                user.role,
                              ),
                              _buildBookingsList(
                                context,
                                cancelled,
                                'No Cancelled Bookings',
                                'No cancelled service requests in your account history.',
                                isDark,
                                primaryColor,
                                user.role,
                              ),
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => EmptyState(
                          icon: Icons.error_outline_rounded,
                          title: 'Unable to Load Bookings',
                          description: e.toString(),
                        ),
                      ),
                    ),
                  ],
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

  bool _isUpcoming(BookingStatus status) {
    return status == BookingStatus.pending ||
        status == BookingStatus.accepted ||
        status == BookingStatus.confirmed ||
        status == BookingStatus.onTheWay ||
        status == BookingStatus.inProgress;
  }

  Widget _buildBookingsList(
    BuildContext context,
    List<Booking> list,
    String emptyTitle,
    String emptyDesc,
    bool isDark,
    Color primaryColor,
    UserRole role,
  ) {
    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_rounded,
        title: emptyTitle,
        description: emptyDesc,
        actionText: 'Explore Home Services',
        onActionPressed: () => context.go('/home'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final booking = list[index];
        return _buildBookingCard(context, booking, isDark, primaryColor, role, index);
      },
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    Booking booking,
    bool isDark,
    Color primaryColor,
    UserRole role,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D3F) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF64748B).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Bar with Service Name & Status Badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                role == UserRole.provider ? Icons.person_rounded : Icons.handyman_rounded,
                                size: 14,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  role == UserRole.provider
                                      ? 'Customer: ${booking.customerName}'
                                      : 'Pro: ${booking.providerName}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    StatusBadge.booking(booking.status),
                  ],
                ),

                const SizedBox(height: 16),

                // Schedule Info & Price Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF14141F) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.access_time_filled_rounded,
                              size: 16,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SCHEDULED TIME',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${booking.date} at ${booking.time}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '₹${booking.priceEstimate.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Live Progress Stepper for Active Bookings
                if (_isUpcoming(booking.status)) ...[
                  const SizedBox(height: 14),
                  _buildProgressStepper(booking.status, isDark, primaryColor),
                ],
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF1F5F9).withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF2D2D3F) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Meetly Verified Protection',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/booking/${booking.id}'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    .animate(delay: (index * 60).ms)
    .fadeIn(duration: 350.ms)
    .slideY(begin: 0.1, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildProgressStepper(BookingStatus status, bool isDark, Color primaryColor) {
    int currentStep = 0;
    if (status == BookingStatus.pending) currentStep = 1;
    if (status == BookingStatus.confirmed || status == BookingStatus.accepted) currentStep = 2;
    if (status == BookingStatus.onTheWay) currentStep = 3;
    if (status == BookingStatus.inProgress) currentStep = 4;

    return Row(
      children: [
        _buildStepDot(1, currentStep, 'Booked', isDark, primaryColor),
        _buildStepLine(1, currentStep, primaryColor),
        _buildStepDot(2, currentStep, 'Confirmed', isDark, primaryColor),
        _buildStepLine(2, currentStep, primaryColor),
        _buildStepDot(3, currentStep, 'On Way', isDark, primaryColor),
        _buildStepLine(3, currentStep, primaryColor),
        _buildStepDot(4, currentStep, 'Working', isDark, primaryColor),
      ],
    );
  }

  Widget _buildStepDot(int step, int currentStep, String label, bool isDark, Color primaryColor) {
    final isActive = currentStep >= step;
    final isCurrent = currentStep == step;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? primaryColor : (isDark ? const Color(0xFF2D2D3F) : const Color(0xFFCBD5E1)),
            border: isCurrent
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? (isDark ? Colors.white : const Color(0xFF1E293B))
                : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step, int currentStep, Color primaryColor) {
    final isActive = currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isActive ? primaryColor : const Color(0xFFCBD5E1).withValues(alpha: 0.4),
      ),
    );
  }
}
