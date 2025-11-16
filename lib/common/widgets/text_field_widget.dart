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
    this.maxLines,
    this.minLines,
  });

  final TextEditingController textController;
  final String text;
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    // Obscured fields cannot be multiline - must have maxLines = 1
    final int? effectiveMaxLines = obscureText ? 1 : maxLines;
    final int? effectiveMinLines = obscureText ? 1 : minLines;
    
    return TextFormField(
      keyboardType: inputType,
      controller: textController,
      style: kRegularTextStyle,
      obscureText: obscureText,
      validator: validator,
      maxLines: effectiveMaxLines,
      minLines: effectiveMinLines,
      textInputAction: effectiveMaxLines != null && effectiveMaxLines > 1 || effectiveMaxLines == null 
          ? TextInputAction.newline 
          : TextInputAction.done,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        hintText: text,
        hintStyle: kHintTextStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}