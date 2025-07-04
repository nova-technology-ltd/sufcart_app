import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../model/user_provider.dart';

class ComplaintCustomCard extends StatelessWidget {
  final Map<String, dynamic> complaints;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  const ComplaintCustomCard({super.key, required this.complaints, required this.onLongPress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userModel;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final createdAt = DateTime.parse(complaints['updatedAt']);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            // color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10)
          ),
          child: Row(
            children: [
              SizedBox(
                height: 53,
                width: 53,
                child: Stack(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(AppColors.primaryColor).withOpacity(0.2),
                        shape: BoxShape.circle
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset("images/STK-20240102-WA0044.webp"),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 28,
                        width: 28,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(width: 2, color: Colors.white)
                        ),
                        child: Center(
                          child: Text(
                              "${complaints['content'].length}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaints['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    complaints['content'][0]['message'].length > 30
                        ? complaints['content'][0]['message'].substring(0, 30) + '...'
                        : complaints['content'][0]['message'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: complaints['isSatisfied'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1),
                      child: Center(
                        child: Text(
                          complaints['isSatisfied'] ? "satisfied" : "unsatisfied",
                          style: TextStyle(
                              fontSize: 8,
                            color: complaints['isSatisfied'] ? Colors.green : Colors.red
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const Spacer(),
              Text(
                  DateFormat('MMM d, yyyy').format(createdAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
