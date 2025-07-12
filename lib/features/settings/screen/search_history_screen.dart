import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Add this to format dates

import '../../../utilities/components/app_bar_back_arrow.dart';
import '../../../utilities/constants/app_colors.dart';
import '../../../utilities/themes/theme_provider.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  List<String> _searchHistory = [];

  Future<void> _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
      // Sort the search history by date
      _searchHistory.sort((a, b) {
        DateTime dateA =
            DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.split(' - ')[1]);
        DateTime dateB =
            DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.split(' - ')[1]);
        return dateB.compareTo(dateA);
      });
    });
  }

  Future<void> _removeFromSearchHistory(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(query);
    });
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  @override
  void initState() {
    _loadSearchHistory();
    super.initState();
  }

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        surfaceTintColor: themeProvider.isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
        leadingWidth: 90,
        automaticallyImplyLeading: false,
        leading: AppBarBackArrow(onClick: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: const Text(
          "Search History",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildSearchHistory(),
        ),
      ),
    );
  }

  List<Widget> _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return [
         Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No history yet',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                  Text(
                    'Seams like you\'ve not searched for anything, we will be sure to keep all your search history here for you',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }
    List<Widget> historyWidgets = [];
    String currentDay = '';

    for (int index = 0; index < _searchHistory.length; index++) {
      DateTime entryDate = DateFormat('yyyy-MM-dd HH:mm:ss')
          .parse(_searchHistory[index].split(' - ')[1]);
      String entryDay = DateFormat('yyyy-MM-dd').format(entryDate);
      String displayDate = DateFormat('MMM dd, yyyy').format(entryDate);

      if (entryDay != currentDay) {
        currentDay = entryDay;
        if (entryDay == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
          historyWidgets.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10),
            child: Text('Today',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ));
        } else {
          historyWidgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10),
            child: Text(displayDate,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ));
        }
      }

      historyWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10),
        child: Dismissible(
          key: Key(_searchHistory[index]),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _removeFromSearchHistory(_searchHistory[index]);
          },
          background: Container(
            color: const Color(AppColors.primaryColor),
            alignment: Alignment.centerRight,
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(IconlyBold.delete, color: Colors.white),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              // _searchController.text = _searchHistory[index];
              // _searchProducts(_searchHistory[index]);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history, size: 20, color: Colors.grey),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          _searchHistory[index].split(' - ')[0],
                          // Show only the query
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_upward_outlined,
                      color: Colors.grey,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
    }

    return historyWidgets;
  }
}
