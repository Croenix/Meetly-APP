import 'package:flutter/material.dart';

class AppDimensions {
  AppDimensions._();

  // Responsive Breakpoints
  static const double mobileBreakPoint = 600.0;
  static const double tabletBreakPoint = 1024.0;

  // Max width of content for desktop centered layout
  static const double maxContentWidth = 1200.0;

  // Border Radii
  static const double radiusExtraSmall = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 24.0;
  static const double radiusCircular = 999.0;

  static BorderRadius get borderSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderLarge => BorderRadius.circular(radiusLarge);
  static BorderRadius get borderExtraLarge => BorderRadius.circular(radiusExtraLarge);
  static BorderRadius get borderCircular => BorderRadius.circular(radiusCircular);

  // Reusable Helper to determine screen type
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= mobileBreakPoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobileBreakPoint && width <= tabletBreakPoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > tabletBreakPoint;

  static bool isScreenWide(BuildContext context) =>
      MediaQuery.of(context).size.width > mobileBreakPoint;
}
