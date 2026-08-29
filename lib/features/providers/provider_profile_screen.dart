import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/service_provider.dart';
import '../../core/models/service_item.dart';
import '../../core/models/review.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../core/widgets/service_card.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/provider_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/service_repository.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  final String providerId;

  const ProviderProfileScreen({
    super.key,
    required this.providerId,
  });

  @override
  ConsumerState<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startChat(BuildContext context, String currentUserId, String partnerId, String partnerName) async {
    // Navigate to chat detail screen
    context.push(
      '/messages/$partnerId',
      extra: {
        'currentUserId': currentUserId,
        'partnerId': partnerId,
        'partnerName': partnerName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerAsync = ref.watch(providerDetailsProvider(widget.providerId));
    final servicesAsync = ref.watch(providerServicesProvider(widget.providerId));
    final reviewsAsync = ref.watch(providerReviewsProvider(widget.providerId));
    final authState = ref.watch(authStateProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return ResponsiveLayoutShell(
      selectedIndex: 0,
      child: Scaffold(
        body: providerAsync.when(
          data: (provider) {
            if (provider == null) {
              return const EmptyState(
                icon: Icons.error_outline,
                title: 'Provider not found',
                description: 'This listing may have been removed or is no longer verified.',
              );
            }

            final isDesktop = AppDimensions.isDesktop(context);

            return authState.when(
              data: (currentUser) {
                final currentUserId = currentUser?.id ?? '';

                Widget mainProfileContent() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover Banner
                      _buildCoverBanner(provider, isDark),
                      
                      // Profile Header (Name, Rating, response time)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildProfileHeader(provider, isDark, textTheme),
                      ),
                      AppSpacing.height16,
                      
                      // Mobile action buttons (only on mobile)
                      if (!isDesktop)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _startChat(context, currentUserId, provider.userId, provider.businessName),
                                  icon: const Icon(Icons.chat_bubble_outline),
                                  label: const Text('Message'),
                                ),
                              ),
                              AppSpacing.width12,
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Trigger booking flow with first service if available
                                    servicesAsync.whenData((list) {
                                      if (list.isNotEmpty) {
                                        context.push(
                                          '/booking/create',
                                          extra: {
                                            'providerId': provider.id,
                                            'providerName': provider.businessName,
                                            'serviceId': list.first.id,
                                            'serviceName': list.first.name,
                                            'price': list.first.price,
                                            'priceType': list.first.priceType,
                                          },
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('No services listed to book.')),
                                        );
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.calendar_month),
                                  label: const Text('Book Now'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      AppSpacing.height24,

                      // Tab Bar
                      TabBar(
                        controller: _tabController,
                        labelColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        indicatorColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        tabs: const [
                          Tab(text: 'About'),
                          Tab(text: 'Services'),
                          Tab(text: 'Portfolio'),
                          Tab(text: 'Reviews'),
                        ],
                      ),

                      // Tab Bar Views
                      SizedBox(
                        height: 500, // Constrained height for nested scrolling tab view
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // 1. About Tab
                            _buildAboutTab(provider, isDark, textTheme),
                            
                            // 2. Services Tab
                            _buildServicesTab(servicesAsync, provider.businessName, textTheme),
                            
                            // 3. Portfolio Tab
                            _buildPortfolioTab(provider),
                            
                            // 4. Reviews Tab
                            _buildReviewsTab(reviewsAsync, provider.rating, provider.reviewCount, isDark, textTheme),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                if (isDesktop) {
                  // Desktop View: Two Column Layout (Left: Profile details + Tabs, Right: Sticky Scheduling Card)
                  return SingleChildScrollView(
                    child: ResponsiveContainer(
                      usePadding: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left details column
                          Expanded(
                            flex: 3,
                            child: Card(
                              elevation: 1,
                              child: mainProfileContent(),
                            ),
                          ),
                          AppSpacing.width24,
                          // Right sidebar sticky booking / scheduler card
                          Expanded(
                            flex: 1,
                            child: StickySchedulerCard(
                              provider: provider,
                              currentUserId: currentUserId,
                              servicesAsync: servicesAsync,
                              isDark: isDark,
                              textTheme: textTheme,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Mobile Layout: Scrolling single column
                return SingleChildScrollView(
                  child: mainProfileContent(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Auth error: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading profile: $e')),
        ),
      ),
    );
  }

  Widget _buildCoverBanner(ServiceProvider provider, bool isDark) {
    return SizedBox(
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner background
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryLight, AppColors.secondaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          // Overlapping profile avatar
          Positioned(
            bottom: 0,
            left: 24,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                ],
              ),
              child: AppAvatar(
                url: provider.portfolioImages.isNotEmpty ? provider.portfolioImages.first : null,
                name: provider.businessName,
                size: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ServiceProvider provider, bool isDark, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.height12,
        Row(
          children: [
            Expanded(
              child: Text(
                provider.businessName,
                style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
              ),
            ),
            if (provider.verified) ...[
              AppSpacing.width4,
              const Icon(Icons.verified, color: AppColors.primaryLight, size: 20),
            ],
          ],
        ),
        Text(
          provider.profession,
          style: textTheme.bodyLarge?.copyWith(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
        ),
        AppSpacing.height8,

        // Rating & Location Row
        Row(
          children: [
            const Icon(Icons.star, size: 18, color: AppColors.warningLight),
            AppSpacing.width4,
            Text(
              provider.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            AppSpacing.width4,
            Text(
              '(${provider.reviewCount} reviews)',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.width12,
            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondaryLight),
            AppSpacing.width4,
            Text(
              provider.location,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutTab(ServiceProvider provider, bool isDark, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          Text('About Business', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.height8,
          Text(
            provider.bio,
            style: textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
          AppSpacing.height24,

          // Business Information list
          Text('Business Information', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.height12,
          _buildInfoRow(Icons.phone_outlined, 'Phone', provider.phone),
          _buildInfoRow(Icons.timer_outlined, 'Response Time', provider.responseTime),
          _buildInfoRow(Icons.map_outlined, 'Service Area', provider.serviceArea),
          _buildInfoRow(Icons.category_outlined, 'Category Group', provider.category),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryLight),
          AppSpacing.width16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab(AsyncValue<List<ServiceItem>> servicesAsync, String providerName, TextTheme textTheme) {
    return servicesAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return const EmptyState(
            icon: Icons.handyman_outlined,
            title: 'No services listed',
            description: 'This professional has not listed specific services yet.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          separatorBuilder: (context, index) => AppSpacing.height12,
          itemBuilder: (context, index) {
            return ServiceCard(
              service: services[index],
              providerName: providerName,
              showBookButton: true,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPortfolioTab(ServiceProvider provider) {
    final images = provider.portfolioImages;

    if (images.isEmpty) {
      return const EmptyState(
        icon: Icons.photo_library_outlined,
        title: 'No portfolio images',
        description: 'No samples of completed work uploaded yet.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => _openFullscreenGallery(context, images, index),
          child: ClipRRect(
            borderRadius: AppDimensions.borderSmall,
            child: Image.network(
              images[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  void _openFullscreenGallery(BuildContext context, List<String> images, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Center(
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(
    AsyncValue<List<Review>> reviewsAsync,
    double averageRating,
    int reviewCount,
    bool isDark,
    TextTheme textTheme,
  ) {
    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const EmptyState(
            icon: Icons.rate_review_outlined,
            title: 'No reviews yet',
            description: 'Be the first customer to book this service and leave a review!',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length + 1, // +1 for rating overview widget at top
          separatorBuilder: (context, index) => AppSpacing.height12,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildRatingOverviewCard(averageRating, reviewCount, isDark, textTheme);
            }

            final review = reviews[index - 1];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderMedium,
                side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Review User header
                    Row(
                      children: [
                        AppAvatar(url: review.customerAvatar, name: review.customerName, size: 36),
                        AppSpacing.width12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(review.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                review.date,
                                style: textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Star Rating
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              Icons.star,
                              size: 14,
                              color: starIndex < review.rating.floor()
                                  ? AppColors.warningLight
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            );
                          }),
                        ),
                      ],
                    ),
                    AppSpacing.height12,
                    // Comment
                    Text(
                      review.comment,
                      style: const TextStyle(height: 1.4),
                    ),
                    
                    // Provider Reply if available
                    if (review.reply != null) ...[
                      AppSpacing.height12,
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                          borderRadius: AppDimensions.borderSmall,
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.subdirectory_arrow_right, size: 16, color: AppColors.primaryLight),
                                SizedBox(width: 8),
                                Text(
                                  'Provider Response',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryLight),
                                ),
                              ],
                            ),
                            AppSpacing.height4,
                            Text(
                              review.reply!,
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildRatingOverviewCard(double avg, int count, bool isDark, TextTheme textTheme) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.primaryLight.withAlpha(8),
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderMedium,
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.primaryLight.withAlpha(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  avg.toStringAsFixed(1),
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  ),
                ),
                Row(
                  children: List.generate(5, (star) {
                    return Icon(
                      Icons.star,
                      size: 14,
                      color: star < avg.floor() ? AppColors.warningLight : Colors.grey.shade400,
                    );
                  }),
                ),
                AppSpacing.height4,
                Text('$count ratings', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            AppSpacing.width32,
            Expanded(
              child: Column(
                children: [
                  _buildRatingProgressRow('5 star', 0.78, isDark),
                  _buildRatingProgressRow('4 star', 0.15, isDark),
                  _buildRatingProgressRow('3 star', 0.05, isDark),
                  _buildRatingProgressRow('2 star', 0.01, isDark),
                  _buildRatingProgressRow('1 star', 0.01, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingProgressRow(String label, double value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
          AppSpacing.width12,
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: isDark ? AppColors.borderDark : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.warningLight),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sidebar Scheduling/Booking Info panel for Desktop view
class StickySchedulerCard extends StatelessWidget {
  final ServiceProvider provider;
  final String currentUserId;
  final AsyncValue<List<ServiceItem>> servicesAsync;
  final bool isDark;
  final TextTheme textTheme;

  const StickySchedulerCard({
    super.key,
    required this.provider,
    required this.currentUserId,
    required this.servicesAsync,
    required this.isDark,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderMedium,
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book this Professional',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.height12,
            
            // Response timing
            Row(
              children: [
                const Icon(Icons.flash_on, color: AppColors.successLight, size: 16),
                AppSpacing.width8,
                Text(
                  'Responds ${provider.responseTime}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.successLight),
                ),
              ],
            ),
            AppSpacing.height24,
            
            // Availability hours
            const Text(
              'Weekly Hours',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            AppSpacing.height8,
            for (final day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
              _buildDayScheduleRow(day),

            AppSpacing.height32,
            
            // Primary Booking Action button
            ElevatedButton(
              onPressed: () {
                servicesAsync.whenData((list) {
                  if (list.isNotEmpty) {
                    context.push(
                      '/booking/create',
                      extra: {
                        'providerId': provider.id,
                        'providerName': provider.businessName,
                        'serviceId': list.first.id,
                        'serviceName': list.first.name,
                        'price': list.first.price,
                        'priceType': list.first.priceType,
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No services listed to book.')),
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Book a Service'),
            ),
            AppSpacing.height12,
            
            // Message Button
            OutlinedButton(
              onPressed: () {
                context.push(
                  '/messages/${provider.userId}',
                  extra: {
                    'currentUserId': currentUserId,
                    'partnerId': provider.userId,
                    'partnerName': provider.businessName,
                  },
                );
              },
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 18),
                  SizedBox(width: 8),
                  Text('Chat with Professional'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayScheduleRow(String day) {
    final sched = provider.workingHours[day];
    final bool isAvail = sched != null && sched['available'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(
            isAvail ? '${sched['start']} - ${sched['end']}' : 'Closed',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isAvail ? FontWeight.bold : FontWeight.normal,
              color: isAvail ? null : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
