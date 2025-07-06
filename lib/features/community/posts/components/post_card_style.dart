import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:sufcart_app/features/community/follows/screens/user_profile_screen.dart';
import 'package:sufcart_app/features/community/repost/socket/repost_socket_provider.dart';
import '../../../../../utilities/socket/socket_config_provider.dart';
import '../../../../utilities/components/read_more_text.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/constants/app_icons.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../auth/service/auth_service.dart';
import '../../../profile/model/user_provider.dart';
import '../../comments/components/comment_bottom_sheet_section.dart';
import '../../comments/model/comment_model.dart';
import '../../comments/service/comment_services.dart';
import '../../follows/model/follow_model.dart';
import '../../follows/socket/follows_socket_provider.dart';
import '../../likes/socket/like_socket_provider.dart';
import '../../reactions/component/reaction_card_style.dart';
import '../../reactions/socket/reaction_socket_provider.dart';
import '../../repost/service/repost_service.dart';
import '../../views/services/post_view_services.dart';
import '../model/post_model.dart';
import '../screen/post_view_screen.dart';
import 'dynamic_post_image_container.dart';

class PostCardStyle extends StatefulWidget {
  final PostModel post;

  const PostCardStyle({super.key, required this.post});

  @override
  State<PostCardStyle> createState() => _PostCardStyleState();
}

class _PostCardStyleState extends State<PostCardStyle> {
  late Future<List<CommentModel>> _futureComments;
  final CommentServices _commentServices = CommentServices();
  bool _showEmojiPicker = false;
  bool _isLiked = false;
  int _likeCount = 0;
  final PostViewServices _postViewServices = PostViewServices();

  final RepostService _repostService = RepostService();

  @override
  void initState() {
    super.initState();
    _futureComments = _commentServices.postComments(
      context,
      widget.post.postID,
    );

    // Initialize like state and count from provider
    final likeProvider = context.read<LikeSocketProvider>();
    final userID = context.read<UserProvider>().userModel.userID;
    _isLiked = likeProvider.isPostLikedByUser(widget.post.postID, userID);
    _likeCount = likeProvider.getLikeCount(widget.post.postID);

    // Join post room after socket connection
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final socketProvider = context.read<SocketConfigProvider>();
      if (!socketProvider.isConnected) {
        await socketProvider.connectionStatus.firstWhere(
          (status) => status == true,
          orElse: () => false,
        );
      }
      if (socketProvider.isConnected) {
        likeProvider.joinPost(widget.post.postID);
        context.read<ReactionSocketProvider>().joinPost(widget.post.postID);
        context.read<FollowsSocketProvider>().joinCommunity(userID);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Socket not connected, please try again'),
          ),
        );
      }
    });
  }

  void _showCommentBottomSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CommentBottomSheetSection(postModel: widget.post),
    );
  }

  Future<void> _toggleLike(BuildContext context) async {
    try {
      final userID = context.read<UserProvider>().userModel.userID;
      final provider = context.read<LikeSocketProvider>();

      // Perform toggle via provider
      await provider.toggleLike(widget.post.postID, userID);

      // Update local state after server response
      setState(() {
        _isLiked = provider.isPostLikedByUser(widget.post.postID, userID);
        _likeCount = provider.getLikeCount(widget.post.postID);
      });

      // View post after successful toggle
      await _postViewServices.viewPost(context, widget.post.postID);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle like: ${e.toString()}')),
      );
    }
  }

  void _addReaction(BuildContext context, String reaction) {
    context.read<ReactionSocketProvider>().addReaction(
      widget.post.postID,
      reaction,
    );
    setState(() {
      _showEmojiPicker = false;
    });
  }

  Future<void> _toggleEmojiPicker() async {
    try {
      setState(() {
        _showEmojiPicker = !_showEmojiPicker;
      });
      await _postViewServices.viewPost(context, widget.post.postID);
    } catch (e) {
      print('Error in _toggleEmojiPicker: $e');
    }
  }

  Future<void> _toggleRepost(BuildContext context, String postID) async {
    try{
      await _repostService.repostPost(context, postID);
      await _postViewServices.viewPost(context, widget.post.postID);
    } catch(e) {
      print(e);
    }
  }

  Future<void> _toggleFollow(BuildContext context) async {
    final userID = context.read<UserProvider>().userModel.userID;
    final postOwnerID = widget.post.userDetails?.userID.toString();
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
        await _postViewServices.viewPost(context, widget.post.postID);
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
        await _postViewServices.viewPost(context, widget.post.postID);
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

  String formatRelativeTime(String dateTimeString) {
    final inputDate = DateTime.parse(dateTimeString).toLocal();
    final now = DateTime.now();
    final difference = now.difference(inputDate);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes${minutes == 1 ? 'm' : 'm'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours${hours == 1 ? 'hr' : 'hr'} ago';
    } else if (difference.inDays < 10) {
      final days = difference.inDays;
      return '$days${days == 1 ? ' day' : ' days'} ago';
    } else {
      final formatter = DateFormat('d MMM yyyy');
      return formatter.format(inputDate);
    }
  }

  Map<String, int> _groupReactions(List<dynamic> reactions) {
    final Map<String, int> grouped = {};
    for (var reaction in reactions) {
      final emoji = reaction['reaction'] as String;
      grouped[emoji] = (grouped[emoji] ?? 0) + 1;
    }
    return grouped;
  }

  String formatNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}b';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}m';
    } else if (number >= 9500) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final user = Provider.of<UserProvider>(context).userModel;
    final formattedTime = formatRelativeTime("${widget.post.createdAt}");
    final userID = context.read<UserProvider>().userModel.userID;
    final postOwnerID = widget.post.userDetails?.userID.toString();
    final userFollowing = context.read<UserProvider>().userModel.following;

    return Consumer4<
      LikeSocketProvider,
      ReactionSocketProvider,
      FollowsSocketProvider,
      RepostSocketProvider
    >(
      builder: (
        context,
        likeProvider,
        reactionProvider,
        followsProvider,
        repostProvider,
        child,
      ) {
        final reactions = reactionProvider.getReactions(widget.post.postID);
        final reposts = repostProvider.getRepost(widget.post.postID);
        final reactionCount = reactions.length;
        final repostCount = reposts.length;
        final userReaction = reactions.firstWhere(
          (r) => r['userID'] == userID,
          orElse: () => null,
        );
        final groupedReactions = _groupReactions(reactions);
        final isFollowing =
            userFollowing.any((f) => f.userID == postOwnerID) ||
            followsProvider
                .getFollowing(userID)
                .any((f) => f['userID'] == postOwnerID);
        _isLiked = likeProvider.isPostLikedByUser(widget.post.postID, userID);
        _likeCount = likeProvider.getLikeCount(widget.post.postID);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5),
          child: GestureDetector(
            onTap: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => PostViewScreen(postModel: widget.post),
              //   ),
              // );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap:
                                        user.userID ==
                                                widget.post.userDetails?.userID
                                            ? () {}
                                            : () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => UserProfileScreen(
                                                        user:
                                                            widget
                                                                .post
                                                                .userDetails,
                                                      ),
                                                  settings: RouteSettings(
                                                    arguments: {
                                                      'heroTag':
                                                          "userProfile_${widget.post.userDetails?.userID}_${widget.post.postID}",
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                    child: Hero(
                                      tag:
                                          "userProfile_${widget.post.userDetails?.userID}_${widget.post.postID}",
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.network(
                                          widget.post.userDetails!.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, err, st) {
                                            return const Center(
                                              child: Icon(
                                                IconlyBold.profile,
                                                color: Colors.grey,
                                                size: 15,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.post.userDetails!.firstName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 2.0,
                                            ),
                                            child: Container(
                                              height: 4,
                                              width: 4,
                                              decoration: const BoxDecoration(
                                                color: Colors.grey,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            formattedTime,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        widget.post.userDetails!.userName,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (!isFollowing && postOwnerID != userID)
                                Container(
                                  height: 30,
                                  width: 75,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: const Color(AppColors.primaryColor),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: MaterialButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _toggleFollow(context),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          "Follow",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
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
                        SizedBox(height: 5),
                        widget.post.postText.isNotEmpty
                            ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: ReadMoreText(
                                longText: widget.post.postText,
                                color: isDarkMode ? null : Colors.black,
                              ),
                            )
                            : const SizedBox.shrink(),
                        SizedBox(height: 5),
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostViewScreen(postModel: widget.post)));
                          },
                            child: DynamicImageContainer(post: widget.post, user: user)),
                        const SizedBox(height: 5),
                        if (groupedReactions.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  groupedReactions.entries.map((entry) {
                                    final emoji = entry.key;
                                    final count = entry.value;
                                    return ReactionCardStyle(
                                      reaction: emoji,
                                      count: "$count",
                                      onTap: (){
                                        context.read<ReactionSocketProvider>().removeReaction(
                                          widget.post.postID,
                                          userReaction?['reactionID'] ?? '',
                                        );
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: SizedBox(
                            height: 30,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Image.asset(
                                            AppIcons.viewsIcon,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          formatNumber(
                                            double.parse(
                                              "${widget.post.views.length}",
                                            ),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        () => _showCommentBottomSheet(context),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: Image.asset(
                                              AppIcons.commentIcon,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          _totalComments(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _toggleLike(context),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 21,
                                            width: 21,
                                            child: Image.asset(
                                              _isLiked
                                                  ? AppIcons.heartSelected
                                                  : AppIcons.heartUnselected,
                                              color:
                                                  _isLiked
                                                      ? Colors.red
                                                      : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            formatNumber(
                                              double.parse(
                                                _likeCount.toString(),
                                              ),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _toggleEmojiPicker,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 19,
                                            width: 19,
                                            child: Image.asset(
                                              AppIcons.reactionIcon,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            formatNumber(
                                              double.parse("$reactionCount"),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _toggleRepost(context, widget.post.postID),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: Icon(
                                              Icons.repeat,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            formatNumber(
                                              double.parse("$repostCount"),
                                            ),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_showEmojiPicker)
                          SizedBox(
                            height: 250,
                            child: EmojiPicker(
                              onEmojiSelected: (category, emoji) {
                                _addReaction(context, emoji.emoji);
                              },
                              config: const Config(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    height: 10,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
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

  Widget _totalComments() {
    return FutureBuilder<List<CommentModel>>(
      future: _futureComments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          return const Text(
            "0",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            "0",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          );
        }
        final comments = snapshot.data!;
        return Text(
          formatNumber(double.parse("${comments.length}")),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}
