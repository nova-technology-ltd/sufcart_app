import 'package:flutter/material.dart';

import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/constants/app_colors.dart';

class DeleteComplaintBottomSheet extends StatelessWidget {
  final Map<String, dynamic> complaints;
  final VoidCallback onClick;
  final bool isLoading;
  const DeleteComplaintBottomSheet(
      {super.key, required this.complaints, required this.onClick, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Container(
          height: 190,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color:
                          const Color(AppColors.primaryColor).withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("images/STK-20240102-WA0044.webp"),
                  ),
                ),
                const Text(
                  "Confirm Deletion",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const Text(
                  "Are you sure you want to delete this complaint? This action cannot be undone, and the complaint will be permanently removed from your account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                        child: CustomButtonOne(
                      title: "Cancel",
                      onClick: () {
                        Navigator.pop(context);
                      },
                      isLoading: false,
                      color: Colors.grey.withOpacity(0.2),
                      textColor: Colors.grey,
                      height: 38,
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: CustomButtonOne(
                      title: "Delete",
                      onClick: onClick,
                      isLoading: isLoading,
                      color: Colors.red.withOpacity(0.2),
                      height: 38,
                      textColor: Colors.red,
                    )),
                  ],
                ),
                const SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
