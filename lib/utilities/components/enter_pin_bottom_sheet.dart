import 'package:flutter/material.dart';
import 'package:sufcart_app/utilities/components/show_snack_bar.dart';

import 'custom_number_button.dart';

class EnterPinBottomSheet extends StatefulWidget {
  final String userPIN;
  final VoidCallback onSuccess;
  const EnterPinBottomSheet({
    super.key, required this.userPIN, required this.onSuccess,
  });

  @override
  State<EnterPinBottomSheet> createState() => _EnterPinBottomSheetState();
}

class _EnterPinBottomSheetState extends State<EnterPinBottomSheet> {
  String accountPIN = "";
  bool isVisible = false;

  void addPinDigit(int number) {
    if (accountPIN.length < 4) {
      setState(() {
        accountPIN += number.toString();
      });

      if (accountPIN.length == 4 && accountPIN == widget.userPIN) {
        widget.onSuccess();
        Navigator.pop(context, accountPIN);
      } else if (accountPIN.length ==4 && accountPIN != widget.userPIN){
        showSnackBar(
            context: context,
            message: "The account PIN you provided is incorrect. Please verify and try again.",
            title: "Invalid Account PIN"
        );
      } else {

      }
    }
  }

  void removeLastPinDigit() {
    if (accountPIN.isNotEmpty) {
      setState(() {
        accountPIN = accountPIN.substring(0, accountPIN.length - 1);
      });
    }
  }

  Widget otpButtons(int number) {
    return CustomNumberButton(
      onClick: () {
        addPinDigit(number);
      },
      numbers: number,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 400,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        child: Padding(
          padding:
          const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 3),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                      )),
                  Text(
                    "Account PIN Required",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black.withOpacity(0.4)),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isVisible = !isVisible;
                      });
                    },
                    child: isVisible
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: Center(
                        child: Image.asset(
                          "images/feather_eye.png",
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : SizedBox(
                      height: 20,
                      width: 20,
                      child: Center(
                        child: Image.asset(
                          "images/feather_eye_off.png",
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: Container(
                          height: 61,
                          width: 55,
                          decoration: BoxDecoration(
                            color: index < accountPIN.length
                                ? Colors.blue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                width: 1,
                                color: index < accountPIN.length
                                    ? Colors.blue
                                    : Colors.grey.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: index < accountPIN.length
                                    ? Colors.blue.withOpacity(0.3)
                                    : Colors.transparent,
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(1, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isVisible
                                ? Text(
                              index < accountPIN.length
                                  ? accountPIN[index]
                                  : "",
                              style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400),
                            )
                                : Container(
                              height: 15,
                              width: 15,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Container(
                height: 34,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield,
                        color: Colors.green,
                      ),
                      Text(
                        " Secure your activities with our account PIN",
                        style: TextStyle(color: Colors.green),
                      )
                    ],
                  ),
                ),
              ),
              const Spacer(),
              for (int i = 0; i < 3; i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                  List.generate(3, (index) => otpButtons(1 + 3 * i + index))
                      .toList(),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: SizedBox(
                      height: 60,
                      width: 100,
                      child: GestureDetector(
                          onTap: () {
                            setState(() {});
                          },
                          child: const Text("")),
                    ),
                  ),
                  otpButtons(0),
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: SizedBox(
                      height: 50,
                      width: 100,
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              accountPIN = accountPIN.substring(
                                  0, accountPIN.length - 1);
                            });
                          },
                          child: Container(
                            decoration:
                            const BoxDecoration(color: Colors.transparent),
                            child: const Center(
                              child: Icon(
                                Icons.backspace,
                                color: Colors.grey,
                              ),
                            ),
                          )),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}