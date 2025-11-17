import 'package:flutter/material.dart';
import '../../../common/styles/text_styles.dart';

class KPICard extends StatelessWidget {
  const KPICard({
    super.key,
    required this.count,
    required this.label,
    this.isDouble = false,
  });

  final String count;
  final String label;
  final bool isDouble;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: List<BoxShadow>.generate(
          3,
          (index) => BoxShadow(
            color: const Color.fromARGB(33, 0, 0, 0),
            blurRadius: 2 * (index + 1),
            offset: Offset(0, 2 * (index + 1)),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count, style: kTitleTextStyle,),
              if (isDouble)
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 2),
                  child: Text(
                    's',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              label,
              style: kRegularTextStyle,
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

