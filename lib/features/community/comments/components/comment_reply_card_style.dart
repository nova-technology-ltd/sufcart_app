import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/comments/components/reply_more_action_bottom_sheet.dart';

import '../../../../../utilities/constants/app_icons.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../profile/model/user_model.dart';
import '../../../profile/model/user_provider.dart';
import '../model/comment_model.dart';
import 'comment_more_action_bottom_sheet.dart';

class CommentReplyCardStyle extends StatefulWidget {
  final ReplyCommentModel reply;
  final VoidCallback onDeleteReplyClick;
  final VoidCallback onReportReplyClick;
  const CommentReplyCardStyle({super.key, required this.reply, required this.onDeleteReplyClick, required this.onReportReplyClick});

  @override
  State<CommentReplyCardStyle> createState() => _CommentReplyCardStyleState();
}

class _CommentReplyCardStyleState extends State<CommentReplyCardStyle> {
  void _showReplyMoreActionBottomSheet({
    required BuildContext context,
    required UserModel user,
    required ReplyCommentModel reply,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return ReplyMoreActionBottomSheet(
          onDeleteClick: () {
            Navigator.pop(context);
            widget.onDeleteReplyClick();
          },
          onReportClick: widget.onReportReplyClick,
          user: user,
          replyCommentModel: reply,
        );
      },
    );
  }
  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes${minutes == 1 ? 'm' : 'm'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours${hours == 1 ? 'hr' : 'hrs'} ago';
    } else if (difference.inDays < 10) {
      final days = difference.inDays;
      return '$days${days == 1 ? ' day' : ' days'} ago';
    } else {
      final formatter = DateFormat('d MMM yyyy');
      return formatter.format(dateTime);
    }
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userModel;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Image.network(
              widget.reply.replyUserDetails['image'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, err, st) {
                return Center(
                  child: Icon(
                    IconlyBold.profile,
                    size: 16,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.reply.replyUserDetails['userName'] ?? "${widget.reply.replyUserDetails['firstName']} ${widget.reply.replyUserDetails['lastName']} ${widget.reply.replyUserDetails['otherNames']}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? null : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatRelativeTime(widget.reply.updatedAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap:
                          () => _showReplyMoreActionBottomSheet(
                        context: context,
                        user: user,
                        reply: widget.reply,
                      ),
                      child: Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.reply.replyText,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? null : Colors.black87,
                  ),
                ),
                if (widget.reply.replyImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        for (
                        int i = 0;
                        i < widget.reply.replyImages.length;
                        i++
                        )
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                            ),
                            child: Container(
                              height: 40,
                              width: 40,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Image.network(
                                widget.reply.replyImages[i],
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                    ) {
                                  if (loadingProgress == null)
                                    return child;
                                  return Center(
                                    child: Image.asset(
                                      AppIcons.koradLogo,
                                      color: Colors.grey,
                                      width: 16,
                                      height: 16,
                                    ),
                                  );
                                },
                                errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return Center(
                                    child: Image.asset(
                                      AppIcons.koradLogo,
                                      color: Colors.grey,
                                      width: 16,
                                      height: 16,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
