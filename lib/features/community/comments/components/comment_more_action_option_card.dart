import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class CommentMoreActionOptionCard extends StatelessWidget {
  final String title;
  final String subMessage;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const CommentMoreActionOptionCard({super.key, required this.title, required this.subMessage, required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric( vertical: 2, horizontal: 10),
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8)
        ),
        child: MaterialButton(
          onPressed: onTap,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(icon, size: 18, color: Colors.grey,),
                ),
              ),
              const SizedBox(width: 5,),
              Text(
                title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  color: Colors.grey
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
