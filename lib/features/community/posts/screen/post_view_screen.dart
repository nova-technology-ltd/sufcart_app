import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../utilities/themes/theme_provider.dart';
import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../comments/components/comment_bottom_sheet_section.dart';
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

  @override
  void initState() {
    super.initState();
    _postViewServices.viewPost(context, widget.postModel.postID);
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);
    final formattedTime = formatRelativeTime(widget.postModel.createdAt);

    return Scaffold(
      backgroundColor: isDarkMode ? theme.scaffoldBackgroundColor : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            leadingWidth: MediaQuery.of(context).size.width,
            backgroundColor: isDarkMode ? null : Colors.white,
            surfaceTintColor: isDarkMode ? Colors.black : Colors.white,
            leading: _buildAppBarContent(formattedTime, isDarkMode, theme),

          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.postModel.postImages.isNotEmpty)
                  _buildPostImages(),
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

  Widget _buildAppBarContent(String formattedTime, bool isDarkMode, ThemeData theme) {
    return Row(
      children: [
        AppBarBackArrow(
          onClick: () => Navigator.pop(context),
        ),
        Container(
          height: 40,
          width: 40,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle
          ),
          child: Image.network(
            widget.postModel.userDetails?.image ?? '',
            fit: BoxFit.cover,
            width: 36,
            height: 36,
            errorBuilder: (context, error, stackTrace) => Icon(
              IconlyBold.profile,
              size: 20,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.postModel.userDetails?.userName ?? 'Unknown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 12,
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
          items: widget.postModel.postImages.map((image) {
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
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
        if (widget.postModel.postImages.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.postModel.postImages.asMap().entries.map((entry) {
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

  Widget _buildPostContent(bool isDarkMode, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildPostStats(bool isDarkMode, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatButton(
            icon: widget.postModel.likes.any((like) => like.userID == widget.postModel.userID)
                ? IconlyBold.heart
                : IconlyLight.heart,
            color: widget.postModel.likes.any((like) => like.userID == widget.postModel.userID)
                ? Colors.red
                : isDarkMode
                ? Colors.grey[400]!
                : Colors.grey[600]!,
            count: widget.postModel.likes.length,
            onTap: () {
              // Implement like functionality
            },
          ),
          _buildStatButton(
            icon: IconlyLight.chat,
            color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
            count: widget.postModel.reactions.length,
            onTap: () => _showCommentBottomSheet(context),
          ),
          _buildStatButton(
            icon: IconlyLight.show,
            color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
            count: widget.postModel.views.length,
            onTap: () {},
          ),
          _buildStatButton(
            icon: IconlyLight.send,
            color: isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
            count: 0,
            onTap: () {
              // Implement share functionality
            },
          ),
        ],
      ),
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
      builder: (context) => CommentBottomSheetSection(postModel: widget.postModel),
    );
  }
}