import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../../../../utilities/constants/app_icons.dart';
import '../../../profile/model/user_model.dart';
import '../model/comment_model.dart';
import 'comment_more_action_option_card.dart';

class CommentMoreActionBottomSheet extends StatelessWidget {
  final VoidCallback onDeleteClick;
  final VoidCallback onReportClick;
  final UserModel user;
  final CommentModel commentModel;

  const CommentMoreActionBottomSheet({
    super.key,
    required this.onDeleteClick,
    required this.onReportClick,
    required this.user,
    required this.commentModel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
        child: Container(
          height: 130,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0, left: 18, right: 18),
                child: Column(
                  children: [
                    Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "You can ${user.userID == commentModel.userID ? "delete" : "report"} this comment.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, top: 10),
                child: Column(
                  children: [
                    user.userID == commentModel.userID ? CommentMoreActionOptionCard(
                      title: "Delete Comment",
                      subMessage: "",
                      icon: IconlyLight.delete,
                      onTap: onDeleteClick,
                      color: Colors.red,
                    ) : const SizedBox.shrink(),
                    user.userID != commentModel.userID
                        ? CommentMoreActionOptionCard(
                          title: "Report Comment",
                          subMessage: "",
                          icon: Icons.report_rounded,
                          onTap: onReportClick,
                          color: Colors.blue,
                        )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
