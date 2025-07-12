import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

import '../../../../../utilities/constants/app_colors.dart';
import '../../../../../utilities/themes/theme_provider.dart';
import '../../../repost/components/emoji_bottom_sheet.dart';
import '../../data/model/messages_model.dart';
import '../../data/provider/messages_socket_provider.dart';

class ReceiverMessageLinkBubble extends StatefulWidget {
  final bool isDarkMode;
  final Function(String) onReactionSelected;
  final Function(String, String) onReactionRemoved;
  final bool isLastInGroup;
  final bool isFirstInGroup;
  final Function(String, String) onReply;
  final MessagesModel messagesModel;

  const ReceiverMessageLinkBubble({
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
  State<ReceiverMessageLinkBubble> createState() => _ReceiverMessageLinkBubbleState();
}

class _ReceiverMessageLinkBubbleState extends State<ReceiverMessageLinkBubble> {
  bool _showTime = false;
  Metadata? _metadata;
  bool _isLoadingMetadata = false;

  @override
  void initState() {
    super.initState();
    _extractMetadata();
  }

  Future<void> _extractMetadata() async {
    final url = _extractUrl(widget.messagesModel.content);
    if (url != null) {
      setState(() => _isLoadingMetadata = true);
      try {
        final data = await MetadataFetch.extract(url);
        setState(() => _metadata = data);
      } catch (e) {
        print('Error fetching metadata: $e');
      } finally {
        setState(() => _isLoadingMetadata = false);
      }
    }
  }

  String? _extractUrl(String text) {
    final urlRegex = RegExp(
      r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
      caseSensitive: false,
    );
    final match = urlRegex.firstMatch(text);
    return match?.group(0);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          height: 40,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Message copied to clipboard",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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


  @override
  Widget build(BuildContext context) {
    final url = _extractUrl(widget.messagesModel.content);
    final finalLink = Uri.parse("$url");
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Align(
      alignment: Alignment.centerLeft,
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
              context.read<MessagesSocketProvider>().deleteMessage(
                widget.messagesModel.messageID,
              );
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
          CupertinoContextMenuAction(
            trailingIcon: CupertinoIcons.heart,
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
            trailingIcon: Icons.copy,
            onPressed: () {
              _copyToClipboard(widget.messagesModel.content);
              Navigator.pop(context);
            },
            child: const Text("Copy"),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        bottom: widget.isLastInGroup ? 2.5 : 1.5,
                        top: widget.isFirstInGroup ? 2.5 : 1.5),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: (widget.messagesModel.images.isNotEmpty)
                          ? Colors.transparent
                          : isDarkMode
                          ? Colors.grey.withOpacity(0.3)
                          : Colors.grey[200],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Link preview container
                        if (_metadata != null || _isLoadingMetadata)
                          GestureDetector(
                            onTap: () => url != null ? setState(() {
                              launchUrl(
                                finalLink,
                                mode: LaunchMode.externalApplication,
                              );
                            }) : null,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: widget.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: _isLoadingMetadata
                                  ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                                  : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_metadata?.image != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: widget.isFirstInGroup
                                            ? const Radius.circular(20)
                                            : const Radius.circular(4),
                                      ),
                                      child: Image.network(
                                        _metadata!.image!,
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            height: 150,
                                            color: Colors.transparent,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                    : null,
                                                color: Colors.white,
                                                strokeWidth: 4,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 150,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (_metadata?.title != null)
                                          Text(
                                            _metadata!.title!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: widget.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const SizedBox(height: 4),
                                        if (_metadata?.description != null)
                                          Text(
                                            _metadata!.description!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: widget.isDarkMode
                                                  ? Colors.grey[300]
                                                  : Colors.grey[700],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          url ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: widget.isDarkMode
                                                ? Colors.blue[200]
                                                : Colors.blue[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Message content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.messagesModel.content,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showTime)
                    Padding(
                      padding: EdgeInsets.only(
                          top: 0, right: 5, bottom: _showTime ? 5 : 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.messagesModel.reactions.isNotEmpty)
                            _buildReactionsWidget(widget.messagesModel.reactions),
                          const Icon(
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
          ),
        ),
      ),
    );
  }

  Widget _buildReactionsWidget(List<dynamic> reactions) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: reactions.map<Widget>((reaction) {
          return GestureDetector(
            onTap: () => widget.onReactionRemoved(
                reaction['messageID'], reaction['reactionID']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDarkMode
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