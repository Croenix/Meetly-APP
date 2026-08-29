import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SkeletonCard extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0); // slate 700 / slate 200

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .color(
      begin: baseColor,
      end: baseColor.withAlpha(isDark ? 100 : 150),
      duration: 1000.ms,
      curve: Curves.easeInOut,
    );
  }
}
