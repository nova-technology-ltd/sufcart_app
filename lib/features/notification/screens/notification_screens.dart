import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../utilities/components/shima_effects/notification_item_shima_effect.dart';
import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../components/custom_notification_alert_dialog.dart';
import '../components/delete_notifications_dialog.dart';
import '../components/notification_item_card_style.dart';
import '../model/notification_model.dart';
import '../service/notification_service.dart';
import 'notification_view_screen.dart';

class NotificationScreens extends StatefulWidget {
  const NotificationScreens({super.key});

  @override
  State<NotificationScreens> createState() => _NotificationScreensState();
}

class _NotificationScreensState extends State<NotificationScreens> {
  late Future<List<NotificationModel>> _futureNotifications;
  NotificationService notificationService = NotificationService();
  List<NotificationModel> selectedNotifications = [];
  bool isSelectionMode = false;
  bool isDeletingNotifications = false;

  @override
  void initState() {
    super.initState();
    _futureNotifications = notificationService.getAllUsersNotification(context);
  }

  Future<void> refreshNotifications(BuildContext context) async {
    setState(() {
      _futureNotifications =
          notificationService.getAllUsersNotification(context);
      isSelectionMode = false;
    });
  }

  Future<void> deleteSelectedNotifications(BuildContext context) async {
    if (selectedNotifications.isNotEmpty) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return DeleteNotificationsDialog(
            okayButton: () async {
              Navigator.pop(context);
              setState(() {
                isDeletingNotifications = true;
              });

              try {
                List<String> notificationIDs =
                selectedNotifications.map((n) => n.notificationID).toList();
                await notificationService.deleteUserNotifications(
                    context, notificationIDs);
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete notifications: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() {
                  isDeletingNotifications = false;
                });
                refreshNotifications(context);
              }
            },
          );
        },
      );
    }
  }

  Future<void> _markNotificationAsRead(
      BuildContext context, NotificationModel notificationID) async {
    try {
      await notificationService.markNotificationAsRead(context, notificationID);
    } catch (e) {
      showSnackBar(
          context: context, message: "$e", title: "Something Went Wrong");
    }
  }

  void toggleSelection(NotificationModel notification) {
    setState(() {
      if (selectedNotifications.contains(notification)) {
        selectedNotifications.remove(notification);
      } else {
        selectedNotifications.add(notification);
      }
      isSelectionMode = selectedNotifications.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
          appBar: AppBar(
            backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
            surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
            leadingWidth: 90,
            title: const Text(
              "Notifications",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
            actions: [
              if (isSelectionMode)
                IconButton(
                  onPressed: () => deleteSelectedNotifications(context),
                  tooltip: "Delete",
                  icon: Icon(
                    IconlyBold.delete,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.red,
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
          body: RefreshIndicator(
            backgroundColor: Colors.white,
            color: const Color(AppColors.primaryColor),
            onRefresh: () async {
              setState(() {
                refreshNotifications(context);
              });
            },
            child: FutureBuilder<List<NotificationModel>>(
              future: _futureNotifications,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const NotificationItemShimaEffect();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LottieBuilder.asset(
                        "lottie/notification_anime.json",
                        height: 200,
                        width: 200,
                      ),
                      const Text(
                        "No Activities Yet!!",
                      ),
                      const Text(
                        "You currently don't have any available notifications yet, we will make sure to keep you notified on your actions here in korad.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      )
                    ],
                  ));
                } else {
                  Map<String, List<NotificationModel>> groupedNotification = {};
                  for (var notification in snapshot.data!) {
                    String date =
                        DateFormat('MMM d, yyyy').format(notification.createdAt);
                    if (!groupedNotification.containsKey(date)) {
                      groupedNotification[date] = [];
                    }
                    groupedNotification[date]!.add(notification);
                  }
                  // Sort notifications within each date group by `createdAt` in descending order
                  groupedNotification.forEach((key, value) {
                    value.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  });

                  List<String> sortedDates = groupedNotification.keys.toList()
                    ..sort((a, b) => DateFormat('MMM d, yyyy')
                        .parse(b)
                        .compareTo(DateFormat('MMM d, yyyy').parse(a)));

                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        for (var date in sortedDates) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: Text(
                              date,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          for (var notification in groupedNotification[date]!)
                            Dismissible(
                              key: Key(notification.notificationID),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                setState(() {
                                  snapshot.data!.remove(notification);
                                });
                                notificationService.deleteUserNotifications(
                                  context,
                                  [notification.notificationID],
                                );
                              },
                              background: Container(
                                color: const Color(AppColors.primaryColor),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(
                                  IconlyBold.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: NotificationItemCardStyle(
                                notificationModel: notification,
                                isSelected: selectedNotifications.contains(notification),
                                onLongPress: () => toggleSelection(notification),
                                onTap: isSelectionMode
                                    ? () => toggleSelection(notification)
                                    : () {
                                  if (notification.message.length > 40 && notification.image != "") {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => NotificationViewScreen(
                                          notificationModel: notification,
                                        ),
                                      ),
                                    );
                                  } else if (notification.message.length > 40 && notification.image == "") {
                                    showDialog(
                                      context: context,
                                      builder: (context) => CustomNotificationAlertDialog(
                                        notificationModel: notification,
                                        onTap: () {
                                          _markNotificationAsRead(context, notification);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                        ],
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
        if (isDeletingNotifications)
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.02)
            ),
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          )
      ],
    );
  }
}
