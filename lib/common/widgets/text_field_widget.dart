import 'package:flutter/material.dart';
import '../styles/text_styles.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    required this.textController,
    required this.text
  });

  final TextEditingController textController;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: textController,
      style: kRegularTextStyle,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: text,
        hintStyle: kHintTextStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}