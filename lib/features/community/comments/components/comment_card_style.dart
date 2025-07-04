import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/constants/app_icons.dart';
import '../../../profile/model/user_model.dart';
import '../../../profile/model/user_provider.dart';
import '../model/comment_model.dart';
import 'comment_more_action_bottom_sheet.dart';
import 'comment_reply_card_style.dart';

class CommentCardStyle extends StatefulWidget {
  final CommentModel comment;
  final ReplyCommentModel? replyCommentModel; // Made nullable
  final VoidCallback onLike;
  final Function(String, String) onReply;
  final VoidCallback onDeleteClick;
  final VoidCallback onReportClick;
  final Function(String) onDeleteReplyClick; // Updated to accept replyID
  final VoidCallback onReportReplyClick;

  const CommentCardStyle({
    super.key,
    required this.comment,
    required this.onLike,
    required this.onReply,
    required this.onDeleteClick,
    required this.onReportClick,
    required this.onDeleteReplyClick,
    required this.onReportReplyClick,
    this.replyCommentModel, // Made nullable
  });

  @override
  State<CommentCardStyle> createState() => _CommentCardStyleState();
}

class _CommentCardStyleState extends State<CommentCardStyle> {
  bool _showAllReplies = false;

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

  void _showCommentMoreActionBottomSheet({
    required BuildContext context,
    required UserModel user,
    required CommentModel comment,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CommentMoreActionBottomSheet(
          onDeleteClick: () {
            Navigator.pop(context);
            widget.onDeleteClick();
          },
          onReportClick: widget.onReportClick,
          user: user,
          commentModel: comment,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final replies = widget.comment.replies
        .where(
          (reply) =>
      reply.replyUserDetails['userName'] != null &&
          reply.replyUserDetails['userName']!.isNotEmpty,
    )
        .toList();
    final displayReplies =
    _showAllReplies ? replies.reversed.toList() : replies.reversed.take(2).toList();
    final formattedTime = formatRelativeTime(widget.comment.createdAt);
    final user = Provider.of<UserProvider>(context).userModel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 35,
                width: 35,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  widget.comment.commentUserDetails['image'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, err, st) {
                    return Center(
                      child: Icon(
                        IconlyBold.profile,
                        size: 13,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.comment.commentUserDetails['userName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Container(
                            height: 4,
                            width: 4,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => _showCommentMoreActionBottomSheet(
                            context: context,
                            user: user,
                            comment: widget.comment,
                          ),
                          child: Icon(
                            Icons.more_horiz,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.comment.commentText,
                          style: const TextStyle(fontSize: 13),
                        ),
                        if (widget.comment.commentImages.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (int i = 0; i < widget.comment.commentImages.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Image.network(
                                          widget.comment.commentImages[i],
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: Image.asset(
                                                AppIcons.koradLogo,
                                                color: Colors.grey,
                                                width: 18,
                                                height: 18,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Center(
                                              child: Image.asset(
                                                AppIcons.koradLogo,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        // Row(
                        //   children: [
                        //     GestureDetector(
                        //       onTap: widget.onLike,
                        //       child: Container(
                        //         height: 19,
                        //         width: 19,
                        //         decoration: const BoxDecoration(),
                        //         child: Image.asset(
                        //           AppIcons.likeOffIcon,
                        //           color: Colors.grey,
                        //         ),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 4),
                        //     Text(
                        //       _formatLikes(widget.comment.likes),
                        //       style: TextStyle(
                        //         fontSize: 12,
                        //         color: Colors.grey[600],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            widget.onReply(
                              widget.comment.commentText,
                              widget.comment.commentID,
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.reply, color: Colors.grey, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Reply',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 46, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...displayReplies.map<Widget>((reply) {
                    return CommentReplyCardStyle(
                      reply: reply,
                      onDeleteReplyClick: () => widget.onDeleteReplyClick(reply.replyID), // Pass replyID
                      onReportReplyClick: widget.onReportReplyClick,
                    );
                  }).toList(),
                  if (replies.length > 2 && !_showAllReplies)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAllReplies = true;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Show more (${replies.length - 2} more)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(AppColors.primaryColor),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatLikes(int likes) {
    if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}k';
    }
    return likes.toString();
  }
}