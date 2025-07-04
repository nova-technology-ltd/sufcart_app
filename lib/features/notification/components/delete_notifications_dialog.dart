import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../utilities/components/custom_button_one.dart';
import '../../../utilities/themes/theme_provider.dart';

class DeleteNotificationsDialog extends StatelessWidget {
  final VoidCallback okayButton;

  const DeleteNotificationsDialog({super.key, required this.okayButton});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Column(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.08) : Colors.red.withOpacity(0.08),
                    shape: BoxShape.circle
                  ),
                  child: Center(
                    child: Icon(IconlyBold.delete, color: themeProvider.isDarkMode ? Colors.white : Colors.red, size: 20,),
                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  "Delete Selected Notifications",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  "Do, you want to permanently delete the notifications you selected?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonOne(
                        title: "Cancel",
                        onClick: () {
                          Navigator.pop(context);
                        },
                        isLoading: false,
                        color: Colors.grey.withOpacity(0.2),
                        textColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButtonOne(
                        title: "Delete",
                        onClick: okayButton,
                        isLoading: false,
                        color: Colors.red.withOpacity(0.2),
                        textColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
