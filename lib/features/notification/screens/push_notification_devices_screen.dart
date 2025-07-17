import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/notification/service/push_notification_service.dart';
import 'package:sufcart_app/utilities/components/app_bar_back_arrow.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';
import '../model/push_notification_model.dart';

class PushNotificationDevicesScreen extends StatefulWidget {
  const PushNotificationDevicesScreen({super.key});

  @override
  State<PushNotificationDevicesScreen> createState() => _PushNotificationDevicesScreenState();
}

class _PushNotificationDevicesScreenState extends State<PushNotificationDevicesScreen> {
  final PushNotificationService _pushNotificationService = PushNotificationService();
  late Future<List<PushNotificationModel>> _futureDevices;

  @override
  void initState() {
    _futureDevices = _pushNotificationService.getUserDevices(context);
    super.initState();
  }

  Future<void> _refreshScreen(BuildContext context) async {
    try {
      setState(() {
        _futureDevices = _pushNotificationService.getUserDevices(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing devices: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return RefreshIndicator(
      onRefresh: () => _refreshScreen(context),
      child: Scaffold(
        backgroundColor: isDarkMode ? null : Colors.white,
        appBar: AppBar(
          backgroundColor: isDarkMode ? null : Colors.white,
          surfaceTintColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leadingWidth: 90,
          leading: AppBarBackArrow(onClick: () {
            Navigator.pop(context);
          }),
          title: const Text(
            "Devices",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                FutureBuilder<List<PushNotificationModel>>(
                  future: _futureDevices,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => _refreshScreen(context),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No devices found'),
                        ),
                      );
                    }

                    final devices = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                          child: ListTile(
                            title: Text(
                              device.deviceId,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              device.deviceId ?? 'No ID',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            trailing: Icon(
                              Icons.devices,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}