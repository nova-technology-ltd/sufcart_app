import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:sufcart_app/features/community/follows/screens/user_profile_screen.dart';
import 'package:sufcart_app/features/profile/model/user_model.dart';

class UserConnectionsCardOne extends StatelessWidget {
  final UserModel user;

  const UserConnectionsCardOne({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Safely construct fullName with null checks
    final fullName = [
      user.firstName ?? '',
      user.lastName ?? '',
      user.otherNames ?? ''
    ].where((name) => name.isNotEmpty).join(' ').trim();

    // Determine display name with truncation
    final displayName = user.userName.isNotEmpty == true
        ? user.userName.length > 8
        ? '${user.userName.substring(0, 8)}...'
        : user.userName
        : fullName.isNotEmpty
        ? fullName.length > 8
        ? '${fullName.substring(0, 8)}...'
        : fullName
        : 'Unknown User';

    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserProfileScreen(user: user)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 55,
            width: 55,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: user.image.isNotEmpty == true
                ? Image.network(
              user.image,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  IconlyBold.profile,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            )
                : const Center(
              child: Icon(
                IconlyBold.profile,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              displayName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}