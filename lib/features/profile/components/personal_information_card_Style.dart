import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/user_provider.dart';

class PersonalInformationCardStyle extends StatelessWidget {
  final String title;
  final String information;

  const PersonalInformationCardStyle(
      {super.key, required this.title, required this.information});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userModel;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        height: 28,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
            title == "Email"
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 19,
                        decoration: BoxDecoration(
                          color: user.isEmailVerified ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                          child: Center(
                            child: Text(user.isEmailVerified ? "Verified" : "Unverified", style: TextStyle(
                              color: user.isEmailVerified ? Colors.green : Colors.red,
                              fontSize: 8,
                              fontWeight: FontWeight.w500
                            ),),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        information,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  )
                : Text(
                    information,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400),
                  ),
          ],
        ),
      ),
    );
  }
}
