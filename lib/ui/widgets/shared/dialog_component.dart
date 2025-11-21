import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/assets_path.dart';
import '../../../constants/colors_lib.dart';
import '../../../constants/core_ui_text_dimensions.dart';
import 'button_filled.dart';


enum DialogType {
  /// Dialog mặc định.
  normal,

  /// Dialog cảnh báo.
  warning,

  /// Dialog lỗi.
  error
}

/// `DialogComponent` là widget thể hiện một hộp thoại (popup dialog).
///
/// Ví dụ:
/// ```dart
/// showDialog(context: context, builder: (context) =>
///   DialogComponent(
///     type: PopupType.error,
///     title: "Title",
///     widgetContent: Container(color: Colors.amber[600], height: 900),
///     buttonLabel: "Button label",
///     subButtonLabel: "Sub button",
///    )
///  );
/// ```
///
class DialogComponent extends StatelessWidget {
  /// Loại dialog.
  final DialogType type;

  /// Tiêu đề của dialog.
  final String title;

  /// Phần nội dung của dialog.
  final Widget widgetContent;

  /// Độ bo tròn của dialog.
  final double borderRadius;

  /// Cho phép đóng dialog bằng nút "back" trên thiết bị hay không.
  final bool canPopByBackButton;

  /// Tên button chính.
  final String buttonLabel;

  /// Màu nền button chính.
  ///
  /// Mặc đinh: `Colors.white`.
  final Color? buttonBackgroundColor;

  /// Màu label của button chính.
  ///
  /// Mặc định: .
  final Color? buttonLabelColor;

  /// Gọi khi nhấn button chính.
  final Function()? buttonOnTap;

  /// Tên button phụ.
  final String subButtonLabel;

  /// Màu nền button phụ.
  ///
  /// Mặc định: `ColorsLib.primary2100`
  final Color? subButtonBackgroundColor;

  /// Màu label của button phụ.
  ///
  /// Mặc định: `ColorsLib.primary2800`
  final Color? subButtonLabelColor;

  /// Gọi khi nhấn button phụ.
  final Function()? subButtonOnTap;

  /// Kích thước icon đóng.
  final double closeIconSize;

  /// Khởi tạo widget [DialogComponent].
  ///
  /// Tùy chỉnh kiểu dialog dựa vào [DialogType].
  ///
  /// Mặc định dialog sẽ có một button chính với [buttonLabel] là bắt buộc.
  ///
  /// Có thể hiển thị thêm một button phụ (nằm bên trái)
  /// bằng cách truyền [subButtonLabel] khác rỗng.
  ///
  const DialogComponent({
    super.key,
    this.type = DialogType.normal,
    required this.title,
    required this.widgetContent,
    this.borderRadius = 24,
    this.canPopByBackButton = true,
    required this.buttonLabel,
    this.buttonBackgroundColor,
    this.buttonLabelColor,
    this.buttonOnTap,
    this.subButtonLabel = "",
    this.subButtonBackgroundColor = ColorsLib.primary2100,
    this.subButtonLabelColor = ColorsLib.primary2800,
    this.subButtonOnTap,
    this.closeIconSize = 32
  });

  @override
  Widget build(BuildContext context) {
    bool hasSubButton = subButtonLabel.isNotEmpty;
    Color mainButtonBackgroundColor = buttonBackgroundColor ?? (hasSubButton ? ColorsLib.primary2950 : ColorsLib.primary2100);
    Color mainButtonLabelColor = buttonLabelColor ?? (hasSubButton ? Colors.white : ColorsLib.primary2800);

    Color topBorderColor = Colors.white;
    double topBorderHeight = 4;
    if (type == DialogType.normal) {
      topBorderHeight = 0;
    } else if (type == DialogType.error) {
      topBorderColor = ColorsLib.red600;
    } else if (type == DialogType.warning) {
      topBorderColor = ColorsLib.yellow400;
    }

    final buttons = [
      if (hasSubButton) ...{
        Expanded(
          child: ButtonFilled(
            defaultLabel: subButtonLabel,
            backgroundColor: subButtonBackgroundColor,
            labelColor: subButtonLabelColor,
            isSmallSize: true,
            onTap: () async {
              if (subButtonOnTap != null) {
                await subButtonOnTap!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        const SizedBox(width: 12),
      },
      Expanded(
        child: ButtonFilled(
          defaultLabel: buttonLabel,
          backgroundColor: mainButtonBackgroundColor,
          labelColor: mainButtonLabelColor,
          isSmallSize: true,
          onTap: () async {
            if (buttonOnTap != null) {
              await buttonOnTap!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      )
    ];

    return Dialog(
      insetPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: PopScope(
        canPop: canPopByBackButton,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: Colors.white,
                border: Border(top: BorderSide(width: 4, color: topBorderColor))
              ),
              padding: const EdgeInsets.all(16).subtract(EdgeInsets.only(top: topBorderHeight)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Builder(
                      builder: (context) {
                        Widget icon = const SizedBox.shrink();
                        Color color = switch (type) {
                          DialogType.normal => ColorsLib.primary2800,
                          DialogType.warning => ColorsLib.yellow600,
                          DialogType.error => ColorsLib.red600,
                        };

                        return Row(
                          children: [
                            icon,
                            Expanded(
                              child: Text(
                                title,
                                style: CoreUiTextDimensions.s22h26w700l0.copyWith(color: color)
                              )
                            ),
                            const SizedBox(width: 64)
                          ],
                        );
                      }
                    ),
                    widgetContent,
                    Stack(
                      children: [
                        Visibility(
                          visible: false,
                          maintainSize: true,
                          maintainState: true,
                          maintainAnimation: true,
                          child: Row(children: buttons),
                        ),
                        Positioned.fill(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: buttons
                          )
                        )
                      ]
                    )
                  ]
                )
              )
            )
          ],
        ),
      )
    );
  }
}
