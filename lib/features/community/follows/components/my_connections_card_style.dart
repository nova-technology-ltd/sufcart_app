import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/profile/model/user_model.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';

import '../../../profile/model/user_provider.dart';
import '../../messages/screens/chat_screen.dart';

class MyConnectionsCardStyle extends StatelessWidget {
  final UserModel user;

  const MyConnectionsCardStyle({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Safely construct fullName with null checks
    final currentUser = Provider.of<UserProvider>(context).userModel;
    final fullName =
        [
          user.firstName ?? '',
          user.lastName ?? '',
          user.otherNames ?? '',
        ].where((name) => name.isNotEmpty).join(' ').trim();

    // Determine display name with truncation
    final displayName =
        user.userName.isNotEmpty == true
            ? user.userName.length > 20
                ? '${user.userName.substring(0, 20)}...'
                : user.userName
            : fullName.isNotEmpty
            ? fullName.length > 20
                ? '${fullName.substring(0, 20)}...'
                : fullName
            : 'Unknown User';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      user.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, err, st) {
                        return Center(
                          child: Icon(
                            IconlyBold.profile,
                            color: Colors.grey,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "user bio goes here",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 32,
              width: 80,
              decoration: BoxDecoration(
                color: Color(AppColors.primaryColor).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ChatScreen(receiver: user, sender: currentUser),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                child: Center(
                  child: Text(
                    "Message",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(AppColors.primaryColor),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
