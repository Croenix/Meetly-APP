import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/app_user.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return ResponsiveLayoutShell(
      selectedIndex: 4, // Profile tab index for Customer
      child: authState.when(
        data: (user) {
          if (user == null) {
            return const Scaffold(
              body: Center(child: Text('User details not loaded.')),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Settings'),
              centerTitle: true,
              elevation: 0,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: ResponsiveContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    child: Column(
                      children: [
                        // User Profile Header Info
                        Center(
                          child: Column(
                            children: [
                              AppAvatar(url: user.avatarUrl, name: user.name, size: 84),
                              AppSpacing.height16,
                              Text(
                                user.name,
                                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              AppSpacing.height4,
                              Text(
                                user.email,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              AppSpacing.height8,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.location,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.height32,

                        // Account & Workspace Switching Section
                        _buildSectionHeader('Account & Workspace Switching', textTheme, isDark),
                        AppSpacing.height12,
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [const Color(0xFF1E1B4B), const Color(0xFF311042)]
                                  : [const Color(0xFFEEF2FF), const Color(0xFFFDF2F8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceDark : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.swap_horiz_rounded,
                                      color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                                      size: 24,
                                    ),
                                  ),
                                  AppSpacing.width12,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Switch Role & Workspace',
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : Colors.indigo[900],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Easily switch between Customer, Service Professional, or Admin accounts.',
                                          style: textTheme.bodySmall?.copyWith(
                                            height: 1.3,
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildRoleSwitchCard(
                                      context,
                                      ref,
                                      title: 'Customer Workspace',
                                      icon: Icons.person_outline,
                                      isActive: user.role == UserRole.customer,
                                      onTap: () async {
                                        await ref.read(authStateProvider.notifier).loginAsDemo(UserRole.customer);
                                        if (context.mounted) context.go('/home');
                                      },
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildRoleSwitchCard(
                                      context,
                                      ref,
                                      title: 'Professional Portal',
                                      icon: Icons.work_outline,
                                      isActive: user.role == UserRole.provider,
                                      onTap: () async {
                                        await ref.read(authStateProvider.notifier).loginAsDemo(UserRole.provider);
                                        if (context.mounted) context.go('/provider/dashboard');
                                      },
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.height24,

                        // Other settings rows
                        _buildSectionHeader('Preferences', textTheme, isDark),
                        AppSpacing.height8,
                        _buildSettingRow(
                          icon: Icons.person_outline,
                          title: 'Account Information',
                          subtitle: 'View profile details',
                          isDark: isDark,
                        ),
                        _buildSettingRow(
                          icon: Icons.notifications_none_outlined,
                          title: 'Notifications Settings',
                          subtitle: 'Enable or disable push alters',
                          isDark: isDark,
                        ),
                        _buildSettingRow(
                          icon: Icons.payment_outlined,
                          title: 'Payment Methods',
                          subtitle: 'Manage cards and details',
                          isDark: isDark,
                        ),
                        AppSpacing.height24,

                        _buildSectionHeader('Safety', textTheme, isDark),
                        AppSpacing.height8,
                        _buildSettingRow(
                          icon: Icons.security_outlined,
                          title: 'Security',
                          subtitle: 'Update passwords and verification steps',
                          isDark: isDark,
                        ),
                        _buildSettingRow(
                          icon: Icons.support_agent_outlined,
                          title: 'Support & Help',
                          subtitle: 'Ask our team or search topics',
                          isDark: isDark,
                        ),
                        AppSpacing.height32,

                        // Logout Action Button
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.read(authStateProvider.notifier).logout();
                            context.go('/login');
                          },
                          icon: const Icon(Icons.logout_outlined, size: 18, color: AppColors.errorLight),
                          label: const Text(
                            'Logout Settings Session',
                            style: TextStyle(color: AppColors.errorLight, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.errorLight, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
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
          body: Center(child: Text('Error loading profile: $e')),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, TextTheme textTheme, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark.withValues(alpha: 0.3) : AppColors.borderLight.withValues(alpha: 0.5),
          ),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildRoleSwitchCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    const primaryColor = Color(0xFF6C5CE7);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? primaryColor
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? primaryColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            width: isActive ? 1.8 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isActive) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
