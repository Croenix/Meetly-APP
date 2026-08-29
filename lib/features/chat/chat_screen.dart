import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/chat_message.dart';
import '../../core/models/notification_item.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/message_repository.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> chatArgs;

  const ChatScreen({
    super.key,
    required this.chatArgs,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _simulatedReplies = [
    'Sure, I can certainly assist you with that! Can you share a photo of the spot?',
    'I am available tomorrow morning. Does 10:00 AM work for you?',
    'Perfect! I have received your request and will check my schedule. Will confirm shortly.',
    'Yes, that starting rate is fixed. Let me know if there are any extra tasks.',
    'Alright, I am wrapping up another task and will head over soon. See you shortly!',
    'Understood. I will make sure to bring the required spare parts with me.',
  ];

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String senderId, String receiverId, String receiverName) async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();

    final newMsg = ChatMessage(
      id: const Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      message: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Save message via repository
    final repo = ref.read(messageRepositoryProvider);
    await repo.sendMessage(newMsg);

    // Invalidate chat history to reload UI immediately
    final historyArg = (currentUserId: senderId, partnerId: receiverId);
    ref.invalidate(chatHistoryProvider(historyArg));
    ref.invalidate(activeChatsProvider(senderId));

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Simulated Responder Trigger (If customer talking to provider)
    if (!senderId.startsWith('p') && receiverId.startsWith('up')) {
      // Receiver is a provider user (up_ prefix represents provider auth profile)
      
      Future.delayed(const Duration(seconds: 2), () async {
        final randomReply = _simulatedReplies[Random().nextInt(_simulatedReplies.length)];
        final replyMsg = ChatMessage(
          id: const Uuid().v4(),
          senderId: receiverId, // sent from provider
          receiverId: senderId, // to customer
          message: randomReply,
          timestamp: DateTime.now(),
          isRead: false,
        );

        await repo.sendMessage(replyMsg);

        // Create a notification for the customer
        final notification = NotificationItem(
          id: const Uuid().v4(),
          userId: senderId,
          title: 'New Message from $receiverName',
          description: randomReply,
          timestamp: DateTime.now(),
          type: 'message',
          isRead: false,
        );
        await repo.createNotification(notification);

        // Refresh providers reactively
        ref.invalidate(chatHistoryProvider(historyArg));
        ref.invalidate(activeChatsProvider(senderId));
        ref.invalidate(userNotificationsProvider(senderId));

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = widget.chatArgs['currentUserId'] as String;
    final partnerId = widget.chatArgs['partnerId'] as String;
    final partnerName = widget.chatArgs['partnerName'] as String;

    final chatHistoryAsync = ref.watch(chatHistoryProvider((
      currentUserId: currentUserId,
      partnerId: partnerId,
    )));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return ResponsiveLayoutShell(
      selectedIndex: 2, // Chat Tab Index
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/messages'),
          ),
          title: Row(
            children: [
              AppAvatar(name: partnerName, size: 36),
              AppSpacing.width12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partnerName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.successLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.width4,
                        Text(
                          'Online',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.successLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: ResponsiveContainer(
          usePadding: false,
          child: Column(
            children: [
              // Message History List
              Expanded(
                child: chatHistoryAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return const Center(child: Text('No messages yet. Say hello!'));
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == currentUserId;

                        return _buildMessageBubble(msg, isMe, isDark, textTheme);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),

              // Bottom Input Bar
              _buildInputBar(currentUserId, partnerId, partnerName, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe, bool isDark, TextTheme textTheme) {
    final bubbleColor = isMe
        ? AppColors.primaryLight
        : (isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9));
        
    final textColor = isMe
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: radius,
          border: !isMe && isDark
              ? Border.all(color: AppColors.borderDark)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.message,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.3),
            ),
            AppSpacing.height4,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a').format(msg.timestamp), // show time part only
                  style: TextStyle(
                    fontSize: 9,
                    color: isMe ? Colors.white70 : Colors.grey,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 12,
                    color: msg.isRead ? Colors.lightBlueAccent : Colors.white60,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(String currentUserId, String partnerId, String partnerName, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(currentUserId, partnerId, partnerName),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: AppColors.primaryLight),
            onPressed: () => _sendMessage(currentUserId, partnerId, partnerName),
          ),
        ],
      ),
    );
  }
}
