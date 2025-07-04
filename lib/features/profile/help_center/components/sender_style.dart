import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SenderStyle extends StatelessWidget {
  final String message;
  final DateTime timeSent;
  final VoidCallback onLongPress;

  const SenderStyle({super.key, required this.message, required this.timeSent, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    // Define a fixed width based on message length
    double containerWidth = message.length > 20 ? 250.0 : double.infinity;

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IntrinsicWidth(
              child: GestureDetector(
                onLongPress: onLongPress,
                child: Container(
                  width: containerWidth, // Set width based on message length
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      topLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    color: Colors.blue[600],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: message.trim(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
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
          ],
        ),
      ),
    );
  }
}
