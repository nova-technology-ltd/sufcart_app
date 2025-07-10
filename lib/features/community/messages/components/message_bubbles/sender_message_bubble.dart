import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sufcart_app/features/community/messages/components/image_message_bubble.dart';
import 'package:sufcart_app/features/community/posts/screen/image_view_screen.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';

import '../../../../../utilities/constants/app_icons.dart';
import '../../../repost/components/emoji_bottom_sheet.dart';
import '../../data/model/messages_model.dart';
import '../../data/provider/messages_socket_provider.dart';

class SenderMessageBubble extends StatefulWidget {
  final bool isDarkMode;
  final Function(String) onReactionSelected;
  final Function(String, String) onReactionRemoved;
  final bool isLastInGroup;
  final bool isFirstInGroup;
  final Function(String, String) onReply;
  final MessagesModel messagesModel;

  const SenderMessageBubble({
    super.key,
    required this.isDarkMode,
    required this.onReactionSelected,
    required this.onReactionRemoved,
    required this.isLastInGroup,
    required this.isFirstInGroup,
    required this.onReply,
    required this.messagesModel,
  });

  @override
  _SenderMessageBubbleState createState() => _SenderMessageBubbleState();
}

class _SenderMessageBubbleState extends State<SenderMessageBubble>
    with SingleTickerProviderStateMixin {
  bool _showTime = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  double _dragOffset = 0.0;
  bool _isSwiping = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0, end: -50).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showEmojiBottomSheet({
    required BuildContext context,
    required Function(Category?, Emoji)? onEmojiSelected,
    required VoidCallback? onBackspacePressed,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return EmojiBottomSheet(
          onEmojiSelected: onEmojiSelected,
          onBackspacePressed: onBackspacePressed,
        );
      },
    );
  }

  void _handleSwipe(DragUpdateDetails details) {
    setState(() {
      _isSwiping = true;
      _dragOffset += details.delta.dx;
      _dragOffset = _dragOffset.clamp(
        -50.0,
        0.0,
      ); // Slide right (negative offset)
      _animationController.value = _dragOffset / -50.0;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragOffset < -30) {
      widget.onReply(widget.messagesModel.messageID, widget.messagesModel.content);
    }
    _animationController.reverse().then((_) {
      setState(() {
        _dragOffset = 0.0;
        _isSwiping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: CupertinoContextMenu(
        actions: [
          CupertinoContextMenuAction(
            trailingIcon: CupertinoIcons.reply,
            onPressed: (){},
            child: const Text("Reply"),
          ),
          CupertinoContextMenuAction(
            trailingIcon: CupertinoIcons.delete,
            onPressed: (){
              print("Deleting message");
              context.read<MessagesSocketProvider>().deleteMessage(
                widget.messagesModel.messageID,
              );
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
          CupertinoContextMenuAction(
            trailingIcon: CupertinoIcons.heart_fill,
            onPressed: () => _showEmojiBottomSheet(
              context: context,
              onEmojiSelected: (category, emoji) {
                widget.onReactionSelected(emoji.emoji);
                Navigator.pop(context);
              },
              onBackspacePressed: () {},
            ),
            child: const Text("React"),
          ),
          CupertinoContextMenuAction(
            trailingIcon: CupertinoIcons.share,
            onPressed: (){},
            child: const Text("Share"),
          ),
        ],
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showTime = !_showTime;
              });
            },
            onHorizontalDragUpdate: _handleSwipe,
            onHorizontalDragEnd: _handleDragEnd,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final offset = _isSwiping ? _dragOffset : _slideAnimation.value;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widget.messagesModel.replyTo.isNotEmpty ? Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.reply, size: 12, color: Colors.grey,),
                                  Text(
                                    "Replying to",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: widget.isLastInGroup ? 2.5 : 1.5,
                                  top: widget.isFirstInGroup ? 2.5 : 1.5,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  (widget.messagesModel.images.isNotEmpty)
                                      ? Colors.grey.withOpacity(0.0)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: IntrinsicWidth(
                                  child: Container(
                                    padding:
                                    (widget.messagesModel.images.isNotEmpty)
                                        ? null
                                        : const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 14,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                          Text(
                                            widget.messagesModel.replyTo,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        if (widget.messagesModel.images.isNotEmpty)
                                          _buildImageWidget(widget.messagesModel.images),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ) : const SizedBox.shrink(),
                        Container(
                          margin: EdgeInsets.only(
                            bottom: widget.isLastInGroup ? 2.5 : 1.5,
                            top: widget.isFirstInGroup ? 2.5 : 1.5,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (widget.messagesModel.images.isNotEmpty)
                                    ? Colors.grey.withOpacity(0.0)
                                    : Color(AppColors.primaryColor),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight:
                                  widget.isFirstInGroup
                                      ? const Radius.circular(20)
                                      : const Radius.circular(4),
                              bottomLeft: const Radius.circular(20),
                              bottomRight:
                                  widget.isLastInGroup
                                      ? const Radius.circular(20)
                                      : const Radius.circular(4),
                            ),
                          ),
                          child: IntrinsicWidth(
                            child: Container(
                              padding:
                                  (widget.messagesModel.images.isNotEmpty)
                                      ? null
                                      : const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 14,
                                      ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (widget.messagesModel.content.isNotEmpty)
                                    Text(
                                      widget.messagesModel.content,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  if (widget.messagesModel.images.isNotEmpty)
                                    _buildImageWidget(widget.messagesModel.images),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_showTime)
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0,
                              right: 5,
                              bottom: _showTime ? 5 : 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (widget.messagesModel.reactions.isNotEmpty)
                                  _buildReactionsWidget(widget.messagesModel.reactions),
                                Icon(
                                  IconlyLight.time_circle,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  DateFormat('hh:mm a').format(widget.messagesModel.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(List<String> urls) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImageViewScreen(imageUrls: urls),
          ),
        );
      },
      child: ImageMessageBubble(
        urls: urls,
        isSender: true,
        isFirstInGroup: widget.isFirstInGroup,
        isLastInGroup: widget.isLastInGroup,
      ),
    );
  }

  Widget _buildReactionsWidget(List<dynamic> reactions) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children:
            reactions.map<Widget>((reaction) {
              return GestureDetector(
                onTap:
                    () => widget.onReactionRemoved(
                      reaction['messageID'],
                      reaction['reactionID'],
                    ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            widget.isDarkMode
                                ? Colors.black26
                                : Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    reaction['reaction'],
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
