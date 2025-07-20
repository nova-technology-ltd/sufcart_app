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
import '../../../settings/account_settings/screens/profile_settings.dart';
import '../../likes/socket/like_socket_provider.dart';
import '../../messages/presentations/screens/chat_screen.dart';
import '../../messages/presentations/screens/my_connections_screen.dart';
import '../../reactions/socket/reaction_socket_provider.dart';
import '../components/user_connections_card_one.dart';
import '../model/follow_model.dart';
import '../socket/follows_socket_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel user;

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
  late Future<List<UserModel>> _futureConnections;
  final PostServices _postServices = PostServices();
  final RepostService _repostService = RepostService();
  final FollowsServices _followsServices = FollowsServices();

  Future<void> _toggleFollow(BuildContext context) async {
    final userID = context.read<UserProvider>().userModel.userID;
    final accountOwnerID = widget.user.userID.toString();
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
          userID: accountOwnerID,
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
        await followsProvider.removeFollower(accountOwnerID);
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
    _futurePosts = _postServices.postsByUser(context, widget.user.userID);
    _futureReposts = _repostService.repostsByUser(context, widget.user.userID);
    _futureAnalytics = _followsServices.userProfileAnalytics(
      context,
      widget.user.userID,
    );
    _futureConnections = _followsServices.getUserConnections(context, widget.user.userID);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final currentUser = Provider.of<UserProvider>(context).userModel;
    final displayedUser = widget.user;

    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
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
              backgroundColor:
                  isDarkMode
                      ? Color(AppColors.primaryColorDarkMode)
                      : Colors.white,
              surfaceTintColor:
                  isDarkMode
                      ? Color(AppColors.primaryColorDarkMode)
                      : Colors.white,
              elevation: 0,
              scrolledUnderElevation: 1,
              centerTitle: true,
              title: Text(
                widget.user.userName.isNotEmpty
                    ? widget.user.userName
                    : "Details",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag:
                                    "${widget.user.firstName}${widget.user.lastName[0]}",
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    height: 70,
                                    width: 70,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        AppColors.primaryColor,
                                      ).withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child:
                                        widget.user.image == ""
                                            ? Center(
                                              child: Text(
                                                "${widget.user.firstName[0]}${widget.user.lastName[0]}",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                            : Image.network(
                                              widget.user.image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                // Fallback to initials if image fails to load
                                                return Center(
                                                  child: Text(
                                                    "${widget.user.firstName[0]}${widget.user.lastName[0]}",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder<Map<String, dynamic>>(
                                      future: _futureAnalytics,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return _buildProfileActivitySummaryRow(
                                            context: context,
                                            followers:
                                                "${widget.user.followers.length}",
                                            likes: "0",
                                            following:
                                                '${widget.user.following.length}',
                                            userID: widget.user.userID,
                                          );
                                        } else if (snapshot.hasError ||
                                            !snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return _buildProfileActivitySummaryRow(
                                            context: context,
                                            followers:
                                                "${widget.user.followers.length}",
                                            likes: "0",
                                            following:
                                                '${widget.user.following.length}',
                                            userID: widget.user.userID,
                                          );
                                        } else {
                                          final analytics = snapshot.data!;
                                          return _buildProfileActivitySummaryRow(
                                            context: context,
                                            followers:
                                                "${widget.user.followers.length}",
                                            likes:
                                                "${analytics['totalLikes'] ?? 0}",
                                            following:
                                                '${widget.user.following.length}',
                                            userID: widget.user.userID,
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 5),
                                    Consumer3<
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
                                        final textColor =
                                            _getFollowButtonTextColor(
                                              currentUser,
                                              displayedUser,
                                              followsProvider,
                                            );
                                        final showIcon = _shouldShowFollowIcon(
                                          currentUser,
                                          displayedUser,
                                          followsProvider,
                                        );

                                        return widget.user.userID == currentUser.userID ? Container(
                                          height: 28,
                                          width: MediaQuery.of(context).size.width,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border: Border.all(
                                              width: 1,
                                              color: Colors.grey.withOpacity(0.5),
                                            ),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: MaterialButton(
                                            onPressed: () {
                                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileSettings(userInfo: currentUser)));
                                            },
                                            padding: EdgeInsets.zero,
                                            child: Center(
                                              child: Text(
                                                "Edit Profile",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ) :  Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 28,
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  color: textColor.withOpacity(
                                                    0.1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: MaterialButton(
                                                  onPressed:
                                                      () => _toggleFollow(
                                                        context,
                                                      ),
                                                  padding: EdgeInsets.zero,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      showIcon
                                                          ? Icon(
                                                            Icons.add,
                                                            color: textColor,
                                                            size: 14,
                                                          )
                                                          : const SizedBox.shrink(),
                                                      SizedBox(
                                                        width: showIcon ? 2 : 0,
                                                      ),
                                                      Text(
                                                        buttonText,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: textColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (currentUser.userID !=
                                                displayedUser.userID.toString())
                                              const SizedBox(width: 5),
                                            if (currentUser.userID !=
                                                displayedUser.userID.toString())
                                              Expanded(
                                                child: Container(
                                                  height: 28,
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: MaterialButton(
                                                    onPressed: () {
                                                      if (currentUser != null &&
                                                          widget.user != null) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => ChatScreen(
                                                                  receiver:
                                                                      widget
                                                                          .user,
                                                                  sender:
                                                                      currentUser,
                                                                ),
                                                          ),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Unable to start chat. User information missing.',
                                                            ),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    padding: EdgeInsets.zero,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons
                                                              .chat_bubble_2,
                                                          color: Colors.orange,
                                                          size: 15,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "Message",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${widget.user.firstName} ${widget.user.lastName} ${widget.user.otherNames}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.user.email,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          widget.user.bio.isEmpty
                              ? const SizedBox.shrink()
                              : ReadMoreText(
                                longText: widget.user.bio,
                                size: 12,
                                color: Color(AppColors.primaryColor),
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Connections",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyConnectionsScreen()));
                                },
                                child: Text(
                                  "See All",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(AppColors.primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        FutureBuilder<List<UserModel>>(
                          future: _futureConnections,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (int i = 0; i < 9; i++)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                        ),
                                        child: Container(
                                          height: 55,
                                          width: 55,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return SizedBox.shrink();
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return SizedBox.shrink();
                            }

                            final connections = snapshot.data!;
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children:
                                  connections.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final user = entry.value;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: index == 0 ? 10.0 : 4.0,
                                        right:
                                        index == connections.length - 1
                                            ? 10.0
                                            : 4.0,
                                      ),
                                      child: UserConnectionsCardOne(
                                        user: user,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
            ProfilePostTabSection(
              futurePosts: _futurePosts,
              onDeletePost: (PostModel) {},
            ),
            ProfileRepostSection(futureReposts: _futureReposts),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileActivitySummaryRow({
    required BuildContext context,
    required String followers,
    required String likes,
    required String following,
    required String userID,
  }) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
                        (context) =>
                            UserFollowersAndFollowingsScreen(userID: userID),
                  ),
                );
              },
            ),
            const SizedBox(width: 2),
            Container(
              height: 30,
              width: 1,
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3)),
            ),
            const SizedBox(width: 2),
            _buildProfileActivitySummary(
              context: context,
              data: likes,
              title: 'Likes',
              onTap: () {},
            ),
            const SizedBox(width: 2),
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
                        (context) =>
                            UserFollowersAndFollowingsScreen(userID: userID),
                  ),
                );
              },
            ),
          ],
        ),
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
