import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilities/components/app_bar_back_arrow.dart';
import '../../../utilities/components/custom_text_field.dart';
import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../../auth/service/auth_service.dart';
import '../model/user_model.dart';
import '../model/user_provider.dart';
import '../service/profile_service.dart';

class CreateKoradTagScreen extends StatefulWidget {
  final UserModel userInfo;

  const CreateKoradTagScreen({super.key, required this.userInfo});

  @override
  State<CreateKoradTagScreen> createState() => _CreateKoradTagScreenState();
}

class _CreateKoradTagScreenState extends State<CreateKoradTagScreen> {
  final tagController = TextEditingController();
  AuthService authService = AuthService();
  bool isLoading = false;
  bool isChecking = false;
  bool isExisting = false;
  bool isNotExisting = false;
  bool badStart = false;

  RegExp numberRegEx = RegExp(r'^\d+(\.\d+)?$');

  final ProfileService _profileService = ProfileService();

  Future<void> startKoradTagUpdate(BuildContext context) async {
    try {
      Map<String, dynamic> updates = {
        'userName': tagController.text.trim(),
      };
      setState(() {
        isLoading = true;
      });
      await authService.koradTag(context, updates);
      await authService.userProfile(context);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkIfTagAlreadyExist(
      BuildContext context, String koradTag) async {
    try {
      setState(() {
        isChecking = true;
      });
      int statusCode =
          await _profileService.checkIfKoradTagAlreadyExists(context, koradTag);
      if (statusCode == 200 || statusCode == 201) {
        setState(() {
          isChecking = false;
          isExisting = true;
          isNotExisting = false;
        });
      } else if (statusCode == -1) {
        showSnackBar(
            context: context,
            message: "We lost hold of the server during this process.",
            title: "Server Error");
      } else {
        setState(() {
          isChecking = false;
          isExisting = false;
          isNotExisting = true;
        });
      }
    } catch (e) {
      setState(() {
        isChecking = false;
        isExisting = false;
        isNotExisting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    tagController.text = widget.userInfo.userName.isEmpty ? "" : widget.userInfo.userName.substring(1);
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

              leadingWidth: 90,
              title: Text(
                user.userName == "" ? "Create TAG" : "Update TAG",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: AppBarBackArrow(onClick: () {
                Navigator.pop(context);
              }),
              actions: [
                IconButton(
                  onPressed: isExisting
                      ? () {}
                      : isChecking ? (){}: badStart
                          ? () {}
                          : tagController.text.trim().length >= 5
                              ? () => startKoradTagUpdate(context)
                              : () {
                                  showSnackBar(
                                      context: context,
                                      message:
                                          "Please make sure not to start with an \"@\" symbol or even numbers, and also make sure your korad tag is at lease 5 characters long",
                                      title: "Invalid Input");
                                },
                  icon: isLoading
                      ? const CupertinoActivityIndicator()
                      : Icon(
                          Icons.check,
                          color: isExisting
                              ? Colors.grey
                              : isChecking ? Colors.grey : badStart
                                  ? Colors.grey
                                  : tagController.text.trim().length < 5
                                      ? Colors.grey
                                      : const Color(AppColors.primaryColor), size: 20,
                        ),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SizedBox(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 45,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 45,
                                      width: 45,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.purple[200],
                                          border: Border.all(
                                              width: 1.5, color: Colors.white)),
                                      child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Image.asset(
                                              "images/STK-20240102-WA0149.webp")),
                                    ),
                                    Container(
                                      height: 45,
                                      width: 45,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 30),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue[200],
                                          border: Border.all(
                                              width: 1.5, color: Colors.white)),
                                      child: SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: Image.asset(
                                              "images/STK-20240102-WA0044.webp")),
                                    ),
                                    Container(
                                      height: 45,
                                      width: 45,
                                      margin: const EdgeInsets.only(left: 60),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.orange[200],
                                          border: Border.all(
                                              width: 1.5, color: Colors.white)),
                                      child: SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: Image.asset(
                                            "images/STK-20240102-WA0157.webp",
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.0)),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    "Korad Tag (Username)",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                  ),
                  const Text(
                    "Your Korad tag is your unique username. Make sure it's distinct, as no two users can have the same tag. Don’t include the '@' symbol—just use the name itself.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(
                    height: 40,
                    child: CustomTextField(
                      hintText: "e.g: username",
                      prefixIcon: const Icon(
                        Icons.alternate_email_rounded,
                        color: Colors.grey,
                      ),
                      isObscure: false,
                      controller: tagController,
                      onChange: (value) {
                        if (tagController.text.trim().isEmpty) {
                          setState(() {
                            badStart = false;
                          });
                        } else if (tagController.text.trim().startsWith("@") ||
                            tagController.text
                                .trim()
                                .startsWith(RegExp(r'\d'))) {
                          setState(() {
                            badStart = true;
                          });
                        } else {
                          setState(() {
                            badStart = false;
                            _checkIfTagAlreadyExist(
                                context,
                                tagController.text
                                    .trim());
                          });
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      badStart
                          ? const Expanded(
                              child: Text(
                                "Please make sure not to start your username with the \"@\" symbol or any numbers.",
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 10),
                              ),
                            )
                          : Text(
                              tagController.text.trim().isEmpty
                                  ? ""
                                  : isChecking
                                      ? "checking"
                                      : isExisting
                                          ? "Tag already in use"
                                          : isNotExisting
                                              ? "Free tag"
                                              : "",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: tagController.text.trim().isEmpty
                                    ? Colors.transparent
                                    : isChecking
                                        ? const Color(AppColors.primaryColor)
                                        : isExisting
                                            ? Colors.red
                                            : isNotExisting
                                                ? Colors.green
                                                : Colors.transparent,
                              ),
                            ),
                      SizedBox(
                        width: isChecking ? 5 : 0,
                      ),
                      SizedBox(
                        height: 10,
                        width: 10,
                        child: isChecking
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(AppColors.primaryColor),
                                strokeCap: StrokeCap.round,
                              )
                            : const SizedBox.shrink(),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.01)),
              // child: const Center(
              //     child: CustomLoader(
              //         colors: Color(AppColors.primaryColor), maxSize: 50))
            )
        ],
      ),
    );
  }
}
