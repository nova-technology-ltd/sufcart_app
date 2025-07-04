import 'package:flutter/material.dart';

class RencentTransferShimmaLoader extends StatefulWidget {
  const RencentTransferShimmaLoader({super.key});

  @override
  State<RencentTransferShimmaLoader> createState() => _RencentTransferShimmaLoaderState();
}

class _RencentTransferShimmaLoaderState extends State<RencentTransferShimmaLoader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 5,
                width: 85,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(50)
                ),
              ),
              Container(
                height: 5,
                width: 45,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(50)
                ),
              ),

            ],
          ),
        ),
        const SizedBox(height: 10,),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < 7; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    children: [
                      Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.08),
                          shape: BoxShape.circle
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Container(
                        height: 5,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(50)
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
