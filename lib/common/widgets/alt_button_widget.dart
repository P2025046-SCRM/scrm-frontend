import 'package:flutter/material.dart';
import '../../common/styles/text_styles.dart';

class AltButtonWidget extends StatelessWidget {
  const AltButtonWidget({super.key, required this.buttonText, required this.onPressed});
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        )
      ),
      child: Text(buttonText, style: kRegularTextStyle,),);
  }
}