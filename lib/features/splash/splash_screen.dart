import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for 2.5 seconds to show the animation
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authRepo = ref.read(authRepositoryProvider);
    final onboardingDone = await authRepo.isOnboardingCompleted();
    if (!mounted) return;

    if (!onboardingDone) {
      context.go('/onboarding');
      return;
    }

    final currentUser = await authRepo.getCurrentUser();
    if (!mounted) return;
    if (currentUser != null) {
      // Direct user to correct flow based on role
      switch (currentUser.role) {
        case UserRole.customer:
          context.go('/home');
          break;
        case UserRole.provider:
          context.go('/provider/dashboard');
          break;
        case UserRole.admin:
          if (kIsWeb) {
            context.go('/admin');
          } else {
            context.go('/admin-restricted');
          }
          break;
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Beautiful App Icon Logo
              Container(
                width: 102,
                height: 102,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                ),
              )
              .animate()
              .fade(duration: 800.ms)
              .scale(delay: 200.ms, duration: 800.ms, curve: Curves.easeOutBack),

              AppSpacing.height24,

              // App Name
              Text(
                'Meetly',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              )
              .animate()
              .fade(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

              AppSpacing.height8,

              // Tagline
              Text(
                'Connect. Collaborate. Grow.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  letterSpacing: 0.5,
                ),
              )
              .animate()
              .fade(delay: 700.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
            ],
          ),
        ),
      ),
    );
  }
}
