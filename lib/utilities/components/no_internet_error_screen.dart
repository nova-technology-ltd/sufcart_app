import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import 'custom_button_one.dart';

class NoInternetErrorScreen extends StatefulWidget {
  final VoidCallback onRefresh;
  const NoInternetErrorScreen({super.key, required this.onRefresh});

  @override
  State<NoInternetErrorScreen> createState() => _NoInternetErrorScreenState();
}

class _NoInternetErrorScreenState extends State<NoInternetErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
                width: 400,
                child: Image.asset(AppIcons.noInternetIcon)),
            Text(
              "Connection Error",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500
              ),
            ),
            Text(
              "Oops! It looks like we hit a snag. Please check your connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey
              ),
            ),
            const SizedBox(height: 10,),
            CustomButtonOne(title: "Retry", onClick: widget.onRefresh, isLoading: false)
          ],
        ),
      ),
    );
  }
}
