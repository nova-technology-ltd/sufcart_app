import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import '../../../../utilities/constants/app_icons.dart';
import '../../posts/screen/image_view_screen.dart';
import 'image_message_bubble.dart';

class ReceiverMessageBubble extends StatefulWidget {
  final String message;
  final List<String> images;
  final List<dynamic>? reactions;
  final bool isDarkMode;
  final String? userImage;
  final DateTime sentTime;
  final Function(String) onReactionSelected;
  final Function(String, String) onReactionRemoved;
  final bool isLastInGroup;
  final bool isFirstInGroup;
  final String messageID;
  final Function(String, String) onReply;
  final Map<String, dynamic>? replyTo;

  const ReceiverMessageBubble({
    super.key,
    required this.message,
    required this.images,
    this.reactions,
    required this.isDarkMode,
    this.userImage,
    required this.sentTime,
    required this.onReactionSelected,
    required this.onReactionRemoved,
    required this.isLastInGroup,
    required this.isFirstInGroup,
    required this.messageID,
    required this.onReply,
    this.replyTo,
  });

  @override
  _ReceiverMessageBubbleState createState() => _ReceiverMessageBubbleState();
}

class _ReceiverMessageBubbleState extends State<ReceiverMessageBubble>
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
    _slideAnimation = Tween<double>(begin: 0, end: 50).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSwipe(DragUpdateDetails details) {
    setState(() {
      _isSwiping = true;
      _dragOffset += details.delta.dx;
      _dragOffset = _dragOffset.clamp(0.0, 50.0);
      _animationController.value = _dragOffset / 50.0;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragOffset > 30) {
      widget.onReply(widget.messageID, widget.message);
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
      alignment: Alignment.centerLeft,
      child: Flexible(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showTime = !_showTime;
            });
          },
          onLongPress: () {
            _showReactionMenu(context);
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          bottom: widget.isLastInGroup ? 2.5 : 1.5,
                          top: widget.isFirstInGroup ? 2.5 : 1.5,
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: (widget.images.isNotEmpty) ? Colors.transparent : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.only(
                            topLeft: widget.isFirstInGroup

                                ? const Radius.circular(20)
                                : const Radius.circular(4),
                            topRight: const Radius.circular(20),
                            bottomLeft: widget.isLastInGroup
                                ? const Radius.circular(20)
                                : const Radius.circular(4),
                            bottomRight: const Radius.circular(20),
                          ),
                        ),
                        child: IntrinsicWidth(
                          child: Container(
                            padding: (widget.images != null && widget.images!.isNotEmpty)
                                ? null
                                : const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.message.isNotEmpty)
                                  Text(
                                    widget.message,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                if (widget.images != null && widget.images!.isNotEmpty)
                                  _buildImageWidget(widget.images!),
                                if (widget.reactions != null && widget.reactions!.isNotEmpty)
                                  _buildReactionsWidget(widget.reactions!),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_showTime)
                        Padding(
                          padding: EdgeInsets.only(top: 0, right: 5, bottom: _showTime ? 5 : 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(IconlyLight.time_circle, size: 12, color: Colors.grey),
                              const SizedBox(width: 2),
                              Text(
                                DateFormat('hh:mm a').format(widget.sentTime),
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
    );
  }

  Widget _buildImageWidget(List<String> urls) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImageViewScreen(imageUrls: urls),
          ),
        );
      },
      child: ImageMessageBubble(
        urls: urls,
        isSender: false,
        isFirstInGroup: widget.isFirstInGroup,
        isLastInGroup: widget.isLastInGroup,
      ),
    );
  }

  Widget _buildReactionsWidget(List<dynamic> reactions) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: reactions.map<Widget>((reaction) {
          return GestureDetector(
            onTap: () => widget.onReactionRemoved(reaction['messageID'], reaction['reactionID']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  void _showReactionMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: widget.isDarkMode ? Colors.grey.shade800 : Colors.white,
      items: [
        const PopupMenuItem(value: '👍', child: Text('👍', style: TextStyle(fontSize: 20))),
        const PopupMenuItem(value: '❤️', child: Text('❤️', style: TextStyle(fontSize: 20))),
        const PopupMenuItem(value: '😂', child: Text('😂', style: TextStyle(fontSize: 20))),
        const PopupMenuItem(value: '😢', child: Text('😢', style: TextStyle(fontSize: 20))),
        const PopupMenuItem(value: '😮', child: Text('😮', style: TextStyle(fontSize: 20))),
      ],
    ).then((value) {
      if (value != null) {
        widget.onReactionSelected(value);
      }
    });
  }
}