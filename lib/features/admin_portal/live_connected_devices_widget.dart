import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/realtime_websocket_service.dart';

class LiveConnectedDevicesWidget extends ConsumerWidget {
  const LiveConnectedDevicesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryAsync = ref.watch(adminTelemetryStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return telemetryAsync.when(
      data: (telemetry) => _buildContent(context, telemetry, isDark),
      loading: () => _buildLoadingState(isDark),
      error: (err, stack) => _buildContent(context, AdminTelemetryData.fallbackOffline(), isDark),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminTelemetryData telemetry, bool isDark) {
    final devices = telemetry.connectedDevices;
    final totalCount = telemetry.totalConnectedDevices;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: telemetry.isConnected 
              ? const Color(0xFF34D399).withValues(alpha: 0.4)
              : Colors.red.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF6C5CE7).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: telemetry.isConnected ? const Color(0xFF34D399) : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: telemetry.isConnected ? const Color(0xFF34D399) : Colors.red,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Live Connected Devices',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalCount Active',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C5CE7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (devices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  telemetry.isConnected
                      ? '1 Active Device (Node Server Connection Established)'
                      : 'No live devices connected (Offline Mode)',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              separatorBuilder: (ctx, idx) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final dev = devices[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      dev.platform.toLowerCase().contains('web')
                          ? Icons.web_rounded
                          : Icons.phone_android_rounded,
                      color: const Color(0xFF6C5CE7),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    dev.deviceName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'ID: ${dev.deviceId} • IP: ${dev.ip}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
