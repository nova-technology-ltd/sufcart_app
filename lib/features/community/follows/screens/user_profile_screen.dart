import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/follows/screens/user_followers_and_followings_screen.dart';
import 'package:sufcart_app/features/community/follows/section/profile_post_tab_section.dart';
import 'package:sufcart_app/features/community/follows/section/profile_repost_section.dart';
import 'package:sufcart_app/features/community/follows/services/follows_services.dart';
import 'package:sufcart_app/features/community/posts/model/post_model.dart';
import 'package:sufcart_app/features/community/posts/service/post_services.dart';
import 'package:sufcart_app/features/community/repost/model/repost_model.dart';
import 'package:sufcart_app/features/community/repost/service/repost_service.dart';
import 'package:sufcart_app/features/profile/model/user_model.dart';
import 'package:sufcart_app/utilities/components/app_bar_back_arrow.dart';
import 'package:sufcart_app/utilities/components/read_more_text.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';
import '../../../auth/service/auth_service.dart';
import '../../../profile/model/user_provider.dart';
import '../../likes/socket/like_socket_provider.dart';
import '../../messages/screens/chat_screen.dart';
import '../../reactions/socket/reaction_socket_provider.dart';
import '../model/follow_model.dart';
import '../socket/follows_socket_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel? user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<PostModel>> _futurePosts;
  late Future<List<Map<String, dynamic>>> _futureReposts;
  late Future<Map<String, dynamic>> _futureAnalytics;
  final PostServices _postServices = PostServices();
  final RepostService _repostService = RepostService();
  final FollowsServices _followsServices = FollowsServices();

  Future<void> _toggleFollow(BuildContext context) async {
    final userID = context.read<UserProvider>().userModel.userID;
    final accountOwnerID = widget.user?.userID.toString();
    final followsProvider = context.read<FollowsSocketProvider>();
    final userProvider = context.read<UserProvider>();
    final isFollowing =
        userProvider.userModel.following.any(
          (f) => f.userID == accountOwnerID,
        ) ||
        followsProvider
            .getFollowing(userID)
            .any((f) => f['userID'] == accountOwnerID);
    final AuthService _authService = AuthService();

    final originalFollowing = List<FollowModel>.from(
      userProvider.userModel.following,
    );

    if (!isFollowing) {
      final updatedFollowing = List<FollowModel>.from(
        userProvider.userModel.following,
      )..add(
        FollowModel(
          followID: '',
          userID: accountOwnerID!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      userProvider.updateUser(
        userProvider.userModel.copyWith(following: updatedFollowing),
      );

      try {
        await followsProvider.addFollower(accountOwnerID);
        await _authService.userProfile(context);
      } catch (e) {
        userProvider.updateUser(
          userProvider.userModel.copyWith(following: originalFollowing),
        );
      }
    } else {
      final updatedFollowing = List<FollowModel>.from(
        userProvider.userModel.following,
      )..removeWhere((f) => f.userID == accountOwnerID);
      userProvider.updateUser(
        userProvider.userModel.copyWith(following: updatedFollowing),
      );

      try {
        await followsProvider.removeFollower(accountOwnerID!);
        await _authService.userProfile(context);
      } catch (e) {
        userProvider.updateUser(
          userProvider.userModel.copyWith(following: originalFollowing),
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

    final isCurrentFollowing =
        currentUser.following.any((f) => f.userID == displayedUserId) ||
        followsProvider
            .getFollowing(currentUserId)
            .any((f) => f['userID'] == displayedUserId);

    final isDisplayedFollowing =
        displayedUser.following.any((f) => f.userID == currentUserId) ||
        followsProvider
            .getFollowing(displayedUserId)
            .any((f) => f['userID'] == currentUserId);

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

    final buttonText = _getFollowButtonText(
      currentUser,
      displayedUser,
      followsProvider,
    );

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

    final buttonText = _getFollowButtonText(
      currentUser,
      displayedUser,
      followsProvider,
    );
    return buttonText == "Follow" || buttonText == "Follow back";
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _futurePosts = _postServices.postsByUser(context, widget.user!.userID);
    _futureReposts = _repostService.repostsByUser(context, widget.user!.userID);
    _futureAnalytics = _followsServices.userProfileAnalytics(
      context,
      widget.user!.userID,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentUser = Provider.of<UserProvider>(context).userModel;
    final displayedUser = widget.user!;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              leadingWidth: 90,
              leading: AppBarBackArrow(
                onClick: () {
                  Navigator.pop(context);
                },
              ),
              actions: [],
              backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
              surfaceTintColor:
                  themeProvider.isDarkMode
                      ? Color(AppColors.primaryColorDarkMode)
                      : Colors.white,
              elevation: 0,
              scrolledUnderElevation: 1,
              centerTitle: true,
              title: const Text(
                "Details",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildProfileHeader(context: context, user: widget.user),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Color(AppColors.primaryColor),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(AppColors.primaryColor),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(IconlyLight.document, size: 18),
                          SizedBox(width: 8),
                          Text('Posts'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(IconlyLight.upload, size: 18),
                          SizedBox(width: 8),
                          Text('Reposts'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          physics: BouncingScrollPhysics(),
          children: [
            ProfilePostTabSection(futurePosts: _futurePosts, onDeletePost: (PostModel ) {  },),
            ProfileRepostSection(futureReposts: _futureReposts),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required BuildContext context,
    required UserModel? user,
  }) {
    final fullName = "${user?.firstName} ${user?.lastName} ${user?.otherNames}";
    final currentUser = Provider.of<UserProvider>(context).userModel;
    final displayedUser = widget.user!;

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
        final buttonText = _getFollowButtonText(
          currentUser,
          displayedUser,
          followsProvider,
        );
        final textColor = _getFollowButtonTextColor(
          currentUser,
          displayedUser,
          followsProvider,
        );
        final showIcon = _shouldShowFollowIcon(
          currentUser,
          displayedUser,
          followsProvider,
        );

        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: [
              Hero(
                tag:
                    ModalRoute.of(context)!.settings.arguments != null
                        ? (ModalRoute.of(context)!.settings.arguments
                            as Map)['heroTag']
                        : "userProfile_${user?.userID}",
                child: Container(
                  height: 70,
                  width: 60,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      height: 70,
                      width: 60,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.network(
                        user!.image,
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
              ),
              const SizedBox(height: 5),
              Text(
                fullName.length > 25
                    ? "${fullName.substring(0, 25)}..."
                    : fullName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                user.userName.length > 25
                    ? "${user.userName.substring(0, 25)}..."
                    : user.userName,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              FutureBuilder<Map<String, dynamic>>(
                future: _futureAnalytics,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildProfileActivitySummaryRow(
                      context: context,
                      followers: "${user.followers.length}",
                      likes: "0",
                      following: '${user.following.length}',
                      posts: '0', userID: user.userID,
                    );
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return _buildProfileActivitySummaryRow(
                      context: context,
                      followers: "${user.followers.length}",
                      likes: "0",
                      following: '${user.following.length}',
                      posts: '0', userID: user.userID,
                    );
                  } else {
                    final analytics = snapshot.data!;
                    return _buildProfileActivitySummaryRow(
                      context: context,
                      followers: "${user.followers.length}",
                      likes: "${analytics['totalLikes'] ?? 0}",
                      following: '${user.following.length}',
                      posts: '${analytics['totalPosts'] ?? 0}', userID: user.userID,
                    );
                  }
                },
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    if (currentUser.userID != displayedUser.userID.toString())
                      Expanded(
                        flex: 7,
                        child: Container(
                          height: 36,
                          width: MediaQuery.of(context).size.width,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: MaterialButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _toggleFollow(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (showIcon)
                                  Icon(Icons.add, color: textColor, size: 15),
                                SizedBox(width: showIcon ? 5 : 0),
                                Text(
                                  buttonText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (currentUser.userID != displayedUser.userID.toString())
                      const SizedBox(width: 10),
                    if (currentUser.userID != displayedUser.userID.toString())
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 35,
                          width: MediaQuery.of(context).size.width,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: MaterialButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              if (currentUser != null && user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ChatScreen(
                                          receiver: user,
                                          sender: currentUser,
                                        ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Unable to start chat. User information missing.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.chat_bubble_2,
                                  color: Colors.orange,
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Message",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.orange,
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
              SizedBox(height: user.bio.isEmpty ? 0 : 15),
              user.bio.isEmpty ? const SizedBox.shrink() : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ReadMoreText(
                  longText:
                      user.bio,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileActivitySummaryRow({
    required BuildContext context,
    required String followers,
    required String likes,
    required String following,
    required String posts,
    required String userID
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildProfileActivitySummary(
            context: context,
            data: followers,
            title: 'Followers',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => UserFollowersAndFollowingsScreen(userID: userID),
                ),
              );
            },
          ),
          const SizedBox(width: 5),
          Container(
            height: 30,
            width: 1,
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3)),
          ),
          const SizedBox(width: 5),
          _buildProfileActivitySummary(
            context: context,
            data: likes,
            title: 'Likes', onTap: () {  },
          ),
          const SizedBox(width: 5),
          Container(
            height: 30,
            width: 1,
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3)),
          ),
          const SizedBox(width: 5),
          _buildProfileActivitySummary(
            context: context,
            data: following,
            title: 'following',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => UserFollowersAndFollowingsScreen(userID: userID),
                ),
              );
            },
          ),
          const SizedBox(width: 5),
          Container(
            height: 30,
            width: 1,
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3)),
          ),
          const SizedBox(width: 5),
          _buildProfileActivitySummary(
            context: context,
            data: posts,
            title: 'Posts',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActivitySummary({
    required BuildContext context,
    required String data,
    required String title,
    required VoidCallback onTap,
  }) {
    String formatNumber(String data) {
      double number = double.tryParse(data) ?? 0;
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

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(),
          child: Column(
            children: [
              Text(
                formatNumber(data),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
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
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      color: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
