import 'package:flutter/material.dart';

class PostShimmerLoader extends StatefulWidget {
  const PostShimmerLoader({super.key});

  @override
  State<PostShimmerLoader> createState() => _PostShimmerLoaderState();
}

class _PostShimmerLoaderState extends State<PostShimmerLoader> with SingleTickerProviderStateMixin {
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

  Widget _buildPostShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          _buildShimmerContainer(
                            width: 40,
                            height: 40,
                            isCircle: true,
                          ),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildShimmerContainer(
                                    width: 100,
                                    height: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildShimmerContainer(
                                    width: 4,
                                    height: 4,
                                    isCircle: true,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildShimmerContainer(
                                    width: 50,
                                    height: 11,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _buildShimmerContainer(
                                width: 80,
                                height: 12,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      _buildShimmerContainer(
                        width: 75,
                        height: 30,
                        borderRadius: 8,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildShimmerContainer(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                  ),
                  const SizedBox(height: 5),
                  _buildShimmerContainer(
                    width: MediaQuery.of(context).size.width,
                    height: 350,
                    borderRadius: 10,
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 30,
                    child: Row(
                      children: List.generate(5, (index) {
                        return Expanded(
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.transparent),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildShimmerContainer(
                                  width: 20,
                                  height: 20,
                                  borderRadius: 4,
                                ),
                                const SizedBox(width: 5),
                                _buildShimmerContainer(
                                  width: 30,
                                  height: 13,
                                  borderRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            _buildShimmerContainer(
              width: MediaQuery.of(context).size.width,
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(3, (index) => _buildPostShimmer()),
      ),
    );
  }
}