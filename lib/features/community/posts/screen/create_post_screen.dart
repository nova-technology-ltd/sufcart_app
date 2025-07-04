// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:iconly/iconly.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import '../../../../utilities/components/app_bar_back_arrow.dart';
// import '../../../../utilities/components/cloudinary_eervices.dart';
// import '../../../../utilities/components/custom_text_field.dart';
// import '../../../../utilities/components/show_snack_bar.dart';
// import '../../../../utilities/constants/app_icons.dart';
// import '../../../../utilities/constants/app_strings.dart';
// import '../../../../utilities/themes/theme_provider.dart';
// import '../../../profile/model/user_provider.dart';
// import '../../follows/components/profile_post_tab_card.dart';
// import '../service/post_services.dart';
//
// class CreatePostScreen extends StatefulWidget {
//   const CreatePostScreen({super.key});
//
//   @override
//   State<CreatePostScreen> createState() => _CreatePostScreenState();
// }
//
// class _CreatePostScreenState extends State<CreatePostScreen> {
//   List<File> postResultImages = [];
//   PostServices communityServices = PostServices();
//   final TextEditingController _textEditingController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   final CloudinaryServices _cloudinaryServices = CloudinaryServices();
//   bool isLoading = false;
//
//   Future<void> _pickImages() async {
//     final pickedFiles = await _picker.pickMultiImage();
//     if (pickedFiles.isNotEmpty) {
//       setState(() {
//         postResultImages.addAll(
//           pickedFiles.map((pickedFile) => File(pickedFile.path)),
//         );
//       });
//     }
//   }
//
//   Future<List<String>> uploadAllImages(List<File> images) async {
//     List<String> downloadUrls = [];
//     try {
//       if (downloadUrls.isEmpty) {
//         for (File image in images) {
//           final downloadUrl = await _cloudinaryServices.uploadImage(image);
//           downloadUrls.add(downloadUrl!);
//         }
//         return downloadUrls;
//       } else {
//         return downloadUrls;
//       }
//     } catch (e) {
//       print('Error uploading images: $e');
//       return downloadUrls;
//     }
//   }
//
//   Future<void> _createPost(BuildContext context, String postText) async {
//     try {
//       setState(() {
//         isLoading = true;
//       });
//       final List<String> _downloadedUrls = await uploadAllImages(
//         postResultImages,
//       );
//       await communityServices.createNewPost(context, postText, _downloadedUrls);
//       setState(() {
//         isLoading = false;
//         _textEditingController.clear();
//         postResultImages.clear();
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       showSnackBar(
//         context: context,
//         message: AppStrings.serverErrorMessage,
//         title: "Server Error",
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
//     final user = Provider.of<UserProvider>(context).userModel;
//     return Scaffold(
//       backgroundColor: isDarkMode ? null : Colors.white,
//       appBar: AppBar(
//         backgroundColor: isDarkMode ? null : Colors.white,
//         surfaceTintColor: isDarkMode ? Colors.black : Colors.white,
//         automaticallyImplyLeading: false,
//         leadingWidth: 90,
//         centerTitle: true,
//         leading: AppBarBackArrow(
//           onClick: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           'New Post',
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//         ),
//         actions: [
//           IconButton(
//             icon: isLoading ? const CupertinoActivityIndicator() : const Icon(Icons.check),
//             onPressed: (_textEditingController.text.trim().isNotEmpty || postResultImages.isNotEmpty)
//                 ? () => _createPost(context, _textEditingController.text.trim())
//                 : null,
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             postResultImages.isNotEmpty
//                 ? SingleChildScrollView(
//               child: Column(
//                 children: [
//                   for (int i = 0; i < (postResultImages.length / 3).ceil(); i++)
//                     Row(
//                       children: [
//                         for (int j = 0; j < 3; j++)
//                           Expanded(
//                             child: (i * 3 + j) < postResultImages.length
//                                 ? Padding(
//                               padding: const EdgeInsets.all(1.0),
//                               child: Container(
//                                 height: 100,
//                                 width: 100,
//                                 clipBehavior: Clip.antiAlias,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[200],
//                                   borderRadius: BorderRadius.circular(0),
//                                 ),
//                                 child: Stack(
//                                   children: [
//                                     Container(
//                                       height: MediaQuery.of(context).size.height,
//                                       width: MediaQuery.of(context).size.width,
//                                       clipBehavior: Clip.antiAlias,
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey[200],
//                                         borderRadius: BorderRadius.circular(0),
//                                       ),
//                                       child: Image.file(
//                                         postResultImages[i * 3 + j],
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (context, error, stackTrace) {
//                                           return Center(
//                                             child: Image.asset(
//                                               AppIcons.koradLogo,
//                                               color: Colors.grey,
//                                               width: 18,
//                                               height: 18,
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                     Container(
//                                       height: MediaQuery.of(context).size.height,
//                                       width: MediaQuery.of(context).size.width,
//                                       clipBehavior: Clip.antiAlias,
//                                       decoration: BoxDecoration(
//                                         color: Colors.black.withOpacity(0.2),
//                                       ),
//                                       child: Center(
//                                         child: IconButton(
//                                           onPressed: () {
//                                             setState(() {
//                                               postResultImages.removeAt(i * 3 + j);
//                                             });
//                                           },
//                                           icon: const Icon(
//                                             IconlyBold.delete,
//                                             color: Colors.white,
//                                             size: 18,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                                 : const SizedBox.shrink(),
//                           ),
//                       ],
//                     ),
//                 ],
//               ),
//             )
//                 : GestureDetector(
//               onTap: _pickImages,
//               child: Container(
//                 height: 200,
//                 color: Colors.grey.withOpacity(0.1),
//                 child: const Center(
//                   child: Icon(
//                     IconlyLight.camera,
//                     size: 40,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               child: Column(
//                 children: [
//                   CustomTextField(
//                     hintText: "Write a caption...",
//                     prefixIcon: null,
//                     isObscure: false,
//                     controller: _textEditingController,
//                     maxLine: 7,
//                     hasBG: false,
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               height: 1,
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html; // Added for web support
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
  List<dynamic> postResultImages = []; // Changed to dynamic to handle File and html.File
  PostServices communityServices = PostServices();
  final TextEditingController _textEditingController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final CloudinaryServices _cloudinaryServices = CloudinaryServices();
  bool isLoading = false;

  Future<void> _pickImages() async {
    if (kIsWeb) {
      // Web-specific image picking
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.multiple = true;
      input.click();
      input.onChange.listen((event) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          setState(() {
            postResultImages.addAll(files);
          });
        }
      });
    } else {
      // Mobile image picking
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          postResultImages.addAll(
            pickedFiles.map((pickedFile) => File(pickedFile.path)),
          );
        });
      }
    }
  }

  Future<List<String>> uploadAllImages(List<dynamic> images) async {
    List<String> downloadUrls = [];
    try {
      for (var image in images) {
        String? downloadUrl;
        if (kIsWeb && image is html.File) {
          // Handle web image upload
          final reader = html.FileReader();
          reader.readAsArrayBuffer(image);
          await reader.onLoad.first;
          final bytes = reader.result as List<int>;
          downloadUrl = await _cloudinaryServices.uploadImageBytes(bytes, image.name);
        } else if (image is File) {
          // Handle mobile image upload
          downloadUrl = await _cloudinaryServices.uploadImage(image);
        }
        if (downloadUrl != null) {
          downloadUrls.add(downloadUrl);
        }
      }
      return downloadUrls;
    } catch (e) {
      print('Error uploading images: $e');
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
          onClick: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'New Post',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: isLoading ? const CupertinoActivityIndicator() : const Icon(Icons.check),
            onPressed: (_textEditingController.text.trim().isNotEmpty || postResultImages.isNotEmpty)
                ? () => _createPost(context, _textEditingController.text.trim())
                : null,
          )
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
                                    Container(
                                      height: MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                      child: kIsWeb
                                          ? FutureBuilder(
                                        future: _readImage(postResultImages[i * 3 + j]),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Image.memory(
                                              snapshot.data as Uint8List,
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
                                          return Center(child: CircularProgressIndicator());
                                        },
                                      )
                                          : Image.file(
                                        postResultImages[i * 3 + j] as File,
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
                                      ),
                                    ),
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
            )
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _readImage(dynamic image) async {
    if (image is html.File) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(image);
      await reader.onLoad.first;
      return reader.result as Uint8List;
    }
    return Uint8List(0);
  }
}