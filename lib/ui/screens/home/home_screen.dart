import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swin/constants/text_dimensions.dart';
import 'package:swin/ui/screens/prediction/prediction_screen.dart';
import 'package:swin/ui/widgets/shared/button_filled.dart';

import '../../../constants/assets_path.dart';
import '../../../constants/colors_lib.dart';
import '../../../core/main_tab.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/generated/app_localizations_vi.dart';
import '../main/bottom_navigation.dart';
import '../uvc/uvc_screen.dart';
import 'banner1.dart';
import 'banner2.dart';
import 'banner_slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizationsVi();

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(AssetsPath.iconLogo, height: 70, width: 70,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localizations.app_name, style: TextDimensions.titleBold22.copyWith(color: Colors.black)),
                      Text(localizations.app_name_subtitle, style: TextDimensions.footnote13.copyWith(color: Colors.black))
                    ],
                  ),
                ],
              )
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  spacing: 40,
                  children: [
                    BannerSlider(
                      items: [
                        Banner1(),
                        Banner2()
                      ],
                    ),
                    Row(
                      spacing: 20,
                      children: [
                        Image.asset(AssetsPath.imgBook, width: 100, height: 100),
                        Expanded(
                          child: Column(
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  Text(
                                    "Thư viện loài gỗ",
                                    style: TextDimensions.titleBold20.copyWith(color: ColorsLib.primary2950),
                                  ),
                                  SvgPicture.asset(AssetsPath.iconNext, width: 24, height: 24)
                                ],
                              ),
                              Text("Khám phá, tìm hiểu về các loài gỗ phổ biến tại Việt Nam và thế giới"),
                            ],
                          ),
                        )
                      ],
                    ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PredictionScreen())
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.asset(
                          AssetsPath.imgForestMask,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            color: Colors.black.withOpacity(1), // có thể điều chỉnh opacity
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dự đoán loài gỗ",
                                style: TextDimensions.titleBold22.copyWith(color: Colors.white),
                              ),
                              Text(
                                "Sử dụng mô hình FA Net với YOLOv11",
                                style: TextDimensions.footnote13.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ButtonFilled(
                  defaultLabel: "Kết nối với uvc camera",
                  backgroundColor: ColorsLib.greenMain,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => UvcScreen())
                  )
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

