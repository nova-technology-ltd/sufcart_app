import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:animate_do/animate_do.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../repost/components/emoji_bottom_sheet.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode textFieldFocusNode;
  final bool isDarkMode;
  final List<File> postResultImages;
  final bool isSendingImages;
  final String? replyToContent;
  final VoidCallback onPickImages;
  final VoidCallback onSnapPicture;
  final VoidCallback onSendMessage;
  final VoidCallback onSendImage;
  final VoidCallback onTextChanged;

  const MessageInput({
    super.key,
    required this.messageController,
    required this.textFieldFocusNode,
    required this.isDarkMode,
    required this.postResultImages,
    required this.isSendingImages,
    required this.replyToContent,
    required this.onPickImages,
    required this.onSnapPicture,
    required this.onSendMessage,
    required this.onSendImage,
    required this.onTextChanged,
  });

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors
            .white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.transparent : Colors.grey.withOpacity(
                0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < postResultImages.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 8.0 : 3,
                  right: i == postResultImages.length - 1 ? 8 : 3,
                ),
                child: FadeInLeft(
                  duration: Duration(milliseconds: 500),
                  delay: Duration(milliseconds: 100),
                  child: Container(
                    height: 80,
                    width: 80,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.file(
                            postResultImages[i],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: GestureDetector(
                                  onTap: () {
                                    postResultImages.removeAt(i);
                                    (context as Element).markNeedsBuild();
                                  },
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
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
          ],
        ),
      ),
      SizedBox(height: postResultImages.isNotEmpty ? 5 : 0),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onPickImages,
              child: Icon(IconlyLight.image, color: Colors.grey),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: onSnapPicture,
              child: Icon(
                IconlyLight.camera,
                color: Colors.grey,
                size: 25,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 4 * 40.0,
                ),
                decoration: BoxDecoration(),
                child: TextFormField(
                  controller: messageController,
                  focusNode: textFieldFocusNode,
                  minLines: 1,
                  maxLines: 4,
                  cursorHeight: 17,
                  cursorColor: Colors.grey,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  readOnly: postResultImages.isNotEmpty ? true : false,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    fillColor: isDarkMode
                        ? Colors.grey[700]!.withOpacity(0.3)
                        : Colors.grey[200]!.withOpacity(0.5),
                    filled: true,
                    hintText: replyToContent != null
                        ? "Replying to: ${replyToContent!.length > 17 ? '${replyToContent!.substring(0, 17)}...' : replyToContent}"
                        : postResultImages.isNotEmpty
                        ? "Send image${postResultImages.length > 1 ? 's' : ''}"
                        : "Type a message...",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => _showEmojiBottomSheet(
                        context: context,
                        onEmojiSelected: (category, emoji) {
                          messageController.text += emoji.emoji; // Append emoji instead of replacing
                        },
                        onBackspacePressed: () {},
                      ),
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onFieldSubmitted: (_) => onSendMessage(),
                  onChanged: (value) => onTextChanged(),
                ),
              ),
            ),
            ZoomIn(
              duration: const Duration(milliseconds: 400),
              child: GestureDetector(
                onTap: postResultImages.isNotEmpty
                    ? onSendImage
                    : onSendMessage,
                child: Container(
                  height: 40,
                  width: 30,
                  decoration: BoxDecoration(),
                  child: isSendingImages
                      ? Center(
                    child: CupertinoActivityIndicator(),
                  )
                      : Center(
                    child: Transform.rotate(
                      angle: 0.8,
                      child: Icon(
                        IconlyLight.send,
                        color: Colors.grey,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ]));
  }
}