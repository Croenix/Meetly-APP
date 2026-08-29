import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_user.dart';
import '../../core/models/chat_message.dart';
import '../../core/models/notification_item.dart';
import '../mock/mock_messages.dart';
import '../mock/mock_notifications.dart';
import '../mock/mock_users.dart';

abstract class MessageRepository {
  Future<List<ChatMessage>> getMessagesBetween(String senderId, String receiverId);
  Future<void> sendMessage(ChatMessage message);
  Future<List<AppUser>> getConversationsForUser(String userId);
  Future<List<NotificationItem>> getNotificationsForUser(String userId);
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> createNotification(NotificationItem notification);
}

class MockMessageRepository implements MessageRepository {
  final List<ChatMessage> _messages = List.from(mockMessages);
  final List<NotificationItem> _notifications = List.from(mockNotifications);

  @override
  Future<List<ChatMessage>> getMessagesBetween(String senderId, String receiverId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _messages.where((m) =>
        (m.senderId == senderId && m.receiverId == receiverId) ||
        (m.senderId == receiverId && m.receiverId == senderId)
    ).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _messages.add(message);
  }

  @override
  Future<List<AppUser>> getConversationsForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Find all unique user IDs that the current user has exchanged messages with
    final activeIds = <String>{};
    for (final msg in _messages) {
      if (msg.senderId == userId) {
        activeIds.add(msg.receiverId);
      } else if (msg.receiverId == userId) {
        activeIds.add(msg.senderId);
      }
    }

    // Map these user IDs back to user objects
    final partners = <AppUser>[];
    for (final id in activeIds) {
      try {
        final partner = allMockUsers.firstWhere((u) => u.id == id);
        partners.add(partner);
      } catch (_) {
        // If partner is a provider, look up in provider users
        final providerUserId = id.startsWith('p') ? id.replaceAll('p', 'up') : id;
        try {
          final partner = allMockUsers.firstWhere((u) => u.id == providerUserId);
          partners.add(partner);
        } catch (__) {
          // Fallback if not found
        }
      }
    }
    return partners;
  }

  @override
  Future<List<NotificationItem>> getNotificationsForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> createNotification(NotificationItem notification) async {
    _notifications.add(notification);
  }
}

// Riverpod Provider
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MockMessageRepository();
});

// Chats List Provider
final activeChatsProvider = FutureProvider.family<List<AppUser>, String>((ref, userId) async {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.getConversationsForUser(userId);
});

// Active Chat History Provider
final chatHistoryProvider = FutureProvider.family<List<ChatMessage>, ({String currentUserId, String partnerId})>((ref, arg) async {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.getMessagesBetween(arg.currentUserId, arg.partnerId);
});

// User Notifications Provider
final userNotificationsProvider = FutureProvider.family<List<NotificationItem>, String>((ref, userId) async {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.getNotificationsForUser(userId);
});
