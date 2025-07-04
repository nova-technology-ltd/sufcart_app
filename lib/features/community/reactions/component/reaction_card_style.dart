import 'package:flutter/material.dart';

class ReactionCardStyle extends StatelessWidget {
  final String reaction;
  final String count;
  const ReactionCardStyle({super.key, required this.reaction, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.purple.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(360),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
          child: Row(
            children: [
              Text(
                reaction,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 5),
              Text(
                '$count',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
