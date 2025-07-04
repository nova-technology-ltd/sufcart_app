import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

import '../model/user_model.dart';

class InvitedFamilyAndFriendsCardStyleTwo extends StatelessWidget {
  final UserModel invites;
  const InvitedFamilyAndFriendsCardStyleTwo({super.key, required this.invites});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            // color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.08),
                        shape: BoxShape.circle
                    ),
                    child: Image.network(invites.image, fit: BoxFit.cover,errorBuilder: (context, error, stackTrace) {
                      // Fallback to initials if image fails to load
                      return Center(
                        child: Icon(IconlyBold.profile, color: Colors.grey.withOpacity(0.7), size: 20,),
                      );
                    }),
                  ),
                  const SizedBox(width: 5,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${invites.firstName.trim()} ${invites.lastName.trim()} ${invites.otherNames.trim()}",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            invites.userName == "" ? "No Korad Tag Yet" : invites.userName.length > 10 ? "${invites.userName.substring(0, 10)}..." : invites.userName,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Container(
                              height: 4,
                              width: 4,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle
                              ),
                            ),
                          ),
                          Text(
                            "Invited On: ${DateFormat('EEE, MMMM d, yyyy').format(DateTime.parse("${invites.createdAt}"))}",
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
