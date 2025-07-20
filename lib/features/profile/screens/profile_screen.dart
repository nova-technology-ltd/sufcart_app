import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/profile/screens/write_us_a_review_screen.dart';

import '../../../utilities/components/app_bar_back_arrow.dart';
import '../../../utilities/components/custom_loader.dart';
import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/constants/app_lottie_anime.dart';
import '../../../utilities/constants/app_strings.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../../auth/service/auth_service.dart';
import '../../settings/screen/settings_screen.dart';
import '../components/personal_information_card_Style.dart';
import '../components/referral_section.dart';
import '../help_center/screens/help_center_screen.dart';
import '../model/user_model.dart';
import '../model/user_provider.dart';
import 'create_korad_tag_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isVerified = false;
  bool isLoading = false;
  late Future<List<UserModel>> _usersFuture;
  late Future<List<Map<String, dynamic>>> _history;
  late Future<List<dynamic>> _futureOrders;
  // ReviewService reviewService = ReviewService();
  late Future<List<Map<String, dynamic>>> _futureReview;
  // OrderService orderService = OrderService();
  final AuthService _authService = AuthService();
  // ShoppingHistoryService shoppingHistoryService = ShoppingHistoryService();
  double _totalPrice = 0.0;

  // VendorService vendorService = VendorService();

  @override
  void initState() {
    _authService.userProfile(context);
    // _futureReview = reviewService.myReviews(context);
    // _history = fetchHistory();
    // _futureOrders = orderService.myOrders(context);
    super.initState();
  }

  Future<void> _refreshScreen(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      await _authService.userProfile(context);
      setState(() {
        // _futureReview = reviewService.myReviews(context);
        // _history = fetchHistory();
        // _futureOrders = orderService.myOrders(context);
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context: context, message: "Sorry but we are unable to refresh this page at the moment, please try again later, Thank You", title: "Something Went Wrong");
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userModel;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return RefreshIndicator(
      onRefresh: () => _refreshScreen(context),
      color: const Color(AppColors.primaryColor),
      backgroundColor: Colors.white,
      child: Scaffold(
        backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
        body: Stack(
          children: [
            Scaffold(
              backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
              appBar: AppBar(
                backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
                surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
                leadingWidth: 90,
                title: const Text(
                  "Profile",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: AppBarBackArrow(onClick: () {
                  Navigator.pop(context);
                }),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                    },
                    tooltip: "Settings",
                    icon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Image.asset("images/settings-outlined.png", color: themeProvider.isDarkMode ? Colors.grey : Colors.black,),
                          user.isEmailVerified ? const SizedBox.shrink() : Positioned(
                            right: 0,
                            child: Container(
                              height: 10,
                              width: 10,
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //profile heights
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${user.firstName} ${user.lastName} ${user.otherNames}",
                                  style: const TextStyle(
                                      fontSize: 17, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  user.email,
                                  style:
                                  const TextStyle(color: Colors.grey, fontSize: 13),
                                )
                              ],
                            ),
                          ),
                          Hero(
                            tag: "${user.firstName}${user.lastName[0]}",
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                height: 55,
                                width: 55,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                    color: const Color(AppColors.primaryColor)
                                        .withOpacity(0.8),
                                    shape: BoxShape.circle),
                                child: user.image == "" ? Center(
                                  child: Text(
                                    "${user.firstName[0]}${user.lastName[0]}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ) : Image.network(user.image, fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to initials if image fails to load
                                    return Center(
                                      child: Text(
                                        "${user.firstName[0]}${user.lastName[0]}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // wallet feature
                      // const BalanceCard(),
                      // const SizedBox(
                      //   height: 30,
                      // ),
                      //personal information section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PERSONAL INFORMATION",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color:
                              const Color(AppColors.primaryColor).withOpacity(0.02),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5),
                              child: Column(
                                children: [
                                  PersonalInformationCardStyle(
                                    title: 'First Name',
                                    information: user.firstName.toUpperCase(),
                                  ),
                                  PersonalInformationCardStyle(
                                    title: 'Last Name',
                                    information: user.lastName.toUpperCase(),
                                  ),
                                  user.otherNames.toString().trim() == "" ? const SizedBox.shrink() : PersonalInformationCardStyle(
                                    title: 'Other Name',
                                    information: user.otherNames.toUpperCase(),
                                  ),
                                  user.userName == ""
                                      ? const SizedBox.shrink()
                                      : Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                    child: Container(
                                      height: 28,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: const BoxDecoration(
                                          color: Colors.transparent),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          RichText(
                                              text: const TextSpan(children: [
                                                TextSpan(
                                                    text: AppStrings.appNameText,
                                                    style: TextStyle(
                                                        color: Color(
                                                            AppColors.primaryColor),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w400)),
                                                TextSpan(
                                                    text: " TAG",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w400)),
                                              ])),
                                          Text(
                                            user.userName,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Color(
                                                    AppColors.primaryColor)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  PersonalInformationCardStyle(
                                    title: 'Email',
                                    information: _maskEmail(user.email),
                                  ),
                                  user.gender == ""
                                      ? const SizedBox.shrink()
                                      : PersonalInformationCardStyle(
                                    title: 'Gender',
                                    information: user.gender,
                                  ),
                                  user.dob == ""
                                      ? const SizedBox.shrink()
                                      : PersonalInformationCardStyle(
                                    title: 'Date Of Birth',
                                    information: user.dob,
                                  ),
                                  PersonalInformationCardStyle(
                                    title: 'Phone Number',
                                    information: _maskPhoneNumber(user.phoneNumber)
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Text(
                        "INVITE YOUR FAMILY AND FRIENDS",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ReferralSection(),
                      const SizedBox(
                        height: 20,
                      ),
                      //korad tag
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: AppStrings.appNameText,
                                    style: TextStyle(
                                        color: Color(AppColors.primaryColor),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400)),
                                TextSpan(
                                    text: " TAG",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400)),
                              ])),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 105,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 8,
                                    child: SizedBox(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                              text: TextSpan(children: [
                                                TextSpan(
                                                    text: "Introducing ",
                                                    style: TextStyle(
                                                        color: themeProvider.isDarkMode ? null : Colors.black,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w400)),
                                                TextSpan(
                                                    text: AppStrings.appNameText,
                                                    style: TextStyle(
                                                        color:
                                                        Color(AppColors.primaryColor),
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w400)),
                                                TextSpan(
                                                    text: " Tags",
                                                    style: TextStyle(
                                                        color: themeProvider.isDarkMode ? null : Colors.black,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w400)),
                                              ])),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          RichText(
                                              text: const TextSpan(children: [
                                                TextSpan(
                                                    text:
                                                    "Create a unique username (identification TAG) to help ease up your experience on ",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w400)),
                                                TextSpan(
                                                    text: AppStrings.appNameText,
                                                    style: TextStyle(
                                                        color:
                                                        Color(AppColors.primaryColor),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w400)),
                                              ])),
                                          const Spacer(),
                                          Container(
                                            height: 30,
                                            width: 120,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                                color: const Color(
                                                    AppColors.primaryColor)
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                BorderRadius.circular(12)),
                                            child: MaterialButton(
                                              onPressed:  () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CreateKoradTagScreen(
                                                              userInfo: user,
                                                            )));
                                              },
                                              child: Center(
                                                child: Text(
                                                  user.userName == ""
                                                      ? "Create TAG"
                                                      : "Update TAG",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w800),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        child: Image.asset(
                                          "images/tag_icon.png",
                                          color: const Color(AppColors.primaryColor)
                                              .withOpacity(0.8),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      // const Text(
                      //   "QUICK ACTIONS",
                      //   style: TextStyle(
                      //       fontSize: 12,
                      //       fontWeight: FontWeight.w400,
                      //       color: Colors.grey),
                      // ),
                      // const SizedBox(
                      //   height: 5,
                      // ),
                      // //history
                      // Container(
                      //   height: 35,
                      //   width: MediaQuery.of(context).size.width,
                      //   clipBehavior: Clip.antiAlias,
                      //   decoration: BoxDecoration(
                      //       color: Colors.grey.withOpacity(0.05),
                      //       borderRadius: BorderRadius.circular(8)),
                      //   child: Stack(
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.symmetric(
                      //             horizontal: 8.0, vertical: 5),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //           children: [
                      //             Row(
                      //               children: [
                      //                 Container(
                      //                   height: 25,
                      //                   width: 25,
                      //                   decoration: BoxDecoration(
                      //                       color: const Color(AppColors.primaryColor)
                      //                           .withOpacity(0.2),
                      //                       shape: BoxShape.circle),
                      //                   child: Center(
                      //                     child: Icon(
                      //                       Icons.history,
                      //                       size: 18,
                      //                       color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.6) : const Color(AppColors.primaryColor),
                      //                     ),
                      //                   ),
                      //                 ),
                      //                 const SizedBox(
                      //                   width: 5,
                      //                 ),
                      //                 Text(
                      //                   "Shopping History",
                      //                   style:
                      //                   TextStyle(fontSize: 12, color: themeProvider.isDarkMode ? null : Colors.black),
                      //                 )
                      //               ],
                      //             ),
                      //             Text(
                      //               "total: ₦${_formatPrice(double.parse(_totalPrice.toString()))}",
                      //               style: const TextStyle(
                      //                   fontSize: 12,
                      //                   fontWeight: FontWeight.w400,
                      //                   color: Colors.grey),
                      //             )
                      //           ],
                      //         ),
                      //       ),
                      //       SizedBox(
                      //         height: MediaQuery.of(context).size.height,
                      //         width: MediaQuery.of(context).size.width,
                      //         child: MaterialButton(
                      //           onPressed: () {
                      //             Navigator.of(context).push(MaterialPageRoute(
                      //                 builder: (context) => const HistoryScreen()));
                      //           },
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 5,
                      // ),
                      // //orders
                      // Container(
                      //   height: 35,
                      //   width: MediaQuery.of(context).size.width,
                      //   clipBehavior: Clip.antiAlias,
                      //   decoration: BoxDecoration(
                      //       color: Colors.grey.withOpacity(0.05),
                      //       borderRadius: BorderRadius.circular(8)),
                      //   child: Stack(
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.symmetric(
                      //             horizontal: 8.0, vertical: 5),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //           children: [
                      //             Row(
                      //               children: [
                      //                 Container(
                      //                   height: 25,
                      //                   width: 25,
                      //                   decoration: BoxDecoration(
                      //                       color: const Color(AppColors.primaryColor)
                      //                           .withOpacity(0.2),
                      //                       shape: BoxShape.circle),
                      //                   child: Center(
                      //                     child: Icon(
                      //                       Icons.edit,
                      //                       size: 18,
                      //                       color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.6) : const Color(AppColors.primaryColor),
                      //                     ),
                      //                   ),
                      //                 ),
                      //                 const SizedBox(
                      //                   width: 5,
                      //                 ),
                      //                 Text(
                      //                   "Orders",
                      //                   style:
                      //                   TextStyle(fontSize: 12, color: themeProvider.isDarkMode ? null : Colors.black),
                      //                 )
                      //               ],
                      //             ),
                      //             Container(
                      //               height: 15,
                      //               width: 15,
                      //               decoration: const BoxDecoration(
                      //                   color: Color(AppColors.primaryColor),
                      //                   shape: BoxShape.circle),
                      //               child: Center(
                      //                 child: FutureBuilder<List<dynamic>>(
                      //                   future: _futureOrders,
                      //                   builder: (context, snapshot) {
                      //                     if (snapshot.connectionState ==
                      //                         ConnectionState.done &&
                      //                         snapshot.hasData) {
                      //                       return Text(
                      //                         "${snapshot.data!.length}",
                      //                         style: const TextStyle(
                      //                             color: Colors.white, fontSize: 8),
                      //                       );
                      //                     }
                      //                     return Container();
                      //                   },
                      //                 ),
                      //               ),
                      //             )
                      //           ],
                      //         ),
                      //       ),
                      //       SizedBox(
                      //         height: MediaQuery.of(context).size.height,
                      //         width: MediaQuery.of(context).size.width,
                      //         child: MaterialButton(
                      //           onPressed: () {
                      //             Navigator.of(context).push(MaterialPageRoute(
                      //                 builder: (context) => const OrderScreen()));
                      //           },
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 5,
                      // ),
                      // //my product review
                      // Container(
                      //   height: 35,
                      //   width: MediaQuery.of(context).size.width,
                      //   clipBehavior: Clip.antiAlias,
                      //   decoration: BoxDecoration(
                      //       color: Colors.grey.withOpacity(0.05),
                      //       borderRadius: BorderRadius.circular(8)),
                      //   child: Stack(
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.symmetric(
                      //             horizontal: 8.0, vertical: 5),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //           children: [
                      //             Row(
                      //               children: [
                      //                 Container(
                      //                   height: 25,
                      //                   width: 25,
                      //                   decoration: BoxDecoration(
                      //                       color: const Color(AppColors.primaryColor)
                      //                           .withOpacity(0.2),
                      //                       shape: BoxShape.circle),
                      //                   child: Center(
                      //                     child: Icon(
                      //                       Icons.shopping_cart,
                      //                       size: 18,
                      //                       color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.6) : const Color(AppColors.primaryColor),
                      //                     ),
                      //                   ),
                      //                 ),
                      //                 const SizedBox(
                      //                   width: 5,
                      //                 ),
                      //                 Text(
                      //                   "My Product Reviews",
                      //                   style:
                      //                   TextStyle(fontSize: 12, color: themeProvider.isDarkMode ? null : Colors.black),
                      //                 )
                      //               ],
                      //             ),
                      //             Row(
                      //               children: [
                      //                 const Text(
                      //                   "You have reviewed ",
                      //                   style:
                      //                   TextStyle(fontSize: 11, color: Colors.grey),
                      //                 ),
                      //                 FutureBuilder<List<Map<String, dynamic>>>(
                      //                   future: _futureReview,
                      //                   builder: (context, snapshot) {
                      //                     if (snapshot.connectionState ==
                      //                         ConnectionState.done &&
                      //                         snapshot.hasData) {
                      //                       return Text(
                      //                         "${snapshot.data!.length}",
                      //                         style: const TextStyle(
                      //                             color: Colors.grey, fontSize: 11),
                      //                       );
                      //                     }
                      //                     return Container();
                      //                   },
                      //                 ),
                      //                 const Text(
                      //                   " item so far",
                      //                   style:
                      //                   TextStyle(fontSize: 11, color: Colors.grey),
                      //                 ),
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       SizedBox(
                      //         height: MediaQuery.of(context).size.height,
                      //         width: MediaQuery.of(context).size.width,
                      //         child: MaterialButton(
                      //           onPressed: () {
                      //             Navigator.of(context).push(MaterialPageRoute(
                      //                 builder: (context) => const MyReviewScreen()));
                      //           },
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 20,
                      // ),
                      const Text(
                        "SEND US A REVIEW",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 44,
                        width: MediaQuery.of(context).size.width,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8)),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                          height: 38,
                                          width: 38,
                                          decoration: BoxDecoration(
                                              color: const Color(AppColors.primaryColor)
                                                  .withOpacity(0.3),
                                              shape: BoxShape.circle),
                                          child: Image.asset(
                                              "images/casual-life-3d-first-place-badge-1.png")),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Write a Review",
                                            style: TextStyle(
                                                fontSize: 14, color: themeProvider.isDarkMode ? null : Colors.black),
                                          ),
                                          Text(
                                            "Write us a review on play store or appstore",
                                            style: TextStyle(
                                                fontSize: 10, color: Colors.grey),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_right_alt,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: MaterialButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WriteUsAReviewScreen()));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "CUSTOMER CARE",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      //customer care
                      Container(
                        height: 35,
                        width: MediaQuery.of(context).size.width,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8)),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 25,
                                        width: 25,
                                        decoration: BoxDecoration(
                                            color: const Color(AppColors.primaryColor)
                                                .withOpacity(0.2),
                                            shape: BoxShape.circle),
                                        child: Center(
                                          child: Icon(
                                            Icons.headphones,
                                            size: 18,
                                            color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.6) : const Color(AppColors.primaryColor),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Contact Us",
                                        style:
                                        TextStyle(fontSize: 12, color: themeProvider.isDarkMode ? null : Colors.black),
                                      )
                                    ],
                                  ),
                                  Container(
                                    height: 6,
                                    width: 6,
                                    decoration: const BoxDecoration(
                                        color: Colors.green, shape: BoxShape.circle),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: MaterialButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const HelpCenterScreen()));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3)
                ),
                child: const Center(child: CustomLoader(colors: Color(AppColors.primaryColor), maxSize: 50)),
              )
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    try {
      return _formatNumber(price);
    } catch (e) {
      return '0';
    }
  }

  String _formatNumber(double number) {
    NumberFormat formatter = NumberFormat("#,###");
    return formatter.format(number);
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return "";
    final parts = email.split('@');

    if (parts.length != 2) return email;

    final localPart = parts[0];
    final domainPart = parts[1];
    final maskedLocalPart = localPart.length > 2
        ? localPart.substring(0, 2) + '*' * (localPart.length - 2)
        : localPart;
    return '$maskedLocalPart@$domainPart';
  }

  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return "";
    if (phoneNumber.length <= 3) return phoneNumber;
    final visiblePart = phoneNumber.substring(0, 3);
    final maskedPart = '*' * (phoneNumber.length - 3);
    return visiblePart + maskedPart;
  }
}
