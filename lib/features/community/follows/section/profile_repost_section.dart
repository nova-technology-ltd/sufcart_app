import 'package:flutter/material.dart';
import 'package:sufcart_app/features/community/follows/components/profile_repost_tab_card.dart';
import 'package:sufcart_app/features/community/posts/components/profile_post_tab_shimma_loader.dart';

class ProfileRepostSection extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> futureReposts;

  const ProfileRepostSection({super.key, required this.futureReposts});

  @override
  State<ProfileRepostSection> createState() => _ProfileRepostSectionState();
}

class _ProfileRepostSectionState extends State<ProfileRepostSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.futureReposts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ProfilePostTabShimmaLoader(animation: _animation);
        } else if (snapshot.hasError) {
          return Center(child: Text('No posts available'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts available'));
        }

        final posts = snapshot.data!;
        return SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < (posts.length / 3).ceil(); i++)
                Row(
                  children: [
                    for (int j = 0; j < 3; j++)
                      Expanded(
                        child:
                        (i * 3 + j) < posts.length
                            ? ProfileRepostTabCard(
                          repost: posts[i * 3 + j],
                        )
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
