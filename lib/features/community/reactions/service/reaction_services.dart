import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_strings.dart';

class ReactionServices {
  final baseUrl = AppStrings.serverUrl;

  Future<void> getPostReactions(BuildContext context, String postID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(Uri.parse("$baseUrl/api/v1/org/community/reaction/$postID/reactions"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }
}