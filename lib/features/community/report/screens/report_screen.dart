import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/report/services/report_services.dart';
import 'package:sufcart_app/features/profile/model/user_provider.dart';
import 'package:sufcart_app/utilities/components/app_bar_back_arrow.dart';
import 'package:sufcart_app/utilities/components/custom_button_one.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';

class ReportScreen extends StatefulWidget {
  final String postID;

  const ReportScreen({super.key, required this.postID});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedReason;
  String? _selectedCategory;
  final TextEditingController _customReasonController = TextEditingController();
  bool _isOtherSelected = false;
  bool _isSubmitted = false;
  bool _isReasonDetailPage = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ReportServices _reportServices = ReportServices();

  // Categorized report reasons
  final Map<String, List<Map<String, String>>> _reportCategories = {
    'Content Issues': [
      {
        'title': 'Inappropriate Content',
        'details': 'Contains nudity, sexual content, or other adult material',
      },
      {
        'title': 'Violent Content',
        'details': 'Shows graphic violence, gore, or harmful acts',
      },
      {
        'title': 'Harmful Activities',
        'details': 'Depicts dangerous challenges or harmful behavior',
      },
      {
        'title': 'Graphic Content',
        'details': 'Shows shocking or disturbing imagery',
      },
      {
        'title': 'Misinformation',
        'details': 'Spreads false information or fake news',
      },
      {
        'title': 'Scam or Fraud',
        'details': 'Attempts to deceive or trick users',
      },
    ],
    'Behavior Issues': [
      {
        'title': 'Harassment or Bullying',
        'details': 'Targets individuals with harmful behavior',
      },
      {
        'title': 'Hate Speech',
        'details': 'Promotes hatred against protected groups',
      },
      {
        'title': 'Threats',
        'details': 'Includes violent threats or intimidation',
      },
      {'title': 'Impersonation', 'details': 'Pretends to be someone else'},
      {
        'title': 'Privacy Violation',
        'details': 'Shares personal information without consent',
      },
      {'title': 'Cyberbullying', 'details': 'Repeated harmful behavior online'},
    ],
    'Community Issues': [
      {'title': 'Spam', 'details': 'Repeated unwanted content'},
      {'title': 'Misleading', 'details': 'Content that deceives viewers'},
      {
        'title': 'Fake Engagement',
        'details': 'Uses bots or artificial engagement',
      },
      {
        'title': 'Plagiarism',
        'details': 'Copies others\' content without credit',
      },
      {
        'title': 'Unauthorized Sales',
        'details': 'Sells regulated goods illegally',
      },
      {
        'title': 'Counterfeit Goods',
        'details': 'Promotes fake or replica products',
      },
    ],
    'Technical Issues': [
      {
        'title': 'Broken Link',
        'details': 'Content doesn\'t load or is inaccessible',
      },
      {
        'title': 'Copyright Issue',
        'details': 'Uses copyrighted material without permission',
      },
      {
        'title': 'Trademark Violation',
        'details': 'Misuses brand names or logos',
      },
      {
        'title': 'Malware or Phishing',
        'details': 'Contains harmful software or links',
      },
      {
        'title': 'Glitch or Bug',
        'details': 'Technical problem with the content',
      },
      {
        'title': 'Accessibility Issue',
        'details': 'Not usable for people with disabilities',
      },
    ],
    'Other Concerns': [
      {'title': 'Animal Cruelty', 'details': 'Shows harm or abuse to animals'},
      {'title': 'Child Safety', 'details': 'Puts minors at risk'},
      {'title': 'Self-Harm', 'details': 'Promotes or depicts self-injury'},
      {'title': 'Terrorism', 'details': 'Supports terrorist organizations'},
      {'title': 'Hate Organization', 'details': 'Promotes extremist groups'},
      {'title': 'Others', 'details': 'Another issue not listed here'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitReport(String reason) async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for your report')),
      );
      return;
    }
    if (_selectedReason == 'Others' && _customReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide details for your report')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _reportServices.newReport(context, widget.postID, reason.trim());
      setState(() {
        _isSubmitted = true;
        _isLoading = false;
      });
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit report: $e')));
    }
  }

  void _showReasonDetails(String reason, String category) {
    setState(() {
      _selectedReason = reason;
      _selectedCategory = category;
      _isOtherSelected = reason == 'Others';
      _isReasonDetailPage = true;
    });
  }

  void _backToCategories() {
    setState(() {
      _isReasonDetailPage = false;
    });
  }

  String _getReasonDetails() {
    if (_selectedReason == 'Others')
      return 'Please describe your concern below';
    for (var category in _reportCategories.entries) {
      for (var reason in category.value) {
        if (reason['title'] == _selectedReason) {
          return reason['details']!;
        }
      }
    }
    return 'No additional details available';
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userModel;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? null : Colors.white,
      appBar: AppBar(
        title:
            _isReasonDetailPage
                ? Text(
                  _selectedReason ?? 'Report Details',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                )
                : const Text(
                  'Report Content',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
        leading: AppBarBackArrow(
          onClick:
              _isReasonDetailPage
                  ? _backToCategories
                  : () => Navigator.pop(context),
        ),
        backgroundColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        surfaceTintColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 90,
      ),
      body:
          _isSubmitted
              ? _buildSuccessScreen()
              : _isReasonDetailPage
              ? _buildReasonDetailScreen()
              : _buildCategorySelectionScreen(),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                const Text(
                  'Report Submitted Successfully!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Thank you for helping keep our community safe',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CustomButtonOne(
              title: "Go Back",
              onClick: () => Navigator.pop(context),
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonDetailScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedReason!,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Category: $_selectedCategory',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getReasonDetails(),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (_isOtherSelected) ...[
            const SizedBox(height: 30),
            const Text(
              'Please provide more details:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _customReasonController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Describe your concern in detail...',
              ),
            ),
          ],
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CustomButtonOne(
              title: "Submit Report",onClick: () => _submitReport(_customReasonController.text.isNotEmpty
                ? _customReasonController.text
                : _selectedReason!),
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelectionScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._reportCategories.entries.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    category.key,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ...category.value.map((reason) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 0,
                    color: Colors.grey.withOpacity(0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        reason['title']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_right_alt_rounded,
                        color: Colors.grey,
                      ),
                      onTap:
                          () => _showReasonDetails(
                            reason['title']!,
                            category.key,
                          ),
                    ),
                  );
                }),
                const SizedBox(height: 5),
              ],
            );
          }),
        ],
      ),
    );
  }
}
