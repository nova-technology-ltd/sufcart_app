import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';

class TermsAndCondition extends StatelessWidget {
  const TermsAndCondition({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        automaticallyImplyLeading: false,
        leadingWidth: 90,
        centerTitle: true,
        title: const Text(
          "Terms And Conditions",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.print,
              color: Colors.grey,
            ),
            tooltip: "Print",
          )
        ],
        leading: AppBarBackArrow(onClick: () {
          Navigator.pop(context);
        }),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            ""
          ),
        ),
      ),
    );
  }
}
