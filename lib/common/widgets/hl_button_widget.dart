import 'package:flutter/material.dart';
import 'package:scrm/utils/constants.dart';
import '../../common/styles/text_styles.dart';

class HighlightedButton extends StatelessWidget {
  const HighlightedButton({super.key, required this.buttonText, this.onPressed});
  final String buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed == null 
            ? Colors.grey 
            : AppColors.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        )
      ),
      child: Text(buttonText, style: kAltRegularTextStyle,),
    );
  }
}