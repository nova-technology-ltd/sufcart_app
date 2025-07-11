import 'package:flutter/material.dart';

class PostViewShimmer extends StatefulWidget {
  const PostViewShimmer({super.key});

  @override
  State<PostViewShimmer> createState() => _PostViewShimmerState();
}

class _PostViewShimmerState extends State<PostViewShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    final highlightColor = isDarkMode ? Colors.grey[600]! : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            leadingWidth: MediaQuery.of(context).size.width,
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            surfaceTintColor: isDarkMode ? Colors.grey[900] : Colors.white,
            leading: _buildShimmerAppBar(baseColor, highlightColor),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildShimmerContainer(
                  width: 24,
                  height: 24,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerImageSection(baseColor, highlightColor),
                _buildShimmerContent(baseColor, highlightColor),
                _buildShimmerStats(baseColor, highlightColor),
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

  Widget _buildShimmerAppBar(Color baseColor, Color highlightColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: _buildShimmerContainer(
            width: 24,
            height: 24,
            baseColor: baseColor,
            highlightColor: highlightColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Container(
          height: 35,
          width: 35,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: _buildShimmerContainer(
            width: 35,
            height: 35,
            baseColor: baseColor,
            highlightColor: highlightColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerContainer(
                width: 100,
                height: 13,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              const SizedBox(height: 2),
              _buildShimmerContainer(
                width: 60,
                height: 10,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerImageSection(Color baseColor, Color highlightColor) {
    return Column(
      children: [
        _buildShimmerContainer(
          width: MediaQuery.of(context).size.width,
          height: 500,
          baseColor: baseColor,
          highlightColor: highlightColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
                  (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                child: _buildShimmerContainer(
                  width: 8,
                  height: 8,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerContent(Color baseColor, Color highlightColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerContainer(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 16,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          const SizedBox(height: 5),
          _buildShimmerContainer(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 16,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerStats(Color baseColor, Color highlightColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                3,
                    (index) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildShimmerContainer(
                    width: 50,
                    height: 24,
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    borderRadius: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
                  (index) => Row(
                children: [
                  _buildShimmerContainer(
                    width: 22,
                    height: 22,
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: 4),
                  _buildShimmerContainer(
                    width: 20,
                    height: 14,
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    required Color baseColor,
    required Color highlightColor,
    BoxShape shape = BoxShape.rectangle,
    double borderRadius = 4,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: shape,
            borderRadius: shape == BoxShape.rectangle
                ? BorderRadius.circular(borderRadius)
                : null,
            gradient: LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [0.0, _animation.value, 1.0],
              begin: Alignment(-1.0 - _animation.value, 0),
              end: Alignment(1.0 + _animation.value, 0),
            ),
          ),
        );
      },
    );
  }
}