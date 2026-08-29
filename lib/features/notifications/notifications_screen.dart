import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/notification_item.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/message_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _markAsRead(BuildContext context, WidgetRef ref, NotificationItem notification, String userId) async {
    if (!notification.isRead) {
      final repo = ref.read(messageRepositoryProvider);
      await repo.markNotificationAsRead(notification.id);
      
      // Invalidate provider list to refresh state reactively
      ref.invalidate(userNotificationsProvider(userId));
    }

    // Optional navigation based on notification type
    if (notification.type == 'message' && context.mounted) {
      context.push('/messages');
    } else if (notification.type == 'booking' && context.mounted) {
      context.push('/bookings');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox();

        final notificationsAsync = ref.watch(userNotificationsProvider(user.id));

        return ResponsiveLayoutShell(
          selectedIndex: 0, // Home / General Index
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: ResponsiveContainer(
              usePadding: false,
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const EmptyState(
                      icon: Icons.notifications_none_outlined,
                      title: 'All caught up! 🔔',
                      description: 'You have no new alerts. Notifications about booking updates and incoming messages will show up here.',
                    );
                  }

                  return ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final n = notifications[index];

                      return InkWell(
                        onTap: () => _markAsRead(context, ref, n, user.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          color: n.isRead
                              ? Colors.transparent
                              : (isDark ? AppColors.primaryDark.withAlpha(20) : AppColors.primaryLight.withAlpha(8)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type Indicator Icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getNotificationColor(n.type, isDark),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getNotificationIcon(n.type),
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              AppSpacing.width16,
                              
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title,
                                            style: TextStyle(
                                              fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd MMM, hh:mm a').format(n.timestamp),
                                          style: textTheme.bodySmall?.copyWith(
                                            fontSize: 10,
                                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppSpacing.height4,
                                    Text(
                                      n.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Error loading notifications',
                  description: e.toString(),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'message':
        return Icons.chat_bubble_outline;
      case 'booking':
        return Icons.calendar_today_outlined;
      case 'verification':
        return Icons.verified_user_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type, bool isDark) {
    switch (type) {
      case 'message':
        return AppColors.primaryLight;
      case 'booking':
        return const Color(0xFF10B981); // green
      case 'verification':
        return const Color(0xFF0284C7); // blue
      default:
        return Colors.grey;
    }
  }
}
