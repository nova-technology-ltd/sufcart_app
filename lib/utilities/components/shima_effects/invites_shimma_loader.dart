import 'package:flutter/material.dart';

class InvitesShimmaLoader extends StatelessWidget {
  final int? count;
  const InvitesShimmaLoader({super.key, this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < (count ?? 5); i++)
            Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          // color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.08),
                        shape: BoxShape.circle
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 8,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(50)
                        ),
                      ),
                      const SizedBox(height: 2,),
                      Row(
                        children: [
                          Container(
                            height: 6,
                            width: 40,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(50)
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Container(
                              height: 4,
                              width: 4,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.4),
                                  shape: BoxShape.circle
                              ),
                            ),
                          ),
                          Container(
                            height: 6,
                            width: 180,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(50)
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    )
      ],
    );
  }
}
