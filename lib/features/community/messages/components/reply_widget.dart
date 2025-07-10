import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../../../utilities/constants/app_colors.dart';

class ReplyWidget extends StatelessWidget {
  final String replyToContent;
  final String replyToSender;
  final bool isDarkMode;
  final VoidCallback onClose;

  const ReplyWidget({
    super.key,
    required this.replyToContent,
    required this.replyToSender,
    required this.isDarkMode,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        child: Container(
          height: 50,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: double.infinity,
                margin: const EdgeInsets.only(left: 0.0, right: 8.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey : Color(AppColors.primaryColor),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Replying to:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      replyToContent.length > 50
                          ? '${replyToContent.substring(0, 50)}...'
                          : replyToContent,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}