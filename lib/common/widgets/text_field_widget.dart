import 'package:flutter/material.dart';
import '../styles/text_styles.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    required this.textController,
    required this.text,
    required this.inputType,
    this.validator,
    this.obscureText = false,
  });

  final TextEditingController textController;
  final String text;
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: inputType,
      controller: textController,
      style: kRegularTextStyle,
      obscureText: obscureText,
      validator: validator,
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