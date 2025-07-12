import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/custom_text_field.dart';
import '../../../../utilities/components/dot_loader.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../components/delete_complaint_bottom_sheet.dart';
import '../components/receiver_style.dart';
import '../components/sender_style.dart';
import '../services/help_center_services.dart';

class ComplaintViewScreen extends StatefulWidget {
  final Map<String, dynamic> complaints;

  const ComplaintViewScreen({super.key, required this.complaints});

  @override
  State<ComplaintViewScreen> createState() => _ComplaintViewScreenState();
}

class _ComplaintViewScreenState extends State<ComplaintViewScreen> {
  final messageSpaceController = TextEditingController();
  bool isTextFieldEmpty = true;
  bool isSatisfied = false;
  bool isSending = false;
  bool _isLoading = false;
  bool isRefreshing = false;
  late Future<Map<String, dynamic>> _conversation;
  final HelpCenterServices _helpCenterServices = HelpCenterServices();

  Future<void> _enableOrDisableSatisfaction(
      BuildContext context, String complaintID) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _helpCenterServices.toggleCompliantStatus(context, complaintID);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(
          context: context,
          message:
              "Sorry, but we are unable to complete your request at the moment, please try again later. Thank You",
          title: "Something Went Wrong");
    }
  }

  Future<void> _addExtraComplaint(
    BuildContext context,
    String complaintID,
    String message,
  ) async {
    try {
      setState(() {
        isSending = true;
      });
      List<String> imageUrls = [];

      for (var image in productResultImages) {
        if (image != null) {
          // final fileName =
          //     'complaint_images/${DateTime.now().millisecondsSinceEpoch}.png';
          // final storageRef = FirebaseStorage.instance.ref().child(fileName);
          // await storageRef.putFile(image);
          // final imageUrl = await storageRef.getDownloadURL();
          // imageUrls.add(imageUrl);
          // print('Image uploaded: $imageUrl');
        }
      }
      int statusCode = await _helpCenterServices.addMoreContentToCompliant(
          context, complaintID, message, imageUrls);
      if (statusCode == 200 || statusCode == 201) {
        setState(() {
          isSending = false;
          imageUrls.clear();
          productResultImages.clear();
          messageSpaceController.clear();
        });
        await _refreshScreen(context);
      } else {
        setState(() {
          isSending = false;
        });
      }
    } catch (e) {
      setState(() {
        isSending = false;
      });
    }
  }

  // Future<void> _showImagePreviewDialog(
  //     BuildContext context, String productImage) async {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return ShowProductImagePreviewDialog(
  //           productImage: productImage,
  //         );
  //       });
  // }

  @override
  void initState() {
    super.initState();

    final complaintID = widget.complaints['complaintID'];
    if (complaintID == null || complaintID is! String) {
      print('Invalid complaintID: $complaintID');
    } else {
      _conversation = _helpCenterServices.getCompliantByYD(
          context, complaintID);
    }

    isSatisfied = widget.complaints['isSatisfied'] ?? false;
  }

  Future<void> _refreshScreen(BuildContext context) async {
    try {
      setState(() {
        isRefreshing = true;
      });
      setState(() {
        final complaintID = widget.complaints['complaintID'];
        if (complaintID == null || complaintID is! String) {
          print('Invalid complaintID: $complaintID');
        } else {
          _conversation = _helpCenterServices.getCompliantByYD(
              context, complaintID);
        }
      });
      setState(() {
        isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  Future<void> deleteUserCompliant(
      BuildContext context, String complaintID) async {
    try {
      setState(() {
        _isLoading = true;
      });
      int statusCode =
      await _helpCenterServices.deleteUserComplaint(context, complaintID);
      if (statusCode == 200 || statusCode == 201) {
        if (context.mounted) {
          Navigator.pop(context);
        }
        setState(() {
          _isLoading = false;
        });
        // if (context.mounted) {
        //   widget.refreshScreen(context);
        // }
      } else {
        Navigator.pop(context);
        setState(() {
          _isLoading = false;
        });
        // if (context.mounted) {
        //   widget.refreshScreen(context);
        // }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  File? _imageFile;
  List<File> productResultImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        productResultImages
            .addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String compliantID = widget.complaints['complaintID'];
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
            appBar: AppBar(
              backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
              surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
              automaticallyImplyLeading: true,
              leadingWidth: 100,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 45,
                    width: 120,
                    decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? Colors.grey.withOpacity(0.08) :Colors.grey[200],
                        borderRadius: BorderRadius.circular(50)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                color: const Color(AppColors.primaryColor)
                                    .withOpacity(0.2),
                                shape: BoxShape.circle),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Image.asset(
                                  "images/STK-20240102-WA0044.webp"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Customer Care",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "24 hours / 7 days",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  )
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      activeColor: const Color(AppColors.primaryColor),
                      value: isSatisfied,
                      onChanged: (value) {
                        setState(() {
                          isSatisfied = value;
                        });
                        _enableOrDisableSatisfaction(
                            context, widget.complaints['complaintID']);
                      },
                    ),
                  ),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.only(bottom: 55.0),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _conversation,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error'),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(
                      child: Text('No conversation found.'),
                    );
                  } else {
                    final complaintData = snapshot.data!;
                    List content = complaintData['content'];
                    List<Map<String, dynamic>> messages = [];

                    for (var c in content) {
                      messages.add({
                        'message': c['message'],
                        'isUser': true, // Indicating this is from the user
                        'timestamp': DateTime.parse(c['createdAt']),
                        'images': c['images'] ?? [],
                        'contentID': c['contentID']
                      });

                      // Add company's response
                      for (var r in c['response']) {
                        messages.add({
                          'message': r['message'],
                          'isUser': false, // Indicating this is from the company
                          'timestamp': DateTime.parse(r['createdAt']),
                          'images': r['images'] ?? [],
                          'contentID': c['contentID']
                        });
                      }
                    }

                    // Sort messages by timestamp
                    messages
                        .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Text(complaintData['title']),
                                Text(
                                  DateFormat('MMM d, yyyy hh:mm a').format(
                                      DateTime.parse(complaintData['updatedAt'])),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Chat bubbles displaying messages
                          for (var message in messages)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: Column(
                                crossAxisAlignment: message['isUser']
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (message['isUser']) ...[
                                    SenderStyle(
                                        message: message['message'],
                                        timeSent: message['timestamp'],
                                      onLongPress: () {},),
                                  ] else ...[
                                    ReceiverStyle(
                                        message: message['message'],
                                        timeSent: message['timestamp']),
                                  ],
                                  // Display images if available
                                  if (message['images'].isNotEmpty)
                                    Column(
                                      children: message['images']
                                          .map<Widget>((imageUrl) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: GestureDetector(
                                            // onTap: () => _showImagePreviewDialog(
                                            //     context, imageUrl),
                                            child: Container(
                                              height: 250,
                                              width: 180,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    productResultImages.isEmpty
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Images",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w500),
                              ),
                              const Text(
                                "Final result of the images",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              productResultImages.isEmpty
                                  ? const SizedBox.shrink()
                                  : const Text(
                                      "(long press on the image to remove it)",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: productResultImages.isEmpty ? 0 : 100,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  itemCount: productResultImages.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: GestureDetector(
                                        onLongPress: () {
                                          setState(() {
                                            productResultImages.removeAt(index);
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 80,
                                              width: 80,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: Image.file(
                                                productResultImages[index],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: SizedBox(
                              child: GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle),
                                    child: const Center(
                                        child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ))),
                              ),
                            )),
                        Expanded(
                            flex: 10,
                            child: SizedBox(
                              height: 40,
                              child: CustomTextField(
                                controller: messageSpaceController,
                                onChange: (value) {
                                  setState(() {
                                    isTextFieldEmpty = value.isEmpty;
                                  });
                                },
                                hintText: 'Enter message',
                                prefixIcon: null,
                                isObscure: false,
                              ),
                            )),
                        Expanded(
                            flex: 2,
                            child: SizedBox(
                              child: GestureDetector(
                                onTap: () {
                                  if (messageSpaceController.text
                                      .trim()
                                      .isEmpty) {
                                    showSnackBar(
                                        context: context,
                                        message:
                                            "You have to at least send something (image or message)",
                                        title: "Not Allowed");
                                  } else {
                                    _addExtraComplaint(context, compliantID,
                                        messageSpaceController.text.trim());
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      color: isTextFieldEmpty
                                          ? Colors.grey[200]
                                          : Colors.blue,
                                      shape: BoxShape.circle),
                                  child: Center(
                                      child: isSending
                                          ? const CupertinoActivityIndicator()
                                          : Icon(
                                              isTextFieldEmpty
                                                  ? IconlyBroken.voice_2
                                                  : IconlyBroken.send,
                                              color: isTextFieldEmpty
                                                  ? Colors.grey
                                                  : Colors.white,
                                            )),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isSending || _isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
              child: Center(
                child: ProgressiveDotLoader(
                  dotSize: 10,
                  dotSpacing: 5,
                  inactiveColor: Color(AppColors.primaryColor).withOpacity(0.1),
                ),
              ),
            )
        ],
      ),
    );
  }
}
