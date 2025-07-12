import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../components/security_questions_alert_dialog.dart';
import '../../service/settings_services.dart';

class SecurityQuestionsScreen extends StatefulWidget {
  const SecurityQuestionsScreen({super.key});

  @override
  State<SecurityQuestionsScreen> createState() =>
      _SecurityQuestionsScreenState();
}

class _SecurityQuestionsScreenState extends State<SecurityQuestionsScreen> {
  bool isLoading = false;
  final SettingsServices _settingsServices = SettingsServices();
  final List<String> _availableSecurityQuestions = [
    "What is your mother's name?",
    "What is your favorite food?",
    "What is your place of birth?",
    "What is your birth year?",
    "What is your dad's phone number?",
    "What is the name of your first phone?",
    "What is the name of your first laptop?",
    "Do you own a cat?",
  ];

  final List<Map<String, String>> _selectedQuestions = [];
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitSecurityQuestions() async {
    try {
      if (_selectedQuestions.length < 3) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please select and answer at least 3 questions.")),
        );
        return;
      } else {
        setState(() {
          isLoading = true;
        });
        await _settingsServices.updateSecurityQuestions(
            context, _selectedQuestions);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
          context: context,
          message:
              "Sorry, but we are unable to complete your request at the moment, please try again later. Thank You",
          title: "Something Went Wrong");
    }
  }

  void _addQuestion(String question, String answer) {
    setState(() {
      _selectedQuestions.add({'question': question, 'answer': answer});
    });
  }

  void _removeQuestion(String question) {
    setState(() {
      _selectedQuestions.removeWhere((q) => q['question'] == question);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        leadingWidth: 90,
        leading: AppBarBackArrow(
          onClick: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Security Questions",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Security Questions",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
              ),
              const Text(
                "Select at least 3 security questions and provide answers:",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              ..._availableSecurityQuestions.map((question) {
                final isSelected =
                    _selectedQuestions.any((q) => q['question'] == question);
                return ListTile(
                  title: Text(question),
                  trailing: isSelected
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () => _removeQuestion(question),
                        )
                      : IconButton(
                          icon:
                              const Icon(Icons.add_circle, color: Color(AppColors.primaryColor)),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => SecurityQuestionsAlertDialog(question: question, onSubmitted: (answer) {
                                  if (answer.isNotEmpty) {
                                    _addQuestion(
                                        question, answer);
                                    Navigator.pop(context);
                                  } else {

                                  }
                                },));
                          },
                        ),
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: CustomButtonOne(
            title: "Submit",
            onClick: _submitSecurityQuestions,
            isLoading: isLoading ? true : false),
      ),
    );
  }
}
