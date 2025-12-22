import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swin/constants/assets_path.dart';
import 'package:swin/ui/screens/more/view_paper_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
                            style: TextDimensions.titleBold20
                                .copyWith(color: ColorsLib.primary2950),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "WoodSwin là ứng dụng nhận diện gỗ thông minh, sử dụng mô hình học sâu FA-Net "
                                "để phân tích đặc trưng vân gỗ và cấu trúc bề mặt từ hình ảnh.\n "
                                "Ứng dụng hỗ trợ xác định chủng loại gỗ nhanh chóng, chính xác, "
                                "giúp người dùng tra cứu, kiểm định và hỗ trợ ra quyết định hiệu quả trong thực tế.",
                            style: TextDimensions.body15
                                .copyWith(color: ColorsLib.primary2950),
                          ),
                        ],

                      ),
                    ),
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: MoreItem(
                            title: "Tìm hiểu thêm",
                            iconPath: AssetsPath.iconFeedback,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ViewPaperScreen())
                            ),
                          ),
                        ),
                        Expanded(
                          child: MoreItem(
                            title: "Liên hệ",
                            iconPath: AssetsPath.iconSupport,
                            onTap: () => showContactDialog(context),
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

  void showContactDialog(BuildContext context) {
    final contacts = [
      ContactInfo(
        name: "Huy Tran",
        tag: "@huytran",
        avatarUrl: AssetsPath.imgSwinChop,
        contactUrl: "https://www.facebook.com/hoanganhvu03",
      ),
      ContactInfo(
        name: "Hoang Anh Vu",
        tag: "@hoanganhvu271",
        avatarUrl: AssetsPath.imgSwinChop,
        contactUrl: "mailto:VuHA.B21CN795@stu.ptit.edu.vn",
      ),
    ];

    showModalBottomSheet(
      useRootNavigator: true,
      isDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        context: context,
        builder: (_)
    {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Text(
              "Liên hệ hỗ trợ",
              style: TextDimensions.titleBold22
                  .copyWith(color: ColorsLib.primary2950),
            ),
            ...contacts.map((contact) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _launchUrl(contact.contactUrl),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage(contact.avatarUrl),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: TextDimensions.bodyBold15
                              .copyWith(color: ColorsLib.primary2950),
                        ),
                        Text(
                          contact.tag,
                          style: TextDimensions.body15
                              .copyWith(color: ColorsLib.primary2500),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )),
            SizedBox(height: 2)
          ],
        ),
      );
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Không thể mở $url';
    }
  }

}

class ContactInfo {
  final String name;
  final String tag;
  final String avatarUrl;
  final String contactUrl;

  ContactInfo({
    required this.name,
    required this.tag,
    required this.avatarUrl,
    required this.contactUrl,
  });
}

class MoreItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback? onTap;

  const MoreItem({
    super.key,
    this.title = '',
    this.iconPath = '',
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(),
      child: Container(
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
      ),
    );
  }
}
