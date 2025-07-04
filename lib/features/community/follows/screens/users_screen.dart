import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/auth/service/auth_service.dart';
import 'package:sufcart_app/features/community/follows/components/users_card_style.dart';
import 'package:sufcart_app/features/community/follows/services/follows_services.dart';
import 'package:sufcart_app/utilities/constants/app_colors.dart';
import '../../../../../../../../utilities/components/shima_effects/invites_shimma_loader.dart';
import '../../../../../../../../utilities/themes/theme_provider.dart';
import '../../../../utilities/components/app_bar_back_arrow.dart';
import '../../../../utilities/components/custom_text_field.dart';
import '../../../profile/model/user_model.dart';
import 'dart:math';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchUsersController = TextEditingController();
  final FollowsServices _followService = FollowsServices();
  final AuthService _authService = AuthService();
  List<UserModel> _allUsers = [];
  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = true;
  String? _currentUserId; // To store the logged-in user's ID

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUsers();
  }

  Future<void> _loadCurrentUser() async {
    // Assuming FollowsServices has a method to get the current user ID
    try {
      final currentUser = await _authService.userProfile(context);
      setState(() {
        _currentUserId = currentUser?.userID; // Assuming UserModel has userId
      });
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  Future<void> _loadUsers({bool isRefresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final users = await _followService.getAllUsers(context);
      setState(() {
        // Filter out the current user
        _allUsers = _shuffleUsers(users.where((user) => user.userID != _currentUserId).toList());
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading users: $e');
    }
  }

  List<UserModel> _shuffleUsers(List<UserModel> users) {
    final random = Random();
    return List.from(users)..shuffle(random);
  }

  void _searchUsers(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final localResults = _allUsers.where((user) {
      return user.userName.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();

    if (localResults.isNotEmpty) {
      setState(() {
        // Filter out the current user from search results
        _searchResults = _shuffleUsers(localResults.where((user) => user.userID != _currentUserId).toList());
      });
    } else {
      _performApiSearch(query);
    }
  }

  Future<void> _performApiSearch(String query) async {
    try {
      final results = await _followService.searchUsers(context, query);
      setState(() {
        // Filter out the current user from API results
        _searchResults = _shuffleUsers(results.where((user) => user.userID != _currentUserId).toList());
      });
    } catch (e) {
      debugPrint('Error searching users: $e');
      setState(() {
        _searchResults = [];
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadUsers(isRefresh: true);
    if (_isSearching) {
      _searchUsers(_searchUsersController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context).isDarkMode;
    final usersToDisplay = _isSearching ? _searchResults : _allUsers;

    return Scaffold(
      backgroundColor: themeProvider ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider ? null : Colors.white,
        surfaceTintColor: themeProvider ? Colors.black : Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Users",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        backgroundColor: Colors.white,
        color: Color(AppColors.primaryColor),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              CustomTextField(
                hintText: "Search...",
                prefixIcon: const Icon(IconlyLight.search),
                isObscure: false,
                controller: _searchUsersController,
                onChange: _searchUsers,
              ),
              Expanded(
                child: _isLoading
                    ? const Expanded(
                  child: SingleChildScrollView(
                    child: InvitesShimmaLoader(count: 20),
                  ),
                )
                    : usersToDisplay.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: usersToDisplay.length,
                  itemBuilder: (context, index) {
                    return UsersCardStyle(
                      data: usersToDisplay[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.hourglass_empty,
            color: Colors.grey,
          ),
          Text(_isSearching ? "No results found" : "No users available"),
          const Text(
            "Try a different search term",
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}