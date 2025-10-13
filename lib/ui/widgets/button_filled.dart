import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rxdart/rxdart.dart';

import '../../constants/colors_lib.dart';
import '../../constants/core_ui_text_dimensions.dart';
import 'loading_widget.dart';

enum ButtonStatus { none, loading }

enum IconPosition { start, left, right, end }

/// Widget thể hiện nút bấm dạng filled.
///
/// Ví dụ sử dụng:
/// ```dart
/// ButtonFilled(
///   defaultLabel: 'Đăng nhập',
///   loadingLabel: 'Đang xử lý...',
///   iconPath: AssetsPath.iconLogin,
///   backgroundColor: Colors.blue,
///   isSmallSize: false,
///   iconPosition: IconPosition.left,
///   onTap: () async {
///     await controller.handleLogin();
///   },
/// )
/// ```
class ButtonFilled extends StatefulWidget {
  /// Tên button.
  final String defaultLabel;

  /// Text hiển thị trên button khi ở trạng thái loading.
  ///
  /// Mặc định sử dụng [defaultLabel].
  final String? loadingLabel;

  /// Đường dẫn của icon (dạng SVG) hiển thị trong button.
  ///
  /// Mặc định: không hiển thị icon.
  final String iconPath;

  /// Màu chữ hiển thị trên button
  ///
  /// Mặc định: `Colors.white`.
  final Color? labelColor;

  /// Màu nền của button.
  ///
  /// Mặc định: `ColorsLib.primary2950`.
  final Color? backgroundColor;

  /// Có hay không việc sử dụng [ButtonFilled] với kich thước nhỏ gọn.
  ///
  /// Thường được sử dụng trong các dialog, các giao diện không gian bé.
  ///
  /// Mặc định: `false`.
  final bool isSmallSize;

  /// Vị trí của icon trên button.
  ///
  /// Tham chiếu giá trị từ [IconPosition]
  /// - `IconPosition.start`: icon nằm ngoài cùng bên trái.
  /// - `IconPosition.left`: icon nằm bên trái, cạnh label.
  /// - `IconPosition.right`: icon nằm bên phải, cạnh label.
  /// - `IconPosition.end`: icon nằm ngoài cùng bên phải.
  ///
  /// Mặc định: `IconPosition.end`.
  final IconPosition iconPosition;

  /// Có hay không việc [ButtonFilled] bị vô hiệu hóa.
  ///
  /// Vô hiệu hóa [ButtonFilled] sẽ làm cho button không thể nhấn và
  /// hiển thị giao diện với 40% opacity.
  ///
  /// Mặc định: `false`.
  final bool isDisable;

  /// Gọi khi button được nhấn.
  final Function()? onTap;

  /// Kiểu hiển thị của label khi vượt quá không gian cho phép.
  final TextOverflow? labelOverFlow;

  /// Khởi tạo một [ButtonFilled].
  const ButtonFilled({
    super.key,
    required this.defaultLabel,
    this.loadingLabel,
    this.iconPath = "",
    this.labelColor,
    this.backgroundColor,
    this.isSmallSize = false,
    this.iconPosition = IconPosition.end,
    this.isDisable = false,
    this.onTap,
    this.labelOverFlow
  });

  @override
  State<ButtonFilled> createState() => _ButtonFilledState();
}

class _ButtonFilledState extends State<ButtonFilled> with SingleTickerProviderStateMixin {
  late BehaviorSubject<ButtonStatus> buttonStatusStream;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    buttonStatusStream = BehaviorSubject.seeded(ButtonStatus.none);

    animationController = AnimationController(vsync: this);
    animationController.repeat(min: 0, max: 1, period: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    buttonStatusStream.close();
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double centerWidgetSize = widget.isSmallSize ? 24 : 28;
    if (MediaQuery.textScalerOf(context).scale(centerWidgetSize) > centerWidgetSize) {
      centerWidgetSize = MediaQuery.textScalerOf(context).scale(centerWidgetSize);
    }

    Color finalLabelColor = widget.labelColor ?? _defaultLabelColor;
    Color finalBackgroundColor = widget.backgroundColor ?? _defaultBackgroundColor;

    return Material(
        color: Colors.transparent,
        child: StreamBuilder<ButtonStatus>(
            stream: buttonStatusStream.stream,
            builder: (context, snapshot) {
              ButtonStatus status = snapshot.data ?? ButtonStatus.none;
              bool isDisable = (status == ButtonStatus.loading) || widget.isDisable;

              Color labelColorFinal = isDisable ? finalLabelColor.withValues(alpha: 0.4) : finalLabelColor;
              Color backgroundColorFinal = isDisable ? finalBackgroundColor.withValues(alpha: 0.4) : finalBackgroundColor;

              Widget icon;
              if (widget.iconPath.isEmpty) {
                icon = const SizedBox.shrink();
              } else {
                if (status == ButtonStatus.loading) {
                  icon = LoadingIndicator(size: centerWidgetSize);
                } else {
                  icon = SvgPicture.asset(
                      widget.iconPath,
                      width: centerWidgetSize, height: centerWidgetSize,
                      colorFilter: ColorFilter.mode(labelColorFinal, BlendMode.srcIn)
                  );
                }
              }

              return InkWell(
                  splashFactory: isDisable ? NoSplash.splashFactory : InkSplash.splashFactory,
                  splashColor: isDisable ? Colors.transparent : null,
                  highlightColor: isDisable ? Colors.transparent : null,
                  borderRadius: BorderRadius.circular(widget.isSmallSize ? 10 : 12),
                  onTap: () async {
                    if (isDisable || widget.onTap == null) return;

                    buttonStatusStream.add(ButtonStatus.loading);
                    await widget.onTap!();

                    if (mounted)  buttonStatusStream.add(ButtonStatus.none);
                  },
                  child: Ink(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: widget.isSmallSize ? 10 : 12, horizontal: 12),
                      decoration: BoxDecoration(
                          color: backgroundColorFinal,
                          borderRadius: BorderRadius.circular(widget.isSmallSize ? 10 : 12)
                      ),
                      child: Row(
                        mainAxisAlignment: (widget.iconPosition == IconPosition.start || widget.iconPosition == IconPosition.end)
                            ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                        children: [
                          if (widget.iconPosition == IconPosition.start || widget.iconPosition == IconPosition.left)
                            icon,
                          if (widget.iconPosition == IconPosition.end)
                            Opacity(opacity: 0, child: icon),
                          Flexible(
                            child: IndexedStack(
                              alignment: Alignment.center,
                              index: widget.iconPath.isNotEmpty || status == ButtonStatus.none ? 0 : 1,
                              children: [
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: widget.isSmallSize ? 2 : 4, horizontal: 8),
                                    child: Text(
                                        widget.defaultLabel,
                                        style: CoreUiTextDimensions.s16h20w500l0.copyWith(color: labelColorFinal),
                                        overflow: widget.labelOverFlow
                                    )
                                ),
                                LoadingIndicator(size: centerWidgetSize)
                              ],
                            ),
                          ),
                          if (widget.iconPosition == IconPosition.right || widget.iconPosition == IconPosition.end)
                            icon,
                          if (widget.iconPosition == IconPosition.start)
                            Opacity(opacity: 0, child: icon)
                        ],
                      )
                  )
              );
            }
        )
    );
  }

  static const _defaultLabelColor = Colors.white;
  static const _defaultBackgroundColor = ColorsLib.primary2950;
}
