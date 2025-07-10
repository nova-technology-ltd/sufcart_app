import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../data/provider/messages_socket_provider.dart';

class ActiveUsersSection extends StatelessWidget {
  final MessagesSocketProvider messagesSocketProvider;

  const ActiveUsersSection({super.key, required this.messagesSocketProvider});

  @override
  Widget build(BuildContext context) {
    // Filter users who are online
    final onlineUsers = messagesSocketProvider.chatUsers
        .where((user) => user.status == 'online')
        .toList();

    return onlineUsers.isEmpty ? const SizedBox.shrink() : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Active Connections",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${onlineUsers.length} of your connections are active",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: onlineUsers.isEmpty
                ? [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "No active connections",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ]
                : onlineUsers.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 10 : 3.0,
                  right: index == onlineUsers.length - 1 ? 10 : 3,
                ),
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.8, color: Colors.green),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(2.5),
                      child: Container(
                        height: 60,
                        width: 60,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          user.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(IconlyBold.profile, size: 20, color: Colors.grey,),
                        )
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // const SizedBox(height: 10),
      ],
    );
  }
}