import 'package:iconly/iconly.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/constants/app_icons.dart';
import '../../profile/model/user_model.dart';
import '../../profile/model/user_provider.dart';
import '../model/notification_model.dart';

class NotificationItemCardStyle extends StatefulWidget {
  final NotificationModel notificationModel;
  final bool isSelected;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const NotificationItemCardStyle({
    super.key,
    required this.notificationModel,
    required this.isSelected,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  State<NotificationItemCardStyle> createState() =>
      _NotificationItemCardStyleState();
}

class _NotificationItemCardStyleState extends State<NotificationItemCardStyle> {
  bool isLoading = false;
  // final OrderService _orderService = OrderService();

  // Future<void> _handleOrderCompletionRequest(
  //   BuildContext context,
  //   String orderId,
  //   int pin,
  //   String userAction,
  //   NotificationModel notification,
  // ) async {
  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });
  //     await _orderService.acceptOrderCompletionRequest(
  //       context,
  //       orderId,
  //       pin,
  //       userAction,
  //       notification,
  //     );
  //   } catch (e) {
  //     showSnackBar(
  //       context: context,
  //       message: "Unable to complete this action, please try again later.",
  //       title: "Something Went Wrong",
  //     );
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userModel;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 3.0,
        horizontal: widget.isSelected ? 10 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: widget.onLongPress,
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                color:
                    widget.isSelected
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isSelected ? Colors.blue : Colors.transparent,
                ),
              ),
              height: widget.notificationModel.image == "" ? 45 : 114,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNotificationIcon(),
                    const SizedBox(width: 5),
                    _buildNotificationText(user),
                    const SizedBox(width: 10),
                    widget.notificationModel.image == ""
                        ? const SizedBox.shrink()
                        : _buildNotificationImage(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    if (widget.notificationModel.image == "") {
      return Expanded(
        flex: 1,
        child: Container(
          decoration: BoxDecoration(
            color: widget.notificationModel.isRead ? Colors.grey.withOpacity(0.2) : const Color(AppColors.primaryColor).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Stack(
                children: [
                  if (widget.notificationModel.title.toLowerCase().contains(
                        "PIN",
                      ) ||
                      widget.notificationModel.title.toLowerCase().contains(
                        "password",
                      ) ||
                      widget.notificationModel.title.toLowerCase().contains(
                        "account",
                      ))
                    Center(
                      child: Image.asset(
                        AppIcons.securityNotificationIcon,
                        color: const Color(AppColors.primaryColor),
                      ),
                    )
                  else if (widget.notificationModel.title
                      .toLowerCase()
                      .contains("profile"))
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Image.asset(
                          AppIcons.accountNotificationIcon,
                          color: widget.notificationModel.isRead ? Colors.grey : const Color(AppColors.primaryColor),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Image.asset(
                        AppIcons.notificationIcon,
                        color: const Color(AppColors.primaryColor),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (widget.notificationModel.notificationIcon != "") {
      return Expanded(
        flex: 2,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Image.network(
            widget.notificationModel.notificationIcon,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(IconlyBold.profile, color: Colors.grey);
            },
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildNotificationText(UserModel user) {
    return Expanded(
      flex: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.notificationModel.title.length > 30
                    ? "${widget.notificationModel.title.substring(0, 20)}.."
                    : widget.notificationModel.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.notificationModel.image == "")
                Text(
                  DateFormat(
                    'MMM d, yyyy',
                  ).format(widget.notificationModel.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
            ],
          ),
          Text(
            widget.notificationModel.message.length > 40
                ? "${widget.notificationModel.message.substring(0, 40)}.."
                : widget.notificationModel.message,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (widget.notificationModel.itemID != "") const SizedBox(height: 5),
          // if (widget.notificationModel.itemID != "") _buildActionButtons(user),
        ],
      ),
    );
  }

  // Widget _buildActionButtons(UserModel user) {
  //   return Row(
  //     children: [
  //       if (widget.notificationModel.isComplete &&
  //           !widget.notificationModel.isCancel)
  //         _buildActionButton(
  //           "Complete",
  //           Colors.blue,
  //           () => _handleOrderCompletionRequest(
  //             context,
  //             widget.notificationModel.itemID,
  //             user.accountPIN,
  //             "Completed",
  //             widget.notificationModel,
  //           ),
  //         )
  //       else if (!widget.notificationModel.isComplete &&
  //           !widget.notificationModel.isCancel)
  //         _buildActionButton(
  //           "Complete",
  //           Colors.blue,
  //           () => _handleOrderCompletionRequest(
  //             context,
  //             widget.notificationModel.itemID,
  //             user.accountPIN,
  //             "Completed",
  //             widget.notificationModel,
  //           ),
  //         )
  //       else
  //         const SizedBox.shrink(),
  //       if (!widget.notificationModel.isComplete &&
  //           !widget.notificationModel.isCancel)
  //         const SizedBox(width: 5),
  //       if (widget.notificationModel.isCancel &&
  //           !widget.notificationModel.isComplete)
  //         _buildActionButton(
  //           "Cancel",
  //           Colors.red,
  //           () => _handleOrderCompletionRequest(
  //             context,
  //             widget.notificationModel.itemID,
  //             user.accountPIN,
  //             "Incomplete",
  //             widget.notificationModel,
  //           ),
  //         )
  //       else if (!widget.notificationModel.isComplete &&
  //           !widget.notificationModel.isCancel)
  //         _buildActionButton(
  //           "Cancel",
  //           Colors.red,
  //           () => _handleOrderCompletionRequest(
  //             context,
  //             widget.notificationModel.itemID,
  //             user.accountPIN,
  //             "Incomplete",
  //             widget.notificationModel,
  //           ),
  //         )
  //       else
  //         const SizedBox.shrink(),
  //     ],
  //   );
  // }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 25,
          width: 100,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              isLoading ? "Please wait.." : text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationImage() {
    return Expanded(
      flex: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 90,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Image.network(
                widget.notificationModel.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          Text(
            DateFormat(
              'MMM d, yyyy',
            ).format(widget.notificationModel.createdAt),
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
