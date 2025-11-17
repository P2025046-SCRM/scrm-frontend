import 'package:flutter/material.dart';
import 'package:scrm/common/widgets/hl_button_widget.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.buttonText,
    required this.loadingText,
    required this.onPressed,
    required this.isLoading,
    this.width = double.infinity,
    this.height = 48,
  });

  final String buttonText;
  final String loadingText;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : HighlightedButton(
              buttonText: buttonText,
              onPressed: isLoading ? null : onPressed,
            ),
    );
  }
}

