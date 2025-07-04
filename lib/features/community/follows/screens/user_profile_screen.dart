import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/follows/section/profile_post_tab_section.dart';
import 'package:sufcart_app/features/community/follows/section/profile_repost_section.dart';
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
  final PostServices _postServices = PostServices();
  final RepostService _repostService = RepostService();

  Future<void> _toggleFollow(BuildContext context) async {
    final userID = context.read<UserProvider>().userModel.userID;
    final accountOwnerID = widget.user?.userID.toString();
    final followsProvider = context.read<FollowsSocketProvider>();
    final userProvider = context.read<UserProvider>();
    final isFollowing =
        userProvider.userModel.following.any((f) => f.userID == accountOwnerID) ||
        followsProvider
            .getFollowing(userID)
            .any((f) => f['userID'] == accountOwnerID);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unfollow: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _futurePosts = _postServices.postsByUser(context, widget.user!.userID);
    _futureReposts = _repostService.repostsByUser(context, widget.user!.userID);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
                  themeProvider.isDarkMode ? Colors.black : Colors.white,
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
            // Posts tab content
            ProfilePostTabSection(futurePosts: _futurePosts),
            // Reposts tab content
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
    final currentUserID = Provider.of<UserProvider>(context).userModel;
    final userID = context.read<UserProvider>().userModel.userID;
    final accountOwner = widget.user?.userID.toString();
    final userFollowing = context.read<UserProvider>().userModel.following;

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
        final isFollowing =
            userFollowing.any((f) => f.userID == accountOwner) ||
                followsProvider
                    .getFollowing(userID)
                    .any((f) => f['userID'] == accountOwner);
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
                    border: Border.all(width: 1, color: Colors.grey)
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
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProfileActivitySummary(
                      context: context,
                      data: "${user.followers.length}",
                      title: 'Followers',
                    ),
                    const SizedBox(width: 5),
                    Container(
                      height: 30,
                      width: 1,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 5),
                    _buildProfileActivitySummary(
                      context: context,
                      data: "${user.following.length}",
                      title: 'Likes',
                    ),
                    const SizedBox(width: 5),
                    Container(
                      height: 30,
                      width: 1,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 5),
                    _buildProfileActivitySummary(
                      context: context,
                      data: "${user.following.length}",
                      title: 'Following',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Container(
                        height: 36,
                        width: MediaQuery.of(context).size.width,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: !isFollowing && accountOwner != userID ? Color(AppColors.primaryColor).withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: MaterialButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _toggleFollow(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              !isFollowing && accountOwner != userID ? Icon(
                                Icons.add,
                                color: Color(AppColors.primaryColor),
                                size: 15,
                              ) : const SizedBox.shrink(),
                              SizedBox(width: !isFollowing && accountOwner != userID ? 5 : 0),
                              Text(
                                !isFollowing && accountOwner != userID ? "Follow" : "Following",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: !isFollowing && accountOwner != userID ? Color(AppColors.primaryColor) : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                            if (currentUserID != null && user != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatScreen(
                                        receiver: user,
                                        sender: currentUserID,
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
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ReadMoreText(
                  longText:
                      "🎵 Singer-Songwriter | 🎸 Guitar Enthusiast | 🎤 Performing Artist",
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileActivitySummary({
    required BuildContext context,
    required String data,
    required String title,
  }) {
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

    return Expanded(
      child: Container(
        decoration: const BoxDecoration(),
        child: Column(
          children: [
            Text(
              formatNumber(double.parse(data)),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
      color: isDarkMode ? null : Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
