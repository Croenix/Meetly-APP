import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/config/app_config.dart';
import '../../data/repositories/auth_repository.dart';

class AdminRestrictedScreen extends ConsumerWidget {
  const AdminRestrictedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0E17) : const Color(0xFFF7F6FE),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF6C5CE7).withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFEAEAFA),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.dns_rounded,
                      size: 64,
                      color: Color(0xFF6C5CE7),
                    ),
                  )
                      .animate()
                      .scale(duration: 500.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 500.ms),
                  AppSpacing.height24,
                  Text(
                    'Admin Console Hosted on Node Server',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
                  AppSpacing.height12,
                  Text(
                    'The Admin Control Panel is hosted on the Node.js Web Server Console.\n\nPlease open a web browser and navigate to ${AppConfig.baseUrl} to manage live system analytics, categories, and promotions.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 350.ms)
                      .slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
                  AppSpacing.height24,
                  
                  // Server URL Badge Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF9F8FD),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF6C5CE7).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.language_rounded, size: 18, color: Color(0xFF6C5CE7)),
                        const SizedBox(width: 8),
                        SelectableText(
                          AppConfig.baseUrl,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6C5CE7)),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.height32,

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(authStateProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text(
                        'Return to Sign In',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
