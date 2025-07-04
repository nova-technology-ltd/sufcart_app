import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/constants/app_icons.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../model/notification_model.dart';

class CustomNotificationAlertDialog extends StatefulWidget {
  final NotificationModel notificationModel;
  final VoidCallback onTap;

  const CustomNotificationAlertDialog({
    super.key,
    required this.notificationModel,
    required this.onTap,
  });

  @override
  State<CustomNotificationAlertDialog> createState() => _CustomNotificationAlertDialogState();
}

class _CustomNotificationAlertDialogState extends State<CustomNotificationAlertDialog> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Center(
      child: Dialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(context),
              const SizedBox(height: 10),
              _buildTitle(),
              const SizedBox(height: 10),
              _buildMessage(),
              const SizedBox(height: 20),
              _buildOkButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: const Color(AppColors.primaryColor).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: _getNotificationIcon(),
        ),
      ),
    );
  }

  Widget _getNotificationIcon() {
    final title = widget.notificationModel.title.toLowerCase();

    if (title.contains("pin") || title.contains("password") || title.contains("account")) {
      return Image.asset(AppIcons.securityNotificationIcon, color: const Color(AppColors.primaryColor));
    } else if (title.contains("profile")) {
      return Image.asset(AppIcons.accountNotificationIcon, color: const Color(AppColors.primaryColor));
    } else if (title.contains("notification") || title.contains("notifications")) {
      return Image.asset(AppIcons.securityNotificationIcon, color: const Color(AppColors.primaryColor));
    } else {
      return Image.asset(AppIcons.notificationIcon, color: const Color(AppColors.primaryColor));
    }
  }

  Widget _buildTitle() {
    return Text(
      widget.notificationModel.title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      widget.notificationModel.message,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildOkButton(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(AppColors.primaryColor),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text(
            "OK",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}