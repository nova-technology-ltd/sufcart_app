import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/dot_indicator.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../components/build_compliant_list.dart';
import '../components/custom_compliant_tab.dart';
import '../services/help_center_services.dart';
import 'make_complain_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  late Future<List<Map<String, dynamic>>> _allComplaints;
  late Future<List<Map<String, dynamic>>> _satisfiedComplaints;
  late Future<List<Map<String, dynamic>>> _unSatisfiedComplaints;
  final HelpCenterServices _helpCenterServices = HelpCenterServices();
  int initialPage = 0;

  void onPageSwipe(int index) {
    setState(() {
      initialPage = index;
    });
  }

  @override
  void initState() {
    _allComplaints = _helpCenterServices.getAllUserCompliant(context);
    _satisfiedComplaints =
        _helpCenterServices.getAllUserSatisfiedCompliant(context);
    _unSatisfiedComplaints =
        _helpCenterServices.getAllUserUnsatisfiedCompliant(context);
    super.initState();
  }

  Future<void> refreshScreen(BuildContext context) async {
    try {
      setState(() {
        _allComplaints = _helpCenterServices.getAllUserCompliant(context);
        _satisfiedComplaints =
            _helpCenterServices.getAllUserSatisfiedCompliant(context);
        _unSatisfiedComplaints =
            _helpCenterServices.getAllUserUnsatisfiedCompliant(context);
      });
    } catch (e) {}
  }

  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        leadingWidth: 90,
        title: Text(
          initialPage == 0
              ? "All Complaint"
              : initialPage == 1
                  ? "Satisfied Complaint"
                  : initialPage == 2
                      ? "Unsatisfied Complaint"
                      : "Contact Us",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: AppBarBackArrow(
          onClick: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              children: [
                for (int i = 0; i < 3; i++)
                  if (i == initialPage)
                    const DotIndicator(isCurrent: true)
                  else
                    const DotIndicator(isCurrent: false)
              ],
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(78.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Any Problem?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, d MMMM').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MakeComplainScreen(),
                          ),
                        ).then((_) {
                          refreshScreen(context);
                        });
                      },
                      child: Container(
                        height: 35,
                        width: 95,
                        decoration: BoxDecoration(
                          color: const Color(AppColors.primaryColor)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: Color(AppColors.primaryColor),
                              size: 17,
                            ),
                            Text(
                              "Complain",
                              style: TextStyle(
                                color: Color(AppColors.primaryColor),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    HelpCenterSumUp(
                      title: "All",
                      content: _buildComplaintCountWidget(
                        future: _allComplaints,
                        isCurrent: initialPage == 0,
                      ),
                      isCurrentTap: initialPage == 0,
                    ),
                    HelpCenterSumUp(
                      title: "Satisfied",
                      content: _buildComplaintCountWidget(
                        future: _satisfiedComplaints,
                        isCurrent: initialPage == 1,
                      ),
                      isCurrentTap: initialPage == 1,
                    ),
                    HelpCenterSumUp(
                      title: "Unsatisfied",
                      content: _buildComplaintCountWidget(
                        future: _unSatisfiedComplaints,
                        isCurrent: initialPage == 2,
                      ),
                      isCurrentTap: initialPage == 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshScreen(context),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            onPageSwipe(index);
            refreshScreen(context);
          },
          children: [
            BuildCompliantList(future:  _allComplaints,
                emptyMessage: "No complaints available.", refreshScreen: refreshScreen),
            BuildCompliantList(future:  _satisfiedComplaints,
                emptyMessage: "No satisfied complaints available.", refreshScreen: refreshScreen),
            BuildCompliantList(future:  _unSatisfiedComplaints,
                emptyMessage: "No unsatisfied complaints available.", refreshScreen: refreshScreen),
          ],
        ),
      ),
    );
  }
}

Widget _buildComplaintCountWidget({
  required Future<List<Map<String, dynamic>>> future,
  required bool isCurrent,
}) {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: future,
    builder: (context, snapshot) {
      String count = snapshot.connectionState == ConnectionState.waiting
          ? "0"
          : (snapshot.data?.length.toString() ?? "0");
      return Text(
        count,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isCurrent ? Colors.white : Colors.black,
        ),
      );
    },
  );
}

class HelpCenterSumUp extends StatelessWidget {
  final String title;
  final content;
  final bool isCurrentTap;

  const HelpCenterSumUp(
      {super.key,
      required this.title,
      this.content,
      required this.isCurrentTap});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
              color: isCurrentTap
                  ? const Color(AppColors.primaryColor)
                  : Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          width: 5,
        ),
        Container(
          decoration: BoxDecoration(
              color: isCurrentTap
                  ? const Color(AppColors.primaryColor).withOpacity(0.8)
                  : themeProvider.isDarkMode ? Colors.grey : Colors.grey[200],
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
            child: Center(
              child: content,
            ),
          ),
        )
      ],
    );
  }
}
