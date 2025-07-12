import 'dart:async';
import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/custom_button_one.dart';
import '../../../../utilities/components/custom_loader.dart';
import '../../../../utilities/components/show_snack_bar.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../../utilities/themes/theme_provider.dart';
import '../../../auth/service/auth_service.dart';
import 'email_verification_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerifyEmail extends StatefulWidget {
  final String email;

  const VerifyEmail({super.key, required this.email});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer.cancel();
    super.dispose();
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  bool isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _verifyEmailAndSendOTP(
      BuildContext context, String email) async {
    try {
      setState(() {
        isLoading = true;
      });
      await _authService.sendEmailVerificationOTP(context, email);
      setState(() {
        isLoading = false;
        _remainingSeconds = 120;
        _timer.cancel();
        startTimer();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  int _remainingSeconds = 120; // 2 minutes in seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _sendEmailVerificationOTP(context, widget.email);
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  String getOTP() {
    return _controllers.map((controller) => controller.text).join();
  }

  bool isOtpComplete() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  Future<void> _sendEmailVerificationOTP(
      BuildContext context, String email) async {
    try {
      await _authService.sendEmailVerificationOTP(context, email);
    } catch (e) {
      showSnackBar(
          context: context, message: "$e", title: "Something Went Wrong");
    }
  }

  Future<void> _resendEmailVerificationOTP(
      BuildContext context, String email) async {
    try {
      setState(() {
        isLoading = true;
      });
      await _authService.resendEmailVerificationOTP(context, email);
      setState(() {
        isLoading = false;
        _remainingSeconds = 120;
        _timer.cancel();
        startTimer();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
          context: context, message: "$e", title: "Something Went Wrong");
    }
  }

  Future<void> _verifyEmailOTP(
      BuildContext context, String email, String otp) async {
    try {
      setState(() {
        isLoading = true;
      });
      await _authService.verifyEmailOTP(context, email, otp);
      setState(() {
        isLoading = false;
        _remainingSeconds = 120;
        _timer.cancel();
        startTimer();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
          context: context, message: "$e", title: "Something Went Wrong");
    }
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
              backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
              surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
              automaticallyImplyLeading: false,
              leadingWidth: 90,
              leading: AppBarBackArrow(onClick: () {
                Navigator.pop(context);
              }),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Verify your email",
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w400),
                          ),
                          const Text(
                            "Please enter the OTP sent to",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            widget.email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      if (index == 3) {
                        return const Text(
                          ' - ',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        );
                      }
                      int otpIndex = index > 3 ? index - 1 : index;
                      return SizedBox(
                        width: 48,
                        height: 48,
                        child: TextField(
                          controller: _controllers[otpIndex],
                          focusNode: _focusNodes[otpIndex],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                              counterText: "",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    width: 0.8,
                                    color: Colors.grey.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    width: 0.8,
                                    color: Color(AppColors.primaryColor)),
                              ),
                              filled: true,
                              fillColor: Colors.transparent),
                          onChanged: (value) {
                            _onOTPChanged(value, otpIndex);
                          },
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                RichText(
                  text: TextSpan(children: [
                    const TextSpan(
                        text: "Code expires in: ",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w400)),
                    TextSpan(
                        text: formatTime(_remainingSeconds),
                        style: TextStyle(
                            color: _remainingSeconds <= 10
                                ? Colors.red
                                : Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ]),
                ),
                const SizedBox(
                  height: 10,
                ),
                _remainingSeconds > 0
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: () =>
                            _verifyEmailAndSendOTP(context, widget.email),
                        child: const Text(
                          "Resend",
                          style: TextStyle(
                              color: Color(AppColors.primaryColor),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(AppColors.primaryColor)),
                        )),
                const Spacer(),
                if (isOtpComplete())
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: CustomButtonOne(
                      title: "Verify",
                      onClick: () =>
                          _verifyEmailOTP(context, widget.email, getOTP()), isLoading: isLoading ? true : false,
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.02)),
              child: const Center(child: CustomLoader(colors: Color(AppColors.primaryColor), maxSize: 50)),
            )
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
