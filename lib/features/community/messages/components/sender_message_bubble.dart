// import 'package:flutter/material.dart';
// import 'package:iconly/iconly.dart';
// import 'package:intl/intl.dart';
// import 'package:sufcart_app/features/community/posts/screen/image_view_screen.dart';
// import 'package:sufcart_app/utilities/constants/app_colors.dart';
//
// import '../../../../utilities/constants/app_icons.dart';
//
// class SenderMessageBubble extends StatefulWidget {
//   final String message;
//   final List<String> images;
//   final List<dynamic>? reactions;
//   final bool isDarkMode;
//   final DateTime sentTime;
//   final Function(String) onReactionSelected;
//   final Function(String, String) onReactionRemoved;
//   final bool isLastInGroup;
//   final bool isFirstInGroup;
//   final String messageID;
//   final Function(String, String) onReply;
//   final Map<String, dynamic>? replyTo;
//
//   const SenderMessageBubble({
//     super.key,
//     required this.message,
//     required this.images,
//     this.reactions,
//     required this.isDarkMode,
//     required this.sentTime,
//     required this.onReactionSelected,
//     required this.onReactionRemoved,
//     required this.isLastInGroup,
//     required this.isFirstInGroup,
//     required this.messageID,
//     required this.onReply,
//     this.replyTo,
//   });
//
//   @override
//   _SenderMessageBubbleState createState() => _SenderMessageBubbleState();
// }
//
// class _SenderMessageBubbleState extends State<SenderMessageBubble>
//     with SingleTickerProviderStateMixin {
//   bool _showTime = false;
//   late AnimationController _animationController;
//   late Animation<double> _slideAnimation;
//   double _dragOffset = 0.0;
//   bool _isSwiping = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _slideAnimation = Tween<double>(begin: 0, end: -50).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _handleSwipe(DragUpdateDetails details) {
//     setState(() {
//       _isSwiping = true;
//       _dragOffset += details.delta.dx;
//       _dragOffset = _dragOffset.clamp(
//         -50.0,
//         0.0,
//       ); // Slide right (negative offset)
//       _animationController.value = _dragOffset / -50.0;
//     });
//   }
//
//   void _handleDragEnd(DragEndDetails details) {
//     if (_dragOffset < -30) {
//       widget.onReply(widget.messageID, widget.message);
//     }
//     _animationController.reverse().then((_) {
//       setState(() {
//         _dragOffset = 0.0;
//         _isSwiping = false;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _showTime = !_showTime;
//           });
//         },
//         onLongPress: () {
//           _showReactionMenu(context);
//         },
//         onHorizontalDragUpdate: _handleSwipe,
//         onHorizontalDragEnd: _handleDragEnd,
//         child: AnimatedBuilder(
//           animation: _animationController,
//           builder: (context, child) {
//             final offset = _isSwiping ? _dragOffset : _slideAnimation.value;
//             return Transform.translate(
//               offset: Offset(offset, 0),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Container(
//                       margin: EdgeInsets.only(
//                         bottom: widget.isLastInGroup ? 2.5 : 1.5,
//                         top: widget.isFirstInGroup ? 2.5 : 1.5,
//                       ),
//                       constraints: BoxConstraints(
//                         maxWidth: MediaQuery.of(context).size.width * 0.75,
//                       ),
//                       decoration: BoxDecoration(
//                         color: (widget.images != null && widget.images!.isNotEmpty)
//                             ? Colors.grey.withOpacity(0.2)
//                             : Color(AppColors.primaryColor),
//                         borderRadius: BorderRadius.only(
//                           topLeft: const Radius.circular(20),
//                           topRight: widget.isFirstInGroup
//                               ? const Radius.circular(20)
//                               : const Radius.circular(4),
//                           bottomLeft: const Radius.circular(20),
//                           bottomRight: widget.isLastInGroup
//                               ? const Radius.circular(20)
//                               : const Radius.circular(4),
//                         ),
//                       ),
//                       child: IntrinsicWidth(
//                         child: Container(
//                           padding: (widget.images != null && widget.images!.isNotEmpty)
//                               ? null
//                               : const EdgeInsets.symmetric(
//                             vertical: 10,
//                             horizontal: 14,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               if (widget.message.isNotEmpty)
//                                 Text(
//                                   widget.message,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 ),
//                               if (widget.images.isNotEmpty)
//                                 _buildImageWidget(widget.images),
//                               if (widget.reactions != null && widget.reactions!.isNotEmpty)
//                                 _buildReactionsWidget(widget.reactions!),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     if (_showTime)
//                       Padding(
//                         padding: EdgeInsets.only(
//                           top: 0,
//                           right: 5,
//                           bottom: _showTime ? 5 : 0,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Icon(
//                               IconlyLight.time_circle,
//                               size: 12,
//                               color: Colors.grey,
//                             ),
//                             const SizedBox(width: 2),
//                             Text(
//                               DateFormat('hh:mm a').format(widget.sentTime),
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildImageWidget(List<String> urls) {
//     return Column(
//       children: [
//         // Padding around images if needed
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ClipRRect(
//             borderRadius: BorderRadius.only(
//               topLeft: const Radius.circular(15),
//               topRight: widget.isFirstInGroup
//                   ? const Radius.circular(15)
//                   : const Radius.circular(4),
//               bottomLeft: const Radius.circular(15),
//               bottomRight: widget.isLastInGroup
//                   ? const Radius.circular(15)
//                   : const Radius.circular(4),
//             ),
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.7,
//               ),
//               child: _buildImageContent(urls),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildImageContent(List<String> urls) {
//     if (urls.isEmpty) return const SizedBox();
//
//     if (urls.length == 1) {
//       return GestureDetector(
//         onTap: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => ImageViewScreen(imageUrl: urls.first),
//             ),
//           );
//         },
//         child: Image.network(
//           urls.first,
//           fit: BoxFit.cover,
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Container(
//               width: 180,
//               height: 210,
//               color: Colors.grey[200],
//               child: Center(
//                 child: CircularProgressIndicator(
//                   value: loadingProgress.expectedTotalBytes != null
//                       ? loadingProgress.cumulativeBytesLoaded /
//                       loadingProgress.expectedTotalBytes!
//                       : null,
//                 ),
//               ),
//             );
//           },
//           errorBuilder: (context, error, stackTrace) {
//             return Container(
//               width: 180,
//               height: 210,
//               color: Colors.grey[200],
//               child: Center(
//                 child: Icon(Icons.broken_image, color: Colors.grey[500]),
//               ),
//             );
//           },
//         ),
//       );
//     } else {
//       // For multiple images, display a grid
//       return GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 4,
//           mainAxisSpacing: 4,
//         ),
//         itemCount: urls.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => ImageViewScreen(imageUrl: urls[index]),
//                 ),
//               );
//             },
//             child: Image.network(
//               urls[index],
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Container(
//                   color: Colors.grey[200],
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       value: loadingProgress.expectedTotalBytes != null
//                           ? loadingProgress.cumulativeBytesLoaded /
//                           loadingProgress.expectedTotalBytes!
//                           : null,
//                     ),
//                   ),
//                 );
//               },
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: Colors.grey[200],
//                   child: Center(
//                     child: Icon(Icons.broken_image, color: Colors.grey[500]),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       );
//     }
//   }
//
//   Widget _buildReactionsWidget(List<dynamic> reactions) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8),
//       child: Wrap(
//         spacing: 6,
//         runSpacing: 4,
//         children:
//         reactions.map<Widget>((reaction) {
//           return GestureDetector(
//             onTap:
//                 () => widget.onReactionRemoved(
//               reaction['messageID'],
//               reaction['reactionID'],
//             ),
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 8,
//                 vertical: 4,
//               ),
//               decoration: BoxDecoration(
//                 color:
//                 widget.isDarkMode ? Colors.grey.shade800 : Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color:
//                     widget.isDarkMode
//                         ? Colors.black26
//                         : Colors.grey.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: const Offset(1, 1),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 reaction['reaction'],
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: widget.isDarkMode ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   void _showReactionMenu(BuildContext context) {
//     showMenu(
//       context: context,
//       position: const RelativeRect.fromLTRB(100, 100, 100, 100),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: widget.isDarkMode ? Colors.grey.shade800 : Colors.white,
//       items: [
//         const PopupMenuItem(
//           value: '👍',
//           child: Text('👍', style: TextStyle(fontSize: 20)),
//         ),
//         const PopupMenuItem(
//           value: '❤️',
//           child: Text('❤️', style: TextStyle(fontSize: 20)),
//         ),
//         const PopupMenuItem(
//           value: '😂',
//           child: Text('😂', style: TextStyle(fontSize: 20)),
//         ),
//         const PopupMenuItem(
//           value: '😢',
//           child: Text('😢', style: TextStyle(fontSize: 20)),
//         ),
//         const PopupMenuItem(
//           value: '😮',
//           child: Text('😮', style: TextStyle(fontSize: 20)),
//         ),
//       ],
//     ).then((value) {
//       if (value != null) {
//         widget.onReactionSelected(value);
//       }
//     });
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:sufcart_app/features/community/messages/components/image_message_bubble.dart';
import 'package:sufcart_app/features/community/posts/screen/image_view_screen.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';

import '../../../../utilities/constants/app_icons.dart';

class SenderMessageBubble extends StatefulWidget {
  final String message;
  final List<String> images;
  final List<dynamic>? reactions;
  final bool isDarkMode;
  final DateTime sentTime;
  final Function(String) onReactionSelected;
  final Function(String, String) onReactionRemoved;
  final bool isLastInGroup;
  final bool isFirstInGroup;
  final String messageID;
  final Function(String, String) onReply;
  final Map<String, dynamic>? replyTo;

  const SenderMessageBubble({
    super.key,
    required this.message,
    required this.images,
    this.reactions,
    required this.isDarkMode,
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
            onPressed: (){},
            child: const Text("Delete"),
          ),
          CupertinoContextMenuAction(
            trailingIcon: CupertinoIcons.heart_fill,
            onPressed: (){
              _showReactionMenu(context);
            },
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
                                (widget.images != null && widget.images.isNotEmpty)
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
                                  (widget.images != null &&
                                          widget.images.isNotEmpty)
                                      ? null
                                      : const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 14,
                                      ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (widget.message.isNotEmpty)
                                    Text(
                                      widget.message,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  if (widget.images != null &&
                                      widget.images.isNotEmpty)
                                    _buildImageWidget(widget.images),
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
                                if (widget.reactions != null &&
                                    widget.reactions!.isNotEmpty)
                                  _buildReactionsWidget(widget.reactions!),
                                Icon(
                                  IconlyLight.time_circle,
                                  size: 12,
                                  color: Colors.grey,
                                ),
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

  void _showReactionMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: widget.isDarkMode ? Colors.grey.shade800 : Colors.white,
      items: [
        const PopupMenuItem(
          value: '👍',
          child: Text('👍', style: TextStyle(fontSize: 20)),
        ),
        const PopupMenuItem(
          value: '❤️',
          child: Text('❤️', style: TextStyle(fontSize: 20)),
        ),
        const PopupMenuItem(
          value: '😂',
          child: Text('😂', style: TextStyle(fontSize: 20)),
        ),
        const PopupMenuItem(
          value: '😢',
          child: Text('😢', style: TextStyle(fontSize: 20)),
        ),
        const PopupMenuItem(
          value: '😮',
          child: Text('😮', style: TextStyle(fontSize: 20)),
        ),
      ],
    ).then((value) {
      if (value != null) {
        widget.onReactionSelected(value);
      }
    });
  }
}
