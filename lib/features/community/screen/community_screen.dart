import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../profile/model/user_provider.dart';
import '../../profile/screens/profile_screen.dart';
import '../posts/components/post_card_style.dart';
import '../posts/helper/post_shimmer_loader.dart';
import '../posts/model/post_model.dart';
import '../posts/service/post_services.dart';
import '../posts/screen/create_post_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late Future<List<PostModel>> _futurePosts;
  final PostServices _communityServices = PostServices();

  @override
  void initState() {
    _futurePosts = _communityServices.allCommunityPosts(context);
    super.initState();
  }

  // Method to refresh posts
  Future<void> _refreshPosts() async {
    setState(() {
      _futurePosts = _communityServices.allCommunityPosts(context);
    });
  }

  // Method to sort posts with weighted randomization
  List<PostModel> _sortPostsWithWeightedRandom(List<PostModel> posts) {
    // Create a copy of the posts list to avoid modifying the original
    List<PostModel> sortedPosts = List.from(posts);
    // Sort by createdAt in descending order (newest first)
    sortedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Ensure at least 70% of the top posts are the newest
    int topNewCount = (sortedPosts.length * 0.7).ceil();
    List<PostModel> topNewPosts = sortedPosts.take(topNewCount).toList();
    List<PostModel> remainingPosts = sortedPosts.skip(topNewCount).toList();

    // Shuffle the remaining posts to introduce randomness
    remainingPosts.shuffle(Random());

    // Combine the top new posts with the shuffled remaining posts
    return [...topNewPosts, ...remainingPosts];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final user = Provider.of<UserProvider>(context).userModel;
    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? null : Colors.white,
        surfaceTintColor: isDarkMode ? Colors.black : Colors.white,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Community",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              "let's get you updated shall we!",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreatePostScreen(),
                ),
              );
            },
            icon: Icon(IconlyLight.image, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(IconlyLight.search, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Hero(
                tag: "${user.firstName}${user.lastName[0]}",
                child: Container(
                  height: 35,
                  width: 35,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    user.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, err, st) {
                      return Center(
                        child: Icon(
                          IconlyBold.profile,
                          size: 13,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        backgroundColor: Colors.white,
        color: Color(AppColors.primaryColor),
        child: FutureBuilder<List<PostModel>>(
          future: _futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return PostShimmerLoader();
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "No posts available",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              );
            }
            final posts = snapshot.data!;
            // Apply weighted randomization to posts
            final displayedPosts = _sortPostsWithWeightedRandom(posts);
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children:
                displayedPosts.map((post) => PostCardStyle(post: post)).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}