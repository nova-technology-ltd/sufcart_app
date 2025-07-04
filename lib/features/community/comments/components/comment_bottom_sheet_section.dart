import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../utilities/components/cloudinary_eervices.dart';
import '../../../../../utilities/components/show_snack_bar.dart';
import '../../../../../utilities/constants/app_strings.dart';
// import '../../../e-commerce/vendor/screens/product_management/components/product_result_image_card.dart';
import '../../posts/model/post_model.dart';
import '../../views/services/post_view_services.dart';
import '../helper/comments_shimmer_loader.dart';
import '../model/comment_model.dart';
import '../service/comment_services.dart';
import 'comment_card_style.dart';

class CommentBottomSheetSection extends StatefulWidget {
  final PostModel postModel;

  const CommentBottomSheetSection({super.key, required this.postModel});

  @override
  State<CommentBottomSheetSection> createState() =>
      _CommentBottomSheetSectionState();
}

class _CommentBottomSheetSectionState extends State<CommentBottomSheetSection> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _commentReplyController = TextEditingController();
  final CommentServices _commentServices = CommentServices();
  final ImagePicker _picker = ImagePicker();
  final CloudinaryServices _cloudinaryServices = CloudinaryServices();
  final PostViewServices _postViewServices = PostViewServices();
  final FocusNode _replyFocusNode = FocusNode();

  late Future<List<CommentModel>> _futureComments;
  List<File> postResultImages = [];
  bool isLoading = false;
  bool isUploadingImages = false;
  String? errorMessage;
  String? replyingToCommentId;
  String? replyingToCommentText;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _postViewServices.viewPost(context, widget.postModel.postID);
  }

  void _loadComments() {
    setState(() {
      errorMessage = null;
      _futureComments = _commentServices
          .postComments(context, widget.postModel.postID)
          .catchError((error) {
            setState(() {
              errorMessage = error.toString();
            });
            return <CommentModel>[];
          });
    });
  }

  Future<void> _addComment() async {
    print('Attempting to add comment or reply');
    final textController =
        replyingToCommentId != null
            ? _commentReplyController
            : _commentController;
    if (textController.text.trim().isEmpty && postResultImages.isEmpty) {
      print('Input validation failed');
      showSnackBar(
        context: context,
        message: 'Please enter a comment or select an image.',
        title: 'Input Required',
      );
      return;
    }

    setState(() {
      isLoading = true;
      isUploadingImages = postResultImages.isNotEmpty;
    });

    try {
      if (replyingToCommentId != null) {
        await _sendNewReply(
          context,
          widget.postModel.postID,
          textController.text.trim(),
          replyingToCommentId!,
          postResultImages,
        );
      } else {
        await _sendNewComment(
          context,
          widget.postModel.postID,
          textController.text.trim(),
        );
      }

      textController.clear();
      postResultImages.clear();
      setState(() {
        replyingToCommentId = null;
        replyingToCommentText = null;
      });
      _loadComments();
    } catch (e) {
      showSnackBar(context: context, message: e.toString(), title: 'Error');
    } finally {
      setState(() {
        isLoading = false;
        isUploadingImages = false;
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          postResultImages.addAll(
            pickedFiles.map((pickedFile) => File(pickedFile.path)),
          );
        });
      }
    } catch (e) {
      showSnackBar(
        context: context,
        message: 'Failed to pick images: ${e.toString()}',
        title: 'Error',
      );
    }
  }

  void _handleReply(String commentText, String commentId) {
    print('Handling reply for comment: $commentId');
    setState(() {
      replyingToCommentId = commentId;
      replyingToCommentText = commentText;
      _commentReplyController.clear();
    });
    FocusScope.of(context).requestFocus(_replyFocusNode);
  }

  Future<List<String>> _uploadAllImages(List<File> images) async {
    List<String> downloadUrls = [];
    try {
      for (File image in images) {
        final downloadUrl = await _cloudinaryServices.uploadImage(image);
        if (downloadUrl != null) {
          downloadUrls.add(downloadUrl);
        }
      }
      return downloadUrls;
    } catch (e) {
      throw Exception('Failed to upload images: ${e.toString()}');
    }
  }

  Future<void> _sendNewComment(
    BuildContext context,
    String postID,
    String commentText,
  ) async {
    try {
      final List<String> imageUrls =
          postResultImages.isNotEmpty
              ? await _uploadAllImages(postResultImages)
              : [];

      await _commentServices.createNewComment(
        context,
        postID,
        commentText,
        imageUrls,
      );
    } catch (e) {
      throw Exception('Failed to send comment: ${e.toString()}');
    }
  }

  Future<void> _sendNewReply(
    BuildContext context,
    String postID,
    String replyText,
    String commentID,
    List<File> replyImages,
  ) async {
    try {
      final List<String> imageUrls =
          replyImages.isNotEmpty ? await _uploadAllImages(replyImages) : [];

      await _commentServices.replyComment(
        context: context,
        commentID: commentID,
        replyText: replyText,
        replyImages: imageUrls,
      );
    } catch (e) {
      throw Exception('Failed to send reply: ${e.toString()}');
    }
  }

  void _handleRefresh() {
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 500,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Comments',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            _totalComments(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildCommentsList()),
                  if (postResultImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // for (int i = 0; i < postResultImages.length; i++)
                          //   ProductResultImageCard(
                          //     productImage: postResultImages[i],
                          //     onDelete: () {
                          //       setState(() {
                          //         postResultImages.removeAt(i);
                          //       });
                          //     },
                          //   ),
                        ],
                      ),
                    ),
                  _buildCommentInput(),
                ],
              ),
              if (isLoading) _buildLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    return FutureBuilder<List<CommentModel>>(
      future: _futureComments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CommentShimmerLoader();
        }

        if (errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $errorMessage'),
                TextButton(
                  onPressed: _loadComments,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No comments yet\nBe the first to comment!',
              textAlign: TextAlign.center,
            ),
          );
        }

        final comments =
            snapshot.data!..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return SingleChildScrollView(
          child: Column(
            children: [
              for (final comment in comments)
                CommentCardStyle(
                  comment: comment,
                  onLike: () {},
                  onReply: _handleReply,
                  onDeleteClick: () async {
                    await _commentServices.deleteComment(
                      context,
                      comment.commentID,
                    );
                    _handleRefresh();
                  },
                  onReportClick: () {},
                  onDeleteReplyClick: (replyID) async {
                    // Updated to accept replyID
                    await _commentServices.deleteCommentReply(context, replyID);
                    _handleRefresh();
                  },
                  onReportReplyClick: () {},
                  replyCommentModel: comment.replies[0],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _totalComments() {
    return FutureBuilder<List<CommentModel>>(
      future: _futureComments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }

        if (errorMessage != null) {
          return SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        }

        final comments = snapshot.data!;
        return Text(
          " (${comments.length})",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  Widget _buildCommentInput() {
    final isReplying = replyingToCommentId != null;
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3), width: 0.5),
        ),
      ),
      child: Column(
        children: [
          if (isReplying)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to: ${replyingToCommentText?.substring(0, replyingToCommentText!.length > 20 ? 20 : replyingToCommentText!.length)}...',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                    onPressed: () {
                      setState(() {
                        replyingToCommentId = null;
                        replyingToCommentText = null;
                        _commentReplyController.clear();
                        postResultImages.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(IconlyLight.image, color: Colors.grey),
                onPressed: isLoading ? null : _pickImages,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller:
                      isReplying ? _commentReplyController : _commentController,
                  focusNode: isReplying ? _replyFocusNode : null,
                  decoration: InputDecoration(
                    hintText:
                        isReplying ? 'Add a reply...' : 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _addComment(),
                  enabled: !isLoading,
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon:
                    isUploadingImages
                        ? const CommentShimmerLoader()
                        : const Icon(IconlyLight.upload, color: Colors.blue),
                onPressed: isLoading ? null : _addComment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.2),
      child: CommentShimmerLoader(),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentReplyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }
}
