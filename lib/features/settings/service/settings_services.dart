import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_strings.dart';

class SettingsServices {
  String baseUrl = AppStrings.serverUrl;

  Future<void> getUserNotificationSettings(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/settings/notification-settings"),headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      print(response.body);
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> toggleNotificationSetting(
      BuildContext context, String settingType) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/org/settings/toggle-notification"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"settingType": settingType}),
      );
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['title'] == "Notification Setting Updated") {
          print("Success: ${jsonResponse['message']}");

        } else {
          showSnackBar(
              context: context,
              message: "${jsonResponse['message']}",
              title: "Error");
        }
      } else {}
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> enableOrDisableExtraSecurity(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(Uri.parse("$baseUrl/api/v1/org/auth/account-extra-security"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      print(response.body);
      print(response.statusCode);
      var responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        showSnackBar(context: context, message: responseBody['message'], title: responseBody['title']);
      } else {
        showSnackBar(context: context, message: responseBody['message'], title: responseBody['title']);
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }
  Future<void> enableOrDisableLoginWithAccountPIN(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(Uri.parse("$baseUrl/api/v1/org/auth/login-with-account-PIN"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      print(response.body);
      print(response.statusCode);
      var responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
      } else {
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }
  Future<void> updateSecurityQuestions(BuildContext context, List<Map<String, String>> selectedQuestions) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final url = Uri.parse("$baseUrl/api/v1/org/auth/update-security-questions");
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'securityQuestions': selectedQuestions,
        }),
      );
      print(response.body);
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }
}