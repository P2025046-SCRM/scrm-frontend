
import 'package:flutter/material.dart';

import '../../../common/styles/text_styles.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/profile_placeholder.png'),
          ),
          SizedBox(height: 8,),
          Text('Juan Perez', style: kSubtitleTextStyle,),
          SizedBox(height: 4,),
          Text('3J Solutions', style: kDescriptionTextStyle,),
          SizedBox(height: 2,),
          Text('juanperez@example.com', style: kDescriptionTextStyle,),
        ],
      ),
    );
  }
}