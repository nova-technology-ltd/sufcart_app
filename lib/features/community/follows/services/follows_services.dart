import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_strings.dart';
import '../../../profile/model/user_model.dart';

class FollowsServices {
  final baseUrl = AppStrings.serverUrl;
  
  Future<List<UserModel>> getFollowers(BuildContext context, String userID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/community/follows/$userID/followers"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      final responseData = jsonDecode(response.body);
      final List<dynamic> followersData = responseData['data'];
      final List<UserModel> followers = followersData.map((data) => UserModel.fromMap(data)).toList();
      return followers;
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
    return [];
  }

  Future<List<UserModel>> getConnections(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/community/follows/user/connections"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      print(response.body);
      final responseData = jsonDecode(response.body);
      final List<dynamic> followingsData = responseData['data'];
      final List<UserModel> followings = followingsData.map((data) => UserModel.fromMap(data)).toList();
      return followings;
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
    return[];
  }

  Future<List<UserModel>> getFollowing(BuildContext context, String userID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/community/follows/$userID/following"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      print(response.body);
      final responseData = jsonDecode(response.body);
      final List<dynamic> followingsData = responseData['data'];
      final List<UserModel> followings = followingsData.map((data) => UserModel.fromMap(data)).toList();
      return followings;
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
    return[];
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
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        List<UserModel> users = [];
        if (responseBody.containsKey('users') && responseBody['users'] is List) {
          for (var userJson in responseBody['users'] as List) {
            users.add(UserModel.fromMap(userJson));
          }
          return users;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } on FormatException catch (e) {
      return [];
    } on http.ClientException catch (e) {
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
      if (response.statusCode == 200) {
        final Map<String, dynamic> analyticsData = jsonDecode(response.body);
        if (analyticsData['title'] == 'Success' && analyticsData['data'] != null) {
          return analyticsData['data'] as Map<String, dynamic>;
        } else {
          return {};
        }
      } else if (response.statusCode == 401) {
        return {};
      } else if (response.statusCode == 404) {
        return {};
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }
}