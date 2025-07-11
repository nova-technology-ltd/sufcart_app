import 'package:flutter/material.dart';
import '../../../../utilities/constants/app_icons.dart';
import '../../posts/screen/post_view_screen.dart';

class ProfileRepostTabCard extends StatelessWidget {
  final Map<String, dynamic> repost;
  const ProfileRepostTabCard({super.key, required this.repost});

  @override
  Widget build(BuildContext context) {
    // Safely access the first image URL from postDetails.postImages
    final imageUrl = repost['postDetails']?['postImages'] is List &&
        (repost['postDetails']['postImages'] as List).isNotEmpty
        ? repost['postDetails']['postImages'][0] as String?
        : null;

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: GestureDetector(
        onTap: repost['postDetails']['postImages'].isEmpty ? (){} : () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) =>
                  PostViewScreen(postID: repost['postDetails']['postID']),
            ),
          );
        },
        child: Container(
          height: 100,
          width: 100,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(0),
          ),
          child: imageUrl != null
              ? Image.network(
            imageUrl,
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
          )
              : Center(
            child: Image.asset(
              AppIcons.koradLogo,
              color: Colors.grey,
              width: 18,
              height: 18,
            ),
          ),
        ),
      ),
    );
  }
}