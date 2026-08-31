import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/realtime_websocket_service.dart';

class ServerConnectedAvatarWidget extends ConsumerWidget {
  final String? imageUrl;
  final String fallbackInitial;
  final double radius;
  final VoidCallback? onTap;

  const ServerConnectedAvatarWidget({
    super.key,
    this.imageUrl,
    this.fallbackInitial = 'U',
    this.radius = 22.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(serverConnectionStatusProvider);

    Color borderColor;
    Color pulseDotColor;
    String tooltipText;

    switch (connectionStatus) {
      case ServerConnectionStatus.connected:
        borderColor = const Color(0xFF34D399); // Green accent
        pulseDotColor = const Color(0xFF10B981);
        tooltipText = 'Direct WebSocket Server Connected (Real-Time Live)';
        break;
      case ServerConnectionStatus.connecting:
        borderColor = Colors.amberAccent;
        pulseDotColor = Colors.amber;
        tooltipText = 'Connecting to Node.js Server...';
        break;
      case ServerConnectionStatus.disconnected:
        borderColor = Colors.redAccent;
        pulseDotColor = Colors.red;
        tooltipText = 'Server Disconnected (Offline Hive Fallback Mode)';
        break;
    }

    return Tooltip(
      message: tooltipText,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dynamic Status Ring Border
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: radius,
                backgroundColor: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                    ? NetworkImage(imageUrl!)
                    : null,
                child: (imageUrl == null || imageUrl!.isEmpty)
                    ? Text(
                        fallbackInitial.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6C5CE7),
                          fontSize: radius * 0.8,
                        ),
                      )
                    : null,
              ),
            ),

            // Live Connection Status Badge Dot
            Positioned(
              bottom: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: pulseDotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: pulseDotColor.withValues(alpha: 0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
