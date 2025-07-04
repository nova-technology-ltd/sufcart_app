import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sufcart_app/utilities/components/app_bar_back_arrow.dart';

class ImageViewScreen extends StatefulWidget {
  final List<String> imageUrls;

  const ImageViewScreen({super.key, required this.imageUrls});

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen>
    with SingleTickerProviderStateMixin {
  bool _isDownloading = false;
  bool _showAppBar = true;
  late AnimationController _animationController;
  late Animation<double> _appBarAnimation;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _appBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _pageController = PageController();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          _showAppBar
              ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: AnimatedBuilder(
                  animation: _appBarAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _appBarAnimation.value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          (1 - _appBarAnimation.value) * -kToolbarHeight,
                        ),
                        child: AppBar(
                          backgroundColor: Colors.black.withOpacity(
                            0.8 * _appBarAnimation.value,
                          ),
                          leadingWidth: 90,
                          leading: AppBarBackArrow(onClick: () => Navigator.pop(context)),
                          actions: [
                            IconButton(
                              icon: const Icon(
                                CupertinoIcons.info,
                                color: Colors.white,
                              ),
                              onPressed: _showImageInfo,
                              tooltip: "Info",
                            ),
                            IconButton(
                              icon:
                                  _isDownloading
                                      ? const CupertinoActivityIndicator(
                                        color: Colors.white,
                                      )
                                      : const Icon(
                                        CupertinoIcons.cloud_download,
                                        color: Colors.white,
                                      ),
                              onPressed: _downloadImage,
                              tooltip: "Download",
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 10.0,
                                left: 5,
                              ),
                              child: Container(
                                height: 40,
                                width: 82,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(360),
                                ),
                                child: MaterialButton(
                                  onPressed: _replyToImage,
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(360),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.reply,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "Reply",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
              : null,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showAppBar = !_showAppBar;
                if (_showAppBar) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 3.0,
                  child: Center(
                    child: Image.network(
                      widget.imageUrls[index],
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentPage == index
                              ? Colors.white
                              : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _downloadImage() async {
    try {
      setState(() {
        _isDownloading = true;
      });
      Directory? downloadsDirectory;
      try {
        if (Platform.isAndroid) {
          downloadsDirectory = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          downloadsDirectory = await getDownloadsDirectory();
        }
      } catch (e) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      final folderPath = '${downloadsDirectory!.path}/sufcart_resources';
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$folderPath/$fileName';

      final response = await http.get(
        Uri.parse(widget.imageUrls[_currentPage]),
      );
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Image saved to $filePath')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download image')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading image: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _replyToImage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Reply unavailable')));
  }

  void _showImageInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'Image Info',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'URL: ${widget.imageUrls[_currentPage]}\nSize: Unknown\nType: JPEG',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
