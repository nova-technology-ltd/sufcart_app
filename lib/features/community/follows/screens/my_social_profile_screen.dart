import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/follows/components/user_connections_card_one.dart';
import 'package:sufcart_app/features/community/follows/screens/user_followers_and_followings_screen.dart';
import 'package:sufcart_app/features/profile/model/user_provider.dart';
import 'package:sufcart_app/features/settings/account_settings/screens/profile_settings.dart';
import 'package:sufcart_app/utilities/components/app_bar_back_arrow.dart';
import 'package:sufcart_app/utilities/components/read_more_text.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';

import '../../../../utilities/constants/app_colors.dart';
import '../../../profile/model/user_model.dart';
import '../../../settings/screen/settings_screen.dart';
import '../../messages/presentations/screens/my_connections_screen.dart';
import '../../posts/model/post_model.dart';
import '../../posts/service/post_services.dart';
import '../../repost/service/repost_service.dart';
import '../section/profile_post_tab_section.dart';
import '../section/profile_repost_section.dart';
import '../services/follows_services.dart';

class MySocialProfileScreen extends StatefulWidget {
  final UserModel user;

  const MySocialProfileScreen({super.key, required this.user});

  @override
  State<MySocialProfileScreen> createState() => _MySocialProfileScreenState();
}

class _MySocialProfileScreenState extends State<MySocialProfileScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _futureAnalytics;
  final FollowsServices _followsServices = FollowsServices();
  late TabController _tabController;
  late Future<List<PostModel>> _futurePosts;
  late Future<List<UserModel>> _futureConnections;
  late Future<List<Map<String, dynamic>>> _futureReposts;
  final PostServices _postServices = PostServices();
  final RepostService _repostService = RepostService();

  // Function to refresh posts
  Future<void> _refreshScreen() async {
    setState(() {
      _futurePosts = _postServices.postsByUser(context, widget.user.userID);
      _futureReposts = _repostService.repostsByUser(
        context,
        widget.user.userID,
      );
      _futureAnalytics = _followsServices.userProfileAnalytics(
        context,
        widget.user.userID,
      );
      _futureConnections = _followsServices.getConnections(context);
    });
  }

  // Function to handle post deletion
  Future<void> _handleDeletePost(PostModel post) async {
    try {
      await _postServices.deletePost(context, post.postID);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _futurePosts = _postServices.postsByUser(context, widget.user.userID);
    _futureReposts = _repostService.repostsByUser(context, widget.user.userID);
    _futureAnalytics = _followsServices.userProfileAnalytics(
      context,
      widget.user.userID,
    );
    _futureConnections = _followsServices.getConnections(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userModel;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              backgroundColor:
                  isDarkMode
                      ? Color(AppColors.primaryColorDarkMode)
                      : Colors.white,
              surfaceTintColor:
                  isDarkMode
                      ? Color(AppColors.primaryColorDarkMode)
                      : Colors.white,
              automaticallyImplyLeading: false,
              leadingWidth: 90,
              centerTitle: true,
              title: Text(
                user.userName.isNotEmpty ? user.userName : "Profile",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              leading: AppBarBackArrow(
                onClick: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  tooltip: "Settings",
                  icon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        Image.asset(
                          "images/settings-outlined.png",
                          color: isDarkMode ? Colors.grey : Colors.black,
                        ),
                        user.isEmailVerified
                            ? const SizedBox.shrink()
                            : Positioned(
                              right: 0,
                              child: Container(
                                height: 10,
                                width: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ],
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
                                tag: "${user.firstName}${user.lastName[0]}",
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
                                        user.image == ""
                                            ? Center(
                                              child: Text(
                                                "${user.firstName[0]}${user.lastName[0]}",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                            : Image.network(
                                              user.image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                // Fallback to initials if image fails to load
                                                return Center(
                                                  child: Text(
                                                    "${user.firstName[0]}${user.lastName[0]}",
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
                                                "${user.followers.length}",
                                            likes: "0",
                                            following:
                                                '${user.following.length}',
                                            userID: user.userID,
                                          );
                                        } else if (snapshot.hasError ||
                                            !snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return _buildProfileActivitySummaryRow(
                                            context: context,
                                            followers:
                                                "${user.followers.length}",
                                            likes: "0",
                                            following:
                                                '${user.following.length}',
                                            userID: user.userID,
                                          );
                                        } else {
                                          final analytics = snapshot.data!;
                                          return _buildProfileActivitySummaryRow(
                                            context: context,
                                            followers:
                                                "${user.followers.length}",
                                            likes:
                                                "${analytics['totalLikes'] ?? 0}",
                                            following:
                                                '${user.following.length}',
                                            userID: user.userID,
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
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
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileSettings(userInfo: user)));
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
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${user.firstName} ${user.lastName} ${user.otherNames}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          user.bio.isEmpty
                              ? const SizedBox.shrink()
                              : ReadMoreText(
                                longText: user.bio,
                                size: 12,
                                color: Color(AppColors.primaryColor),
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
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
              onDeletePost: _handleDeletePost,
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
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
