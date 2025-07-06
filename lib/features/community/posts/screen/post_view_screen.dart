import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
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
  final PostModel postModel;

  const PostViewScreen({super.key, required this.postModel});

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  final PostViewServices _postViewServices = PostViewServices();
  int _currentImageIndex = 0;
  late Future<List<CommentModel>> _futureComments;
  final CommentServices _commentServices = CommentServices();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _postViewServices.viewPost(context, widget.postModel.postID);
    _futureComments = _commentServices.postComments(
      context,
      widget.postModel.postID,
    );
  }

  Future<void> _downloadImage() async {
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

      final response = await http.get(
        Uri.parse(widget.postModel.postImages[_currentImageIndex]),
      );
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Image saved to $filePath')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading image: $e')));
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

  bool _showEmojiPicker = false;
  final RepostService _repostService = RepostService();

  Map<String, int> _groupReactions(List<dynamic> reactions) {
    final Map<String, int> grouped = {};
    for (var reaction in reactions) {
      final emoji = reaction['reaction'] as String;
      grouped[emoji] = (grouped[emoji] ?? 0) + 1;
    }
    return grouped;
  }

  Future<void> _toggleEmojiPicker() async {
    try {
      setState(() {
        _showEmojiPicker = !_showEmojiPicker;
      });
      await _postViewServices.viewPost(context, widget.postModel.postID);
    } catch (e) {
      print('Error in _toggleEmojiPicker: $e');
    }
  }

  Future<void> _toggleRepost(BuildContext context, String postID) async {
    try {
      await _repostService.repostPost(context, postID);
      await _postViewServices.viewPost(context, widget.postModel.postID);
    } catch (e) {
      print(e);
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
    final formattedTime = formatRelativeTime(widget.postModel.createdAt);
    final user = Provider.of<UserProvider>(context).userModel;

    return Scaffold(
      backgroundColor:
          isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            leadingWidth: MediaQuery.of(context).size.width,
            backgroundColor: isDarkMode ? null : Colors.white,
            surfaceTintColor:
                isDarkMode
                    ? Color(AppColors.primaryColorDarkMode)
                    : Colors.white,
            leading: _buildAppBarContent(formattedTime, isDarkMode, theme),
            actions: [
              IconButton(
                icon:
                    _isDownloading
                        ? const CupertinoActivityIndicator()
                        : const Icon(CupertinoIcons.cloud_download),
                onPressed: _downloadImage,
                tooltip: "Download",
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.postModel.postImages.isNotEmpty) _buildPostImages(),
                _buildPostContent(isDarkMode, theme),
                _buildPostStats(isDarkMode, theme),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarContent(
    String formattedTime,
    bool isDarkMode,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
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
            widget.postModel.userDetails?.image ?? '',
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Icon(
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
                widget.postModel.userDetails?.userName ?? 'Unknown',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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

  Widget _buildPostImages() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 500,
            viewportFraction: 1.0,
            enableInfiniteScroll: widget.postModel.postImages.length > 1,
            autoPlay: widget.postModel.postImages.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items:
              widget.postModel.postImages.map((image) {
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
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                        ),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) => Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                  ),
                );
              }).toList(),
        ),
        if (widget.postModel.postImages.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  widget.postModel.postImages.asMap().entries.map((entry) {
                    return Container(
                      width: _currentImageIndex == entry.key ? 8 : 6,
                      height: _currentImageIndex == entry.key ? 8 : 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentImageIndex == entry.key
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

  Widget _buildPostContent(bool isDarkMode, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        widget.postModel.postText,
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

  Widget _buildPostStats(bool isDarkMode, ThemeData theme) {
    final userID = context.read<UserProvider>().userModel.userID;
    final postOwnerID = widget.postModel.userDetails?.userID.toString();
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
        final reactions = reactionProvider.getReactions(
          widget.postModel.postID,
        );
        final reposts = repostProvider.getRepost(widget.postModel.postID);
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
                    children:
                        groupedReactions.entries.map((entry) {
                          final emoji = entry.key;
                          final count = entry.value;
                          return ReactionCardStyle(
                            reaction: emoji,
                            count: "$count",
                            onTap: () {
                              context
                                  .read<ReactionSocketProvider>()
                                  .removeReaction(
                                    widget.postModel.postID,
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
                    icon:
                        widget.postModel.likes.any(
                              (like) => like.userID == widget.postModel.userID,
                            )
                            ? IconlyBold.heart
                            : IconlyLight.heart,
                    color:
                        widget.postModel.likes.any(
                              (like) => like.userID == widget.postModel.userID,
                            )
                            ? Colors.red
                            : isDarkMode
                            ? Colors.grey[400]!
                            : Colors.grey[600]!,
                    count: widget.postModel.likes.length,
                    onTap: () {
                      // Implement like functionality
                    },
                  ),
                  GestureDetector(
                    onTap: () => _showCommentBottomSheet(context),
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
                    count: int.parse(
                      formatNumber(
                        double.parse("${widget.postModel.views.length}"),
                      ),
                    ),
                    onTap: () {},
                  ),
                  _buildStatButton(
                    icon: Icons.emoji_emotions_outlined,
                    color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                    count: int.parse(
                      formatNumber(double.parse("$reactionCount")),
                    ),
                    onTap: _toggleEmojiPicker,
                  ),
                  _buildStatButton(
                    icon: Icons.repeat,
                    color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                    count: 0,
                    onTap: () => _toggleRepost(context, widget.postModel.postID),
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

  void _showCommentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CommentBottomSheetSection(postModel: widget.postModel),
    );
  }
}
