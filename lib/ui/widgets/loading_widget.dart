import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../constants/colors_lib.dart';
import '../../constants/core_ui_text_dimensions.dart';

part 'loading_indicator.dart';

/// Widget hiển thị trạng thái đang tải dữ liệu.
///
/// [LoadingWidget] bao gồm một [LoadingIndicator] và/hoặc
/// một [Text] hiển thị thông điệp, tuân theo Design System.
///
/// Thường được dùng để hiển thị trong lúc chờ dữ liệu hoặc đang xử lý task.
///
/// ### Ví dụ:
/// ```dart
/// LoadingWidget()
/// ```
/// hoặc với cấu hình tuỳ chỉnh:
/// ```dart
/// LoadingWidget(
///   darkTheme: true,
///   iconSize: 32,
///   text: "Đang đồng bộ...",
/// )
/// ```
class LoadingWidget extends StatelessWidget {
  /// Khoảng cách bao quanh widget. Mặc định là [EdgeInsets.zero].
  final EdgeInsets margin;

  /// Vị trí căn chỉnh của nội dung trong widget.
  ///
  /// Hành vi tương tự [alignment] của [Container].
  final Alignment? alignment;

  /// Kích thước của [LoadingIndicator]
  ///
  /// Mặc định là `24`.
  final double iconSize;

  /// Có hiển thị chữ dưới indicator hay không.
  final bool hasText;

  /// Nội dung văn bản hiển thị bên dưới indicator.
  final String? text;

  /// Kiểu chữ cho văn bản [text].
  final TextStyle? textStyle;

  /// Màu nền của vòng tròn.
  final Color? backgroundColor;

  /// Màu của phần vòng quay (vùng đã tải).
  final Color? indicatorColor;

  /// Màu chữ văn bản [text].
  final Color? textColor;

  /// Khởi tạo một [LoadingWidget].
  const LoadingWidget({
    super.key,
    this.margin = EdgeInsets.zero,
    this.alignment,
    this.iconSize = _defaultIconSize,
    this.hasText = true,
    this.text,
    this.textStyle,
    this.backgroundColor,
    this.indicatorColor,
    this.textColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: alignment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          LoadingIndicator(
            size: iconSize,
            strokeWidth: 1.5 * iconSize / _defaultIconSize,
            backgroundColor: backgroundColor ?? _defaultBackgroundColor,
            indicatorColor: indicatorColor ?? _defaultIndicatorColor
          ),
          if (hasText) Text(
            text ?? "Loading",
            style: _defaultTextStyle.merge(textStyle).copyWith(color: textColor)
          )
        ]
      )
    );
  }

  static const double _defaultIconSize = 24;
  static const Color _defaultBackgroundColor = ColorsLib.primary2100;
  static const Color _defaultIndicatorColor = ColorsLib.primary2600;
  static const Color _defaultTextColor = ColorsLib.primary2600;
  static final TextStyle _defaultTextStyle = CoreUiTextDimensions.s14h20w400l0.copyWith(
    color: _defaultTextColor
  );
}
