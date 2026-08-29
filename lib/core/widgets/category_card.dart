import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  factory CategoryCard.fromName(String name) {
    // Map categories case-insensitively to custom colored cards with original name preserved
    switch (name.toLowerCase()) {
      case 'electrician':
      case 'electrical':
        return CategoryCard(
          categoryName: name,
          icon: Icons.electric_bolt_outlined,
          backgroundColor: const Color(0xFFEEF2FF), // soft indigo
          iconColor: const Color(0xFF4F46E5),
        );
      case 'plumber':
      case 'plumbing':
        return CategoryCard(
          categoryName: name,
          icon: Icons.water_drop_outlined,
          backgroundColor: const Color(0xFFE0F2FE), // soft blue
          iconColor: const Color(0xFF0284C7),
        );
      case 'ac repair':
      case 'appliance':
        return CategoryCard(
          categoryName: name,
          icon: Icons.ac_unit_outlined,
          backgroundColor: const Color(0xFFE0F7FA), // soft cyan
          iconColor: const Color(0xFF00ACC1),
        );
      case 'cleaning':
        return CategoryCard(
          categoryName: name,
          icon: Icons.cleaning_services_outlined,
          backgroundColor: const Color(0xFFDCFCE7), // soft green
          iconColor: const Color(0xFF16A34A),
        );
      case 'carpenter':
      case 'carpentry':
        return CategoryCard(
          categoryName: name,
          icon: Icons.handyman_outlined,
          backgroundColor: const Color(0xFFFEF3C7), // soft amber
          iconColor: const Color(0xFFD97706),
        );
      case 'painter':
      case 'painting':
        return CategoryCard(
          categoryName: name,
          icon: Icons.format_paint_outlined,
          backgroundColor: const Color(0xFFFDF2F8), // soft pink
          iconColor: const Color(0xFFDB2777),
        );
      case 'computer repair':
        return CategoryCard(
          categoryName: name,
          icon: Icons.laptop_mac_outlined,
          backgroundColor: const Color(0xFFF1F5F9), // soft grey
          iconColor: const Color(0xFF475569),
        );
      case 'tutor':
        return CategoryCard(
          categoryName: name,
          icon: Icons.school_outlined,
          backgroundColor: const Color(0xFFFAF5FF), // soft purple
          iconColor: const Color(0xFF9333EA),
        );
      case 'mechanic':
        return CategoryCard(
          categoryName: name,
          icon: Icons.build_circle_outlined,
          backgroundColor: const Color(0xFFFFF7ED), // soft orange
          iconColor: const Color(0xFFEA580C),
        );
      case 'pest control':
        return CategoryCard(
          categoryName: name,
          icon: Icons.bug_report_outlined,
          backgroundColor: const Color(0xFFFEE2E2), // soft red
          iconColor: const Color(0xFFEF4444),
        );
      case 'beauty':
      case 'salon':
        return CategoryCard(
          categoryName: name,
          icon: Icons.face_retouching_natural_outlined,
          backgroundColor: const Color(0xFFFFF1F2), // soft rose
          iconColor: const Color(0xFFE11D48),
        );
      default:
        return CategoryCard(
          categoryName: name,
          icon: Icons.miscellaneous_services_outlined,
          backgroundColor: const Color(0xFFF8FAFC),
          iconColor: const Color(0xFF64748B),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Elegant Icon circle with interactive circular inkwell
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.push('/category/$categoryName');
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? iconColor.withValues(alpha: 0.3)
                      : iconColor.withValues(alpha: 0.12),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : iconColor).withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(child: Icon(icon, size: 26, color: iconColor)),
            ),
          ),
        ),
        AppSpacing.height8,
        // Label
        Text(
          categoryName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: -0.2,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
