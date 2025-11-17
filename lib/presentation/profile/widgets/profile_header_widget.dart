import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrm/data/providers/user_provider.dart';

import '../../../common/styles/text_styles.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final name = userProvider.userName ?? 'Usuario';
        final email = userProvider.userEmail ?? '';
        final company = userProvider.userCompany ?? '';

        return Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_placeholder.png'),
              ),
              SizedBox(height: 8,),
              Text(name, style: kSubtitleTextStyle,),
              if (company.isNotEmpty) ...[
                SizedBox(height: 4,),
                Text(company, style: kDescriptionTextStyle,),
              ],
              if (email.isNotEmpty) ...[
                SizedBox(height: 2,),
                Text(email, style: kDescriptionTextStyle,),
              ],
            ],
          ),
        );
      },
    );
  }
}