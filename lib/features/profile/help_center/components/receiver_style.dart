import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiverStyle extends StatelessWidget {
  final String message;
  final DateTime timeSent;
  const ReceiverStyle({super.key, required this.message, required this.timeSent});

  @override
  Widget build(BuildContext context) {
    double containerWidth = message.length > 20 ? 250.0 : MediaQuery.of(context).size.width / 2;

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              width: containerWidth,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                color: Colors.grey[200],
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: message.trim(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              DateFormat('hh:mm a').format(timeSent),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
