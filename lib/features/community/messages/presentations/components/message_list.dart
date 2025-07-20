import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconly/iconly.dart';
import 'package:sufcart_app/features/profile/model/user_provider.dart';
import '../../../../profile/model/user_model.dart';
import '../../data/model/messages_model.dart';
import '../../data/provider/messages_socket_provider.dart';
import '../../utilities/helpers.dart';
import '../components/typing_indicator.dart';
import 'package:provider/provider.dart';
import 'message_bubbles/receiver_message_bubble.dart';
import 'message_bubbles/receiver_message_link_bubble.dart';
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
    final loggedInUser = Provider.of<UserProvider>(context).userModel;
    return messages.isEmpty
        ? Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: 70,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle
              ),
              child: Image.network(receiver.image, fit: BoxFit.cover, errorBuilder: (context, err, st) {
                return Center(
                  child: Icon(IconlyBold.profile, color: Colors.grey,),
                );
              },),
            ),
            Text(
              '${receiver.firstName} ${receiver.lastName} ${receiver.otherNames}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500
              ),
            ),
            receiver.userName.isEmpty ? const SizedBox.shrink() : Text(
              receiver.userName,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${receiver.followers.length} Followers",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 4,
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle
                    ),
                  ),
                ),
                Text(
                  "${receiver.following.length} Following",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey
                  ),
                ),
              ],
            ),
            Text(
              receiver.followers.isNotEmpty && receiver.followers[0].userID == loggedInUser.userID ? "You've followed this SufCart account" : 'You are still yet to follow this SufCart account',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      shape: BoxShape.circle
                  ),
                  child: Image.network(receiver.image, fit: BoxFit.cover, errorBuilder: (context, err, st) {
                    return Center(
                      child: Icon(IconlyBold.profile, color: Colors.grey,),
                    );
                  },),
                ),
                const SizedBox(height: 3,),
                Text(
                  '${receiver.firstName} ${receiver.lastName} ${receiver.otherNames}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                  ),
                ),
                receiver.userName.isEmpty ? const SizedBox.shrink() : Text(
                  receiver.userName,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${receiver.followers.length} Followers",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        height: 4,
                        width: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle
                        ),
                      ),
                    ),
                    Text(
                      "${receiver.following.length} Following",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                      ),
                    ),
                  ],
                ),
                Text(
                  receiver.followers.isNotEmpty && receiver.followers[0].userID == loggedInUser.userID ? "You've followed this SufCart account" : 'You are still yet to follow this SufCart account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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