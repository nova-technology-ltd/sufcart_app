import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_strings.dart';
import '../../posts/model/post_model.dart';
import '../model/comment_model.dart';

class CommentServices {
  final String baseUrl = AppStrings.serverUrl;

  Future<void> createNewComment(
    BuildContext context,
    String postID,
    String commentText,
    List<String> commentImages,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/org/community/comment/new-comment"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "postID": postID,
          "commentText": commentText,
          "commentImages": commentImages,
        }),
      );
    } catch (e) {
      showSnackBar(
        context: context,
        message: AppStrings.serverErrorMessage,
        title: "Server Error",
      );
    }
  }

  Future<void> deleteComment(BuildContext context, String commentID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.delete(
        Uri.parse("$baseUrl/api/v1/org/community/comment/delete-comment"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"commentID": commentID}),
      );
    } catch (e) {
      showSnackBar(
        context: context,
        message: AppStrings.serverErrorMessage,
        title: "Server Error",
      );
    }
  }

  Future<void> replyComment({
    required BuildContext context,
    required String commentID,
    required String replyText,
    required List<String> replyImages,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/org/community/comment/reply-comment"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "commentID": commentID,
          "replyText": replyText,
          "replyImages": replyImages,
        }),
      );
    } catch (e) {
      showSnackBar(
        context: context,
        message: AppStrings.serverErrorMessage,
        title: "Server Error",
      );
    }
  }

  Future<void> deleteCommentReply(BuildContext context, String replyID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.delete(
        Uri.parse("$baseUrl/api/v1/org/community/comment/delete-reply"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"replyID": replyID}),
      );
    } catch (e) {
      showSnackBar(
        context: context,
        message: AppStrings.serverErrorMessage,
        title: "Server Error",
      );
    }
  }

  Future<List<CommentModel>> postComments(
    BuildContext context,
    String postID,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/v1/org/community/comment/post-comments/$postID",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> commentsData =
            jsonResponse['data'] as List<dynamic>;
        return commentsData
            .map(
              (commentJson) =>
                  CommentModel.fromMap(commentJson as Map<String, dynamic>),
            )
            .toList();
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
}
