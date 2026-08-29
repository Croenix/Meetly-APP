import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Riverpod Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Log Standard App Open Event
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      if (kDebugMode) {
        print("AnalyticsService: Logged App Open");
      }
    } catch (e) {
      if (kDebugMode) {
        print("AnalyticsService: Error logging App Open ($e)");
      }
    }
  }

  // Log Standard Screen View Event
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logEvent(
        name: 'screen_view',
        parameters: {
          'screen_name': screenName,
          'screen_class': screenName,
        },
      );
      if (kDebugMode) {
        print("AnalyticsService: Logged Screen View ($screenName)");
      }
    } catch (e) {
      if (kDebugMode) {
        print("AnalyticsService: Error logging Screen View ($e)");
      }
    }
  }

  // Log Custom Search Event
  Future<void> logSearch(String query) async {
    try {
      await _analytics.logSearch(searchTerm: query);
      if (kDebugMode) {
        print("AnalyticsService: Logged Search Query ($query)");
      }
    } catch (e) {
      if (kDebugMode) {
        print("AnalyticsService: Error logging Search ($e)");
      }
    }
  }

  // Log Custom Category Click Event
  Future<void> logCategoryClick(String categoryName) async {
    try {
      await _analytics.logEvent(
        name: 'category_click',
        parameters: {
          'category_name': categoryName,
        },
      );
      if (kDebugMode) {
        print("AnalyticsService: Logged Category Click ($categoryName)");
      }
    } catch (e) {
      if (kDebugMode) {
        print("AnalyticsService: Error logging Category Click ($e)");
      }
    }
  }

  // Log Custom Booking Attempt Event
  Future<void> logBookingAttempt(String providerId, String category) async {
    try {
      await _analytics.logEvent(
        name: 'booking_attempt',
        parameters: {
          'provider_id': providerId,
          'category': category,
        },
      );
      if (kDebugMode) {
        print("AnalyticsService: Logged Booking Attempt ($providerId, $category)");
      }
    } catch (e) {
      if (kDebugMode) {
        print("AnalyticsService: Error logging Booking Attempt ($e)");
      }
    }
  }

  // Log Custom Banner Click Event
  Future<void> logBannerClick(String bannerId, String promoTitle) async {
    try {
      await _analytics.logEvent(
        name: 'banner_click',
        parameters: {
          'banner_id': bannerId,
          'promo_title': promoTitle,
        },
      );
      if (kDebugMode) {
        print("AnalyticsService: Logged Banner Click ($bannerId, $promoTitle)");
      }
    } catch (e) {
      if (kDebugMode) {
        print("AnalyticsService: Error logging Banner Click ($e)");
      }
    }
  }
}
