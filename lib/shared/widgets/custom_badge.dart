import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final TextStyle? textStyle;

  const CustomBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        label,
        style: textStyle ??
            TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
      ),
    );
  }
}
