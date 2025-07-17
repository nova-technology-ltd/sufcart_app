import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utilities/constants/app_strings.dart';

class PushNotificationService {
  final String baseUrl = AppStrings.serverUrl;
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permission (iOS only)
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true, // For provisional authorization on iOS
    );

    print('Notification settings: $settings');

    // Get FCM token
    String? token = await firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Handle token refresh
    firebaseMessaging.onTokenRefresh.listen((newToken) {
      print("FCM Token refreshed: $newToken");
      // You might want to send this new token to your server
    });

    // Initialize local notifications
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      _showNotification(message);
    });

    // Handle background/terminated messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened from background/terminated state');
      print('Message data: ${message.data}');
      // You can navigate to specific screen based on message data
    });
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    // Android channel setup
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'high_importance_channel', // channel id
      'High Importance Notifications', // channel name
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    // iOS notification details
    const DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Platform specific notification details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    // Show notification
    await _flutterLocalNotificationsPlugin.show(
      message.hashCode, // Unique ID for each notification
      message.notification?.title ?? "New Notification",
      message.notification?.body ?? "You have a new message",
      platformChannelSpecifics,
      payload: jsonEncode(message.data), // Pass any additional data
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
    await _showNotification(message);
  }

  // Register device with backend
  Future<void> registerDevice({
    required BuildContext context,
    required String deviceId,
    required String token,
  }) async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString("Authorization");

      if (authToken == null) {
        print('No auth token found');
        return;
      }

      final Map<String, dynamic> requestBody = {
        'deviceId': deviceId,
        'platform': platform,
        'token': token,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/org/push-notifications/register-new-devices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Device registered successfully: ${response.body}');
      } else {
        print('Failed to register device: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to register device');
      }
    } catch (e) {
      print('Error registering device: $e');
      rethrow;
    }
  }

  // Send test notification via backend
  Future<void> sendTestNotification({
    required BuildContext context,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString("Authorization");

      if (authToken == null) {
        print('No auth token found');
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/org/push-notifications/send-push-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          if (data != null) 'data': data,
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully: ${response.body}');
      } else {
        print('Failed to send notification: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to send notification');
      }
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}