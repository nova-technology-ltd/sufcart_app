import 'package:flutter/material.dart';

import '../../../../../../utilities/constants/app_icons.dart';


class ImageMessageBubble extends StatelessWidget {
  final List<String> urls;
  final bool isSender;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const ImageMessageBubble({
    super.key,
    required this.urls,
    required this.isSender,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });

  @override
  Widget build(BuildContext context) {
    return urls.length > 1
        ? Column(
      children: [
        for (int i = 0; i < 2; i++)
          Row(
            children: [
              for (int j = 0; j < 2; j++)
                Expanded(
                  child: (i * 2 + j) < urls.length
                      ? Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: Container(
                      height: 80,
                      width: 80,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            height:
                            MediaQuery.of(context).size.height,
                            width:
                            MediaQuery.of(context).size.width,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.network(
                              urls[i * 2 + j],
                              fit: BoxFit.cover,
                              errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                  ) {
                                return Center(
                                  child: Image.asset(
                                    AppIcons.koradLogo,
                                    color: Colors.grey,
                                    width: 18,
                                    height: 18,
                                  ),
                                );
                              },
                            ),
                          ),
                          if (i * 2 + j == 3 && urls.length > 4)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '+${urls.length - 4}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
            ],

          ),
      ],
    )
        : Container(
      width: 163,
      height: 163,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.network(
        urls[0],
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Image.asset(
              AppIcons.koradLogo,
              color: Colors.grey,
              width: 50,
              height: 50,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Image.asset(
              AppIcons.koradLogo,
              color: Colors.grey,
              width: 50,
              height: 50,
            ),
          );
        },
      ),
    );
  }
}