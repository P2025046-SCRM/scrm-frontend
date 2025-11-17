import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  const CardContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.color,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        boxShadow: List<BoxShadow>.generate(
          3,
          (index) => BoxShadow(
            color: const Color.fromARGB(33, 0, 0, 0),
            blurRadius: 2 * (index + 1),
            offset: Offset(0, 2 * (index + 1)),
          ),
        ),
      ),
      child: child,
    );
  }
}

