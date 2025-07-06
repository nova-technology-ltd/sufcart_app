import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufcart_app/features/community/messages/components/messages_card_style.dart';
import 'package:sufcart_app/features/community/messages/sections/active_users_section.dart';
import 'package:sufcart_app/features/profile/model/user_model.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';
import 'package:sufcart_app/features/profile/model/user_provider.dart';
import 'package:sufcart_app/features/community/messages/provider/messages_socket_provider.dart';

class TalksScreen extends StatefulWidget {
  const TalksScreen({super.key});

  @override
  State<TalksScreen> createState() => _TalksScreenState();
}

class _TalksScreenState extends State<TalksScreen> {
  final TextEditingController _searchConversationsController = TextEditingController();
  bool _isOffline = false;
  bool _isShowingConnected = false;
  List<UserModel> _cachedChatUsers = [];
  Timer? _statusPollingTimer;

  @override
  void initState() {
    super.initState();
    _loadCachedChatUsers();
    _initConnectivity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshChatUsers();
    });
    // Periodic polling for user statuses
    _statusPollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isOffline && mounted) {
        print('Polling user statuses');
        final provider = Provider.of<MessagesSocketProvider>(context, listen: false);
        for (var user in provider.chatUsers) {
          provider.requestUserStatus(user.userID);
        }
      }
    });
  }

  Future<void> _loadCachedChatUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('chat_users_cache');
      if (cachedData != null && mounted) {
        final List<dynamic> jsonData = jsonDecode(cachedData);
        setState(() {
          _cachedChatUsers = jsonData.map((json) => UserModel.fromJson(json)).toList();
          print('Loaded cached chat users: ${_cachedChatUsers.map((u) => u.userID).toList()}');
        });
      }
    } catch (e) {
      print('Error loading cached chat users: $e');
    }
  }

  Future<void> _cacheChatUsers(List<UserModel> chatUsers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = chatUsers.map((user) => user.toJson()).toList();
      await prefs.setString('chat_users_cache', jsonEncode(jsonData));
      print('Cached chat users: ${chatUsers.map((u) => u.userID).toList()}');
    } catch (e) {
      print('Error caching chat users: $e');
    }
  }

  Future<void> _initConnectivity() async {
    try {
      final connectivity = Connectivity();
      final connectivityResult = await connectivity.checkConnectivity();
      setState(() {
        _isOffline = !connectivityResult.contains(ConnectivityResult.mobile) &&
            !connectivityResult.contains(ConnectivityResult.wifi);
        print('Initial connectivity: ${_isOffline ? 'Offline' : 'Online'}');
      });

      connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
        if (!mounted) return;
        final isNowOffline = !result.contains(ConnectivityResult.mobile) &&
            !result.contains(ConnectivityResult.wifi);
        setState(() {
          _isOffline = isNowOffline;
          print('Connectivity changed: ${_isOffline ? 'Offline' : 'Online'}');
          if (!_isOffline) {
            _isShowingConnected = true;
            _refreshChatUsers();
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _isShowingConnected = false;
                });
              }
            });
          }
        });
      });
    } catch (e) {
      print('Error initializing connectivity: $e');
    }
  }

  Future<void> _refreshChatUsers() async {
    if (!_isOffline) {
      try {
        print('Refreshing chat users');
        final provider = Provider.of<MessagesSocketProvider>(context, listen: false);
        await provider.fetchChatUsers();
        if (provider.chatUsers.isNotEmpty) {
          await _cacheChatUsers(provider.chatUsers);
          // Request status for all users to ensure real-time updates
          for (var user in provider.chatUsers) {
            provider.requestUserStatus(user.userID);
          }
        }
      } catch (e) {
        print('Error refreshing chat users: $e');
      }
    }
  }

  @override
  void dispose() {
    print('Disposing TalksScreen');
    _statusPollingTimer?.cancel();
    _searchConversationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sender = Provider.of<UserProvider>(context).userModel;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Consumer<MessagesSocketProvider>(
      builder: (context, provider, child) {
        final chatUsers = provider.chatUsers.isNotEmpty ? provider.chatUsers : _cachedChatUsers;
        print('Rendering TalksScreen with chatUsers: ${chatUsers.map((u) => '${u.userID} (${u.status})').toList()}');
        if (provider.chatUsers.isNotEmpty && provider.chatUsers != _cachedChatUsers) {
          _cacheChatUsers(provider.chatUsers);
        }
        final errorMessage = provider.errorMessage;

        return Scaffold(
          backgroundColor: isDarkMode ? null : Colors.white,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Talks',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                if (_isOffline)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Connecting...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                else if (_isShowingConnected)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Connected',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
              ],
            ),
            centerTitle: true,
            backgroundColor: isDarkMode ? null : Colors.white,
            surfaceTintColor: isDarkMode ? Colors.black : Colors.white,
            automaticallyImplyLeading: false,
          ),
          body: errorMessage != null
              ? Center(child: Text('Error: $errorMessage'))
              : chatUsers.isEmpty
              ? const Center(child: Text('No conversations yet'))
              : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    height: 43,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 7.0),
                            child: Icon(
                              IconlyLight.search,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _searchConversationsController,
                              cursorColor: Colors.grey,
                              cursorHeight: 18,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                hintText: "search conversations...",
                                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                // Implement search filtering if needed
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ActiveUsersSection(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Talks",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "You’ve had ${chatUsers.length} talks so far",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                for (final user in chatUsers)
                  MessagesCardStyle(
                    user: user,
                    roomID: _getRoomID(sender.userID, user.userID),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getRoomID(String userID1, String userID2) {
    final ids = [userID1, userID2];
    ids.sort();
    return 'chat:${ids.join(':')}';
  }
}