import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/model/messages_model.dart';

class ChatHelper {
  static String getRoomID(String senderID, String receiverID) {
    final ids = [senderID, receiverID];
    ids.sort();
    return 'chat:${ids.join(':')}';
  }

  static Widget buildDateHeader(List<MessagesModel> messages, int index, bool isDarkMode) {
    if (index == 0 || !_isSameDay(messages[index].createdAt, messages[index - 1].createdAt)) {
      final date = messages[index].createdAt;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(date.year, date.month, date.day);

      String dateText;
      if (messageDate == today) {
        dateText = 'Today';
      } else if (messageDate == yesterday) {
        dateText = 'Yesterday';
      } else {
        dateText = DateFormat('d MMMM').format(date);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? null : Colors.grey,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}