import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/likes/socket/like_socket_provider.dart';
import '../../../../../utilities/components/dot_indicator.dart';
import '../../../../utilities/constants/app_icons.dart';
import '../../../profile/model/user_model.dart';
import '../../views/services/post_view_services.dart';
import '../model/post_model.dart';

class DynamicImageContainer extends StatefulWidget {
  final PostModel post;
  final UserModel user;

  const DynamicImageContainer({super.key, required this.post, required this.user});

  @override
  State<DynamicImageContainer> createState() => _DynamicImageContainerState();
}

class _DynamicImageContainerState extends State<DynamicImageContainer>
    with SingleTickerProviderStateMixin {
  int currentImageIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  bool _showHeart = false;
  Offset _tapPosition = Offset.zero;
  late AnimationController _animationController;
  final PostViewServices _postViewServices = PostViewServices();
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Fast and smooth
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack, // Bouncy scaling
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut), // Delayed fade
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showHeart = false;
        });
        _animationController.reset();
      }
    });

    // Initialize like state from provider
    final likeProvider = context.read<LikeSocketProvider>();
    _isLiked = likeProvider.isPostLikedByUser(widget.post.postID, widget.user.userID);

    // Join the post's socket room when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.likeSocketProvider.joinPost(widget.post.postID);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageSwiper(int index) {
    setState(() {
      currentImageIndex = index;
    });
  }

  Future<void> _onDoubleTap(TapDownDetails details) async {
    try {
      final likeProvider = context.read<LikeSocketProvider>();
      final wasLiked = _isLiked;
      if (!wasLiked) {
        setState(() {
          _showHeart = true;
          _tapPosition = details.localPosition;
          _isLiked = true;
        });
        _animationController.forward();
        await likeProvider.toggleLike(widget.post.postID, widget.user.userID);
        setState(() {
          _isLiked = likeProvider.isPostLikedByUser(widget.post.postID, widget.user.userID);
        });

        await _postViewServices.viewPost(context, widget.post.postID);
      }
    } catch (e) {
      setState(() {
        _isLiked = context.read<LikeSocketProvider>().isPostLikedByUser(widget.post.postID, widget.user.userID);
        _showHeart = false;
      });
      _animationController.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like post: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LikeSocketProvider>(
      builder: (context, likeProvider, child) {
        _isLiked = likeProvider.isPostLikedByUser(widget.post.postID, widget.user.userID);
        return widget.post.postImages.isNotEmpty
            ? GestureDetector(
          onDoubleTapDown: _onDoubleTap,
          child: Container(
            width: MediaQuery.of(context).size.width,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    widget.post.postImages.length > 1
                        ? Stack(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 450,
                            minHeight: 250,
                          ),
                          child: PageView.builder(
                            itemCount: widget.post.postImages.length,
                            controller: _pageController,
                            onPageChanged: _onPageSwiper,
                            itemBuilder: (BuildContext context, int index) {
                              return Image.network(
                                widget.post.postImages[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                    ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: Image.asset(
                                      AppIcons.koradLogo,
                                      color: Colors.grey,
                                      width: 50,
                                      height: 50,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Image.asset(
                                      AppIcons.koradLogo,
                                      color: Colors.grey,
                                      width: 50,
                                      height: 50,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0; i < widget.post.postImages.length; i++) ...[
                                    if (i == currentImageIndex) ...[
                                      DotIndicator(
                                        isCurrent: true,
                                        height: 10,
                                        width: 10,
                                        shape: 10,
                                      ),
                                    ] else ...[
                                      DotIndicator(
                                        isCurrent: false,
                                        height: 10,
                                        width: 10,
                                        shape: 10,
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                        : ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 450,
                        minHeight: 250,
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Image.network(
                          widget.post.postImages[0],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: Image.asset(
                                AppIcons.koradLogo,
                                color: Colors.grey,
                                width: 50,
                                height: 50,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Image.asset(
                                AppIcons.koradLogo,
                                color: Colors.grey,
                                width: 50,
                                height: 50,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (_showHeart)
                      Positioned(
                        left: _tapPosition.dx - 50,
                        top: _tapPosition.dy - 50,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Opacity(
                                opacity: _opacityAnimation.value,
                                child: Image.asset(
                                  AppIcons.likeOnIcon,
                                  color: Colors.red,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        )
            : const SizedBox.shrink();
      },
    );
  }
}