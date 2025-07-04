import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_strings.dart';
import '../model/user_model.dart';

class ProfileService {
  final baseUrl = AppStrings.serverUrl;

  Future<int> checkIfKoradTagAlreadyExists(BuildContext context, String koradTag) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("Authorization");

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/org/wishlist/find-users"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode({
          "koradTAG": "@$koradTag",
        }),
      );
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Found");
        return response.statusCode;
      } else {
        print("Not Found");
        return response.statusCode;
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      return -1;
    }
  }

  Future<void> writeUsASoftwareReview(BuildContext context, String title, String message, String stars) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(Uri.parse("$baseUrl/api/v1/org/user/review-software"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }, body: json.encode({
        "title": title,
        "message": message,
        "stars": stars,
      }));
      print(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        showSnackBar(context: context, message: responseData['message'], title: responseData['title']);
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(context: context, message: responseData['message'], title: responseData['title']);
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<Map<String, dynamic>?> mySoftwareReview(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/user/my-software-review"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['data'] is List && responseBody['data'].isNotEmpty) {
          final List<dynamic> dataList = responseBody['data'];
          // Assuming you want to return the first item in the `data` list
          return dataList[0];
        }
        return null; // If `data` is empty, return null
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(
          context: context,
          message: responseData['message'],
          title: responseData['title'],
        );
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
    return null;
  }

  Future<void> updateUserSoftwareReview(BuildContext context, String title, String message, String stars, String SRID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.put(Uri.parse("$baseUrl/api/v1/org/user/update-user-software-review"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }, body: json.encode({
        "SRID": SRID,
        "title": title,
        "message": message,
        "stars": stars,
      }));
      print(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        showSnackBar(context: context, message: responseData['message'], title: responseData['title']);
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(context: context, message: responseData['message'], title: responseData['title']);
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> clearUserSoftwareReview(BuildContext context, String SRID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.delete(Uri.parse("$baseUrl/api/v1/org/user/clear-software-review/user"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }, body: json.encode({
        "SRID": SRID,
      }));
      print(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        showSnackBar(context: context, message: responseData['message'], title: responseData['title']);
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(context: context, message: responseData['message'], title: responseData['title']);
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> generateInviteCode(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(Uri.parse("$baseUrl/api/v1/org/user/new-invite-code"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        showSnackBar(context: context, message: responseData['message'], title: responseData['title']);
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(context: context, message: responseData['message'], title: responseData['title']);
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }
  
  Future<List<UserModel>> getAllUserInvites(BuildContext context) async {
    List<UserModel> invites = [];
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/user/user-invites"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> responseData = jsonDecode(response.body)['invites'];
        for (var categoryData in responseData) {
          invites.add(UserModel.fromMap(categoryData));
        }
      } else {
        throw Exception('Failed to fetch products');
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
    return invites;
  }


  Future<List<UserModel>> getAllUsers(BuildContext context) async {
    List<UserModel> users = [];
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/user/all-users"), headers: {
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
        Uri.parse("$baseUrl/api/v1/org/user/search?userName=$query"),
        // headers: {
        //   "Content-Type": "application/json",
        //   "Authorization": "Bearer $token"
        // },
      );

      print(response.body);

      if (response.statusCode == 200) {
        // First decode the response body
        final Map<String, dynamic> responseBody = json.decode(response.body);
        List<UserModel> users = [];

        // Check if 'users' exists and is a List
        if (responseBody.containsKey('users') && responseBody['users'] is List) {
          // Convert each user map to UserModel
          for (var userJson in responseBody['users'] as List) {
            users.add(UserModel.fromMap(userJson));
          }
          return users;
        } else {
          // Handle case where 'users' field is missing or not a list
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


}