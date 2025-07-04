import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_strings.dart';

class PostViewServices {
  final baseUrl = AppStrings.serverUrl;

  Future<void> viewPost(BuildContext context, String postID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(Uri.parse("$baseUrl/api/v1/org/community/post/add-post-view"), headers: {
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
}