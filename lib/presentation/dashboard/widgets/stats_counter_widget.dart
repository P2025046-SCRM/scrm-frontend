
import 'package:flutter/material.dart';

import '../../../common/styles/text_styles.dart';

class StatsCounter extends StatelessWidget {
  const StatsCounter({
    super.key,
    required this.count,
    required this.statLabel,
  });
  final int count;
  final String statLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(count.toString(), style: kTitleTextStyle,),
            SizedBox(height: 2,),
            Text(statLabel, style: kRegularTextStyle,),
          ],
        )
      ],
    );
  }
}