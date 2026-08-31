import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Riverpod Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app',
      );

  Future<void> _syncEventToFirebaseDatabase(String name, Map<String, dynamic> params) async {
    try {
      final eventId = 'evt_${DateTime.now().millisecondsSinceEpoch}';
      await _database.ref('analytics_events/$eventId').set({
        'name': name,
        'parameters': params,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': kIsWeb ? 'Web' : defaultTargetPlatform.name,
      });
    } catch (e) {
      if (kDebugMode) {
        print("AnalyticsService: Error syncing event to Firebase RTDB ($e)");
      }
    }
  }

  // Log Standard App Open Event
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      await _syncEventToFirebaseDatabase('app_open', {'event': 'app_open'});
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
      await _syncEventToFirebaseDatabase('screen_view', {
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
      await _syncEventToFirebaseDatabase('search', {
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
      await _syncEventToFirebaseDatabase('category_click', {
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
      await _syncEventToFirebaseDatabase('booking_attempt', {
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
      await _syncEventToFirebaseDatabase('banner_click', {
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
