import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Heights
  static const Widget height4 = SizedBox(height: xxs);
  static const Widget height8 = SizedBox(height: xs);
  static const Widget height12 = SizedBox(height: sm);
  static const Widget height16 = SizedBox(height: md);
  static const Widget height24 = SizedBox(height: lg);
  static const Widget height32 = SizedBox(height: xl);
  static const Widget height48 = SizedBox(height: xxl);

  // Widths
  static const Widget width4 = SizedBox(width: xxs);
  static const Widget width8 = SizedBox(width: xs);
  static const Widget width12 = SizedBox(width: sm);
  static const Widget width16 = SizedBox(width: md);
  static const Widget width24 = SizedBox(width: lg);
  static const Widget width32 = SizedBox(width: xl);
  static const Widget width48 = SizedBox(width: xxl);
}
