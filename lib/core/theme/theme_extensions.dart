import 'package:flutter/material.dart';

@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color infoBackground;
  final Color infoIcon;
  final Color successLight;
  final Color errorLight;
  final Color pendingLight;

  const AppCustomColors({
    required this.infoBackground,
    required this.infoIcon,
    required this.successLight,
    required this.errorLight,
    required this.pendingLight,
  });

  @override
  AppCustomColors copyWith({
    Color? infoBackground,
    Color? infoIcon,
    Color? successLight,
    Color? errorLight,
    Color? pendingLight,
  }) {
    return AppCustomColors(
      infoBackground: infoBackground ?? this.infoBackground,
      infoIcon: infoIcon ?? this.infoIcon,
      successLight: successLight ?? this.successLight,
      errorLight: errorLight ?? this.errorLight,
      pendingLight: pendingLight ?? this.pendingLight,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      infoBackground: Color.lerp(infoBackground, other.infoBackground, t)!,
      infoIcon: Color.lerp(infoIcon, other.infoIcon, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      pendingLight: Color.lerp(pendingLight, other.pendingLight, t)!,
    );
  }
}
