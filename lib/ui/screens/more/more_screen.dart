import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swin/constants/assets_path.dart';

import '../../../constants/colors_lib.dart';
import '../../../constants/text_dimensions.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/generated/app_localizations_vi.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizationsVi();

    return Material(
      color: ColorsLib.primary2050,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                localizations.more,
                style: TextDimensions.titleBold28.copyWith(color: ColorsLib.primary2950),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  spacing: 16,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        spacing: 12,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Về WoodSwin",
                            style: TextDimensions.titleBold20.copyWith(color: ColorsLib.primary2950),
                          ),
                          Text(
                            "WoodSwin là ứng dụng tiên tiến giúp nhận diện nhanh chóng và chính xác các loài gỗ với hình ảnh phóng đại trung bình. Nhờ tích hợp mô hình Swin Transformer, một kiến trúc mạng nơ-ron hiện đại trong lĩnh vực thị giác máy tính, ứng dụng có khả năng phân loại hàng trăm loại gỗ khác nhau dựa trên kết cấu, màu sắc và vân gỗ đặc trưng.",
                            style: TextDimensions.body15.copyWith(color: ColorsLib.primary2950),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: MoreItem(
                            title: "Góp ý sản phẩm",
                            iconPath: AssetsPath.iconFeedback,
                          ),
                        ),
                        Expanded(
                          child: MoreItem(
                            title: "Đánh giá",
                            iconPath: AssetsPath.iconSupport,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MoreItem extends StatelessWidget {
  final String title;
  final String iconPath;

  const MoreItem({
    super.key,
    this.title = '',
    this.iconPath = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, width: 24, height: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              title,
              style: TextDimensions.bodyBold15.copyWith(color: ColorsLib.primary2950),
            ),
          ),
        ],
      ),
    );
  }
}
