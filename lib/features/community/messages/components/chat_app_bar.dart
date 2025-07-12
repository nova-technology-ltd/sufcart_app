import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sufcart_app/features/community/follows/screens/user_profile_screen.dart';
import 'package:sufcart_app/features/profile/model/user_provider.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../../../profile/model/user_model.dart';
import '../data/provider/messages_socket_provider.dart';
import '../utilities/helpers.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel receiver;
  final bool isDarkMode;
  final bool isSearching;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onSearchChanged;
  final VoidCallback toggleSearch;

  const ChatAppBar({
    super.key,
    required this.receiver,
    required this.isDarkMode,
    required this.isSearching,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.toggleSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userModel;
    final fullName = "${receiver.firstName} ${receiver.lastName} ${receiver.otherNames}";
    return AppBar(
      backgroundColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
      surfaceTintColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
      leadingWidth: 0,
      automaticallyImplyLeading: false,
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.1),
      title: isSearching
          ? TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search messages...',
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        onChanged: (value) => onSearchChanged(),
      )
          : Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              IconlyLight.arrow_left,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          ElasticIn(
            duration: const Duration(milliseconds: 800),
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserProfileScreen(user: receiver)));
              },
              child: Container(
                height: 35,
                width: 35,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  receiver.image,
                  errorBuilder: (context, err, st) => const Center(
                    child: Icon(
                      IconlyBold.profile,
                      color: Colors.grey,
                      size: 17,
                    ),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                receiver.userName.isNotEmpty
                    ? receiver.userName.substring(1, receiver.userName.length)
                    : fullName.length > 22
                    ? "${fullName.substring(0, 22)}..."
                    : fullName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Consumer<MessagesSocketProvider>(
                builder: (context, provider, child) {
                  final roomID = ChatHelper.getRoomID(
                    user.userID ?? '',
                    receiver.userID,
                  );
                  final status = provider.getUserStatus(roomID, receiver.userID);
                  return Row(
                    children: [
                      Text(
                        receiver.userName.isNotEmpty
                            ? receiver.userName.substring(1, receiver.userName.length)
                            : status == 'online'
                            ? "Online"
                            : status == 'disconnected'
                            ? "Disconnected"
                            : "Offline",
                        style: TextStyle(
                          fontSize: 11,
                          color: status == 'online' ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.1,
                            color: status == 'online' ? Colors.green : Colors.grey,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: status == 'online' ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: toggleSearch,
          icon: Icon(
            isSearching ? Icons.close : IconlyLight.search,
            color: isDarkMode ? null : Colors.grey,
          ),
        ),
      ],
    );
  }
}