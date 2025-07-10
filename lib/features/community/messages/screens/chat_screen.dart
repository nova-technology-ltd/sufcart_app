// import 'dart:io';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:iconly/iconly.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:animate_do/animate_do.dart';
// import '../../../../utilities/components/cloudinary_eervices.dart';
// import '../../../../utilities/constants/app_colors.dart';
// import '../../../../utilities/themes/theme_provider.dart';
// import '../../../profile/model/user_model.dart';
// import '../../repost/components/emoji_bottom_sheet.dart';
// import '../components/message_bubbles/receiver_message_bubble.dart';
// import '../components/reply_widget.dart';
// import '../components/message_bubbles/sender_message_bubble.dart';
// import '../components/typing_indicator.dart';
// import '../data/model/messages_model.dart';
// import '../data/provider/messages_socket_provider.dart';
// import '../utilities/helpers.dart';
//
// class ChatScreen extends StatefulWidget {
//   final UserModel receiver;
//   final UserModel sender;
//
//   const ChatScreen({super.key, required this.receiver, required this.sender});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _messageController = TextEditingController();
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _textFieldFocusNode = FocusNode();
//   final FocusNode _searchFocusNode = FocusNode();
//   late AnimationController _dragAnimationController;
//   bool isSendingImages = false;
//   bool _isSearching = false;
//   String? _replyToMessageID;
//   String? _replyToContent;
//   List<File> postResultImages = [];
//   final CloudinaryServices _cloudinaryServices = CloudinaryServices();
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     _dragAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     final provider = context.read<MessagesSocketProvider>();
//     provider.joinChat(widget.receiver.userID);
//     final roomID = ChatHelper.getRoomID(
//       widget.sender.userID,
//       widget.receiver.userID,
//     );
//     final messages = provider.fetchChatHistory(roomID);
//     for (var msg in messages) {
//       if (msg.receiverID == widget.sender.userID && !msg.isRead) {
//         provider.markMessageAsRead(msg.messageID);
//       }
//     }
//     _messageController.addListener(_onTextChanged);
//     _searchController.addListener(_onSearchChanged);
//     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//     provider.addListener(_handleProviderChanges);
//   }
//
//   @override
//   void dispose() {
//     _messageController.removeListener(_onTextChanged);
//     _messageController.dispose();
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     _scrollController.dispose();
//     _textFieldFocusNode.dispose();
//     _searchFocusNode.dispose();
//     _dragAnimationController.dispose();
//     context.read<MessagesSocketProvider>().removeListener(
//       _handleProviderChanges,
//     );
//     super.dispose();
//   }
//
//   void _onSearchChanged() {
//     setState(() {
//       _searchQuery = _searchController.text.trim().toLowerCase();
//     });
//   }
//
//   void _onTextChanged() {
//     final text = _messageController.text.trim();
//     final isTyping = text.isNotEmpty;
//     context.read<MessagesSocketProvider>().sendTypingStatus(
//       widget.receiver.userID,
//       isTyping,
//       senderID: widget.sender.userID,
//     );
//   }
//
//   void _handleProviderChanges() {
//     _scrollToBottom();
//   }
//
//   Future<void> _pickImages() async {
//     try {
//       final pickedFiles = await _picker.pickMultiImage();
//       if (pickedFiles.isNotEmpty) {
//         setState(() {
//           postResultImages.addAll(
//             pickedFiles.map((pickedFile) => File(pickedFile.path)),
//           );
//         });
//         _scrollToBottom();
//       }
//     } catch (e) {}
//   }
//
//   Future<void> _snapPicture() async {
//     try {
//       final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//       if (pickedFile != null) {
//         setState(() {
//           postResultImages.add(File(pickedFile.path));
//         });
//         _scrollToBottom();
//       }
//     } catch (e) {}
//   }
//
//   Future<List<String>> _uploadAllImages(List<File> images) async {
//     List<String> downloadUrls = [];
//     try {
//       for (File image in images) {
//         final downloadUrl = await _cloudinaryServices.uploadImage(image);
//         if (downloadUrl != null) {
//           downloadUrls.add(downloadUrl);
//         }
//       }
//     } catch (e) {
//       rethrow;
//     }
//     return downloadUrls;
//   }
//
//   Future<void> _sendImage() async {
//     if (postResultImages.isEmpty) return;
//     try {
//       setState(() {
//         isSendingImages = true;
//       });
//       final List<String> downloadUrls = await _uploadAllImages(
//         postResultImages,
//       );
//       context.read<MessagesSocketProvider>().sendMessage(
//         senderID: widget.sender.userID,
//         images: downloadUrls,
//         replyTo: _replyToContent ?? "",
//         receiverID: widget.receiver.userID,
//         content: '',
//       );
//       setState(() {
//         _replyToMessageID = null;
//         _replyToContent = null;
//         postResultImages.clear();
//         isSendingImages = false;
//       });
//       _scrollToBottom();
//     } catch (e) {
//       setState(() {
//         isSendingImages = false;
//       });
//     }
//   }
//
//   void _sendMessage() {
//     if (_messageController.text.trim().isNotEmpty) {
//       context.read<MessagesSocketProvider>().sendMessage(
//         receiverID: widget.receiver.userID,
//         content: _messageController.text.trim(),
//         senderID: widget.sender.userID,
//         images: [],
//         replyTo: _replyToContent ?? "",
//       );
//       setState(() {
//         _replyToMessageID = null;
//         _replyToContent = null;
//       });
//       _messageController.clear();
//       _scrollToBottom();
//     }
//   }
//
//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   void _onReply(String messageID, String content) {
//     setState(() {
//       _replyToMessageID = messageID;
//       _replyToContent = content;
//     });
//     FocusScope.of(context).requestFocus(_textFieldFocusNode);
//   }
//
//   void _toggleSearch() {
//     setState(() {
//       _isSearching = !_isSearching;
//       if (!_isSearching) {
//         _searchController.clear();
//         _searchQuery = '';
//       } else {
//         FocusScope.of(context).requestFocus(_searchFocusNode);
//       }
//     });
//   }
//
//   void _showEmojiBottomSheet({
//     required BuildContext context,
//     required Function(Category?, Emoji)? onEmojiSelected,
//     required VoidCallback? onBackspacePressed,
//   }) {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (context) {
//         return EmojiBottomSheet(
//           onEmojiSelected: onEmojiSelected,
//           onBackspacePressed: onBackspacePressed,
//         );
//       },
//     );
//   }
//
//   String _searchQuery = '';
//
//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
//     final provider = context.watch<MessagesSocketProvider>();
//     final fullName =
//         "${widget.receiver.firstName} ${widget.receiver.lastName} ${widget.receiver.otherNames}";
//     final roomID = ChatHelper.getRoomID(
//       widget.sender.userID,
//       widget.receiver.userID,
//     );
//     final allMessages = provider.fetchChatHistory(roomID);
//     final messages =
//         allMessages
//             .where(
//               (msg) =>
//                   (msg.senderID == widget.sender.userID &&
//                       msg.receiverID == widget.receiver.userID) ||
//                   (msg.senderID == widget.receiver.userID &&
//                       msg.receiverID == widget.sender.userID),
//             )
//             .toList();
//     final filteredMessages =
//         _searchQuery.isEmpty
//             ? messages
//             : messages
//                 .where(
//                   (msg) => msg.content.toLowerCase().contains(_searchQuery),
//                 )
//                 .toList();
//     final isReceiverTyping =
//         provider.getTypingStatus(roomID, widget.receiver.userID) &&
//         widget.receiver.userID != widget.sender.userID;
//
//     return Scaffold(
//       backgroundColor: isDarkMode ? null : Colors.white,
//       appBar: AppBar(
//         backgroundColor: isDarkMode ? null : Colors.white,
//         surfaceTintColor:
//             isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
//         leadingWidth: 0,
//         automaticallyImplyLeading: false,
//         elevation: 3,
//         shadowColor: Colors.grey.withOpacity(0.1),
//         title:
//             _isSearching
//                 ? TextField(
//                   controller: _searchController,
//                   focusNode: _searchFocusNode,
//                   decoration: InputDecoration(
//                     hintText: 'Search messages...',
//                     border: InputBorder.none,
//                     hintStyle: TextStyle(
//                       color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                     ),
//                   ),
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.white : Colors.black,
//                   ),
//                   onChanged: (value) => _onSearchChanged(),
//                 )
//                 : Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Icon(
//                         IconlyLight.arrow_left,
//                         color: isDarkMode ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     ElasticIn(
//                       duration: const Duration(milliseconds: 800),
//                       child: Container(
//                         height: 35,
//                         width: 35,
//                         clipBehavior: Clip.antiAlias,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Image.network(
//                           widget.receiver.image,
//                           errorBuilder:
//                               (context, err, st) => const Center(
//                                 child: Icon(
//                                   IconlyBold.profile,
//                                   color: Colors.grey,
//                                   size: 17,
//                                 ),
//                               ),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 5),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.receiver.userName.isNotEmpty
//                               ? widget.receiver.userName.substring(
//                                 1,
//                                 widget.receiver.userName.length,
//                               )
//                               : fullName.length > 22
//                               ? "${fullName.substring(0, 22)}..."
//                               : fullName,
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: isDarkMode ? Colors.white : Colors.black,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Consumer<MessagesSocketProvider>(
//                           builder: (context, provider, child) {
//                             final status = provider.getUserStatus(
//                               roomID,
//                               widget.receiver.userID,
//                             );
//                             return Row(
//                               children: [
//                                 Text(
//                                   widget.receiver.userName.isNotEmpty
//                                       ? widget.receiver.userName.substring(
//                                         1,
//                                         widget.receiver.userName.length,
//                                       )
//                                       : status == 'online'
//                                       ? "Online"
//                                       : status == 'disconnected'
//                                       ? "Disconnected"
//                                       : "Offline",
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color:
//                                         status == 'online'
//                                             ? Colors.green
//                                             : Colors.grey,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 5),
//                                 Container(
//                                   height: 10,
//                                   width: 10,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       width: 1.1,
//                                       color:
//                                           status == 'online'
//                                               ? Colors.green
//                                               : Colors.grey,
//                                     ),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Center(
//                                     child: Container(
//                                       height: 10,
//                                       width: 10,
//                                       decoration: BoxDecoration(
//                                         color:
//                                             status == 'online'
//                                                 ? Colors.green
//                                                 : Colors.grey,
//                                         shape: BoxShape.circle,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//         actions: [
//           IconButton(
//             onPressed: _toggleSearch,
//             icon: Icon(
//               _isSearching ? Icons.close : IconlyLight.search,
//               color: isDarkMode ? null : Colors.grey,
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child:
//                 filteredMessages.isEmpty
//                     ? Center(
//                       child: FadeIn(
//                         duration: const Duration(milliseconds: 600),
//                         child: Text(
//                           _searchQuery.isEmpty
//                               ? 'No messages yet'
//                               : 'No messages found',
//                           style: TextStyle(
//                             color:
//                                 isDarkMode
//                                     ? Colors.grey[400]
//                                     : Colors.grey[600],
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     )
//                     : SingleChildScrollView(
//                       controller: _scrollController,
//                       physics: const BouncingScrollPhysics(),
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minWidth: MediaQuery.of(context).size.width,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 8),
//                             for (var i = 0; i < filteredMessages.length; i++)
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   ChatHelper.buildDateHeader(
//                                     filteredMessages,
//                                     i,
//                                     isDarkMode,
//                                   ),
//                                   _buildMessageTile(
//                                     filteredMessages[i],
//                                     filteredMessages[i].senderID ==
//                                         widget.sender.userID,
//                                     isDarkMode,
//                                   ),
//                                 ],
//                               ),
//                             if (isReceiverTyping)
//                               ZoomIn(
//                                 duration: Duration(milliseconds: 800),
//                                 child: Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                       left: 0,
//                                       bottom: 8.0,
//                                     ),
//                                     child: TypingIndicator(
//                                       dotColor: Colors.grey.withOpacity(0.2),
//                                       dotSize: 8.0,
//                                       animationDuration: const Duration(
//                                         milliseconds: 800,
//                                       ),
//                                       amplitude: 3.0,
//                                       userModel: widget.receiver,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             const SizedBox(height: 8),
//                           ],
//                         ),
//                       ),
//                     ),
//           ),
//           if (_replyToContent != null)
//             ReplyWidget(
//               replyToContent: _replyToContent!,
//               replyToSender: "",
//               isDarkMode: isDarkMode,
//               onClose: () {
//                 setState(() {
//                   _replyToMessageID = null;
//                   _replyToContent = null;
//                 });
//               },
//             ),
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             decoration: BoxDecoration(
//               color:
//                   isDarkMode
//                       ? Color(AppColors.primaryColorDarkMode)
//                       : Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color:
//                       isDarkMode
//                           ? Colors.transparent
//                           : Colors.grey.withOpacity(0.1),
//                   blurRadius: 5,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   physics: BouncingScrollPhysics(),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       for (int i = 0; i < postResultImages.length; i++)
//                         Padding(
//                           padding: EdgeInsets.only(
//                             left: i == 0 ? 8.0 : 3,
//                             right: i == postResultImages.length - 1 ? 8 : 3,
//                           ),
//                           child: FadeInLeft(
//                             duration: Duration(milliseconds: 500),
//                             delay: Duration(milliseconds: 100),
//                             child: Container(
//                               height: 80,
//                               width: 80,
//                               clipBehavior: Clip.antiAlias,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   Container(
//                                     height: MediaQuery.of(context).size.height,
//                                     width: MediaQuery.of(context).size.width,
//                                     clipBehavior: Clip.antiAlias,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey[200],
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: Image.file(
//                                       postResultImages[i],
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                   Container(
//                                     height: MediaQuery.of(context).size.height,
//                                     width: MediaQuery.of(context).size.width,
//                                     clipBehavior: Clip.antiAlias,
//                                     decoration: BoxDecoration(
//                                       color: Colors.black.withOpacity(0.3),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.all(5.0),
//                                           child: GestureDetector(
//                                             onTap: () {
//                                               setState(() {
//                                                 postResultImages.removeAt(i);
//                                               });
//                                             },
//                                             child: Container(
//                                               height: 28,
//                                               width: 28,
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white.withOpacity(
//                                                   0.8,
//                                                 ),
//                                                 shape: BoxShape.circle,
//                                               ),
//                                               child: Icon(
//                                                 Icons.close,
//                                                 color: Colors.black,
//                                                 size: 18,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: postResultImages.isNotEmpty ? 5 : 0),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Row(
//                     children: [
//                       GestureDetector(
//                         onTap: _pickImages,
//                         child: Icon(IconlyLight.image, color: Colors.grey),
//                       ),
//                       const SizedBox(width: 5),
//                       GestureDetector(
//                         onTap: _snapPicture,
//                         child: Icon(
//                           IconlyLight.camera,
//                           color: Colors.grey,
//                           size: 25,
//                         ),
//                       ),
//                       const SizedBox(width: 5),
//                       Expanded(
//                         child: Container(
//                           height: 40,
//                           decoration: BoxDecoration(),
//                           child: TextFormField(
//                             controller: _messageController,
//                             focusNode: _textFieldFocusNode,
//                             minLines: 1,
//                             maxLines: 4,
//                             cursorHeight: 15,
//                             cursorColor: Colors.grey,
//                             keyboardType: TextInputType.multiline,
//                             textInputAction: TextInputAction.newline,
//                             readOnly:
//                                 postResultImages.isNotEmpty ? true : false,
//                             decoration: InputDecoration(
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 10,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                                 borderSide: const BorderSide(
//                                   color: Colors.transparent,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                                 borderSide: const BorderSide(
//                                   color: Colors.transparent,
//                                 ),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                                 borderSide: const BorderSide(
//                                   color: Colors.transparent,
//                                 ),
//                               ),
//                               fillColor:
//                                   isDarkMode
//                                       ? Colors.grey[700]!.withOpacity(0.3)
//                                       : Colors.grey[200]!.withOpacity(0.5),
//                               filled: true,
//                               hintText:
//                                   _replyToContent != null
//                                       ? "Replying to: ${_replyToContent!.length > 17 ? '${_replyToContent!.substring(0, 17)}...' : _replyToContent}"
//                                       : postResultImages.isNotEmpty
//                                       ? "Send image${postResultImages.length > 1 ? '\'s' : ''}"
//                                       : "Type a message...",
//                               hintStyle: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 12,
//                               ),
//                               suffixIcon: IconButton(
//                                 onPressed:
//                                     () => _showEmojiBottomSheet(
//                                       context: context,
//                                       onEmojiSelected: (category, emoji) {
//                                         _messageController.text = emoji.emoji;
//                                       },
//                                       onBackspacePressed: () {},
//                                     ),
//                                 icon: Icon(
//                                   Icons.emoji_emotions_outlined,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ),
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: isDarkMode ? Colors.white : Colors.black,
//                             ),
//                             onFieldSubmitted: (_) => _sendMessage(),
//                             onChanged: (value) {
//                               setState(() {
//                                 _onTextChanged();
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       ZoomIn(
//                         duration: const Duration(milliseconds: 400),
//                         child: GestureDetector(
//                           onTap:
//                               postResultImages.isNotEmpty
//                                   ? _sendImage
//                                   : _messageController.text.trim().isNotEmpty
//                                   ? _sendMessage
//                                   : null,
//                           child: Container(
//                             height: 40,
//                             width: 30,
//                             decoration: BoxDecoration(),
//                             child:
//                                 isSendingImages
//                                     ? Center(
//                                       child: CupertinoActivityIndicator(
//                                         color: Colors.white,
//                                       ),
//                                     )
//                                     : Center(
//                                       child: Transform.rotate(
//                                         angle: 0.8,
//                                         child: Icon(
//                                           IconlyBold.send,
//                                           color: Colors.grey,
//                                           size: 25,
//                                         ),
//                                       ),
//                                     ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageTile(
//     MessagesModel message,
//     bool isCurrentUser,
//     bool isDarkMode,
//   ) {
//     final userIds = [widget.sender.userID, widget.receiver.userID];
//     userIds.sort();
//     final roomID = 'chat:${userIds.join(':')}';
//     final messages = context.read<MessagesSocketProvider>().fetchChatHistory(
//       roomID,
//     );
//     final currentIndex = messages.indexOf(message);
//     final isFirstInGroup =
//         currentIndex == 0 ||
//         messages[currentIndex - 1].senderID != message.senderID;
//     final isLastInGroup =
//         currentIndex == messages.length - 1 ||
//         messages[currentIndex + 1].senderID != message.senderID;
//
//     if (isCurrentUser) {
//       return Align(
//         alignment: Alignment.centerRight,
//         child: SenderMessageBubble(
//           isDarkMode: isDarkMode,
//           onReply: _onReply,
//           onReactionSelected: (reaction) {
//             context.read<MessagesSocketProvider>().addMessageReaction(
//               message.messageID,
//               reaction,
//             );
//           },
//           onReactionRemoved: (messageId, reactionId) {
//             context.read<MessagesSocketProvider>().removeMessageReaction(
//               messageId,
//               reactionId,
//             );
//           },
//           isLastInGroup: isLastInGroup,
//           isFirstInGroup: isFirstInGroup,
//           messagesModel: message,
//         ),
//       );
//     } else {
//       return Align(
//         alignment: Alignment.centerLeft,
//         child: ReceiverMessageBubble(
//           isDarkMode: isDarkMode,
//           userData: widget.receiver,
//           messageID: message.messageID,
//           onReply: _onReply,
//           replyTo: {},
//           onReactionSelected: (reaction) {
//             context.read<MessagesSocketProvider>().addMessageReaction(
//               message.messageID,
//               reaction,
//             );
//           },
//           onReactionRemoved: (messageId, reactionId) {
//             context.read<MessagesSocketProvider>().removeMessageReaction(
//               messageId,
//               reactionId,
//             );
//           },
//           isLastInGroup: isLastInGroup,
//           isFirstInGroup: isFirstInGroup,
//           messagesModel: message,
//         ),
//       );
//     }
//   }
// }














import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/components/cloudinary_eervices.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../profile/model/user_model.dart';
import '../components/chat_app_bar.dart';
import '../components/message_input.dart';
import '../components/message_list.dart';
import '../components/reply_widget.dart';
import '../data/provider/messages_socket_provider.dart';
import '../utilities/helpers.dart';

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
    final roomID = ChatHelper.getRoomID(widget.sender.userID, widget.receiver.userID);
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
          postResultImages.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
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
      final List<String> downloadUrls = await _uploadAllImages(postResultImages);
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
    final roomID = ChatHelper.getRoomID(widget.sender.userID, widget.receiver.userID);
    final allMessages = provider.fetchChatHistory(roomID);
    final messages = allMessages
        .where((msg) =>
    (msg.senderID == widget.sender.userID && msg.receiverID == widget.receiver.userID) ||
        (msg.senderID == widget.receiver.userID && msg.receiverID == widget.sender.userID))
        .toList();
    final filteredMessages = _searchQuery.isEmpty
        ? messages
        : messages.where((msg) => msg.content.toLowerCase().contains(_searchQuery)).toList();
    final isReceiverTyping = provider.getTypingStatus(roomID, widget.receiver.userID) &&
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
            onSendMessage: _messageController.text.trim().isNotEmpty ? _sendMessage : (){},
            onSendImage: _sendImage,
            onTextChanged: _onTextChanged,
          ),
        ],
      ),
    );
  }
}
