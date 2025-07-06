import 'dart:math';
import 'package:animate_do/animate_do.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchVisible = false;

  @override
  void initState() {
    _futurePosts = _communityServices.allCommunityPosts(context);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method to refresh posts
  Future<void> _refreshPosts() async {
    setState(() {
      _futurePosts = _communityServices.allCommunityPosts(context);
    });
  }

  // Method to sort posts with weighted randomization
  List<PostModel> _sortPostsWithWeightedRandom(List<PostModel> posts) {
    List<PostModel> sortedPosts = List.from(posts);
    sortedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    int topNewCount = (sortedPosts.length * 0.7).ceil();
    List<PostModel> topNewPosts = sortedPosts.take(topNewCount).toList();
    List<PostModel> remainingPosts = sortedPosts.skip(topNewCount).toList();
    remainingPosts.shuffle(Random());
    return [...topNewPosts, ...remainingPosts];
  }

  // Method to filter posts based on search query
  List<PostModel> _filterPosts(List<PostModel> posts, String query) {
    if (query.isEmpty) return posts;
    return posts.where((post) {
      // Assuming PostModel has fields like 'title' or 'description'
      // Modify based on your PostModel structure
      final userName = post.userDetails?.userName.toLowerCase() ?? '';
      final firstName = post.userDetails?.firstName.toLowerCase() ?? '';
      final lastName = post.userDetails?.lastName.toLowerCase() ?? '';
      final otherNames = post.userDetails?.otherNames.toLowerCase() ?? '';
      final description = post.postText.toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      return userName.contains(queryLower) || firstName.contains(queryLower) || lastName.contains(queryLower) || description.contains(queryLower) || otherNames.contains(queryLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final user = Provider.of<UserProvider>(context).userModel;
    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? null : Colors.white,
        surfaceTintColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
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
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            icon: Icon(
              _isSearchVisible ? IconlyLight.close_square : IconlyLight.search,
              color: Colors.grey,
            ),
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
                    color: Colors.grey.withOpacity(0.2),
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
        child: Column(
          children: [
            if (_isSearchVisible)
              ZoomIn(
                duration: Duration(milliseconds: 500),
                child: Column(
                  children: [
                    Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: Container(
                      height: 43,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 7.0),
                              child: Icon(
                                IconlyLight.search,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller:
                                _searchController,
                                cursorColor: Colors.grey,
                                cursorHeight: 18,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  hintText: "search community...",
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                                ),
                    const SizedBox(height: 10,),
                  ],
                ),
              ),
            Expanded(
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
                  // Apply weighted randomization and then filter by search query
                  final sortedPosts = _sortPostsWithWeightedRandom(posts);
                  final displayedPosts = _filterPosts(sortedPosts, _searchQuery);
                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: displayedPosts
                          .map((post) => PostCardStyle(post: post))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}