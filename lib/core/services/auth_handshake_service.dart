import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class HandshakeResponse {
  final bool isSuccess;
  final String sessionKey;
  final int serverTimestamp;
  final String errorMessage;

  HandshakeResponse({
    required this.isSuccess,
    required this.sessionKey,
    required this.serverTimestamp,
    this.errorMessage = '',
  });

  factory HandshakeResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return HandshakeResponse(
        isSuccess: false,
        sessionKey: '',
        serverTimestamp: 0,
        errorMessage: 'Invalid null response from server',
      );
    }

    final isOk = (json['status']?.toString() == 'success') || (json['success'] == true);
    return HandshakeResponse(
      isSuccess: isOk,
      sessionKey: json['sessionKey']?.toString() ?? '',
      serverTimestamp: (json['serverTimestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      errorMessage: json['error']?.toString() ?? json['message']?.toString() ?? '',
    );
  }
}
class AuthHandshakeService {
  static String get appSecret => AppConfig.sharedAppSecret;

  // Perform secure HTTP POST handshake exchange
  static Future<HandshakeResponse> performHandshake({
    String? serverBaseUrl,
    required String userId,
    required String deviceId,
  }) async {
    try {
      final baseUrl = (serverBaseUrl != null && serverBaseUrl.isNotEmpty) ? serverBaseUrl : AppConfig.baseUrl;
      final endpointUrl = Uri.parse('$baseUrl/api/v1/auth/handshake');
      if (kDebugMode) {
        print("HandshakeService: Sending POST handshake request to $endpointUrl...");
      }

      final response = await http.post(
        endpointUrl,
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': appSecret,
        },
        body: jsonEncode({
          'userId': userId,
          'deviceId': deviceId,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final handshakeRes = HandshakeResponse.fromJson(data);
        if (kDebugMode) {
          print("HandshakeService: Handshake succeeded! Token: ${handshakeRes.sessionKey}");
        }
        return handshakeRes;
      } else {
        if (kDebugMode) {
          print("HandshakeService: Handshake HTTP error ${response.statusCode}: ${response.body}");
        }
        return HandshakeResponse(
          isSuccess: false,
          sessionKey: '',
          serverTimestamp: 0,
          errorMessage: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("HandshakeService: Exception during handshake ($e)");
      }
      return HandshakeResponse(
        isSuccess: false,
        sessionKey: '',
        serverTimestamp: 0,
        errorMessage: 'Network exception: $e',
      );
    }
  }
}
