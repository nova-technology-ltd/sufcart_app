import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_strings.dart';
import '../../../profile/model/user_model.dart';

class FollowsServices {
  final baseUrl = AppStrings.serverUrl;
  
  Future<void> getFollowers(BuildContext context, String userID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/community/follows/$userID/followers"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> getFollowing(BuildContext context, String userID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/community/follows/$userID/following"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<List<UserModel>> getAllUsers(BuildContext context) async {
    List<UserModel> users = [];
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/community/follows/users"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> responseData = jsonDecode(response.body)['data'];
        for (var userData in responseData) {
          users.add(UserModel.fromMap(userData));
        }
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
    return users;
  }

  Future<List<UserModel>> searchUsers(BuildContext context, String query) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/community/follows/search?userName=$query"),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        List<UserModel> users = [];
        if (responseBody.containsKey('users') && responseBody['users'] is List) {
          for (var userJson in responseBody['users'] as List) {
            users.add(UserModel.fromMap(userJson));
          }
          return users;
        } else {
          showSnackBar(
            context: context,
            message: "Invalid response format from server",
            title: "Data Error",
          );
          return [];
        }
      } else {
        showSnackBar(
          context: context,
          message: "Failed to search recipients: ${response.statusCode}",
          title: "Search Error",
        );
        return [];
      }
    } on FormatException catch (e) {
      showSnackBar(
        context: context,
        message: "Data format error: ${e.message}",
        title: "Data Error",
      );
      return [];
    } on http.ClientException catch (e) {
      showSnackBar(
        context: context,
        message: "Network error: ${e.message}",
        title: "Network Error",
      );
      return [];
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      return [];
    }
  }

  Future<Map<String, dynamic>> userProfileAnalytics(BuildContext context, String userID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/community/follows/user/$userID/analytics"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        // Parse the JSON response into a Map<String, dynamic>
        final Map<String, dynamic> analyticsData = jsonDecode(response.body);

        // Verify the response structure
        if (analyticsData['title'] == 'Success' && analyticsData['data'] != null) {
          return analyticsData['data'] as Map<String, dynamic>;
        } else {
          showSnackBar(
            context: context,
            message: 'Unexpected response format',
            title: 'Error',
          );
          return {};
        }
      } else if (response.statusCode == 401) {
        showSnackBar(
          context: context,
          message: 'You must be logged in to access this resource',
          title: 'Unauthorized',
        );
        return {};
      } else if (response.statusCode == 404) {
        showSnackBar(
          context: context,
          message: 'No posts found for this user',
          title: 'Not Found',
        );
        return {};
      } else {
        showSnackBar(
          context: context,
          message: 'Server Error: ${response.statusCode}',
          title: 'Server Error',
        );
        return {};
      }
    } catch (e) {
      showSnackBar(
        context: context,
        message: AppStrings.serverErrorMessage,
        title: 'Server Error',
      );
      return {};
    }
  }
}