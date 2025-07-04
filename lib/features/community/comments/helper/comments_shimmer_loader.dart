import 'package:flutter/material.dart';

class CommentShimmerLoader extends StatefulWidget {
  const CommentShimmerLoader({super.key});

  @override
  State<CommentShimmerLoader> createState() => _CommentShimmerLoaderState();
}

class _CommentShimmerLoaderState extends State<CommentShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    double borderRadius = 4.0,
    bool isCircle = false,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              colors: [
                Colors.grey.withOpacity(0.2),
                Colors.grey.withOpacity(0.1),
                Colors.grey.withOpacity(0.2),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value - 1, 0),
              end: const Alignment(1, 0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar placeholder
              _buildShimmerContainer(
                width: 35,
                height: 35,
                isCircle: true,
              ),
              const SizedBox(width: 10),
              // Comment content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username and date
                    Row(
                      children: [
                        _buildShimmerContainer(
                          width: 100,
                          height: 13,
                        ),
                        const SizedBox(width: 5),
                        _buildShimmerContainer(
                          width: 4,
                          height: 4,
                          isCircle: true,
                        ),
                        const SizedBox(width: 5),
                        _buildShimmerContainer(
                          width: 50,
                          height: 12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Comment text
                    _buildShimmerContainer(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 13,
                    ),
                    const SizedBox(height: 5),
                    // Comment images (optional, assuming up to 3 images)
                    Row(
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: _buildShimmerContainer(
                            width: 50,
                            height: 50,
                            borderRadius: 10,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 5),
                    // Interaction buttons
                    Row(
                      children: [
                        Row(
                          children: [
                            _buildShimmerContainer(
                              width: 19,
                              height: 19,
                              borderRadius: 4,
                            ),
                            const SizedBox(width: 4),
                            _buildShimmerContainer(
                              width: 20,
                              height: 12,
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            _buildShimmerContainer(
                              width: 20,
                              height: 20,
                              borderRadius: 4,
                            ),
                            const SizedBox(width: 4),
                            _buildShimmerContainer(
                              width: 40,
                              height: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Replies
          Padding(
            padding: const EdgeInsets.only(left: 46, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(2, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerContainer(
                        width: 28,
                        height: 28,
                        isCircle: true,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildShimmerContainer(
                                  width: 80,
                                  height: 12,
                                ),
                                const SizedBox(width: 6),
                                _buildShimmerContainer(
                                  width: 40,
                                  height: 10,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            _buildShimmerContainer(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          // Show more replies placeholder
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _buildShimmerContainer(
              width: 100,
              height: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(3, (index) => _buildCommentShimmer()),
      ),
    );
  }
}