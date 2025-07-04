import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utilities/components/app_bar_back_arrow.dart';
import '../../../utilities/components/custom_button_one.dart';
import '../../../utilities/components/shima_effects/invites_shimma_loader.dart';
import '../../../utilities/components/show_snack_bar.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../../auth/service/auth_service.dart';
import '../components/invited_family_and_friends_card_style_two.dart';
import '../model/user_model.dart';
import '../model/user_provider.dart';
import '../service/profile_service.dart';

class InviteFamilyAndFriendsScreen extends StatefulWidget {
  const InviteFamilyAndFriendsScreen({super.key});

  @override
  State<InviteFamilyAndFriendsScreen> createState() => _InviteFamilyAndFriendsScreenState();
}

class _InviteFamilyAndFriendsScreenState extends State<InviteFamilyAndFriendsScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  late Future<List<UserModel>> futureInvites;

  bool isLoading = false;
  Future<void> _beginInviteCodeGeneration(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      await _profileService.generateInviteCode(context);
      await _authService.userProfile(context);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context: context, message: "Sorry, we encountered an error while trying to process your request, please try again later. Thank You.", title: "Something Went Wrong");
    }
  }
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          height: 40,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Invite code copied to clipboard",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _shareProduct(BuildContext context, UserModel user) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final String text =
        'Hello, i am using Korad, an ecosystem where commerce meets perfection. When registering, use my invite code \"${user.inviteCode}\" to automatically join my clan.';

    final result = await Share.share(
      text,
      subject: "Invite",
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );

    if (result.status == ShareResultStatus.success) {
      print('Shared successfully');
    } else {
      print('Failed to share');
    }
  }

  @override
  void initState() {
    futureInvites = _profileService.getAllUserInvites(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = Provider.of<UserProvider>(context).userModel;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
          appBar: AppBar(
            backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
            surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leadingWidth: 90,
            leading: AppBarBackArrow(onClick: (){Navigator.pop(context);}),
            title:  Text("Invites", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
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
                              margin:
                              const EdgeInsets.symmetric(horizontal: 30),
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
                  const SizedBox(height: 10,),
                  Text(
                    "Your Invite Code",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    "Your Invite Code is a unique code that the person you are inviting uses to identify that you are the one inviting them.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.8) : Colors.grey
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(onPressed: () => _shareProduct(context, user), icon: Icon(Icons.share, size: 20, color: Colors.grey,)),
                      Container(
                        decoration: BoxDecoration(
                            color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.2) : Color(AppColors.primaryColor).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                          child: Text(
                            user.inviteCode != "" ? user.inviteCode : "Generate-Code",
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode ? Colors.white : Color(AppColors.primaryColor)
                            ),
                          ),
                        ),
                      ),
                      IconButton(onPressed: () => _copyToClipboard(user.inviteCode), icon: Icon(Icons.copy, size: 20, color: Colors.grey,)),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Family & Friends",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          Text(
                            "Here is the list of the people you've invited so far.",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 10,),
                      FutureBuilder<List<UserModel>>(
                        future: futureInvites,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: InvitesShimmaLoader());
                          } else if (snapshot.hasError) {
                            return const SizedBox.shrink();
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.hourglass_empty,
                                    color: Colors.grey,
                                  ),
                                  Text("No Invites Yet!"),
                                  Text(
                                    "You have not invited anyone yet.",
                                    style: TextStyle(color: Colors.grey, fontSize: 11),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            List<UserModel> invites = snapshot.data ?? [];
                            List<Widget> invitesWidget = [];
                            for (var invite in invites) {
                              invitesWidget.add(
                                InvitedFamilyAndFriendsCardStyleTwo(invites: invite,),
                              );
                            }
                            return SingleChildScrollView(
                              child: Column(
                                children: invitesWidget,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CustomButtonOne(title: "Generate new invite code", onClick: () => _beginInviteCodeGeneration(context), isLoading: isLoading ? true : false),
          ),
        ),
        if (isLoading)
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2)
            ),
          )
      ],
    );
  }
}
