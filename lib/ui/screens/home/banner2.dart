import 'package:flutter/material.dart';
import 'package:swin/constants/assets_path.dart';
import 'package:swin/constants/text_dimensions.dart';

class Banner2 extends StatelessWidget {
  const Banner2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Color(0xFF203603),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Phòng chống buôn lậu gỗ",
                  style: TextDimensions.titleBold22.copyWith(color: Color(0xFF27BC16)),
                ),
                SizedBox(height: 16),
                Text(
                  "Sử dụng trí tuệ nhân tạo",
                  style: TextDimensions.body15.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Image.asset(AssetsPath.imgWoodBanner, height: 200,)
        ],
      ),
    );
  }
}
