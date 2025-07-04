import 'package:flutter/material.dart';

class AppBarBackArrow extends StatelessWidget {
  final VoidCallback onClick;
  final Color? bg;
  const AppBarBackArrow({super.key, required this.onClick, this.bg});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios_new_rounded, color: bg ?? Colors.grey, size: 18,),
              Text(
                " Go Back",
                style: TextStyle(
                  fontSize: 12,
                  color: bg ?? Colors.grey
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
