import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../services/sync_service.dart';

// Riverpod Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> _syncEventToServer(String name, Map<String, dynamic> params) async {
    try {
      final serverUrl = await SyncService().fetchServerUrl();
      final uri = Uri.parse('$serverUrl/api/analytics/event');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'eventName': name,
          'payload': {
            ...params,
            'timestamp': DateTime.now().toIso8601String(),
            'platform': kIsWeb ? 'Web' : defaultTargetPlatform.name,
          },
        }),
      ).timeout(const Duration(seconds: 6));
    } catch (e) {
      if (kDebugMode) {
        print("AnalyticsService: Server telemetry sync offline/ignored ($e)");
      }
    }
  }

  // Log Standard App Open Event
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      await _syncEventToServer('app_open', {'event': 'app_open'});
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
      await _syncEventToServer('screen_view', {
        'screen_name': screenName,
      });
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
      await _syncEventToServer('search', {
        'query': query,
      });
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
      await _syncEventToServer('category_click', {
        'category_name': categoryName,
      });
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
      await _syncEventToServer('booking_attempt', {
        'provider_id': providerId,
        'category': category,
      });
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
      await _syncEventToServer('banner_click', {
        'banner_id': bannerId,
        'promo_title': promoTitle,
      });
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
