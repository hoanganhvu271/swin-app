import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swin/constants/assets_path.dart';
import 'package:swin/constants/colors_lib.dart';
import 'package:swin/constants/text_dimensions.dart';

class Banner1 extends StatelessWidget {
  const Banner1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Color(0xFFD5E488),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Chung tay góp phần bảo vệ rừng",
                  style: TextDimensions.titleBold22.copyWith(color: ColorsLib.primary2950),
                ),
                SvgPicture.asset(AssetsPath.iconDeco1, height: 50,)
              ],
            ),
          ),
          SizedBox(width: 16),
          SvgPicture.asset(AssetsPath.iconDeco2, width: 80,)
        ],
      ),
    );
  }
}
