import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/follows/components/delete_my_post_bottom_sheet.dart';
import 'package:sufcart_app/features/community/follows/components/profile_post_tab_card.dart';
import 'package:sufcart_app/features/community/posts/components/profile_post_tab_shimma_loader.dart';
import 'package:sufcart_app/features/community/posts/model/post_model.dart';
import 'package:sufcart_app/features/profile/model/user_provider.dart';

class ProfilePostTabSection extends StatefulWidget {
  final Future<List<PostModel>> futurePosts;
  final Function(PostModel) onDeletePost; // Add callback for deleting post

  const ProfilePostTabSection({
    super.key,
    required this.futurePosts,
    required this.onDeletePost,
  });

  @override
  State<ProfilePostTabSection> createState() => _ProfilePostTabSectionState();
}

class _ProfilePostTabSectionState extends State<ProfilePostTabSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<PostModel> _posts = []; // Store posts locally for state management

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

  void _showDeleteDialog(BuildContext context, PostModel post, int index) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return DeleteMyPostBottomSheet(onClick: (){
          setState(() {
            _posts.removeAt(index);
          });
          widget.onDeletePost(post);
          Navigator.of(context).pop();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userModel;
    return FutureBuilder<List<PostModel>>(
      future: widget.futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ProfilePostTabShimmaLoader(animation: _animation);
        } else if (snapshot.hasError) {
          return const Center(child: Text('No posts available'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts available'));
        }

        _posts = snapshot.data!; // Update local posts list
        return SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < (_posts.length / 3).ceil(); i++)
                Row(
                  children: [
                    for (int j = 0; j < 3; j++)
                      Expanded(
                        child: (i * 3 + j) < _posts.length
                            ? ProfilePostTabCard(
                          postModel: _posts[i * 3 + j],
                          onLongPress: () {
                            print("Long Pressed");
                            // Check if current user is the post owner
                            if (user.userID == _posts[i * 3 + j].userID) {
                              _showDeleteDialog(
                                  context, _posts[i * 3 + j], i * 3 + j);
                            }
                          },
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
