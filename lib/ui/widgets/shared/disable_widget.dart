import 'package:flutter/widgets.dart';

/// Disable Widget cho phép vô hiệu hóa một widget.
///
/// Widget bị vô hiệu hóa sẽ được bọc bởi [IgnorePointer] và
/// opacity sẽ được thay đổi.
class DisableWidget extends StatelessWidget {
  /// Tình trạng disable của widget.
  final bool disable;

  /// Độ mờ khi widget bị disable (opacity từ 0 đến 1).
  ///
  /// Mặc định: 0.4.
  final double? opacityDisabled;

  /// Widget cần được disable.
  final Widget child;

  /// Khởi tạo một [DisableWidget].
  ///
  /// Ví dụ:
  /// ```dart
  /// DisableWidget(
  ///   disable: true,
  ///   opacity: 0.6
  ///   child: ChildWidget()
  /// )
  /// ```
  const DisableWidget({
    super.key,
    this.disable = false,
    this.opacityDisabled,
    this.child = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    final finalOpacityDisabled = opacityDisabled ?? 0.4;

    return IgnorePointer(
      ignoring: disable,
      child: Opacity(
        opacity: disable ? finalOpacityDisabled : 1,
        child: child
      )
    );
  }
}
