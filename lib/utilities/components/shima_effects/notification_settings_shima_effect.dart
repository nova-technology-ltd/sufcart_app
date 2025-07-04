import 'package:flutter/material.dart';

class NotificationSettingsShimaEffect extends StatelessWidget {
  const NotificationSettingsShimaEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                for (int i = 0; i < 4; i++)
                  Container(
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[000]),
                    child: Row(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 8,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 8,
                              width: 280,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              height: 10,
              width: 150,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
            ),
            const SizedBox(
              height: 15,
            ),
            Column(
              children: [
                for (int i = 0; i < 5; i++)
                  Container(
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[000]),
                    child: Row(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 8,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 8,
                              width: 280,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              height: 10,
              width: 150,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
            ),
            const SizedBox(
              height: 15,
            ),
            Column(
              children: [
                for (int i = 0; i < 3; i++)
                  Container(
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[000]),
                    child: Row(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 8,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 8,
                              width: 280,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              height: 10,
              width: 150,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20)),
            ),
            const SizedBox(
              height: 15,
            ),
            Column(
              children: [
                for (int i = 0; i < 6; i++)
                  Container(
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[000]),
                    child: Row(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 8,
                              width: 150,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 8,
                              width: 280,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
