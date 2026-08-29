import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/category_card.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../data/repositories/provider_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../core/models/service_provider.dart';
import '../../core/services/sync_service.dart';

// StateProvider to reactively store the user selected city location
final selectedLocationProvider = StateProvider<String?>((ref) => null);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});


  void _showLocationBottomSheet(BuildContext context, WidgetRef ref, String currentLoc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      builder: (context) {
        final cities = ['Kochi', 'Kottayam', 'Alappuzha', 'Thiruvalla', 'Changanassery'];
        
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find services and pros in your city',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      final isSelected = city.toLowerCase() == currentLoc.toLowerCase();
                      
                      return InkWell(
                        onTap: () {
                          ref.read(selectedLocationProvider.notifier).state = city;
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                city,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final providersAsync = ref.watch(providersListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final categoriesAsync = ref.watch(categoriesListProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox();

        final selectedLocation = ref.watch(selectedLocationProvider) ?? user.location;

        // Load notifications count reactively
        final notificationsAsync = ref.watch(userNotificationsProvider(user.id));
        final unreadCount = notificationsAsync.maybeWhen(
          data: (list) => list.where((n) => !n.isRead).length,
          orElse: () => 0,
        );

        return ResponsiveLayoutShell(
          selectedIndex: 0,
          child: Scaffold(
            body: SingleChildScrollView(
              child: ResponsiveContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row (Profile Avatar, Greetings & Location Pill, Notifications)
                    Row(
                      children: [
                        AppAvatar(
                          url: user.avatarUrl,
                          name: user.name,
                          size: 48,
                        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(duration: 400.ms),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${user.name.split(' ').first}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              InkWell(
                                onTap: () => _showLocationBottomSheet(context, ref, selectedLocation),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      selectedLocation,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 14,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.1, end: 0, delay: 100.ms, curve: Curves.easeOutQuad),
                        ),
                        
                        // Notifications Button (Circular White Card)
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_none_outlined),
                                onPressed: () => context.push('/notifications'),
                                style: IconButton.styleFrom(
                                  shape: const CircleBorder(),
                                ),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.errorLight,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 14,
                                      minHeight: 14,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9), delay: 300.ms, curve: Curves.easeOutBack),
                      ],
                    ),
                    AppSpacing.height24,

                    // Headline
                    RichText(
                      text: TextSpan(
                        style: textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: -0.6,
                        ),
                        children: [
                          TextSpan(
                            text: 'Find trusted ',
                            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight),
                          ),
                          TextSpan(
                            text: 'local\nservice professionals',
                            style: TextStyle(
                              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 500.ms)
                        .slideY(begin: 0.15, end: 0, delay: 150.ms, curve: Curves.easeOutQuad),
                    AppSpacing.height24,

                    // Search & Filter Row
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push('/search'),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  if (!isDark)
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                  AppSpacing.width12,
                                  Expanded(
                                    child: Text(
                                      'Search',
                                      style: textTheme.bodyMedium?.copyWith(
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Filter Button (Circular Icon)
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryLight, AppColors.secondaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.tune_outlined, color: Colors.white, size: 20),
                            onPressed: () => context.push('/search'),
                            constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
                            padding: EdgeInsets.zero,
                            style: IconButton.styleFrom(
                              shape: const CircleBorder(),
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0, delay: 250.ms, curve: Curves.easeOutQuad),
                    AppSpacing.height24,

                    // Interactive Dynamic Promotion Banner (Offline-first Synced)
                    ref.watch(appSettingsStateProvider).when(
                      data: (settings) {
                        final bannerImageUrl = settings.bannerImageUrl;
                        
                        return Container(
                          width: double.infinity,
                          height: 165,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEBF3FF), Color(0xFFD2E3FC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                top: -20,
                                bottom: -20,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            settings.promoSubtitle,
                                            style: const TextStyle(
                                              color: Color(0xFF1A73E8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            settings.promoTitle,
                                            style: const TextStyle(
                                              color: Color(0xFF202124),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 32,
                                            child: ElevatedButton(
                                              onPressed: () => context.push('/search'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF1A73E8),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                elevation: 2,
                                                shadowColor: const Color(0xFF1A73E8).withValues(alpha: 0.4),
                                              ),
                                              child: const Text(
                                                'Book a Service',
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: bannerImageUrl.isNotEmpty
                                            ? Image.network(
                                                bannerImageUrl,
                                                fit: BoxFit.contain,
                                                alignment: Alignment.centerRight,
                                                errorBuilder: (context, e, s) => Image.asset(
                                                  'assets/images/3d_builder_banner.jpg',
                                                  fit: BoxFit.contain,
                                                  alignment: Alignment.centerRight,
                                                ),
                                              )
                                            : Image.asset(
                                                'assets/images/3d_builder_banner.jpg',
                                                fit: BoxFit.contain,
                                                alignment: Alignment.centerRight,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 350.ms, duration: 600.ms)
                            .slideY(begin: 0.1, end: 0, delay: 350.ms, curve: Curves.easeOutQuad);
                      },
                      loading: () => Container(
                        width: double.infinity,
                        height: 155,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, _) => Container(
                        width: double.infinity,
                        height: 155,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(child: Text("Sync Offline")),
                      ),
                    ),
                    AppSpacing.height32,

                    // Categories Title Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Most Booked Services',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => context.push('/search'),
                          child: const Text('View all'),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: -0.05, end: 0, delay: 400.ms),
                    AppSpacing.height12,

                    // Categories Horizontal Scroll Row
                    categoriesAsync.when(
                      data: (categories) {
                        return SizedBox(
                          height: 110,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final categoryName = categories[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => context.push('/category/$categoryName'),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 84,
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceDark : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IgnorePointer(
                                      child: CategoryCard.fromName(categoryName),
                                    ),
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: (50 * index + 400).ms, duration: 350.ms)
                                  .slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuad, duration: 350.ms);
                            },
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error loading categories: $e'),
                    ),
                    AppSpacing.height32,

                    // Load provider states
                    providersAsync.when(
                      data: (providers) {
                        // Recommended (Highest rated, verified)
                        final recommendedList = providers
                            .where((p) => p.rating >= 4.7 && p.verified)
                            .take(5)
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 3. Top Picks for you
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Top Picks for you',
                                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                  onPressed: () => context.push('/search'),
                                  child: const Text('View all'),
                                ),
                              ],
                            )
                                .animate()
                                .fadeIn(delay: 450.ms)
                                .slideX(begin: -0.05, end: 0, delay: 450.ms),
                            AppSpacing.height12,
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recommendedList.length,
                              separatorBuilder: (context, index) => AppSpacing.height16,
                              itemBuilder: (context, index) {
                                return TopPickCard(provider: recommendedList[index])
                                    .animate()
                                    .fadeIn(delay: (100 * index + 450).ms, duration: 400.ms)
                                    .slideY(begin: 0.1, end: 0, delay: (100 * index + 450).ms, curve: Curves.easeOutQuad);
                              },
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error loading providers: $e'),
                    ),
                    AppSpacing.height32,

                    // 4. How Meetly Works Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.primaryLight.withValues(alpha: 0.05),
                        borderRadius: AppDimensions.borderLarge,
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.primaryLight.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How Meetly Works',
                            style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.primaryLight,
                                ),
                          ),
                          AppSpacing.height16,
                          SizedBox(
                            height: 115,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildStepCard(context, '1', 'Search', 'Find certified, local experts.', Icons.search, isDark)
                                    .animate()
                                    .fadeIn(delay: 650.ms, duration: 400.ms)
                                    .scale(begin: const Offset(0.95, 0.95), delay: 650.ms, curve: Curves.easeOutBack),
                                const SizedBox(width: 12),
                                _buildStepCard(context, '2', 'Connect', 'Compare stars and chat.', Icons.chat_bubble_outline, isDark)
                                    .animate()
                                    .fadeIn(delay: 750.ms, duration: 400.ms)
                                    .scale(begin: const Offset(0.95, 0.95), delay: 750.ms, curve: Curves.easeOutBack),
                                const SizedBox(width: 12),
                                _buildStepCard(context, '3', 'Book', 'Schedule date/time easily.', Icons.calendar_today_outlined, isDark)
                                    .animate()
                                    .fadeIn(delay: 850.ms, duration: 400.ms)
                                    .scale(begin: const Offset(0.95, 0.95), delay: 850.ms, curve: Curves.easeOutBack),
                                const SizedBox(width: 12),
                                _buildStepCard(context, '4', 'Grow', 'Write reviews & support pros.', Icons.trending_up, isDark)
                                    .animate()
                                    .fadeIn(delay: 950.ms, duration: 400.ms)
                                    .scale(begin: const Offset(0.95, 0.95), delay: 950.ms, curve: Curves.easeOutBack),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.1, end: 0, delay: 600.ms, curve: Curves.easeOutQuad),
                    AppSpacing.height32,
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Auth Error: $e')),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context,
    String num,
    String title,
    String description,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 14,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    num,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class TopPickCard extends ConsumerWidget {
  final ServiceProvider provider;
  const TopPickCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasImage = provider.portfolioImages.isNotEmpty;
    final imageUrl = hasImage
        ? provider.portfolioImages.first
        : 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600&auto=format&fit=crop';

    // Watch the favorite status of this provider
    final favListAsync = ref.watch(favoritesListProvider);
    final isFav = favListAsync.when(
      data: (list) => list.any((p) => p.id == provider.id),
      loading: () => false,
      error: (_, _) => false,
    );

    return InkWell(
      onTap: () => context.push('/provider/${provider.id}'),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Full image background
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, e, s) => Container(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.broken_image_outlined, size: 40),
                  ),
                ),
              ),
              // Bottom gradient overlay for text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.4, 0.9],
                    ),
                  ),
                ),
              ),
              // Top-left orange pill badge: "24/7 Support"
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFE845F), Color(0xFFFE583B)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_filled, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        '24/7 Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Top-right floating Fav Button
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.errorLight : AppColors.textSecondaryLight,
                      size: 18,
                    ),
                    onPressed: () async {
                      await ref.read(providerRepositoryProvider).toggleFavorite(provider.id);
                      ref.invalidate(favoritesListProvider);
                    },
                  ),
                ),
              ),
              // Bottom Details Text
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.handyman_outlined,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Trusted ${provider.category} Help',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.businessName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Rating & Price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.warningLight),
                            const SizedBox(width: 4),
                            Text(
                              provider.rating.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${provider.reviewCount} reviews)',
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                        Text(
                          '₹${provider.startingPrice.toStringAsFixed(0)} / visit',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
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
}
