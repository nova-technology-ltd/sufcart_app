import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufcart_app/utilities/components/show_snack_bar.dart';
import 'package:sufcart_app/utilities/constants/app_strings.dart';

import '../../../state_management/shared_preference_services.dart';
import '../../profile/model/user_model.dart';
import '../../profile/model/user_provider.dart';
import '../import_user_settings_screen.dart';

class GoogleSignInService {
  final String baseUrl = AppStrings.serverUrl;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final String? _clientId;
  final String? _serverClientId;
  bool _isInitialized = false;
  bool _isAuthenticating = false;

  GoogleSignInService({
    String? clientId,
    String? serverClientId,
  })  : _clientId = clientId ?? AppStrings.CLIENT_ID,
        _serverClientId = serverClientId ??
            AppStrings.SERVER_CLIENT_ID;

  Future<void> _initializeGoogleSignIn() async {
    if (_isInitialized) return;

    try {
      await _googleSignIn.initialize(
        clientId: _clientId,
        serverClientId: _serverClientId,
      );

      _googleSignIn.authenticationEvents.listen(
            (event) {
        },
        onError: (error) {
        },
      );

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Google Sign-In: $e');
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    if (_isAuthenticating) {
    }

    _isAuthenticating = true;
    try {
      await _initializeGoogleSignIn();

      GoogleSignInAccount? account;

      if (_googleSignIn.supportsAuthenticate()) {
        account = await _googleSignIn.authenticate();
      } else {
        if (kIsWeb) {
          throw UnsupportedError(
              'Web sign-in requires rendering Google Sign-In button. Use platform-specific UI.');
        }
        account = await _googleSignIn.attemptLightweightAuthentication();
      }
      final auth = await account?.authentication;
      final idToken = auth?.idToken;
      final response = await _sendTokenToBackend(context, idToken!);

      return response;
    } catch (e) {
      showSnackBar(context: context, message: "Error during Google Sign-In", title: "Error");
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<void> _sendTokenToBackend(BuildContext context, String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/org/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identityToken': idToken}),
      );
      print(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var responseBody = jsonDecode(response.body);
      var userJson = responseBody['user'];
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).setUser(jsonEncode(userJson));
      String? token = userJson['token'];
      String? userID = userJson['userID'];
      if (token != null && userID != null) {
        await prefs.setString('Authorization', token);
        await prefs.setString('user', userID);
        // Save the UserModel to SharedPreferences
        UserModel userModel = UserModel.fromJson(jsonEncode(userJson));
        SharedPreferencesService sharedPreferencesService =
        await SharedPreferencesService.getInstance();
        await sharedPreferencesService.saveUserModel(userModel);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ImportUserSettingsScreen(),
          ),
        );
      } else {
        print("Error: token or userID is null");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed. Please try again.")),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending token to backend: $e');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      _isInitialized = false;
    } catch (e) {
      rethrow;
    }
  }
}