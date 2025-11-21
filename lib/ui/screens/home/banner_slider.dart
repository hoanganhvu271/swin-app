import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swin/constants/colors_lib.dart';

class BannerSlider extends StatefulWidget {
  final List<Widget> items; // 👈 đổi từ String sang Widget

  const BannerSlider({
    super.key,
    required this.items,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Slider
        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: widget.items.length,
          itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: () {
                debugPrint("Tapped banner $index");
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.items[index],
              ),
            );
          },
          options: CarouselOptions(
            height: 200,
            viewportFraction: 1,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 8),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            pauseAutoPlayOnTouch: true,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),

        const SizedBox(height: 12),

        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.items.asMap().entries.map((entry) {
            final idx = entry.key;
            return GestureDetector(
              onTap: () => _controller.animateToPage(idx),
              child: Container(
                width: _current == idx ? 12.0 : 8.0,
                height: _current == idx ? 12.0 : 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == idx
                      ? ColorsLib.greenMain
                      : Colors.grey[400],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
