import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_strings.dart';

class HelpCenterServices {
  final String baseUrl = AppStrings.serverUrl;

  Future<int> makeCompliant(
      {
        required BuildContext context,
        required String title,
        required String message,
        required String email,
        required List<String> images,

      }) async {
    try {
      final response = await http.post(
          Uri.parse("$baseUrl/api/v1/org/complaint/new-complaint"),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "title": title,
            "message": message,
            "images": images,
            "email": email
          }));
      print(response.body);
      print(images);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context: context,
            message: responseData['message'],
            title: responseData['title']);
        return response.statusCode;
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context: context,
            message: responseData['message'],
            title: responseData['title']);
        return response.statusCode;
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUserCompliant(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/complaint/all-complaints/user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print("All Complaint: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey("data")) {
          return List<Map<String, dynamic>>.from(responseData["data"]);
        } else {
          throw Exception("Data field not found in the response.");
        }
      } else {
        throw Exception("Failed to fetch complaints: ${response.reasonPhrase}");
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      return [];
    }
  }

  Future<Map<String, dynamic>> getCompliantByYD(BuildContext context, String complaintID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("Authorization");
      final Uri url = Uri.parse("$baseUrl/api/v1/org/complaint/compliant-by-ID/$complaintID");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey("data")) {
          return Map<String, dynamic>.from(responseData["data"]);
        } else {
          throw Exception("The response does not contain a 'data' field.");
        }
      } else {
        throw Exception("Failed to fetch complaints. Status code: ${response.statusCode}, Reason: ${response.reasonPhrase}");
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      rethrow; // Re-throws the exception to indicate failure.
    }
  }

  Future<List<Map<String, dynamic>>> getAllUserSatisfiedCompliant(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/complaint/satisfied-compliants/user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print("Satisfied Complaint: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey("data")) {
          return List<Map<String, dynamic>>.from(responseData["data"]);
        } else {
          throw Exception("Data field not found in the response.");
        }
      } else {
        throw Exception("Failed to fetch complaints: ${response.reasonPhrase}");
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllUserUnsatisfiedCompliant(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/complaint/unsatisfied-compliants/user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print("Unsatisfied Complaint: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey("data")) {
          return List<Map<String, dynamic>>.from(responseData["data"]);
        } else {
          throw Exception("Data field not found in the response.");
        }
      } else {
        throw Exception("Failed to fetch complaints: ${response.reasonPhrase}");
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      return [];
    }
  }

  Future<int> deleteUserComplaint(
      BuildContext context, String complaintID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.delete(
        Uri.parse(
            "$baseUrl/api/v1/org/complaint/delete-compliants/user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode(
          {
            "complaintID": complaintID,
          },
        ),
      );
      print("Unsatisfied Compliant: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context: context,
            message: responseData['message'],
            title: responseData['title']);
        return response.statusCode;
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context: context,
            message: responseData['message'],
            title: responseData['title']);
        return response.statusCode;
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      return -1;
    }
  }
  Future<void> deleteUserComplaintContent(
      BuildContext context, String complaintID, String contentID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.delete(
        Uri.parse(
            "$baseUrl/api/v1/org/complaint/delete-compliants-content/user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode(
          {
            "complaintID": complaintID,
            "contentID": contentID
          },
        ),
      );
      print("Unsatisfied Compliant: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context: context,
            message: responseData['message'],
            title: responseData['title']);
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context: context,
            message: responseData['message'],
            title: responseData['title']);
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }
  Future<int> addMoreContentToCompliant(BuildContext context, String complaintID, String message,
      List<String> images) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(
          Uri.parse("$baseUrl/api/v1/org/complaint/add-complaint"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: json.encode({
            "complaintID": complaintID,
            "message": message,
            "images": images,
          }));
      print(response.body);
      print(complaintID);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context: context,
            message: responseData['message'],
            title: responseData['title']);
        return response.statusCode;
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context: context,
            message: responseData['message'],
            title: responseData['title']);
        return response.statusCode;
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      return -1;
    }
  }
  Future<void> toggleCompliantStatus(BuildContext context, String complaintID) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(
          Uri.parse("$baseUrl/api/v1/org/complaint/toggle-status"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: json.encode({
            "complaintID": complaintID,
          }));
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context: context,
            message: responseData['message'],
            title: responseData['title']);
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context: context,
            message: responseData['message'],
            title: responseData['title']);
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }
}
