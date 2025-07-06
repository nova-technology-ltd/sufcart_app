import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/profile/model/user_model.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';
import '../../../../utilities/components/radar_glow_indicator.dart';
import '../../../profile/model/user_provider.dart';
import '../model/messages_model.dart';
import '../provider/messages_socket_provider.dart';
import '../screens/chat_screen.dart';

class MessagesCardStyle extends StatefulWidget {
  final UserModel user;
  final String roomID;

  const MessagesCardStyle({
    super.key,
    required this.user,
    required this.roomID,
  });

  @override
  State<MessagesCardStyle> createState() => _MessagesCardStyleState();
}

class _MessagesCardStyleState extends State<MessagesCardStyle> {
  Timer? _statusPollingTimer;

  @override
  void initState() {
    super.initState();
    final messagesProvider = Provider.of<MessagesSocketProvider>(context, listen: false);
    print('MessagesCardStyle init for userID: ${widget.user.userID}, roomID: ${widget.roomID}');
    messagesProvider.joinChat(widget.user.userID);
    messagesProvider.requestUserStatus(widget.user.userID);
    // Periodic polling as a fallback
    _statusPollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      print('Polling status for userID: ${widget.user.userID}');
      messagesProvider.requestUserStatus(widget.user.userID);
    });
  }

  @override
  void dispose() {
    print('Disposing MessagesCardStyle for userID: ${widget.user.userID}');
    _statusPollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).userModel;

    return Selector<MessagesSocketProvider, (List<MessagesModel>, String?, bool, UserModel)>(
      selector: (context, provider) => (
      provider.fetchChatHistory(widget.roomID),
      provider.getUserStatus(widget.roomID, widget.user.userID) ?? provider.chatUsers
          .firstWhere((u) => u.userID == widget.user.userID, orElse: () => widget.user)
          .status,
      provider.getTypingStatus(widget.roomID, widget.user.userID),
      provider.chatUsers.firstWhere(
            (u) => u.userID == widget.user.userID,
        orElse: () => widget.user,
      ),
      ),
      builder: (context, data, child) {
        final messages = data.$1;
        final userStatus = data.$2 ?? 'offline';
        final isTyping = data.$3;
        final user = data.$4;

        print('Rendering MessagesCardStyle for userID: ${user.userID}, status: $userStatus');

        // Calculate unread count
        final unreadCount = messages
            .where((msg) =>
        msg.receiverID == currentUser.userID &&
            !msg.isRead &&
            msg.senderID == widget.user.userID)
            .length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
          child: GestureDetector(
            onTap: () {
              final messagesProvider = Provider.of<MessagesSocketProvider>(context, listen: false);
              for (var msg in messages) {
                if (msg.receiverID == currentUser.userID && !msg.isRead) {
                  print('Marking message as read: ${msg.messageID}');
                  messagesProvider.markMessageAsRead(msg.messageID);
                }
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    receiver: user,
                    sender: currentUser,
                  ),
                ),
              );
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 53,
                        width: 53,
                        child: Stack(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              child: user.image.isEmpty
                                  ? const Center(
                                child: Icon(
                                  IconlyBold.profile,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              )
                                  : Image.network(
                                user.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, err, st) => const Center(
                                  child: Icon(
                                    IconlyBold.profile,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: userStatus == "online"
                                    ? RadarCircleIndicator(
                                  size: 12,
                                  color: Colors.green,
                                  animationSpeed: 5,
                                  circleCount: 3,
                                )
                                    : Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(width: 1.5, color: Colors.grey),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Container(
                                        height: 15,
                                        width: 15,
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.userName.isNotEmpty
                              ? user.userName.substring(1)
                              : '${user.firstName} ${user.lastName}'.trim(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 1),
                        if (isTyping) ...[
                          Text(
                            'Typing...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ] else ...[
                          Text(
                            user.lastMessage != null
                                ? (user.lastMessage!.content.isNotEmpty
                                ? user.lastMessage!.content
                                : user.lastMessage!.images != null && user.lastMessage!.images!.isNotEmpty
                                ? 'Image'
                                : 'No message')
                                : 'No message',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: unreadCount > 0 ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTimestamp(user.lastMessage?.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: unreadCount > 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 1),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(AppColors.primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return TimeOfDay.fromDateTime(dateTime).format(context);
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MM/dd/yy').format(dateTime);
    }
  }
}