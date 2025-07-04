import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_strings.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/post_model.dart';

class PostServices {
  final String baseUrl = AppStrings.serverUrl;

  Future<void> createNewPost(BuildContext context, String postText, List<String> postImages) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(Uri.parse("$baseUrl/api/v1/org/community/post/new-post"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }, body: json.encode({
        "postText": postText,
        "postImages": postImages,
      }));
      print(response.body);
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> deletePost(BuildContext context, String postID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.delete(Uri.parse("$baseUrl/api/v1/org/community/post/delete-post"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }, body: json.encode({
        "postID": postID,
      }));
      print(response.body);
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> getPostByID(BuildContext context, String postID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/community/post/single-post/$postID"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      print(response.body);
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<List<PostModel>> getAllUserPosts(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/community/post/user-posts"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> postsData = jsonResponse['data'] as List<dynamic>;
        return postsData.map((postJson) => PostModel.fromMap(postJson as Map<String, dynamic>)).toList();
      } else {
        showSnackBar(
          context: context,
          message: AppStrings.serverErrorMessage,
          title: "Server Error",
        );
        return [];
      }
    } catch (e) {
      print(e);
      showSnackBar(
        context: context,
        message: AppStrings.serverErrorMessage,
        title: "Server Error",
      );
      return [];
    }
  }

  Future<List<PostModel>> allCommunityPosts(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/community/post/community-posts"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> postsData = jsonResponse['data'] as List<dynamic>;
        return postsData.map((postJson) => PostModel.fromMap(postJson as Map<String, dynamic>)).toList();
      } else {
        showSnackBar(
          context: context,
          message: AppStrings.serverErrorMessage,
          title: "Server Error",
        );
        return [];
      }
    } catch (e) {
      print(e);
      showSnackBar(
        context: context,
        message: AppStrings.serverErrorMessage,
        title: "Server Error",
      );
      return [];
    }
  }


  Future<List<PostModel>> postsByUser(BuildContext context, String userID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/community/post/posts-by-user/$userID"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> postsData = jsonResponse['data'] as List<dynamic>;
        return postsData.map((postJson) => PostModel.fromMap(postJson as Map<String, dynamic>)).toList();
      } else {
        showSnackBar(
          context: context,
          message: AppStrings.serverErrorMessage,
          title: "Server Error",
        );
        return [];
      }
    } catch (e) {
      print(e);
      showSnackBar(
        context: context,
        message: AppStrings.serverErrorMessage,
        title: "Server Error",
      );
      return [];
    }
  }

  Future<void> searchUserPosts(BuildContext context, String name) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(Uri.parse("$baseUrl/api/v1/org/community/post/search?$name"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      print(response.body);
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }


}