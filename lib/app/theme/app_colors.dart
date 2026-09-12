import 'package:flutter/material.dart';

/// Màu ngoài Material ColorScheme (success, warning, ...) khai báo qua ThemeExtension
/// để đọc bằng `context.appColors.success`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.success, required this.warning});

  final Color success;
  final Color warning;

  static const light = AppColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFF9A825),
  );
  static const dark = AppColors(
    success: Color(0xFF81C784),
    warning: Color(0xFFFFD54F),
  );

  @override
  AppColors copyWith({Color? success, Color? warning}) => AppColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
