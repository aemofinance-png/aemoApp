import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.width,
    this.height,
    this.textStyle,
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidth = width ?? double.infinity;
    final buttonHeight = height ?? 52.0;

    // Use Theme-based styling with optional overrides
    if (isOutlined) {
      return SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle ??
              (color != null
                  ? OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color!),
                    )
                  : null),
          child: _buildChild(context),
        ),
      );
    }

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle ??
            (color != null
                ? ElevatedButton.styleFrom(backgroundColor: color)
                : null),
        child: _buildChild(context),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      final theme = Theme.of(context);
      final indicatorColor = isOutlined
          ? (color ?? theme.colorScheme.primary)
          : (theme.colorScheme.onPrimary);

      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
        ),
      );
    }
    return Text(label, style: textStyle);
  }
}
