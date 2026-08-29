import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import 'avatar.dart';

class ResponsiveLayoutShell extends ConsumerWidget {
  final Widget child;
  final int selectedIndex;

  const ResponsiveLayoutShell({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return authState.when(
      data: (user) {
        if (user == null) {
          // If not logged in, just return the child directly (auth screens)
          return child;
        }

        final role = user.role;
        final destinations = _getDestinations(role);
        final isDesktop = AppDimensions.isDesktop(context);

        if (isDesktop) {
          // Desktop Layout with Sidebar Navigation
          return Scaffold(
            body: Row(
              children: [
                _buildSidebar(context, ref, user, destinations, isDark),
                const VerticalDivider(width: 1),
                Expanded(
                  child: SafeArea(
                    child: child,
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile / Tablet Layout with Bottom Navigation Bar
        return Scaffold(
          body: Stack(
            children: [
              // Safe area wrapper for the child screen, with bottom padding for the floating bar
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 95),
                  child: child,
                ),
              ),
              // Floating Bottom Navigation Bar
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark.withValues(alpha: 0.5)
                          : AppColors.borderLight.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(destinations.length, (index) {
                          final d = destinations[index];
                          final isSelected = index == selectedIndex;
                          final activeColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
                          final inactiveColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
                          
                          return Expanded(
                            child: InkWell(
                              onTap: () => _onNavigate(context, index, role),
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? activeColor.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSelected ? d.activeIcon : d.icon,
                                      color: isSelected ? activeColor : inactiveColor,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      d.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? activeColor : inactiveColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error loading shell: $err')),
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
    List<NavigationItemData> destinations,
    bool isDark,
  ) {
    return Container(
      width: 260,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Logo Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hub_outlined,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
              ),
              AppSpacing.width12,
              Text(
                'Meetly',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          AppSpacing.height32,

          // User Profile Widget (Sidebar Header)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              borderRadius: AppDimensions.borderMedium,
            ),
            child: Row(
              children: [
                AppAvatar(url: user.avatarUrl, name: user.name, size: 40),
                AppSpacing.width12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.role.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.height32,

          // Sidebar Navigation Links
          Expanded(
            child: ListView.separated(
              itemCount: destinations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final d = destinations[index];
                final isSelected = index == selectedIndex;
                final activeColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

                return InkWell(
                  onTap: () => _onNavigate(context, index, user.role),
                  borderRadius: AppDimensions.borderMedium,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight.withAlpha(isDark ? 30 : 20)
                          : Colors.transparent,
                      borderRadius: AppDimensions.borderMedium,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? d.activeIcon : d.icon,
                          color: isSelected ? activeColor : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          size: 20,
                        ),
                        AppSpacing.width16,
                        Text(
                          d.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? activeColor : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Logout Button
          const Divider(),
          AppSpacing.height16,
          InkWell(
            onTap: () {
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
            borderRadius: AppDimensions.borderMedium,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.logout_outlined, color: AppColors.errorLight, size: 20),
                  AppSpacing.width16,
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.errorLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavigate(BuildContext context, int index, UserRole role) {
    if (role == UserRole.customer) {
      switch (index) {
        case 0:
          context.go('/home');
          break;
        case 1:
          context.go('/bookings');
          break;
        case 2:
          context.go('/messages');
          break;
        case 3:
          context.go('/favorites');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    } else if (role == UserRole.provider) {
      switch (index) {
        case 0:
          context.go('/provider/dashboard');
          break;
        case 1:
          context.go('/provider/bookings');
          break;
        case 2:
          context.go('/messages');
          break;
        case 3:
          context.go('/provider/services');
          break;
        case 4:
          context.go('/provider/profile');
          break;
      }
    } else if (role == UserRole.admin) {
      switch (index) {
        case 0:
          context.go('/admin');
          break;
        case 1:
          context.go('/admin/providers');
          break;
        case 2:
          context.go('/admin/bookings');
          break;
        case 3:
          context.go('/admin/categories');
          break;
        case 4:
          context.go('/admin/reviews');
          break;
      }
    }
  }

  List<NavigationItemData> _getDestinations(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return [
          NavigationItemData(
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          NavigationItemData(
            label: 'Bookings',
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today,
          ),
          NavigationItemData(
            label: 'Chats',
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
          ),
          NavigationItemData(
            label: 'Favorites',
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
          ),
          NavigationItemData(
            label: 'Profile',
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ];
      case UserRole.provider:
        return [
          NavigationItemData(
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
          ),
          NavigationItemData(
            label: 'Jobs',
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today,
          ),
          NavigationItemData(
            label: 'Chats',
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
          ),
          NavigationItemData(
            label: 'My Services',
            icon: Icons.handyman_outlined,
            activeIcon: Icons.handyman,
          ),
          NavigationItemData(
            label: 'Business Profile',
            icon: Icons.business_outlined,
            activeIcon: Icons.business,
          ),
        ];
      case UserRole.admin:
        if (!kIsWeb) return [];
        return [
          NavigationItemData(
            label: 'Overview',
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
          ),
          NavigationItemData(
            label: 'Providers',
            icon: Icons.supervised_user_circle_outlined,
            activeIcon: Icons.supervised_user_circle,
          ),
          NavigationItemData(
            label: 'Bookings',
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today,
          ),
          NavigationItemData(
            label: 'Categories',
            icon: Icons.category_outlined,
            activeIcon: Icons.category,
          ),
          NavigationItemData(
            label: 'Reviews',
            icon: Icons.rate_review_outlined,
            activeIcon: Icons.rate_review,
          ),
        ];
    }
  }
}

class NavigationItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  NavigationItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
