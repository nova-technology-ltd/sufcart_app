import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';

import '../../../utilities/components/app_bar_back_arrow.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../model/notification_model.dart';

class NotificationViewScreen extends StatefulWidget {
  final NotificationModel notificationModel;
  const NotificationViewScreen({super.key, required this.notificationModel});

  @override
  State<NotificationViewScreen> createState() => _NotificationViewScreenState();
}

class _NotificationViewScreenState extends State<NotificationViewScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        leadingWidth: 90,
        title: Text(
          DateFormat('MMMM dd, yyyy')
              .format(widget.notificationModel.createdAt),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              DateFormat('hh:mm a')
                  .format(widget.notificationModel.createdAt),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400,),
            ),
          ),
        ],
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: AppBarBackArrow(
            onClick: () {
          Navigator.pop(context);
        }),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.notificationModel.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Text(
                widget.notificationModel.message.trim(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey
                ),
              ),
              const SizedBox(height: 15,),
              widget.notificationModel.image == "" ? const SizedBox.shrink() : Center(
                child: Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width / 3,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Image.network(widget.notificationModel.image, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image, color: Colors.grey,),
                    );
                  },),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
