import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utilities/components/sample_message_card.dart';

class PhoneSimulator extends StatefulWidget {
  const PhoneSimulator({super.key});

  @override
  State<PhoneSimulator> createState() => _PhoneSimulatorState();
}

class _PhoneSimulatorState extends State<PhoneSimulator> {
  String formattedDate = '';
  String formattedTime = '';

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    formattedDate = DateFormat('EEEE-MMMM d').format(now);
    formattedTime = DateFormat('jm').format(now);
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width / 1.2,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 10, color: Colors.black),
                  borderRadius: BorderRadius.circular(40)),
              child: Stack(
                children: [
                  Container(
                    height:
                    MediaQuery.of(context).size.height / 1.5,
                    width:
                    MediaQuery.of(context).size.width / 1.2,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      // border: Border.all(width: 10, color: Colors.black),
                        borderRadius:
                        BorderRadius.circular(28)),
                    child: Image.asset(
                      "images/ipone_wallpaper.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formattedTime,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                  Colors.white.withOpacity(0.7)),
                            ),
                            Center(
                              child: Container(
                                height: 26,
                                width: 90,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                    BorderRadius.circular(50)),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                //network bar
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    for (int i = 0; i < 4; i++)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 0.5),
                                        child: Container(
                                          height: 5 + i.toDouble(),
                                          width: 2.5,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.7),
                                              borderRadius: BorderRadius.circular(1)
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                                const SizedBox(width: 5,),
                                //battery
                                Row(
                                  children: [
                                    Container(
                                      height: 8,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1, color: Colors.white.withOpacity(0.7)),
                                        borderRadius: BorderRadius.circular(2)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.5),
                                        child: Container(
                                          height: 12,
                                          width: 22,
                                          decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.7),
                                              borderRadius: BorderRadius.circular(2)
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 0.5,),
                                    Container(
                                      height: 6,
                                      width: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(1)
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                            fontSize: 12,
                            color:
                            Colors.white.withOpacity(0.3)),
                      ),
                      Text(
                        formattedTime,
                        style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color:
                            Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: SampleMessageCard(
                      message:
                      '@Aisha reviewed a product the you just bought',
                      image: 'STK-20240102-WA0044.webp',
                      time: 'now',
                      name: 'Product Review',
                      bg: Colors.blue,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: SampleMessageCard(
                      message:
                      'Your order has been placed Successfully',
                      image: 'phone_slip.png',
                      time: '10min',
                      name: 'Notification',
                      bg: Colors.green,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: SampleMessageCard(
                      message:
                      'Your order has gotten to pickup location',
                      image: 'onboarding_img_seven.png',
                      time: 'now',
                      name: 'Dispatch #005',
                      bg: Colors.red,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: SampleMessageCard(
                      message:
                      'Item added to wishlist',
                      image: '3d-casual-life-ringing-bell.png',
                      time: 'now',
                      name: 'Wishlist',
                      bg: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
