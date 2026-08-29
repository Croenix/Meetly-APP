import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/app_user.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/message_repository.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox();

        final activeChatsAsync = ref.watch(activeChatsProvider(user.id));

        return ResponsiveLayoutShell(
          selectedIndex: 2, // Chats index
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Conversations'),
            ),
            body: ResponsiveContainer(
              usePadding: false,
              child: Column(
                children: [
                  // Search conversations bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search chats...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),

                  // Chats list
                  Expanded(
                    child: activeChatsAsync.when(
                      data: (partners) {
                        final filteredPartners = partners.where((p) {
                          if (_searchQuery.isEmpty) return true;
                          return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
                        }).toList();

                        if (filteredPartners.isEmpty) {
                          return const EmptyState(
                            icon: Icons.chat_bubble_outline,
                            title: 'No conversations',
                            description: 'Type a query or find a local service provider to start a discussion.',
                          );
                        }

                        return ListView.separated(
                          itemCount: filteredPartners.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final partner = filteredPartners[index];
                            return _ConversationTile(
                              currentUser: user,
                              partner: partner,
                              textTheme: textTheme,
                              isDark: isDark,
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => EmptyState(
                        icon: Icons.error_outline,
                        title: 'Error loading conversations',
                        description: e.toString(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  final AppUser currentUser;
  final AppUser partner;
  final TextTheme textTheme;
  final bool isDark;

  const _ConversationTile({
    required this.currentUser,
    required this.partner,
    required this.textTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read chat history to get the last message preview
    final chatHistoryAsync = ref.watch(chatHistoryProvider((
      currentUserId: currentUser.id,
      partnerId: partner.id,
    )));

    return chatHistoryAsync.when(
      data: (messages) {
        if (messages.isEmpty) return const SizedBox();

        final lastMsg = messages.last;
        final hasUnread = !lastMsg.isRead && lastMsg.senderId == partner.id;

        return ListTile(
          onTap: () {
            context.push(
              '/messages/${partner.id}',
              extra: {
                'currentUserId': currentUser.id,
                'partnerId': partner.id,
                'partnerName': partner.name,
              },
            );
          },
          leading: AppAvatar(url: partner.avatarUrl, name: partner.name, size: 48),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                partner.name,
                style: TextStyle(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                DateFormat('hh:mm a').format(lastMsg.timestamp), // show time snippet
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: hasUnread
                      ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                      : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lastMsg.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                      color: hasUnread
                          ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                ),
                if (hasUnread) ...[
                  AppSpacing.width12,
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const ListTile(
        leading: CircleAvatar(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator())),
        title: Text('Loading...'),
      ),
      error: (_, _) => const SizedBox(),
    );
  }
}
