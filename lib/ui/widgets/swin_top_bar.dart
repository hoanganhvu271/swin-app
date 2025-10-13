import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/colors_lib.dart';
import '../../constants/text_dimensions.dart';

class SwinTopBar extends StatelessWidget {
  final String title;
  final String? iconRightPath;
  final VoidCallback? iconRightOnTap;
  final VoidCallback? onBack;

  const SwinTopBar({
    super.key,
    this.title = "",
    this.iconRightPath,
    this.iconRightOnTap,
    this.onBack
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: kToolbarHeight),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 8,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    color: Colors.black.withValues(alpha: 0.1)
                )
              ],
            ),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onBack ?? () => Navigator.of(context).pop(),
                child: Container(
                  width: 40, height: 40,
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    "assets/icons/icon_arrow_left.svg",
                    width: 24, height: 24,
                    alignment: Alignment.center,
                    colorFilter: const ColorFilter.mode(ColorsLib.primary2800, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              child: Text(
                title,
                style: TextDimensions.headline17.copyWith(color: ColorsLib.primary2800),
                textAlign: TextAlign.center,
              )
          ),
          if (iconRightPath != null)
            DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Material(
                color: ColorsLib.primary2050,
                borderRadius: BorderRadius.circular(100),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => iconRightOnTap?.call(),
                  child: Container(
                    width: 40, height: 40,
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      iconRightPath!,
                      width: 24, height: 24,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 40, width: 40)
        ],
      ),
    );
  }
}
