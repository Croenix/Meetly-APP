import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primaryLight = Color(0xFF4F46E5); // Indigo
  static const Color primaryDark = Color(0xFF818CF8);

  static const Color secondaryLight = Color(0xFF7C3AED); // Violet
  static const Color secondaryDark = Color(0xFFA78BFA);

  static const Color accentLight = Color(0xFF06B6D4); // Cyan
  static const Color accentDark = Color(0xFF22D3EE);

  // Background and Surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderDark = Color(0xFF334155); // Slate 700

  // Text colors
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50

  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400

  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500

  // Status indicators
  static const Color successLight = Color(0xFF16A34A); // Green 600
  static const Color successDark = Color(0xFF4ADE80); // Green 400

  static const Color warningLight = Color(0xFFF59E0B); // Amber 500
  static const Color warningDark = Color(0xFFFBBF24); // Amber 400

  static const Color errorLight = Color(0xFFDC2626); // Red 600
  static const Color errorDark = Color(0xFFF87171); // Red 400

  // Static functional colors
  static const Color shadowLight = Color(0x0A0F172A);
  static const Color shadowDark = Color(0x66000000);

  // Shimmer colors for skeletons
  static const Color shimmerBaseLight = Color(0xFFE2E8F0);
  static const Color shimmerHighlightLight = Color(0xFFF1F5F9);
  static const Color shimmerBaseDark = Color(0xFF334155);
  static const Color shimmerHighlightDark = Color(0xFF475569);
}
