import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/posts/helper/post_view_shimmer.dart';
import 'package:sufcart_app/features/community/posts/service/post_services.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';
import '../../../../../utilities/themes/theme_provider.dart';
import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/constants/app_icons.dart';
import '../../../profile/model/user_provider.dart';
import '../../comments/components/comment_bottom_sheet_section.dart';
import '../../comments/model/comment_model.dart';
import '../../comments/service/comment_services.dart';
import '../../follows/socket/follows_socket_provider.dart';
import '../../likes/socket/like_socket_provider.dart';
import '../../reactions/component/reaction_card_style.dart';
import '../../reactions/socket/reaction_socket_provider.dart';
import '../../repost/service/repost_service.dart';
import '../../repost/socket/repost_socket_provider.dart';
import '../../views/services/post_view_services.dart';
import '../model/post_model.dart';

class PostViewScreen extends StatefulWidget {
  final String postID;

  const PostViewScreen({super.key, required this.postID});

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  final PostViewServices _postViewServices = PostViewServices();
  final PostServices _postServices = PostServices();
  final CommentServices _commentServices = CommentServices();
  final RepostService _repostService = RepostService();
  int _currentImageIndex = 0;
  late Future<PostModel> _futurePost;
  late Future<List<CommentModel>> _futureComments;
  bool _isDownloading = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    // Initialize the future to fetch the post
    _futurePost = _postServices.getPostByID(context, widget.postID);
  }

  Future<void> _downloadImage(String imageUrl) async {
    try {
      setState(() {
        _isDownloading = true;
      });
      Directory? downloadsDirectory;
      try {
        if (Platform.isAndroid) {
          downloadsDirectory = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          downloadsDirectory = await getDownloadsDirectory();
        }
      } catch (e) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      final folderPath = '${downloadsDirectory!.path}/sufcart_resources';
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$folderPath/$fileName';

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image saved to $filePath')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download image')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes min${minutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hr${hours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 10) {
      final days = difference.inDays;
      return '$days day${days == 1 ? '' : 's'} ago';
    } else {
      final formatter = DateFormat('d MMM yyyy');
      return formatter.format(dateTime);
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

  Future<void> _toggleEmojiPicker(String postID) async {
    try {
      setState(() {
        _showEmojiPicker = !_showEmojiPicker;
      });
      await _postViewServices.viewPost(context, postID);
    } catch (e) {
      print('Error in _toggleEmojiPicker: $e');
    }
  }

  Future<void> _toggleRepost(BuildContext context, String postID) async {
    try {
      await _repostService.repostPost(context, postID);
      await _postViewServices.viewPost(context, postID);
    } catch (e) {
      print('Error in _toggleRepost: $e');
    }
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
      isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
      body: FutureBuilder<PostModel>(
        future: _futurePost,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return PostViewShimmer();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading post: ${snapshot.error}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No post found'));
          }

          final postModel = snapshot.data!;
          // Initialize comments future after post is fetched
          _futureComments = _commentServices.postComments(context, postModel.postID);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: false,
                floating: true,
                snap: true,
                automaticallyImplyLeading: false,
                leadingWidth: MediaQuery.of(context).size.width,
                backgroundColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
                surfaceTintColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
                leading: _buildAppBarContent(postModel, isDarkMode, theme),
                actions: [
                  IconButton(
                    icon: _isDownloading
                        ? const CupertinoActivityIndicator()
                        : const Icon(CupertinoIcons.cloud_download),
                    onPressed: () => _downloadImage(postModel.postImages[_currentImageIndex]),
                    tooltip: "Download",
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (postModel.postImages.isNotEmpty) _buildPostImages(postModel),
                    _buildPostContent(postModel, isDarkMode, theme),
                    _buildPostStats(postModel, isDarkMode, theme),
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBarContent(PostModel postModel, bool isDarkMode, ThemeData theme) {
    final formattedTime = formatRelativeTime(postModel.createdAt);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.grey,
            size: 20,
          ),
        ),
        Container(
          height: 35,
          width: 35,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Image.network(
            postModel.userDetails?.image ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              IconlyBold.profile,
              size: 18,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                postModel.userDetails?.userName ?? 'Unknown',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 10,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostImages(PostModel postModel) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 500,
            viewportFraction: 1.0,
            enableInfiniteScroll: postModel.postImages.length > 1,
            autoPlay: postModel.postImages.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: postModel.postImages.map((image) {
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey[400],
                ),
              ),
            );
          }).toList(),
        ),
        if (postModel.postImages.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: postModel.postImages.asMap().entries.map((entry) {
                return Container(
                  width: _currentImageIndex == entry.key ? 8 : 6,
                  height: _currentImageIndex == entry.key ? 8 : 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPostContent(PostModel postModel, bool isDarkMode, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        postModel.postText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isDarkMode ? Colors.white : Colors.black87,
          height: 1.4,
        ),
      ),
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        );
      },
    );
  }

  Widget _buildPostStats(PostModel postModel, bool isDarkMode, ThemeData theme) {
    final userID = context.read<UserProvider>().userModel.userID;
    return Consumer4<
        LikeSocketProvider,
        ReactionSocketProvider,
        FollowsSocketProvider,
        RepostSocketProvider>(
      builder: (
          context,
          likeProvider,
          reactionProvider,
          followsProvider,
          repostProvider,
          child,
          ) {
        final reactions = reactionProvider.getReactions(postModel.postID);
        final reposts = repostProvider.getRepost(postModel.postID);
        final reactionCount = reactions.length;
        final repostCount = reposts.length;
        final userReaction = reactions.firstWhere(
              (r) => r['userID'] == userID,
          orElse: () => null,
        );
        final groupedReactions = _groupReactions(reactions);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (groupedReactions.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: groupedReactions.entries.map((entry) {
                      final emoji = entry.key;
                      final count = entry.value;
                      return ReactionCardStyle(
                        reaction: emoji,
                        count: "$count",
                        onTap: () {
                          context.read<ReactionSocketProvider>().removeReaction(
                            postModel.postID,
                            userReaction?['reactionID'] ?? '',
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(height: groupedReactions.isNotEmpty ? 5 : 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatButton(
                    icon: postModel.likes.any((like) => like.userID == userID)
                        ? IconlyBold.heart
                        : IconlyLight.heart,
                    color: postModel.likes.any((like) => like.userID == userID)
                        ? Colors.red
                        : isDarkMode
                        ? Colors.grey[400]!
                        : Colors.grey[600]!,
                    count: postModel.likes.length,
                    onTap: () {
                      // Implement like functionality
                    },
                  ),
                  GestureDetector(
                    onTap: () => _showCommentBottomSheet(context, postModel),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Image.asset(AppIcons.commentIcon),
                          ),
                          const SizedBox(width: 5),
                          _totalComments(),
                        ],
                      ),
                    ),
                  ),
                  _buildStatButton(
                    icon: IconlyLight.show,
                    color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                    count: int.parse(formatNumber(double.parse("${postModel.views.length}"))),
                    onTap: () {},
                  ),
                  _buildStatButton(
                    icon: Icons.emoji_emotions_outlined,
                    color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                    count: int.parse(formatNumber(double.parse("$reactionCount"))),
                    onTap: () => _toggleEmojiPicker(postModel.postID),
                  ),
                  _buildStatButton(
                    icon: Icons.repeat,
                    color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                    count: repostCount,
                    onTap: () => _toggleRepost(context, postModel.postID),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatButton({
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 4),
          Text(
            count > 0 ? '$count' : '',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentBottomSheet(BuildContext context, PostModel postModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheetSection(postModel: postModel),
    );
  }
}