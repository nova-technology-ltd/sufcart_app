import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../state_management/shared_preference_services.dart';
import '../../../utilities/components/custom_bottom_nav/custom_bottom_navigation_bar.dart';
import '../../../utilities/components/http_error_handler.dart';
import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_strings.dart';
import '../../profile/model/user_model.dart';
import '../../profile/model/user_provider.dart';
import '../../profile/screens/korad_tag_creation_success_screen.dart';
import '../../settings/account_settings/screens/email_verification_success_screen.dart';
import '../../settings/account_settings/screens/profile_update_success_screen.dart';
import '../../settings/screen/account_pin_login_screen.dart';
import '../../settings/security_settings/screens/account_pin_success_screen.dart';
import '../../settings/security_settings/screens/password_change_success_screen.dart';
import '../forgot_password/screens/forgot_password_otp_screen.dart';
import '../forgot_password/screens/reset_password_success_screen.dart';
import '../import_user_settings_screen.dart';
import '../login/screens/login_screen.dart';
import '../registration/screens/registration_success_screen.dart';

class AuthService with ChangeNotifier {
  String baseUrl = AppStrings.serverUrl;

  //registration
  Future<void> registerUser(
      {required BuildContext context,
        required String firstName,
        required String lastName,
        required String otherNames,
        required String phoneNumber,
        required String email,
        required String password,
        required String inviteCode,
      }
  ) async {
    try {
      final response =
          await http.post(Uri.parse("$baseUrl/api/v1/org/auth/register-user"),
              headers: {"Content-Type": "application/json"},
              body: json.encode({
                "firstName": firstName,
                "lastName": lastName,
                "otherNames": otherNames,
                "phoneNumber": phoneNumber,
                "email": email,
                "password": password,
                "invitedBy": inviteCode,
              }));
      httpErrorHandler(
          response: response,
          context: context,
          onSuccess: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const RegistrationSuccessScreen()),
                (route) => false);
          });
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  //login
  Future<void> userLogin(
      BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/org/auth/user-login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(
          {
            "email": email,
            "password": password,
          },
        ),
      );
      httpErrorHandler(
          response: response,
          context: context,
          onSuccess: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var responseBody = jsonDecode(response.body);
            var userJson = responseBody['user'];
            Provider.of<UserProvider>(context, listen: false)
                .setUser(jsonEncode(userJson));
            String? token = userJson['token'];
            String? userID = userJson['userID'];
            if (token != null && userID != null) {
              await prefs.setString('Authorization', token);
              await prefs.setString('user', userID);
              // Save the UserModel to SharedPreferences
              UserModel userModel = UserModel.fromJson(jsonEncode(userJson));
              SharedPreferencesService sharedPreferencesService = await SharedPreferencesService.getInstance();
              await sharedPreferencesService.saveUserModel(userModel);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ImportUserSettingsScreen(),
              ));
            } else {
              print("Error: token or userID is null");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Login failed. Please try again.")),
              );
            }
          });
    } catch (err) {
      print(err);
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<UserModel?> userProfile(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/user/user-profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        var userJson = responseBody['data'];
        // Set the user in the provider


        UserModel userModel = UserModel.fromJson(jsonEncode(userJson));
        SharedPreferencesService sharedPreferencesService = await SharedPreferencesService.getInstance();
        await sharedPreferencesService.saveUserModel(userModel);

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(jsonEncode(userJson));
        // Return the user model
        return userProvider.userModel;
      } else {
        // Handle HTTP error
        httpErrorHandler(
            response: response, context: context, onSuccess: () {});
        return null; // Return null in case of failure
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      return null;
    }
  }

  Future<UserModel?> checkIfUserIsLoggedIn(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/org/user/user-profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = jsonDecode(response.body);
        var userJson = responseBody['data'];
        bool isAccountPinEnabled = userJson['userSettings']['passCodeLock'] ?? false;

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(jsonEncode(userJson));

        if (isAccountPinEnabled) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AccountPinLoginScreen()),
                (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const CustomBottomNavigationBar()),
                (route) => false,
          );
        }
        return userProvider.userModel;
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
        return null;
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      return null;
    }
  }

  //update profile
  Future<void> updateProfile(
      BuildContext context, Map<String, dynamic> updates) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final Uri url =
          Uri.parse("$baseUrl/api/v1/org/user/update-user-profile");

      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(updates),
      );
      httpErrorHandler(
          response: response,
          context: context,
          onSuccess: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ProfileUpdateSuccessScreen()));
          });
    } catch (error) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> updateAccountPersonalization(
      BuildContext context, Map<String, dynamic> updates) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final Uri url =
      Uri.parse("$baseUrl/api/v1/org/user/update-user-profile");

      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(updates),
      );
      httpErrorHandler(
          response: response,
          context: context,
          onSuccess: () {});
    } catch (error) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> removeProfileImage(
      BuildContext context, Map<String, dynamic> updates) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final Uri url =
      Uri.parse("$baseUrl/api/v1/org/user/update-user-profile");

      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(updates),
      );
    } catch (error) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> uploadProfileImage(
      BuildContext context, Map<String, dynamic> updates) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final Uri url =
      Uri.parse("$baseUrl/api/v1/org/user/update-user-profile");

      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(updates),
      );
    } catch (error) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> updatePassword(
      BuildContext context, String oldPassword, String newPassword) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final Uri url =
          Uri.parse("$baseUrl/api/v1/org/user/update-user-password");

      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );
      httpErrorHandler(
          response: response,
          context: context,
          onSuccess: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const PasswordChangeSuccessScreen()));
          });
    } catch (error) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> koradTag(
      BuildContext context, Map<String, dynamic> userTag) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final Uri url =
          Uri.parse("$baseUrl/api/v1/org/user/update-user-profile");

      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(userTag),
      );
      httpErrorHandler(
          response: response,
          context: context,
          onSuccess: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const KoradTagCreationSuccessScreen()));
          });
    } catch (error) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> setAccountPIN(BuildContext context, int accountPIN) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.put(
          Uri.parse("$baseUrl/api/v1/org/user/set-user-account-pin"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: json.encode({"accountPIN": accountPIN}));
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AccountPinSuccessScreen()));
      } else {
        showSnackBar(
            context: context,
            message:
                "We are unable to set your account PIN, please try again later or contact our customer care to help get the issue resolved",
            title: "Unable To Set PIN");
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  //reset password
  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      final response = await http.post(
          Uri.parse("$baseUrl/api/v1/org/auth/forgot-password"),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({"email": email}));
      print(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ForgotPasswordOtpScreen(email: email)));
      } else {
        httpErrorHandler(
            response: response, context: context, onSuccess: () {});
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> resendForgotPasswordSendOTP(
      BuildContext context, String email) async {
    try {
      final response = await http.post(
          Uri.parse("$baseUrl/api/v1/org/auth/forgot-password"),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({"email": email}));
      print(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("OTP sent to $email")));
      } else {
        httpErrorHandler(
            response: response, context: context, onSuccess: () {});
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> verifyOTPAndResetPassword(BuildContext context, String email,
      String otp, String newPassword) async {
    try {
      final response = await http.post(
          Uri.parse("$baseUrl/api/v1/org/auth/reset-password"),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "email": email,
            "otp": otp,
            "newPassword": newPassword,
          }));
      print(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const ResetPasswordSuccessScreen()),
            (route) => false);
      } else {
        httpErrorHandler(
            response: response, context: context, onSuccess: () {});
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  //verify account email
  Future<void> sendEmailVerificationOTP(
      BuildContext context, String email) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(
          Uri.parse("$baseUrl/api/v1/org/auth/send-email-verification-otp"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: json.encode({"email": email}));
      print(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        showSnackBar(context: context, message: "Your account email verification has successfully been sent to: $email and it expires in 2 minutes", title: "OTP Successfully Sent");
      } else {
        httpErrorHandler(
            response: response, context: context, onSuccess: () {});
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> verifyEmailOTP(
      BuildContext context, String email, String otp) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(
          Uri.parse("$baseUrl/api/v1/org/auth/verify-email"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: json.encode({"email": email, "otp": otp}));
      print(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const EmailVerificationSuccessScreen()));
      } else {
        httpErrorHandler(
            response: response, context: context, onSuccess: () {});
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  Future<void> resendEmailVerificationOTP(
      BuildContext context, String email) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");
      final response = await http.post(
          Uri.parse("$baseUrl/api/v1/org/auth/send-email-verification-otp"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: json.encode({
            "email": email,
          }));
      print(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("OTP sent to $email")));
      } else {
        httpErrorHandler(
            response: response, context: context, onSuccess: () {});
      }
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
    }
  }

  //logout
  Future<void> logOut(BuildContext context) async {
    try {
      // Initialize SharedPreferences instance
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("Authorization");

      // Make HTTP POST request to logout API
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/org/auth/user-logout"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      // Handle HTTP response
      httpErrorHandler(
        response: response,
        context: context,
        onSuccess: () async {
          // Clear shared preferences after successful logout
          await prefs.clear();

          // Navigate to the login screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context: context, message: AppStrings.serverErrorMessage, title: "Server Error");
      print(e);
    }
  }
}
