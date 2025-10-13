import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:swin/ui/blocs/prediction_bloc.dart';
import 'package:swin/ui/screens/result_screen.dart';

import '../../constants/base_status.dart';
import '../../constants/text_dimensions.dart';

class LoadingPredictionScreen extends StatelessWidget {
  final File image;

  final List<String> leafImagePaths = const [
    "assets/images/img_leaf.png",
    "assets/images/img_leaf_5.png",
    "assets/images/img_leaf_6.png",
    "assets/images/img_leaf_36.png",
    "assets/images/img_leaf_75.png",
  ];

  const LoadingPredictionScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PredictionBloc, PredictionState>(
      listener: (context, state) {
        if (state.status == BaseStatus.success && state.predicted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<PredictionBloc>(),
                child: ResultScreen(image: image)
              ),
            ),
          );
        } else if (state.status == BaseStatus.failure) {

        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Material(
          color: Colors.white,
          child: SafeArea(
            child: Center(
              child: SizedBox(
                width: 400, // 🔹 tăng khung chứa (ảnh 300 + khoảng trôi lá)
                height: 400,
                child: Column(
                  spacing: 50,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // 🔹 Các lá bay quanh ảnh
                        for (int i = 0; i < 20; i++)
                          _AnimatedLeaf(
                            imagePath: leafImagePaths[i % leafImagePaths.length],
                            startAngle: Random().nextDouble() * 2 * pi,
                            radius: 200 + Random().nextDouble() * 80,
                            size: 35 + Random().nextDouble() * 30,
                            duration: Duration(seconds: 4 + Random().nextInt(3)),
                          ),

                        // 🔹 Ảnh trung tâm có shimmer
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: Shimmer(
                            color: Colors.white,
                            colorOpacity: 0.5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Swin is running...",
                      style: TextDimensions.titleBold22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedLeaf extends StatefulWidget {
  final String imagePath;
  final double startAngle;
  final double radius;
  final double size;
  final Duration duration;

  const _AnimatedLeaf({
    required this.imagePath,
    required this.startAngle,
    required this.radius,
    required this.size,
    required this.duration,
  });

  @override
  State<_AnimatedLeaf> createState() => _AnimatedLeafState();
}

class _AnimatedLeafState extends State<_AnimatedLeaf>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _rotationAnim = Tween<double>(
      begin: widget.startAngle,
      end: widget.startAngle + pi / 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnim,
      builder: (context, child) {
        final angle = _rotationAnim.value;
        final radius = widget.radius;
        final center = const Offset(200, 200); // 🔹 Stack center (400x400)
        final offset = Offset(
          cos(angle) * radius,
          sin(angle) * radius,
        );
        return Positioned(
          left: center.dx + offset.dx - widget.size / 2,
          top: center.dy + offset.dy - widget.size / 2,
          child: Transform.rotate(
            angle: angle,
            child: Image.asset(
              widget.imagePath,
              width: widget.size,
              height: widget.size,
              opacity: const AlwaysStoppedAnimation(0.8),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
