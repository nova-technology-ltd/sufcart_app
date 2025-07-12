import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sufcart_app/features/community/messages/components/message_bubbles/receiver_message_link_bubble.dart';
import '../components/typing_indicator.dart';
import '../../../profile/model/user_model.dart';
import '../data/model/messages_model.dart';
import 'package:provider/provider.dart';
import '../data/provider/messages_socket_provider.dart';
import '../utilities/helpers.dart';
import 'message_bubbles/receiver_message_bubble.dart';
import 'message_bubbles/sender_message_bubble.dart';
import 'message_bubbles/sender_link_message_bubble.dart';

class MessageList extends StatelessWidget {
  final List<MessagesModel> messages;
  final ScrollController scrollController;
  final bool isDarkMode;
  final String currentUserId;
  final UserModel receiver;
  final bool isReceiverTyping;
  final Function(String, String) onReply;

  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.isDarkMode,
    required this.currentUserId,
    required this.receiver,
    required this.isReceiverTyping,
    required this.onReply,
  });

  // Helper method to detect URLs in text
  bool _containsUrl(String text) {
    final urlRegex = RegExp(
      r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return messages.isEmpty
        ? Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 600),
        child: Text(
          'No messages yet',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    )
        : SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            for (var i = 0; i < messages.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ChatHelper.buildDateHeader(messages, i, isDarkMode),
                  _buildMessageTile(messages[i], context),
                ],
              ),
            if (isReceiverTyping)
              ZoomIn(
                duration: Duration(milliseconds: 800),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0, bottom: 8.0),
                    child: TypingIndicator(
                      dotColor: Colors.grey.withOpacity(0.2),
                      dotSize: 8.0,
                      animationDuration: const Duration(milliseconds: 800),
                      amplitude: 3.0,
                      userModel: receiver,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTile(MessagesModel message, BuildContext context) {
    final userIds = [currentUserId, receiver.userID];
    userIds.sort();
    final roomID = 'chat:${userIds.join(':')}';
    final messages = context.read<MessagesSocketProvider>().fetchChatHistory(roomID);
    final currentIndex = messages.indexOf(message);
    final isFirstInGroup = currentIndex == 0 || messages[currentIndex - 1].senderID != message.senderID;
    final isLastInGroup = currentIndex == messages.length - 1 || messages[currentIndex + 1].senderID != message.senderID;

    if (message.senderID == currentUserId) {
      // Check if message contains URL and no images
      if (_containsUrl(message.content) && message.images.isEmpty) {
        return Align(
          alignment: Alignment.centerRight,
          child: SenderLinkMessageBubble(
            isDarkMode: isDarkMode,
            onReply: onReply,
            onReactionSelected: (reaction) {
              context.read<MessagesSocketProvider>().addMessageReaction(
                  message.messageID, reaction);
            },
            onReactionRemoved: (messageId, reactionId) {
              context.read<MessagesSocketProvider>().removeMessageReaction(
                  messageId, reactionId);
            },
            isLastInGroup: isLastInGroup,
            isFirstInGroup: isFirstInGroup,
            messagesModel: message,
          ),
        );
      } else {
        // Regular message bubble
        return Align(
          alignment: Alignment.centerRight,
          child: SenderMessageBubble(
            isDarkMode: isDarkMode,
            onReply: onReply,
            onReactionSelected: (reaction) {
              context.read<MessagesSocketProvider>().addMessageReaction(
                  message.messageID, reaction);
            },
            onReactionRemoved: (messageId, reactionId) {
              context.read<MessagesSocketProvider>().removeMessageReaction(
                  messageId, reactionId);
            },
            isLastInGroup: isLastInGroup,
            isFirstInGroup: isFirstInGroup,
            messagesModel: message,
          ),
        );
      }
    } else {
      if (_containsUrl(message.content) && message.images.isEmpty) {
        return Align(
          alignment: Alignment.centerLeft,
          child: ReceiverMessageLinkBubble(
            isDarkMode: isDarkMode,
            onReply: onReply,
            onReactionSelected: (reaction) {
              context.read<MessagesSocketProvider>().addMessageReaction(
                  message.messageID, reaction);
            },
            onReactionRemoved: (messageId, reactionId) {
              context.read<MessagesSocketProvider>().removeMessageReaction(
                  messageId, reactionId);
            },
            isLastInGroup: isLastInGroup,
            isFirstInGroup: isFirstInGroup,
            messagesModel: message,
          ),
        );
      } else {
        return Align(
          alignment: Alignment.centerLeft,
          child: ReceiverMessageBubble(
            isDarkMode: isDarkMode,
            userData: receiver,
            messageID: message.messageID,
            onReply: onReply,
            replyTo: {},
            onReactionSelected: (reaction) {
              context.read<MessagesSocketProvider>().addMessageReaction(
                  message.messageID, reaction);
            },
            onReactionRemoved: (messageId, reactionId) {
              context.read<MessagesSocketProvider>().removeMessageReaction(
                  messageId, reactionId);
            },
            isLastInGroup: isLastInGroup,
            isFirstInGroup: isFirstInGroup,
            messagesModel: message,
          ),
        );
      }
    }
  }
}