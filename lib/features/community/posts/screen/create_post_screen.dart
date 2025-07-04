import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/cloudinary_eervices.dart';
import '../../../../utilities/components/custom_text_field.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_icons.dart';
import '../../../../utilities/constants/app_strings.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../profile/model/user_provider.dart';
import '../../follows/components/profile_post_tab_card.dart';
import '../service/post_services.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  List<dynamic> postResultImages = []; // Use dynamic to handle File and XFile
  PostServices communityServices = PostServices();
  final TextEditingController _textEditingController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final CloudinaryServices _cloudinaryServices = CloudinaryServices();
  bool isLoading = false;

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          if (kIsWeb) {
            // On web, store XFile directly
            postResultImages.addAll(pickedFiles);
          } else {
            // On mobile, convert XFile to File
            postResultImages.addAll(
              pickedFiles.map((pickedFile) => File(pickedFile.path)),
            );
          }
        });
      }
    } catch (e) {
      showSnackBar(
        context: context,
        message: "Failed to pick images: $e",
        title: "Error",
      );
    }
  }

  Future<List<String>> uploadAllImages(List<dynamic> images) async {
    List<String> downloadUrls = [];
    try {
      for (var image in images) {
        String? downloadUrl;
        if (kIsWeb) {
          // For web, handle XFile
          final bytes = await (image as XFile).readAsBytes();
          downloadUrl = await _cloudinaryServices.uploadImageFromBytes(bytes);
        } else {
          // For mobile, handle File
          downloadUrl = await _cloudinaryServices.uploadImage(image as File);
        }
        if (downloadUrl != null) {
          downloadUrls.add(downloadUrl);
        }
      }
      return downloadUrls;
    } catch (e) {
      print('Error uploading images: $e');
      showSnackBar(
        context: context,
        message: "Failed to upload images: $e",
        title: "Upload Error",
      );
      return downloadUrls;
    }
  }

  Future<void> _createPost(BuildContext context, String postText) async {
    try {
      setState(() {
        isLoading = true;
      });
      final List<String> downloadedUrls = await uploadAllImages(postResultImages);
      await communityServices.createNewPost(context, postText, downloadedUrls);
      setState(() {
        isLoading = false;
        _textEditingController.clear();
        postResultImages.clear();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context: context,
        message: AppStrings.serverErrorMessage,
        title: "Server Error",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final user = Provider.of<UserProvider>(context).userModel;
    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? null : Colors.white,
        surfaceTintColor: isDarkMode ? Colors.black : Colors.white,
        automaticallyImplyLeading: false,
        leadingWidth: 90,
        centerTitle: true,
        leading: AppBarBackArrow(
          onClick: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: isLoading
                ? const CupertinoActivityIndicator()
                : const Icon(Icons.check),
            onPressed: (_textEditingController.text.trim().isNotEmpty ||
                    postResultImages.isNotEmpty)
                ? () => _createPost(context, _textEditingController.text.trim())
                : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            postResultImages.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < (postResultImages.length / 3).ceil(); i++)
                          Row(
                            children: [
                              for (int j = 0; j < 3; j++)
                                Expanded(
                                  child: (i * 3 + j) < postResultImages.length
                                      ? Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Container(
                                            height: 100,
                                            width: 100,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(0),
                                            ),
                                            child: Stack(
                                              children: [
                                                _buildImageWidget(i * 3 + j),
                                                Container(
                                                  height: MediaQuery.of(context).size.height,
                                                  width: MediaQuery.of(context).size.width,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.2),
                                                  ),
                                                  child: Center(
                                                    child: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          postResultImages.removeAt(i * 3 + j);
                                                        });
                                                      },
                                                      icon: const Icon(
                                                        IconlyBold.delete,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                            ],
                          ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      height: 200,
                      color: Colors.grey.withOpacity(0.1),
                      child: const Center(
                        child: Icon(
                          IconlyLight.camera,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  CustomTextField(
                    hintText: "Write a caption...",
                    prefixIcon: null,
                    isObscure: false,
                    controller: _textEditingController,
                    maxLine: 7,
                    hasBG: false,
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(int index) {
    final image = postResultImages[index];
    if (kIsWeb) {
      // For web, use Image.memory with bytes from XFile
      return FutureBuilder<Uint8List>(
        future: (image as XFile).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Image.asset(
                    AppIcons.koradLogo,
                    color: Colors.grey,
                    width: 18,
                    height: 18,
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Image.asset(
                AppIcons.koradLogo,
                color: Colors.grey,
                width: 18,
                height: 18,
              ),
            );
          }
          return const Center(child: CupertinoActivityIndicator());
        },
      );
    } else {
      // For mobile, use Image.file
      return Image.file(
        image as File,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Image.asset(
              AppIcons.koradLogo,
              color: Colors.grey,
              width: 18,
              height: 18,
            ),
          );
        },
      );
    }
  }
}