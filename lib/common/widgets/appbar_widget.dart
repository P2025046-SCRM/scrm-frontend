import 'package:flutter/material.dart';

import '../styles/text_styles.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    required this.title,
    required this.showProfile,
  });
  final String title;
  final bool showProfile;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title, style: kTitleTextStyle,),
      actions: showProfile
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, 'profile'),
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/profile_placeholder.png'), // Placeholder image change later for actual profile picture
                  ),
                ),
              ),
            ]
          : null,
    );
  }
}
