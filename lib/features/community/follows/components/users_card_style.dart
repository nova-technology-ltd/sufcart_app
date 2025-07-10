// import 'package:flutter/material.dart';
// import 'package:iconly/iconly.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../utilities/constants/app_colors.dart';
// import '../../../auth/service/auth_service.dart';
// import '../../../profile/model/user_model.dart';
// import '../../../profile/model/user_provider.dart';
// import '../../likes/socket/like_socket_provider.dart';
// import '../../reactions/socket/reaction_socket_provider.dart';
// import '../model/follow_model.dart';
// import '../screens/user_profile_screen.dart';
// import '../socket/follows_socket_provider.dart';
//
// class UsersCardStyle extends StatefulWidget {
//   final UserModel data;
//
//   const UsersCardStyle({super.key, required this.data});
//
//   @override
//   State<UsersCardStyle> createState() => _UsersCardStyleState();
// }
//
// class _UsersCardStyleState extends State<UsersCardStyle> {
//   Future<void> _toggleFollow(BuildContext context) async {
//     final userID = context.read<UserProvider>().userModel.userID;
//     final postOwnerID = widget.data.userID.toString();
//     final followsProvider = context.read<FollowsSocketProvider>();
//     final userProvider = context.read<UserProvider>();
//     final isFollowing =
//         userProvider.userModel.following.any((f) => f.userID == postOwnerID) ||
//         followsProvider
//             .getFollowing(userID)
//             .any((f) => f['userID'] == postOwnerID);
//     final AuthService _authService = AuthService();
//
//     // Store original following list for reversion on error
//     final originalFollowing = List<FollowModel>.from(
//       userProvider.userModel.following,
//     );
//
//     if (!isFollowing) {
//       // Optimistic update: Add to UserModel's following list
//       final updatedFollowing = List<FollowModel>.from(
//         userProvider.userModel.following,
//       )..add(
//         FollowModel(
//           followID: '', // Placeholder, server provides actual ID
//           userID: postOwnerID!,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//       );
//       userProvider.updateUser(
//         userProvider.userModel.copyWith(following: updatedFollowing),
//       );
//
//       try {
//         await followsProvider.addFollower(postOwnerID);
//         await _authService.userProfile(context);
//       } catch (e) {
//         userProvider.updateUser(
//           userProvider.userModel.copyWith(following: originalFollowing),
//         );
//       }
//     } else {
//       final updatedFollowing = List<FollowModel>.from(
//         userProvider.userModel.following,
//       )..removeWhere((f) => f.userID == postOwnerID);
//       userProvider.updateUser(
//         userProvider.userModel.copyWith(following: updatedFollowing),
//       );
//
//       try {
//         await followsProvider.removeFollower(postOwnerID!);
//         await _authService.userProfile(context);
//       } catch (e) {
//         userProvider.updateUser(
//           userProvider.userModel.copyWith(following: originalFollowing),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to unfollow: ${e.toString()}')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<UserProvider>(context).userModel;
//     final userID = context.read<UserProvider>().userModel.userID;
//     final postOwnerID = widget.data.userID.toString();
//     final userFollowing = context.read<UserProvider>().userModel.following;
//     return Consumer3<
//       LikeSocketProvider,
//       ReactionSocketProvider,
//       FollowsSocketProvider
//     >(
//       builder: (
//         context,
//         likeProvider,
//         reactionProvider,
//         followsProvider,
//         child,
//       ) {
//         final isFollowing =
//             userFollowing.any((f) => f.userID == postOwnerID) ||
//             followsProvider
//                 .getFollowing(userID)
//                 .any((f) => f['userID'] == postOwnerID);
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
//           child: GestureDetector(
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => UserProfileScreen(
//                     user: widget.data,
//                   ),
//                 ),
//               );
//             },
//             child: Container(
//               height: 45,
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(color: Colors.transparent),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     height: 50,
//                     width: 50,
//                     child: Stack(
//                       children: [
//                         Container(
//                           height: 50,
//                           width: 50,
//                           clipBehavior: Clip.antiAlias,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.withOpacity(0.3),
//                             shape: BoxShape.circle,
//                           ),
//                           child:
//                               widget.data.image.isEmpty
//                                   ? Center(
//                                     child: Icon(
//                                       IconlyBold.profile,
//                                       color: Colors.grey,
//                                       size: 18,
//                                     ),
//                                   )
//                                   : Image.network(
//                                     widget.data.image,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, err, st) {
//                                       return Center(
//                                         child: Icon(
//                                           IconlyBold.profile,
//                                           color: Colors.grey,
//                                           size: 18,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                         ),
//                         widget.data.gender.isNotEmpty
//                             ? Align(
//                               alignment: Alignment.bottomCenter,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color:
//                                       widget.data.gender == "Male"
//                                           ? Colors.purple
//                                           : Colors.orange,
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8.0,
//                                     vertical: 1,
//                                   ),
//                                   child: Text(
//                                     widget.data.gender,
//                                     style: TextStyle(
//                                       fontSize: 9,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             )
//                             : const SizedBox.shrink(),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 5),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "${widget.data.firstName} ${widget.data.lastName} ${widget.data.otherNames}",
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w400,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       Text(
//                         "Joined: ${DateFormat('MMMM d, y').format(DateTime.parse("${widget.data.createdAt}"))}",
//                         style: const TextStyle(fontSize: 11, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   Spacer(),
//                   Container(
//                     height: 25,
//                     width: 70,
//                     clipBehavior: Clip.antiAlias,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: !isFollowing && postOwnerID != userID ? Color(AppColors.primaryColor).withOpacity(0.2) : Colors.grey.withOpacity(0.1),
//                     ),
//                     child: MaterialButton(
//                       padding: EdgeInsets.zero,
//                       onPressed: () => _toggleFollow(context),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           !isFollowing && postOwnerID != userID ? Icon(
//                             Icons.add,
//                             color: Color(AppColors.primaryColor),
//                             size: 14,
//                           ) : const SizedBox.shrink(),
//                           SizedBox(width: !isFollowing && postOwnerID != userID ? 2 : 0),
//                           Text(
//                             !isFollowing && postOwnerID != userID ? "Follow" : "Following",
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: !isFollowing && postOwnerID != userID ? Color(AppColors.primaryColor) : Colors.grey,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/constants/app_colors.dart';
import '../../../auth/service/auth_service.dart';
import '../../../profile/model/user_model.dart';
import '../../../profile/model/user_provider.dart';
import '../../likes/socket/like_socket_provider.dart';
import '../../reactions/socket/reaction_socket_provider.dart';
import '../model/follow_model.dart';
import '../screens/user_profile_screen.dart';
import '../socket/follows_socket_provider.dart';

class UsersCardStyle extends StatefulWidget {
  final UserModel data;

  const UsersCardStyle({super.key, required this.data});

  @override
  State<UsersCardStyle> createState() => _UsersCardStyleState();
}

class _UsersCardStyleState extends State<UsersCardStyle> {
  Future<void> _toggleFollow(BuildContext context) async {
    final userID = context.read<UserProvider>().userModel.userID;
    final postOwnerID = widget.data.userID.toString();
    final followsProvider = context.read<FollowsSocketProvider>();
    final userProvider = context.read<UserProvider>();
    final isFollowing =
        userProvider.userModel.following.any((f) => f.userID == postOwnerID) ||
            followsProvider
                .getFollowing(userID)
                .any((f) => f['userID'] == postOwnerID);
    final AuthService _authService = AuthService();

    // Store original following list for reversion on error
    final originalFollowing = List<FollowModel>.from(
      userProvider.userModel.following,
    );

    if (!isFollowing) {
      // Optimistic update: Add to UserModel's following list
      final updatedFollowing = List<FollowModel>.from(
        userProvider.userModel.following,
      )..add(
        FollowModel(
          followID: '', // Placeholder, server provides actual ID
          userID: postOwnerID!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      userProvider.updateUser(
        userProvider.userModel.copyWith(following: updatedFollowing),
      );

      try {
        await followsProvider.addFollower(postOwnerID);
        await _authService.userProfile(context);
      } catch (e) {
        userProvider.updateUser(
          userProvider.userModel.copyWith(following: originalFollowing),
        );
      }
    } else {
      final updatedFollowing = List<FollowModel>.from(
        userProvider.userModel.following,
      )..removeWhere((f) => f.userID == postOwnerID);
      userProvider.updateUser(
        userProvider.userModel.copyWith(following: updatedFollowing),
      );

      try {
        await followsProvider.removeFollower(postOwnerID!);
        await _authService.userProfile(context);
      } catch (e) {
        userProvider.updateUser(
          userProvider.userModel.copyWith(following: originalFollowing),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unfollow: ${e.toString()}')),
        );
      }
    }
  }

  String _getFollowButtonText(
      UserModel currentUser,
      UserModel displayedUser,
      FollowsSocketProvider followsProvider,
      ) {
    final currentUserId = currentUser.userID;
    final displayedUserId = displayedUser.userID.toString();

    if (currentUserId == displayedUserId) {
      return ""; // Don't show button for self
    }

    final isCurrentFollowing = currentUser.following.any((f) => f.userID == displayedUserId) ||
        followsProvider.getFollowing(currentUserId).any((f) => f['userID'] == displayedUserId);

    final isDisplayedFollowing = displayedUser.following.any((f) => f.userID == currentUserId) ||
        followsProvider.getFollowing(displayedUserId).any((f) => f['userID'] == currentUserId);

    if (isCurrentFollowing && isDisplayedFollowing) {
      return "Connected";
    } else if (!isCurrentFollowing && isDisplayedFollowing) {
      return "Follow back";
    } else if (isCurrentFollowing && !isDisplayedFollowing) {
      return "Following";
    } else {
      return "Follow";
    }
  }


  Color _getFollowButtonTextColor(
      UserModel currentUser,
      UserModel displayedUser,
      FollowsSocketProvider followsProvider,
      ) {
    final currentUserId = currentUser.userID;
    final displayedUserId = displayedUser.userID.toString();

    if (currentUserId == displayedUserId) {
      return Colors.transparent;
    }

    final buttonText = _getFollowButtonText(currentUser, displayedUser, followsProvider);

    switch (buttonText) {
      case "Connected":
        return Colors.green;
      case "Follow back":
        return Color(AppColors.primaryColor);
      case "Following":
        return Colors.grey;
      case "Follow":
        return Color(AppColors.primaryColor);
      default:
        return Colors.transparent;
    }
  }

  bool _shouldShowFollowIcon(
      UserModel currentUser,
      UserModel displayedUser,
      FollowsSocketProvider followsProvider,
      ) {
    final currentUserId = currentUser.userID;
    final displayedUserId = displayedUser.userID.toString();

    if (currentUserId == displayedUserId) {
      return false;
    }

    final buttonText = _getFollowButtonText(currentUser, displayedUser, followsProvider);
    return buttonText == "Follow" || buttonText == "Follow back";
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).userModel;
    final displayedUser = widget.data;
    final currentUserId = currentUser.userID;
    final displayedUserId = displayedUser.userID.toString();

    return Consumer3<
        LikeSocketProvider,
        ReactionSocketProvider,
        FollowsSocketProvider
    >(
      builder: (
          context,
          likeProvider,
          reactionProvider,
          followsProvider,
          child,
          ) {
        final buttonText = _getFollowButtonText(currentUser, displayedUser, followsProvider);
        final textColor = _getFollowButtonTextColor(currentUser, displayedUser, followsProvider);
        final showIcon = _shouldShowFollowIcon(currentUser, displayedUser, followsProvider);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    user: widget.data,
                  ),
                ),
              );
            },
            child: Container(
              height: 45,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.transparent),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: Stack(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child:
                          widget.data.image.isEmpty
                              ? Center(
                            child: Icon(
                              IconlyBold.profile,
                              color: Colors.grey,
                              size: 18,
                            ),
                          )
                              : Image.network(
                            widget.data.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, err, st) {
                              return Center(
                                child: Icon(
                                  IconlyBold.profile,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              );
                            },
                          ),
                        ),
                        widget.data.gender.isNotEmpty
                            ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                              widget.data.gender == "Male"
                                  ? Colors.purple
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 1,
                              ),
                              child: Text(
                                widget.data.gender,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.data.firstName} ${widget.data.lastName} ${widget.data.otherNames}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "Joined: ${DateFormat('MMMM d, y').format(DateTime.parse("${widget.data.createdAt}"))}",
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  Spacer(),
                  if (currentUserId != displayedUserId) // Only show button if not current user
                    Container(
                      height: 25,
                      // width: buttonText == "Connected" ? 85 : 70,
                      width: buttonText == "Follow" || buttonText == "Following" ? 70 : buttonText == "Connected" ? 70 : 90,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: textColor.withOpacity(0.1),
                      ),
                      child: MaterialButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _toggleFollow(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            showIcon ? Icon(
                              Icons.add,
                              color: textColor,
                              size: 14,
                            ) : const SizedBox.shrink(),
                            SizedBox(width: showIcon ? 2 : 0),
                            Text(
                              buttonText,
                              style: TextStyle(
                                fontSize: 11,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
