import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';
import '../../../../utilities/components/cloudinary_eervices.dart';
import '../../../profile/model/user_model.dart';
import '../components/receiver_message_bubble.dart';
import '../components/sender_message_bubble.dart';
import '../provider/messages_socket_provider.dart';
import '../model/messages_model.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiver;
  final UserModel sender;

  const ChatScreen({super.key, required this.receiver, required this.sender});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _dragAnimationController;
  bool isSendingImages = false;
  bool _isSearching = false;
  String? _replyToMessageID;
  String? _replyToContent;
  File? _selectedImage;
  String _searchQuery = '';
  List<File> postResultImages = [];

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          postResultImages.addAll(
            pickedFiles.map((pickedFile) => File(pickedFile.path)),
          );
        });
        _scrollToBottom(); // Scroll to show the images
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    } catch (e) {
      print('Error uploading images: $e');
      rethrow; // Re-throw to handle in the calling function
    }

    return downloadUrls;
  }

  final CloudinaryServices _cloudinaryServices = CloudinaryServices();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _dragAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    final provider = context.read<MessagesSocketProvider>();
    provider.joinChat(widget.receiver.userID);
    // Mark unread messages as read when opening the chat
    final roomID = _getRoomID(widget.sender.userID, widget.receiver.userID);
    final messages = provider.fetchChatHistory(roomID);
    for (var msg in messages) {
      if (msg.receiverID == widget.sender.userID && !msg.isRead) {
        provider.markMessageAsRead(msg.messageID);
      }
    }
    _messageController.addListener(_onTextChanged);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    provider.addListener(_handleProviderChanges);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    _searchFocusNode.dispose();
    _dragAnimationController.dispose();
    context.read<MessagesSocketProvider>().removeListener(_handleProviderChanges);
    super.dispose();
  }

  String _getRoomID(String senderID, String receiverID) {
    final ids = [senderID, receiverID];
    ids.sort();
    return 'chat:${ids.join(':')}';
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  void _onTextChanged() {
    final text = _messageController.text.trim();
    final isTyping = text.isNotEmpty;
    context.read<MessagesSocketProvider>().sendTypingStatus(
      widget.receiver.userID,
      isTyping,
      senderID: widget.sender.userID,
    );
  }

  void _handleProviderChanges() {
    final provider = context.read<MessagesSocketProvider>();
    if (provider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    if (postResultImages.isEmpty) return;

    try {
      setState(() {
        isSendingImages = true;
      });

      // Upload all selected images
      final List<String> downloadUrls = await _uploadAllImages(postResultImages);

      // Send the message with images
      await context.read<MessagesSocketProvider>().sendMessage(
        widget.receiver.userID,
        _messageController.text.trim(), // Optional caption
        senderID: widget.sender.userID,
        images: downloadUrls,
      );

      // Clear the state after successful send
      setState(() {
        _messageController.clear();
        _replyToMessageID = null;
        _replyToContent = null;
        postResultImages.clear();
        isSendingImages = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        isSendingImages = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty || _selectedImage != null) {
      context.read<MessagesSocketProvider>().sendMessage(
        widget.receiver.userID,
        _messageController.text.trim(),
        senderID: widget.sender.userID,
        images: [],
      );
      setState(() {
        _replyToMessageID = null;
        _replyToContent = null;
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onReply(String messageID, String content) {
    setState(() {
      _replyToMessageID = messageID;
      _replyToContent = content;
    });
    FocusScope.of(context).requestFocus(_textFieldFocusNode);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      } else {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final provider = context.watch<MessagesSocketProvider>();
    final fullName =
        "${widget.receiver.firstName} ${widget.receiver.lastName} ${widget.receiver.otherNames}";

    final roomID = _getRoomID(widget.sender.userID, widget.receiver.userID);

    final allMessages = provider.fetchChatHistory(roomID);
    final messages = allMessages
        .where(
          (msg) =>
      (msg.senderID == widget.sender.userID &&
          msg.receiverID == widget.receiver.userID) ||
          (msg.senderID == widget.receiver.userID &&
              msg.receiverID == widget.sender.userID),
    )
        .toList();

    final filteredMessages = _searchQuery.isEmpty
        ? messages
        : messages
        .where((msg) => msg.content.toLowerCase().contains(_searchQuery))
        .toList();

    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? null : Colors.white,
        surfaceTintColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        elevation: 3,
        shadowColor: Colors.grey.withOpacity(0.1),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search messages...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onChanged: (value) => _onSearchChanged(),
        )
            : Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                IconlyLight.arrow_left,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 10),
            ElasticIn(
              duration: const Duration(milliseconds: 800),
              child: Container(
                height: 35,
                width: 35,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  widget.receiver.image,
                  errorBuilder: (context, err, st) => const Center(
                    child: Icon(
                      IconlyBold.profile,
                      color: Colors.grey,
                      size: 17,
                    ),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiver.userName.isNotEmpty
                      ? widget.receiver.userName.substring(
                    1,
                    widget.receiver.userName.length,
                  )
                      : fullName.length > 22
                      ? "${fullName.substring(0, 22)}..."
                      : fullName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Consumer<MessagesSocketProvider>(
                  builder: (context, provider, child) {
                    final status = provider.getUserStatus(
                      roomID,
                      widget.receiver.userID,
                    );
                    final isTyping = provider.getTypingStatus(
                      roomID,
                      widget.receiver.userID,
                    ) &&
                        widget.receiver.userID != widget.sender.userID;
                    return Row(
                      children: [
                        Text(
                          isTyping
                              ? "Typing..."
                              : status == 'online'
                              ? "Online"
                              : status == 'disconnected'
                              ? "Disconnected"
                              : "Offline",
                          style: TextStyle(
                            fontSize: 11,
                            color: isTyping
                                ? Colors.blue
                                : status == 'online'
                                ? Colors.green
                                : status == 'disconnected'
                                ? Colors.red
                                : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.1,
                              color: isTyping
                                  ? Colors.blue
                                  : status == 'online'
                                  ? Colors.green
                                  : status == 'disconnected'
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: isTyping
                                      ? Colors.blue
                                      : status == 'online'
                                      ? Colors.green
                                      : status == 'disconnected'
                                      ? Colors.red
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearching ? Icons.close : IconlyLight.search,
              color: isDarkMode ? null : Colors.grey,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: filteredMessages.isEmpty
                ? Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  _searchQuery.isEmpty ? 'No messages yet' : 'No messages found',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            )
                : SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    for (var i = 0; i < filteredMessages.length; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildDateHeader(filteredMessages, i, isDarkMode),
                          _buildMessageTile(
                            filteredMessages[i],
                            filteredMessages[i].senderID == widget.sender.userID,
                            isDarkMode,
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          if (_replyToContent != null)
            FadeIn(
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Replying to: ${_replyToContent!.length > 20 ? '${_replyToContent!.substring(0, 20)}...' : _replyToContent}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _replyToMessageID = null;
                          _replyToContent = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.transparent : Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < postResultImages.length; i++)
                        Padding(
                          padding: EdgeInsets.only(left: i == 0 ? 8.0 : 3, right: i == postResultImages.length - 1 ? 8 : 3),
                          child: FadeInLeft(
                            duration: Duration(milliseconds: 500),
                            delay: Duration(milliseconds: 100),
                            child: Container(
                              height: 80,
                              width: 80,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Image.file(postResultImages[i], fit: BoxFit.cover,),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                postResultImages.removeAt(i);
                                              });
                                            },
                                            child: Container(
                                              height: 28,
                                              width: 28,
                                              decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.8),
                                                  shape: BoxShape.circle
                                              ),
                                              child: Icon(Icons.close, color: Colors.black, size: 18,),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                SizedBox(height: postResultImages.isNotEmpty ? 5 : 0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _messageController,
                          focusNode: _textFieldFocusNode,
                          minLines: 1,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          readOnly: postResultImages.isNotEmpty ? true : false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.transparent),
                            ),
                            fillColor: isDarkMode
                                ? Colors.grey[700]!.withOpacity(0.3)
                                : Colors.grey[200]!.withOpacity(0.5),
                            filled: true,
                            hintText: _replyToContent != null
                                ? "Replying to: ${_replyToContent!.length > 20 ? '${_replyToContent!.substring(0, 20)}...' : _replyToContent}"
                                : postResultImages.isNotEmpty ? "Send image${postResultImages.length > 1 ? '\'s' : ''}" : "Type a message...",
                            hintStyle: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          onFieldSubmitted: (_) => _sendMessage(),
                          onChanged: (value) {
                            setState(() {
                              _onTextChanged();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ZoomIn(
                        duration: const Duration(milliseconds: 400),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(AppColors.primaryColor),
                          child: IconButton(
                            icon: Icon(
                              _messageController.text.trim().isNotEmpty ? Icons.send : IconlyLight.image,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _messageController.text.trim().isNotEmpty ? _sendMessage : _pickImages,
                          ),
                        ),
                      ),
                      SizedBox(width: postResultImages.isNotEmpty ? 5 : 0,),
                      postResultImages.isNotEmpty ? ZoomIn(
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(AppColors.primaryColor),
                          child: IconButton(
                            icon: isSendingImages
                                ? CupertinoActivityIndicator(color: Colors.white)
                                : Icon(Icons.send, color: Colors.white),
                            onPressed: isSendingImages ? null : _sendImage,
                          ),
                        ),
                      ) : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(List<MessagesModel> messages, int index, bool isDarkMode) {
    if (index == 0 || !_isSameDay(messages[index].createdAt, messages[index - 1].createdAt)) {
      final date = messages[index].createdAt;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(date.year, date.month, date.day);

      String dateText;
      if (messageDate == today) {
        dateText = 'Today';
      } else if (messageDate == yesterday) {
        dateText = 'Yesterday';
      } else {
        dateText = DateFormat('d MMMM').format(date);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? null : Colors.grey,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildMessageTile(
      MessagesModel message,
      bool isCurrentUser,
      bool isDarkMode,
      ) {
    final userIds = [widget.sender.userID, widget.receiver.userID];
    userIds.sort();
    final roomID = 'chat:${userIds.join(':')}';
    final messages = context.read<MessagesSocketProvider>().fetchChatHistory(roomID);
    final currentIndex = messages.indexOf(message);

    final isFirstInGroup =
        currentIndex == 0 || messages[currentIndex - 1].senderID != message.senderID;

    final isLastInGroup =
        currentIndex == messages.length - 1 || messages[currentIndex + 1].senderID != message.senderID;

    if (isCurrentUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: SenderMessageBubble(
          message: message.content,
          images: message.images,
          reactions: message.reactions,
          isDarkMode: isDarkMode,
          sentTime: message.createdAt,
          messageID: message.messageID,
          onReply: _onReply,
          replyTo: {},
          onReactionSelected: (reaction) {
            context.read<MessagesSocketProvider>().addMessageReaction(
              message.messageID,
              reaction,
            );
          },
          onReactionRemoved: (messageId, reactionId) {
            context.read<MessagesSocketProvider>().removeMessageReaction(
              messageId,
              reactionId,
            );
          },
          isLastInGroup: isLastInGroup,
          isFirstInGroup: isFirstInGroup,
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: ReceiverMessageBubble(
          message: message.content,
          images: message.images,
          reactions: message.reactions,
          isDarkMode: isDarkMode,
          userImage: widget.receiver.image,
          sentTime: message.createdAt,
          messageID: message.messageID,
          onReply: _onReply,
          replyTo: {},
          onReactionSelected: (reaction) {
            context.read<MessagesSocketProvider>().addMessageReaction(
              message.messageID,
              reaction,
            );
          },
          onReactionRemoved: (messageId, reactionId) {
            context.read<MessagesSocketProvider>().removeMessageReaction(
              messageId,
              reactionId,
            );
          },
          isLastInGroup: isLastInGroup,
          isFirstInGroup: isFirstInGroup,
        ),
      );
    }
  }
}