import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:sufcart_app/utilities/constants/app_colors.dart';

class EmojiBottomSheet extends StatelessWidget {
  final TextEditingController? textEditingController;
  final Function(Category?, Emoji)? onEmojiSelected;
  final VoidCallback? onBackspacePressed;

  const EmojiBottomSheet({
    super.key,
    this.textEditingController,
    this.onEmojiSelected,
    this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Material(
        color: Colors.transparent,
        elevation: 10.0,
        // borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: 350,
          width: MediaQuery.of(context).size.width,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
            // borderRadius: BorderRadius.circular(15.0),
          ),
          child: EmojiPicker(
            onEmojiSelected: onEmojiSelected ?? (category, emoji) {},
            onBackspacePressed: onBackspacePressed,
            textEditingController: textEditingController,
            config: Config(
              height: 350,
              skinToneConfig: const SkinToneConfig(
                dialogBackgroundColor: Colors.white,
                indicatorColor: Color(AppColors.primaryColor),
              ),
              categoryViewConfig: CategoryViewConfig(
                tabBarHeight: 35,
                backgroundColor: isDarkMode ? Color(AppColors.primaryColorDarkMode) : Colors.white,
                indicatorColor: Colors.grey,
                dividerColor: Colors.transparent,
                iconColorSelected: Colors.grey,
                categoryIcons: const CategoryIcons(
                  recentIcon: Icons.history_rounded,
                  smileyIcon: Icons.emoji_emotions_rounded,
                  animalIcon: Icons.pets_rounded,
                  foodIcon: Icons.fastfood_rounded,
                  travelIcon: Icons.place_rounded,
                  activityIcon: Icons.sports_soccer_rounded,
                  objectIcon: Icons.lightbulb_rounded,
                  symbolIcon: Icons.tag_rounded,
                  flagIcon: Icons.flag_rounded,
                ),
                recentTabBehavior: RecentTabBehavior.RECENT,
              ),
              emojiViewConfig: EmojiViewConfig(
                backgroundColor: Colors.transparent,
              ),
              bottomActionBarConfig: const BottomActionBarConfig(
                showBackspaceButton: true,
                showSearchViewButton: false,
                backgroundColor: Colors.transparent,
                buttonIconColor: Colors.grey,),
              searchViewConfig: SearchViewConfig(
                // backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                // buttonIconColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                hintText: 'Search Emojis',
              ),
              checkPlatformCompatibility: true,
            ),
          ),
        ),
      ),
    );
  }
}