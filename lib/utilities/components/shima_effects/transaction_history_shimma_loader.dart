import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class TransactionHistoryShimmaLoader extends StatefulWidget {
  final int size;
  const TransactionHistoryShimmaLoader({super.key, required this.size});

  @override
  State<TransactionHistoryShimmaLoader> createState() =>
      _TransactionHistoryShimmaLoaderState();
}

class _TransactionHistoryShimmaLoaderState
    extends State<TransactionHistoryShimmaLoader> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < widget.size; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Container(
                // height: 45,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(AppColors.primaryColor).withOpacity(0.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 1,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 35,
                        width: 35,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 5,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50)
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 5,
                            width: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50)
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 5,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50)
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 5,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(50)
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
