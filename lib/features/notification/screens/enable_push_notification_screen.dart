import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sufcart_app/features/notification/service/push_notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/utilities/components/custom_button_one.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';
import '../../../utilities/components/sample_message_card.dart';
import '../../../utilities/constants/sample_avatars.dart';

class EnablePushNotificationScreen extends StatefulWidget {
  const EnablePushNotificationScreen({super.key});

  @override
  State<EnablePushNotificationScreen> createState() =>
      _EnablePushNotificationScreenState();
}

class _EnablePushNotificationScreenState extends State<EnablePushNotificationScreen> {
  String formattedDate = '';
  String formattedTime = '';

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  bool _isLoading = false;
  String? _deviceId;
  String? _fcmToken;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    formattedDate = DateFormat('EEEE-MMMM d').format(now);
    formattedTime = DateFormat('jm').format(now);
    _initialize();
  }
  Future<void> _initialize() async {
    try {
      setState(() => _isLoading = true);
      await PushNotificationService.initialize();
      await _getDeviceInfo();
      await _getFCMToken();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getDeviceInfo() async {
    try {
      String deviceId;

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? const Uuid().v4();
      } else {
        deviceId = const Uuid().v4();
      }

      setState(() => _deviceId = deviceId);
    } catch (e) {
      print('Error getting device info: $e');
      setState(() => _errorMessage = 'Failed to get device information');
    }
  }

  Future<void> _getFCMToken() async {
    try {
      final token = await PushNotificationService.firebaseMessaging.getToken();
      if (token == null) throw Exception('Failed to get FCM token');
      setState(() => _fcmToken = token);
    } catch (e) {
      print('Error getting FCM token: $e');
      setState(() => _errorMessage = 'Failed to get notification token');
    }
  }

  Future<void> _registerDevice() async {
    try {
      if (_deviceId == null || _fcmToken == null) {
        throw Exception('Device information not available');
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await PushNotificationService().registerDevice(
        context: context,
        deviceId: _deviceId!,
        token: _fcmToken!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications enabled successfully!')),
      );
    } catch (e) {
      print('Error registering device: $e');
      setState(() => _errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to enable notifications: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await PushNotificationService().sendTestNotification(
        context: context,
        title: "Test Notification",
        body: "This is a test notification from your app!",
        data: {'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent!')),
      );
    } catch (e) {
      print('Error sending test notification: $e');
      setState(() => _errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send test: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.white,
        surfaceTintColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(45),
                  border: Border.all(
                      width: 8, color: Colors.grey.withOpacity(0.4))),
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 28,
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.withOpacity(0.3)),
                  ),
                  Text(
                    formattedTime,
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.withOpacity(0.3)),
                  )
                ],
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2)),
          ),
          Column(
            children: [
              Expanded(
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 140,),
                          SampleMessageCard(message: 'What store did you say you got that abaya', image: 'STK-20240102-WA0060.webp', time: '30min', name: 'Nafeesa Ibrahim', bg: Colors.red,),
                          SizedBox(height: 5,),
                          SampleMessageCard(message: 'Your password has been updated.', image: 'casual-life-3d-yellow-padlock-with-key.png', time: '1:30AM', name: 'Account Update', bg: Colors.blue),
                          SizedBox(height: 5,),
                          SampleMessageCard(message: 'Hi, just wanted to know if you will be available...', image: 'STK-20240102-WA0439.webp', time: 'now', name: 'John Doe', bg: Colors.blue),
                        ],
                      ),
                    ),
                  )),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                        child: Column(
                          children: [
                            const Spacer(),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SampleAvatars(height: 50, width: 50, image: "STK-20240102-WA0031.webp", color: Colors.green,),
                                Column(
                                  children: [
                                    SampleAvatars(height: 25, width: 25, image: "STK-20240102-WA0060.webp", color: Colors.orange,),
                                    SizedBox(height: 20,),
                                    SampleAvatars(height: 35, width: 35, image: "STK-20240102-WA0063.webp", color: Colors.pink,),
                                  ],
                                ),
                                SampleAvatars(height: 85, width: 85, image: "STK-20240102-WA0070.webp", color: Colors.purple,),
                                Column(
                                  children: [
                                    SampleAvatars(height: 25, width: 25, image: "STK-20240102-WA0070.webp", color: Colors.blue,),
                                    SizedBox(height: 20,),
                                    SampleAvatars(height: 35, width: 35, image: "STK-20240102-WA0072.webp", color: Colors.red,),
                                  ],
                                ),
                                SampleAvatars(height: 50, width: 50, image: "STK-20240102-WA0298.webp", color: Colors.yellow,),
                              ],
                            ),
                            const Spacer(),
                            const Text(
                              "Stay Connected and In the Loop",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            const Text(
                              "Enable notifications to receive important updates and real-time activity from your network.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10,),
                            CustomButtonOne(title: "Enable Notifications", onClick: _registerDevice, isLoading: _isLoading,),
                            TextButton(
                                style: TextButton.styleFrom(
                                  overlayColor: Colors.transparent,
                                ),
                                onPressed: (){
                                  Navigator.pop(context);
                                }, child: const Text("Maybe next time", style: TextStyle(color: Colors.grey, fontSize: 13),))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

