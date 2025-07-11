import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_strings.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../posts/model/post_model.dart';

class ReportServices {
  final String baseUrl = AppStrings.serverUrl;

  Future<void> newReport(BuildContext context, String postID, String reason) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(Uri.parse("$baseUrl/api/v1/org/community/report/report-post"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }, body: json.encode({
        "postID": postID,
        "reason": reason,
      }));
      print(response.body);
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

}