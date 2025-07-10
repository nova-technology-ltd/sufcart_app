import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/follows/services/follows_services.dart';
import 'package:sufcart_app/utilities/components/app_bar_back_arrow.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';
import '../../../../utilities/components/shima_effects/invites_shimma_loader.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../profile/model/user_model.dart';
import '../components/users_card_style.dart';

class UserFollowersAndFollowingsScreen extends StatefulWidget {
  final String userID;

  const UserFollowersAndFollowingsScreen({super.key, required this.userID});

  @override
  State<UserFollowersAndFollowingsScreen> createState() =>
      _UserFollowersAndFollowingsScreenState();
}

class _UserFollowersAndFollowingsScreenState
    extends State<UserFollowersAndFollowingsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<UserModel>> _futureFollowers;
  late TabController _tabController;
  late Future<List<UserModel>> _futureFollowing;
  final FollowsServices _followsServices = FollowsServices();
  String _appBarTitle = "Followers";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _futureFollowers = _followsServices.getFollowers(context, widget.userID);
    _futureFollowing = _followsServices.getFollowing(context, widget.userID);
    _tabController.addListener(() {
      setState(() {
        _appBarTitle = _tabController.index == 0 ? "Followers" : "Following";
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? null : Colors.white,
        surfaceTintColor:
        isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        leadingWidth: 90,
        leading: AppBarBackArrow(
          onClick: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          _appBarTitle,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(AppColors.primaryColor),
          unselectedLabelColor: Colors.grey,
          isScrollable: false,
          indicatorColor: Color(AppColors.primaryColor),
          tabs: const [Tab(text: "Followers"), Tab(text: "Following")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Followers Tab
          FutureBuilder<List<UserModel>>(
            future: _futureFollowers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: InvitesShimmaLoader(count: 20),
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text('No followers'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No followers'));
              }

              final followers = snapshot.data!;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    children: [
                      for (var user in followers) UsersCardStyle(data: user),
                    ],
                  ),
                ),
              );
            },
          ),
          // Following Tab
          FutureBuilder<List<UserModel>>(
            future: _futureFollowing,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: InvitesShimmaLoader(count: 20),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No following found'));
              }

              final following = snapshot.data!;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    children: [
                      for (var user in following) UsersCardStyle(data: user),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}