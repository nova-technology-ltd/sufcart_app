import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../utilities/components/app_bar_back_arrow.dart';
import '../../../utilities/components/custom_button_one.dart';
import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../service/profile_service.dart';

class WriteUsAReviewScreen extends StatefulWidget {
  const WriteUsAReviewScreen({super.key});

  @override
  State<WriteUsAReviewScreen> createState() => _WriteUsAReviewScreenState();
}

class _WriteUsAReviewScreenState extends State<WriteUsAReviewScreen> {
  String? selectedOption;
  String SRID = "";
  int selectedStars = 0;
  final FocusNode _focusNode = FocusNode();
  final opinionController = TextEditingController();
  late Future<Map<String, dynamic>?> _futureSoftwareReviewData;
  bool isSending = false;
  final ProfileService _profileService = ProfileService();
  bool hasExistingReview = false;
  bool isDataLoading = false;
  bool isClearing = false;

  Future<void> _sendReview(
      BuildContext context, String title, String message, String stars) async {
    try {
      setState(() {
        isSending = true;
      });
      await _profileService.writeUsASoftwareReview(
        context,
        title,
        message,
        stars,
      );
      _futureSoftwareReviewData = _profileService.mySoftwareReview(context);
      await _getData();
      setState(() {
        isSending = false;
      });
    } catch (e) {
      setState(() {
        isSending = false;
      });
    }
  }

  Future<void> _updateUserReviewData(
      {required BuildContext context,
      required String title,
      required String message,
      required String stars,
      required String SRID}) async {
    try {
      setState(() {
        isSending = true;
      });
      await _profileService.updateUserSoftwareReview(
          context, title, message, stars, SRID);
      _futureSoftwareReviewData = _profileService.mySoftwareReview(context);
      await _getData();
      setState(() {
        isSending = false;
      });
    } catch (e) {
      setState(() {
        isSending = false;
      });
    }
  }

  void updateStarRating(String? option, int stars) {
    setState(() {
      selectedOption = option;
      selectedStars = stars;
    });
  }

  Future<void> _clearSoftwareReview(BuildContext context, String SRID) async {
    try {
      setState(() {
        isClearing = true;
      });
      await _profileService.clearUserSoftwareReview(context, SRID);
      setState(() {
        SRID = "";
        selectedOption = null;
        selectedStars = 0;
        opinionController.clear();
        hasExistingReview = false;
      });
      _futureSoftwareReviewData = _profileService.mySoftwareReview(context);
      await _getData();
      setState(() {
        isClearing = false;
      });
    } catch (e) {
      setState(() {
        isClearing = false;
      });
    }
  }

  @override
  void initState() {
    _futureSoftwareReviewData = _profileService.mySoftwareReview(context);
    _getData();
    super.initState();
  }

  Future<void> _getData() async {
    try {
      setState(() {
        isDataLoading = true;
      });
      final softwareReviewData = await _futureSoftwareReviewData;

      if (softwareReviewData != null) {
        setState(() {
          opinionController.text = softwareReviewData['message'] ?? '';
          selectedOption = softwareReviewData['title'] ?? '';
          selectedStars = int.tryParse(softwareReviewData['stars'] ?? '0') ?? 0;
          SRID = softwareReviewData['SRID'] ?? '';
          hasExistingReview = SRID.isNotEmpty;
        });
        setState(() {
          isDataLoading = false;
        });
      } else {
        setState(() {
          isDataLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isDataLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              leading: AppBarBackArrow(onClick: () {
                Navigator.pop(context);
              }),
              centerTitle: true,
              title: const Text(
                "Rate Us",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      _clearSoftwareReview(context, SRID);
                      _focusNode.unfocus();
                    },
                    icon: isClearing
                        ? const CupertinoActivityIndicator()
                        : Icon(
                            IconlyBold.delete,
                            size: 20,
                            color: hasExistingReview ? Colors.red : Colors.grey,
                          ))
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "How do you like our \nservices?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 5; i++)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              IconlyBold.star,
                              color: i < selectedStars
                                  ? const Color(AppColors.primaryColor)
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          )
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? Colors.grey.withOpacity(0.05) :  const Color(AppColors.primaryColor)
                              .withOpacity(0.02),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            RatingServicePicOption(
                              title: "Excellent",
                              onClick: () {
                                updateStarRating("Excellent", 5);
                              },
                              isSelected: selectedOption == "Excellent",
                            ),
                            RatingServicePicOption(
                              title: "Good",
                              onClick: () {
                                updateStarRating("Good", 4);
                              },
                              isSelected: selectedOption == "Good",
                            ),
                            RatingServicePicOption(
                              title: "Average",
                              onClick: () {
                                updateStarRating("Average", 3);
                              },
                              isSelected: selectedOption == "Average",
                            ),
                            RatingServicePicOption(
                              title: "Poor",
                              onClick: () {
                                updateStarRating("Poor", 2);
                              },
                              isSelected: selectedOption == "Poor",
                            ),
                            RatingServicePicOption(
                              title: "Terrible",
                              onClick: () {
                                updateStarRating("Terrible", 1);
                              },
                              isSelected: selectedOption == "Terrible",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Text(
                      "What would you like to say",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: opinionController,
                      cursorColor: Colors.grey,
                      maxLines: 5,
                      focusNode: _focusNode,
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
                      height: 50,
                    )
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: CustomButtonOne(
                  title: hasExistingReview ? "Update Review" : "Send Review",
                  // Conditionally update title
                  onClick: hasExistingReview
                      ? () {
                          if (selectedOption != null &&
                              opinionController.text.trim().isNotEmpty) {
                            _updateUserReviewData(
                              context: context,
                              title: "$selectedOption",
                              message: opinionController.text.trim(),
                              stars: "$selectedStars",
                              SRID: SRID,
                            );
                            _focusNode.unfocus();
                          } else {
                            showSnackBar(
                                context: context,
                                message:
                                    "Please provide both a rating and a description.",
                                title: "Missing Entries");
                          }
                        }
                      : () {
                          if (selectedOption != null &&
                              opinionController.text.trim().isNotEmpty) {
                            _sendReview(
                                context,
                                "$selectedOption",
                                opinionController.text.trim(),
                                "$selectedStars");
                            _focusNode.unfocus();
                          } else {
                            showSnackBar(
                                context: context,
                                message:
                                    "Please provide both a rating and a description.",
                                title: "Missing Entries");
                          }
                        },
                  isLoading: isSending ? true : false),
            ),
          ),
          if (isSending)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
              ),
            )
          else if (isDataLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Center(
                child: CupertinoActivityIndicator(),
              ),
            )
        ],
      ),
    );
  }
}

class RatingServicePicOption extends StatelessWidget {
  final String title;
  final VoidCallback onClick;
  final bool isSelected;

  const RatingServicePicOption(
      {super.key,
      required this.title,
      required this.onClick,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w400, color: themeProvider.isDarkMode ? null : Colors.black),
          ),
          GestureDetector(
            onTap: onClick,
            child: Container(
              height: 23,
              width: 23,
              decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(AppColors.primaryColor)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      width: 1.5, color: const Color(AppColors.primaryColor))),
              child: Center(
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 15,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          )
        ],
      ),
    );
  }
}
