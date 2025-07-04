import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import 'app_bar_back_arrow.dart';

class CustomSliverAppBar extends StatefulWidget {
  final String coverImage;
  final bool? hasColor;
  final FlexibleSpaceBar? flexibleSpaceBar;
  final String title;
  final List<Widget> slivers;
  final double expandedHeight;

  const CustomSliverAppBar({
    super.key,
    required this.coverImage,
    required this.title,
    required this.slivers,
    this.expandedHeight = 250.0, this.hasColor, this.flexibleSpaceBar,
  });

  @override
  State<CustomSliverAppBar> createState() => _CustomSliverAppBarState();
}

class _CustomSliverAppBarState extends State<CustomSliverAppBar> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _isCollapsed = _scrollController.offset > (widget.expandedHeight - kToolbarHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
            surfaceTintColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
            expandedHeight: widget.expandedHeight,
            floating: false,
            pinned: true,
            leading: AppBarBackArrow(onClick: () {
              Navigator.pop(context);
            }, bg: _isCollapsed ? themeProvider.isDarkMode ? null : Colors.black : Colors.white, ),
            leadingWidth: 90,
            automaticallyImplyLeading: false,
            flexibleSpace: widget.hasColor == false || widget.flexibleSpaceBar == null ?  FlexibleSpaceBar(
              background: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Image.network(
                        widget.coverImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              title: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _isCollapsed ? themeProvider.isDarkMode ? null : Colors.black : Colors.white,
                ),
              ),
            ) : widget.flexibleSpaceBar,
          ),
          ...widget.slivers,
        ],
      ),
    );
  }
}
