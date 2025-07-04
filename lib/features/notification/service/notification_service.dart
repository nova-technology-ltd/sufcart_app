import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_strings.dart';
import '../model/notification_model.dart';

class NotificationService {
  String baseUrl = AppStrings.serverUrl;

  Future<List<NotificationModel>> getAllUsersNotification(
      BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("Authorization");
    List<NotificationModel> notifications = [];
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/notification/my-notifications"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['data'];
        for (var wishListData in responseData) {
          notifications.add(NotificationModel.fromMap(wishListData));
        }
      } else {
        // print("Failed to fetch notifications: ${response.statusCode}");
        return notifications;
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
    return notifications;
  }

  Future<void> markNotificationAsRead(
      BuildContext context, NotificationModel notificationID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(
          Uri.parse("$baseUrl/api/v1/org/notification/mark-as-read"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: json.encode({"notificationID": notificationID.notificationID}));
      print(response.body);
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<List<NotificationModel>> getAllStoreNotifications(
      BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("Authorization");
    List<NotificationModel> notifications = [];
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/notification/store-notifications"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['data'];
        for (var wishListData in responseData) {
          notifications.add(NotificationModel.fromMap(wishListData));
        }
      } else {
        // print("Failed to fetch notifications: ${response.statusCode}");
        return notifications;
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
    return notifications;
  }

  Future<Map<String, dynamic>?> getNotificationSettings(
      BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/org/notification/notification-settings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      return null;
    }
  }

  Future<void> deleteUserNotifications(
      BuildContext context, List<String> notificationIDs) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      final response = await http.delete(
        Uri.parse("$baseUrl/api/v1/org/notification/delete-notification"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "notificationIDs": notificationIDs,
        }),
      );

      if (response.statusCode == 200) {
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unable to delete notifications.")));
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> deleteStoreNotifications(
      BuildContext context, List<String> notificationIDs) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      final response = await http.delete(
        Uri.parse(
            "$baseUrl/api/v1/org/notification/delete-store-notification"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "notificationIDs": notificationIDs,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Notifications Deleted")));
      } else if (response.statusCode == 207) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("Partial Success: Some notifications were not deleted.")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unable to delete notifications.")));
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }
}
