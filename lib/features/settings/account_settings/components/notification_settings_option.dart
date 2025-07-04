import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';

class NotificationSettingsOption extends StatelessWidget {
  final String title;
  final String subMessage;
  final bool switchValue;
  final Icon? iconOne;
  final Image? iconTwo;
  final VoidCallback onClick;
  final Function(bool) onChange;
  const NotificationSettingsOption({super.key, required this.title, required this.switchValue, required this.onClick, required this.onChange, this.iconOne, this.iconTwo, required this.subMessage});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onClick,
            child: Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[000]),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        color: const Color(AppColors.primaryColor).withOpacity(0.2),
                        shape: BoxShape.circle
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: iconOne ?? iconTwo,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: title,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: themeProvider.isDarkMode ? null : Colors.black)),
                        ]),
                      ),
                      Text(
                        subMessage,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.grey
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    child: Center(
                      child: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          activeColor: const Color(AppColors.primaryColor),
                          value: switchValue,
                          onChanged: onChange,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
