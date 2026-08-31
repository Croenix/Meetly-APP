import 'package:flutter/foundation.dart';

// Defensive Model for Verified Live Connected Devices
class DeviceSessionModel {
  final String deviceId;
  final String userId;
  final String deviceName;
  final String platform;
  final String ip;
  final String connectedAt;

  DeviceSessionModel({
    required this.deviceId,
    required this.userId,
    required this.deviceName,
    required this.platform,
    required this.ip,
    required this.connectedAt,
  });

  factory DeviceSessionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DeviceSessionModel.fallback();
    }
    return DeviceSessionModel(
      deviceId: json['deviceId']?.toString() ?? 'dev_unknown',
      userId: json['userId']?.toString() ?? 'guest_user',
      deviceName: json['deviceName']?.toString() ?? 'Flutter Application',
      platform: json['platform']?.toString() ?? 'Mobile',
      ip: json['ip']?.toString() ?? '127.0.0.1',
      connectedAt: json['connectedAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  factory DeviceSessionModel.fallback() {
    return DeviceSessionModel(
      deviceId: 'dev_offline',
      userId: 'offline_user',
      deviceName: 'Offline Device Session',
      platform: 'Unknown',
      ip: '127.0.0.1',
      connectedAt: DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'userId': userId,
        'deviceName': deviceName,
        'platform': platform,
        'ip': ip,
        'connectedAt': connectedAt,
      };
}

// Defensive Model for Real-Time System Analytics & Telemetry Payload
class SystemTelemetryModel {
  final int activeConnections;
  final int totalConnectedDevices;
  final List<DeviceSessionModel> connectedDevices;
  final int totalUsers;
  final int customerCount;
  final int providerCount;
  final int totalBookings;
  final Map<String, int> bookingMetrics;
  final double totalRevenue;
  final double avgTicketSize;
  final String currency;
  final String timestamp;
  final bool isConnected;

  SystemTelemetryModel({
    required this.activeConnections,
    required this.totalConnectedDevices,
    required this.connectedDevices,
    required this.totalUsers,
    required this.customerCount,
    required this.providerCount,
    required this.totalBookings,
    required this.bookingMetrics,
    required this.totalRevenue,
    required this.avgTicketSize,
    required this.currency,
    required this.timestamp,
    this.isConnected = true,
  });

  factory SystemTelemetryModel.fallbackOffline() {
    return SystemTelemetryModel(
      activeConnections: 0,
      totalConnectedDevices: 0,
      connectedDevices: [],
      totalUsers: 0,
      customerCount: 0,
      providerCount: 0,
      totalBookings: 0,
      bookingMetrics: {
        'pending': 0,
        'confirmed': 0,
        'inProgress': 0,
        'completed': 0,
        'cancelled': 0,
      },
      totalRevenue: 0.0,
      avgTicketSize: 0.0,
      currency: "INR",
      timestamp: DateTime.now().toIso8601String(),
      isConnected: false,
    );
  }

  factory SystemTelemetryModel.fromJson(Map<String, dynamic>? json, {bool isConnected = true}) {
    if (json == null) {
      return SystemTelemetryModel.fallbackOffline();
    }

    final bMetrics = json['bookingMetrics'] as Map<String, dynamic>? ?? {};
    final rMetrics = json['revenueMetrics'] as Map<String, dynamic>? ?? {};

    List<DeviceSessionModel> parsedDevices = [];
    if (json['connectedDevices'] is List) {
      try {
        parsedDevices = (json['connectedDevices'] as List)
            .map((item) => DeviceSessionModel.fromJson(
                item is Map ? Map<String, dynamic>.from(item) : null))
            .toList();
      } catch (e) {
        if (kDebugMode) {
          print("SystemTelemetryModel: Error parsing connectedDevices list ($e)");
        }
      }
    }

    final totalDevs = (json['totalConnectedDevices'] as num?)?.toInt() ??
        (json['activeConnections'] as num?)?.toInt() ??
        parsedDevices.length;

    return SystemTelemetryModel(
      activeConnections: totalDevs,
      totalConnectedDevices: totalDevs,
      connectedDevices: parsedDevices,
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      customerCount: (json['customerCount'] as num?)?.toInt() ?? 0,
      providerCount: (json['providerCount'] as num?)?.toInt() ?? 0,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      bookingMetrics: {
        'pending': (bMetrics['pending'] as num?)?.toInt() ?? 0,
        'confirmed': (bMetrics['confirmed'] as num?)?.toInt() ?? 0,
        'inProgress': (bMetrics['inProgress'] as num?)?.toInt() ?? 0,
        'completed': (bMetrics['completed'] as num?)?.toInt() ?? 0,
        'cancelled': (bMetrics['cancelled'] as num?)?.toInt() ?? 0,
      },
      totalRevenue: (rMetrics['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      avgTicketSize: (rMetrics['avgTicketSize'] as num?)?.toDouble() ?? 0.0,
      currency: rMetrics['currency']?.toString() ?? "INR",
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      isConnected: isConnected,
    );
  }
}
