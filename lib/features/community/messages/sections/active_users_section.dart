import 'dart:math';

import 'package:flutter/material.dart';

class ActiveUsersSection extends StatefulWidget {
  const ActiveUsersSection({super.key});

  @override
  State<ActiveUsersSection> createState() => _ActiveUsersSectionState();
}

class _ActiveUsersSectionState extends State<ActiveUsersSection> {
  final demoUsers = [
    "#miami#brickell#brickellmiami.jpeg",
    "#mall #shopping #fyp.jpeg",
    "70891f69-4ac3-49d4-9a16-e3061f6dba20.jpeg",
    "c7008c73-b7ab-4e62-9b29-eddf21be238a.jpeg",
    "custom_jewelry_banner_image.jpg",
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Active Connections",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),
              ),
              Text(
                "83 of your connections are active",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10,),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Row(
            children: [
              for (int i = 0; i < 18; i++)
                Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 10 : 3.0, right: i == 9 ? 10 : 3),
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(width: 1.8, color: Colors.green)
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: Container(
                          height: 60,
                          width: 60,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle
                          ),
                          child: Image.asset("images/${demoUsers[Random().nextInt(demoUsers.length)]}", fit: BoxFit.cover,),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
