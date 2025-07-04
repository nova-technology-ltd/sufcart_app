import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/components/custom_text_field.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../model/user_provider.dart';
import '../services/help_center_services.dart';

class MakeComplainScreen extends StatefulWidget {
  const MakeComplainScreen({super.key});

  @override
  State<MakeComplainScreen> createState() => _MakeComplainScreenState();
}

class _MakeComplainScreenState extends State<MakeComplainScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  List<File> productResultImages = [];
  final HelpCenterServices _helpCenterServices = HelpCenterServices();
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

  Future<void> _sendComplaint(
      BuildContext context, String title, String message, String email) async {
    try {
      setState(() {
        _isLoading = true;
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

      int statusCode = await _helpCenterServices.makeCompliant(
          context: context,
          title: title,
          message: message,
          email: email,
          images: imageUrls);

      if (statusCode == 200 || statusCode == 201) {
        setState(() {
          _isLoading = false;
          _titleController.clear();
          _messageController.clear();
          productResultImages.clear();
          imageUrls.clear();
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      showSnackBar(
          context: context,
          message: "Failed to upload image.",
          title: "Image Upload Failed");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userModel;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
            appBar: AppBar(
              backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
              surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
              centerTitle: true,
              automaticallyImplyLeading: false,
              leadingWidth: 90,
              leading: AppBarBackArrow(onClick: () {
                Navigator.pop(context);
              }),
              title: const Text(
                "Lay Complain",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      if (_titleController.text.trim().isNotEmpty &&
                          _messageController.text.trim().isNotEmpty) {
                        _sendComplaint(context, _titleController.text.trim(),
                            _messageController.text.trim(), user.email);
                      } else {
                        showSnackBar(
                            context: context,
                            message:
                                "Please make sure to provide the title of the complaint you wish to make and also the explanation on what went on",
                            title: "Missing Fields");
                      }
                    },
                    icon: _isLoading
                        ? const CupertinoActivityIndicator()
                        : const Icon(
                            Icons.check,
                            color: Color(AppColors.primaryColor),
                            size: 20,
                          ))
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    CustomTextField(
                      hintText: "Title",
                      prefixIcon: null,
                      isObscure: false,
                      controller: _titleController,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _messageController,
                      cursorColor: Colors.grey,
                      maxLines: 5,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          fillColor: Colors.grey.withOpacity(0.08),
                          filled: true,
                          hintText: "Describe it here",
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                          prefixIcon: null,
                          suffixIcon: null,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 5)),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20)),
                        child: const Center(
                          child: Icon(
                            IconlyBold.camera,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //image result
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Images",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        const Text(
                          "Final result of the images",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        productResultImages.isEmpty
                            ? const SizedBox.shrink()
                            : const Text(
                                "(long press on the image to remove it)",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
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
                                                BorderRadius.circular(15)),
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
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
            )
        ],
      ),
    );
  }
}
