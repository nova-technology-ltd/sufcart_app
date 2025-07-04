import 'dart:io';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/cloudinary_eervices.dart';
import '../../../../utilities/components/custom_loader.dart';
import '../../../../utilities/components/custom_text_field.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../auth/service/auth_service.dart';
import '../../../profile/components/gender_bottom_sheet.dart';
import '../../../profile/model/user_model.dart';
import '../../../profile/model/user_provider.dart';

class ProfileSettings extends StatefulWidget {
  final UserModel userInfo;
  const ProfileSettings({super.key, required this.userInfo});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final otherNameController = TextEditingController();
  AuthService authService = AuthService();
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();
  String gender = "";
  Future<void> _showGenderBottomSheet(BuildContext context) async {
    showCupertinoModalPopup(context: context, builder: (context) {
      return GenderBottomSheet(onMaleClicked: () {
        setState(() {
          gender = "Male";
        });
        Navigator.pop(context);
      }, onFemaleClicked: () {
        setState(() {
          gender = "Female";
        });
        Navigator.pop(context);
      },);
    });
  }
  final phoneNumberController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  Future<void> _startProfileUpdate(BuildContext context) async {
    try {
      Map<String, dynamic> updates = {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'otherNames': otherNameController.text.trim(),
        'phoneNumber': phoneNumberController.text.trim(),
        'dob': dateOfBirthController.text.trim(),
        'gender': gender.trim(),
      };
      setState(() {
        isLoading = true;
      });
      await authService.updateProfile(context, updates);
      await authService.userProfile(context);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }
  Future<void> _removeProfileImage(BuildContext context) async {
    try {
      Map<String, dynamic> updates = {
        'image': ""
      };
      setState(() {
        isLoading = true;
      });
      await authService.removeProfileImage(context, updates);
      await authService.userProfile(context);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.userInfo.firstName;
    lastNameController.text = widget.userInfo.lastName;
    otherNameController.text = widget.userInfo.otherNames;
    phoneNumberController.text = widget.userInfo.phoneNumber;
    dateOfBirthController.text = widget.userInfo.dob;
    gender = widget.userInfo.gender;
  }
  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
  // Show the CupertinoDatePicker
  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
          child: Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25)
            ),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              backgroundColor: Colors.transparent,
              initialDateTime: selectedDate,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  selectedDate = newDate;
                  dateOfBirthController.text = _formatDate(selectedDate);  // Update text field
                });
              },
            ),
          ),
        );
      },
    );
  }


  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();


  final CloudinaryServices _cloudinaryServices = CloudinaryServices();

  Future<String?> _uploadProfileImage(BuildContext context, File imageFile) async {
    try {
      final downloadedImage = await _cloudinaryServices.uploadImage(imageFile);
      return downloadedImage;
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image")),
      );
      return null;
    }
  }

  Future<void> _updateProfileImage(BuildContext context) async {
    if (_selectedImage == null) {
      showSnackBar(
          context: context,
          message: "Please select an image.",
          title: "Image Required");
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      final imageUrl = await _uploadProfileImage(context, _selectedImage!);
      Map<String, dynamic> updates = {
        'image': imageUrl,
      };
      print("Image URL is: $imageUrl");
      await authService.uploadProfileImage(context, updates);
      await authService.userProfile(context);
      print("uploaded");
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
      showSnackBar(
          context: context,
          message: "Failed to upload image.",
          title: "Image Upload Failed");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        _updateProfileImage(context);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userModel;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
            appBar: AppBar(
              backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
              surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
              leadingWidth: 90,
              title: const Text(
                "Profile Settings",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: AppBarBackArrow(onClick: () {
                Navigator.pop(context);
              }),
              actions: [
                IconButton(onPressed: () => _startProfileUpdate(context), icon: const Icon(Icons.check, color: Color(AppColors.primaryColor),))
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 80,
                          width: 80,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle),
                          child: Stack(
                            children: [
                              Container(
                                height: 90,
                                width: 80,
                                clipBehavior: Clip.antiAlias,
                                decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                                child: _selectedImage != null
                                    ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                )
                                    : user.image != ""
                                    ? Image.network(
                                  user.image ?? '',
                                  fit: BoxFit.cover,
                                )
                                    : const Center(
                                  child: Icon(Icons.person),
                                ),
                              ),
                              Center(
                                  child: Icon(
                                    IconlyBold.camera,
                                    color: Colors.white.withOpacity(0.8),
                                  ))
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        style: IconButton.styleFrom(
                          hoverColor: Colors.transparent,
                          foregroundColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          focusColor: Colors.transparent
                        ),
                          onPressed: (){
                          if (_selectedImage != null) {
                            setState(() {
                              _selectedImage == null;
                              _removeProfileImage(context);
                            });
                          } else {
                            setState(() {
                              user.image == "";
                              _removeProfileImage(context);
                            });
                          }
                          }, child: const Text("Remove Image", style: TextStyle(
                        color: Color(AppColors.primaryColor),
                        fontWeight: FontWeight.w400
                      ),)),
                      const SizedBox(height: 20,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("First Name", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),),
                          SizedBox(
                            height: 40,
                            child: CustomTextField(hintText: "First Name", prefixIcon: SizedBox(height: 10, width: 10,child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset("images/profile_outlined.png", color: Colors.grey,),
                            )), isObscure: false, controller: firstNameController,),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Last Name", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),),
                          SizedBox(
                            height: 40,
                            child: CustomTextField(hintText: "Last Name", prefixIcon: SizedBox(height: 10, width: 10,child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset("images/profile_outlined.png", color: Colors.grey,),
                            )), isObscure: false, controller: lastNameController,),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Other Names", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),),
                          SizedBox(
                            height: 40,
                            child: CustomTextField(hintText: "other Names (optional)", prefixIcon: SizedBox(height: 10, width: 10,child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset("images/profile_outlined.png", color: Colors.grey,),
                            )), isObscure: false, controller: otherNameController,),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),),
                          SizedBox(
                            height: 40,
                            child: CustomTextField(hintText: "Phone Number", prefixIcon: SizedBox(height: 10, width: 10,child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset("images/feather_phone.png", color: Colors.grey,),
                            )), isObscure: false, controller: phoneNumberController,),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Gender", style: TextStyle(fontWeight: FontWeight.w500),),
                          GestureDetector(
                            onTap: () => _showGenderBottomSheet(context),
                            child: Container(
                              height: 38,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 28,
                                          width: 28,
                                          decoration: BoxDecoration(
                                              color: const Color(AppColors.primaryColor).withOpacity(0.2),
                                              shape: BoxShape.circle
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.compare_arrows,
                                              size: 17,
                                              color: Color(AppColors.primaryColor),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5,),
                                        Text(
                                          "Your Gender",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: themeProvider.isDarkMode ? null : Colors.black
                                          ),
                                        )
                                      ],
                                    ),
                                    Center(
                                      child: Text(
                                        gender,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Date Of Birth", style: TextStyle(fontWeight: FontWeight.w500),),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(hintText: "mm/dd/yyyy", prefixIcon: SizedBox(height: 10, width: 10,child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Image.asset("images/calendar_outlined.png", color: Colors.grey,),
                                )), isObscure: false, controller: dateOfBirthController,),
                              ),
                              const SizedBox(width: 10,),
                              GestureDetector(
                                onTap: _showDatePicker,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: themeProvider.isDarkMode ? null : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        offset: const Offset(1, 3),
                                        blurRadius: 10,
                                        spreadRadius: 1
                                      )
                                    ]
                                  ),
                                  child: const Center(
                                    child: Icon(IconlyLight.calendar, color: Color(AppColors.primaryColor),),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: const Color(AppColors.primaryColor).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.announcement_outlined, color: Color(AppColors.primaryColor)),
                              SizedBox(width: 5,),
                              Expanded(
                                child: Text(
                                  "Please make sure your date of birth follows this format \"mm/dd/yyy\", the 'MM' is for the Month, the 'DD' is for the Day and the 'YYYY' is for the Year",
                                  style: TextStyle(
                                      color: Color(AppColors.primaryColor),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5)
              ),
              child: const Center(child: CustomLoader(colors: Color(AppColors.primaryColor), maxSize: 50))
            )
        ],
      ),
    );
  }
}
