import 'package:flutter/material.dart';

class ActionIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isDisabled;
  final Color? iconColor;

  const ActionIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isDisabled = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDarkMode
            ? [] // No shadow in dark mode
            : [
                BoxShadow(
                  color: const Color.fromARGB(130, 158, 158, 158),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: IconButton(
        onPressed: isDisabled ? null : onPressed,
        icon: Icon(icon),
        color: iconColor ?? Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}