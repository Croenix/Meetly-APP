import 'package:flutter/foundation.dart';

/// Central application configuration for server URLs, ports, and API endpoints.
/// Easily change the server URL by updating [customServerUrl] or calling [setCustomServerUrl].
class AppConfig {
  /// Default server host configuration
  static const String defaultLocalhost = 'http://localhost:5000';
  static const String defaultAndroidEmulatorHost = 'http://192.168.1.2:5000';
  static const int defaultPort = 5000;

  /// Cryptographic shared application secret for API handshakes
  static const String sharedAppSecret = 'meetly_secure_secret_2026';

  /// Custom override server URL (e.g. 'http://192.168.1.100:5000' or 'https://api.meetly.in')
  static String _customServerUrl = '';

  /// Set custom server URL dynamically at runtime
  static void setCustomServerUrl(String url) {
    _customServerUrl = url.trim().replaceAll(RegExp(r'/$'), '');
  }

  /// Get current server URL override
  static String get customServerUrl => _customServerUrl;

  /// Base Server URL auto-resolving platform defaults unless custom URL is set
  static String get baseUrl {
    if (_customServerUrl.isNotEmpty) {
      return _customServerUrl;
    }

    // Android emulator cannot access 127.0.0.1 directly; route to 10.0.2.2
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return defaultAndroidEmulatorHost;
    }

    return defaultLocalhost;
  }

  /// Base WebSocket URL auto-converting HTTP scheme to WS scheme
  static String get wsUrl {
    final base = baseUrl;
    if (base.startsWith('https://')) {
      return base.replaceFirst('https://', 'wss://');
    }
    return base.replaceFirst('http://', 'ws://');
  }

  // --- REST API ENDPOINT MAPPINGS ---

  /// Authentication Handshake endpoint
  static String get authHandshakeEndpoint => '$baseUrl/api/v1/auth/handshake';

  /// Stores (Business Listings) API endpoint
  static String get storesEndpoint => '$baseUrl/api/v1/stores';

  /// Service Providers API endpoint
  static String get serviceProvidersEndpoint =>
      '$baseUrl/api/v1/service-providers';

  /// Banners API endpoint
  static String get bannersEndpoint => '$baseUrl/api/v1/banners';

  /// Application Settings API endpoint
  static String get settingsEndpoint => '$baseUrl/api/v1/settings';

  /// Admin Business Aggregator / Directory Endpoint
  static String get adminDirectoryEndpoint =>
      '$baseUrl/api/admin/fetch-directory';
}
