import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../utilities/components/cloudinary_eervices.dart';
import '../../../../../utilities/themes/theme_provider.dart';
import '../../../../profile/model/user_model.dart';
import '../../data/provider/messages_socket_provider.dart';
import '../../utilities/helpers.dart';
import '../components/chat_app_bar.dart';
import '../components/message_input.dart';
import '../components/message_list.dart';
import '../components/reply_widget.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiver;
  final UserModel sender;

  const ChatScreen({super.key, required this.receiver, required this.sender});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
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
  List<File> postResultImages = [];
  final CloudinaryServices _cloudinaryServices = CloudinaryServices();
  final ImagePicker _picker = ImagePicker();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _dragAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    final provider = context.read<MessagesSocketProvider>();
    provider.joinChat(widget.receiver.userID);
    final roomID = ChatHelper.getRoomID(
      widget.sender.userID,
      widget.receiver.userID,
    );
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
    context.read<MessagesSocketProvider>().removeListener(
      _handleProviderChanges,
    );
    super.dispose();
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
    _scrollToBottom();
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          postResultImages.addAll(
            pickedFiles.map((pickedFile) => File(pickedFile.path)),
          );
        });
        _scrollToBottom();
      }
    } catch (e) {}
  }

  Future<void> _snapPicture() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          postResultImages.add(File(pickedFile.path));
        });
        _scrollToBottom();
      }
    } catch (e) {}
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
      rethrow;
    }
    return downloadUrls;
  }

  Future<void> _sendImage() async {
    if (postResultImages.isEmpty) return;
    try {
      setState(() {
        isSendingImages = true;
      });
      final List<String> downloadUrls = await _uploadAllImages(
        postResultImages,
      );
      context.read<MessagesSocketProvider>().sendMessage(
        senderID: widget.sender.userID,
        images: downloadUrls,
        replyTo: _replyToContent ?? "",
        receiverID: widget.receiver.userID,
        content: '',
      );
      setState(() {
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
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<MessagesSocketProvider>().sendMessage(
        receiverID: widget.receiver.userID,
        content: _messageController.text.trim(),
        senderID: widget.sender.userID,
        images: [],
        replyTo: _replyToContent ?? "",
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
    final roomID = ChatHelper.getRoomID(
      widget.sender.userID,
      widget.receiver.userID,
    );
    final allMessages = provider.fetchChatHistory(roomID);
    final messages =
        allMessages
            .where(
              (msg) =>
                  (msg.senderID == widget.sender.userID &&
                      msg.receiverID == widget.receiver.userID) ||
                  (msg.senderID == widget.receiver.userID &&
                      msg.receiverID == widget.sender.userID),
            )
            .toList();
    final filteredMessages =
        _searchQuery.isEmpty
            ? messages
            : messages
                .where(
                  (msg) => msg.content.toLowerCase().contains(_searchQuery),
                )
                .toList();
    final isReceiverTyping =
        provider.getTypingStatus(roomID, widget.receiver.userID) &&
        widget.receiver.userID != widget.sender.userID;

    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      appBar: ChatAppBar(
        receiver: widget.receiver,
        isDarkMode: isDarkMode,
        isSearching: _isSearching,
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
        onSearchChanged: _onSearchChanged,
        toggleSearch: _toggleSearch,
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              messages: filteredMessages,
              scrollController: _scrollController,
              isDarkMode: isDarkMode,
              currentUserId: widget.sender.userID,
              receiver: widget.receiver,
              onReply: _onReply,
              isReceiverTyping: isReceiverTyping,
            ),
          ),
          if (_replyToContent != null)
            ReplyWidget(
              replyToContent: _replyToContent!,
              replyToSender: "",
              isDarkMode: isDarkMode,
              onClose: () {
                setState(() {
                  _replyToMessageID = null;
                  _replyToContent = null;
                });
              },
            ),
          MessageInput(
            messageController: _messageController,
            textFieldFocusNode: _textFieldFocusNode,
            isDarkMode: isDarkMode,
            postResultImages: postResultImages,
            isSendingImages: isSendingImages,
            replyToContent: _replyToContent,
            onPickImages: _pickImages,
            onSnapPicture: _snapPicture,
            onSendMessage: _sendMessage,
            onSendImage: _sendImage,
            onTextChanged: _onTextChanged,
          ),
        ],
      ),
    );
  }
}
