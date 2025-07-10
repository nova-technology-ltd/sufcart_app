import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_strings.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../posts/model/post_model.dart';
import '../model/repost_model.dart';

class RepostService {
  final String baseUrl = AppStrings.serverUrl;

  Future<void> repostPost(BuildContext context, String postID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(Uri.parse("$baseUrl/api/v1/org/community/repost/repost-content"), headers: {
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

  Future<void> deleteRepost(BuildContext context, String repostID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.delete(Uri.parse("$baseUrl/api/v1/org/community/repost/delete-repost"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }, body: json.encode({
        "repostID": repostID,
      }));
      print(response.body);
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> getRepostByID(BuildContext context, String repostID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/community/repost/$repostID/single-repost"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      });
      print(response.body);
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<List<PostModel>> getUserReposts(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/community/repost/user-reposts"),
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
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> repostsByUser(BuildContext context, String userID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("Authorization");

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/community/repost/$userID/all-reposts"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['data'] == null || jsonResponse['data'] is! List) {
          return [];
        }
        final List<dynamic> repostsData = jsonResponse['data'] as List<dynamic>;
        return repostsData
            .where((repostJson) => repostJson != null && repostJson is Map<String, dynamic>)
            .cast<Map<String, dynamic>>()
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

}