import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:sufcart_app/features/community/posts/model/post_model.dart';
import 'package:sufcart_app/features/community/posts/screen/post_view_screen.dart';

import '../../../../utilities/constants/app_icons.dart';

class ProfilePostTabCard extends StatelessWidget {
  final PostModel postModel;
  const ProfilePostTabCard({super.key, required this.postModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostViewScreen(postModel: postModel)));
        },
        child: Container(
          height: 100,
          width: 100,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(0)
          ),
          child: postModel.postImages.isEmpty ? Center(
            child: Image.asset(
              AppIcons.koradLogo,
              color: Colors.grey,
              width: 18,
              height: 18,
            ),
          ) : Image.network(
            postModel.postImages[0],
            fit: BoxFit.cover,
            loadingBuilder: (
                context,
                child,
                loadingProgress,
                ) {
              if (loadingProgress == null) return child;
              return Center(
                child: Image.asset(
                  AppIcons.koradLogo,
                  color: Colors.grey,
                  width: 18,
                  height: 18,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Image.asset(
                  AppIcons.koradLogo,
                  color: Colors.grey,
                  width: 18,
                  height: 18,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
