import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/ui/blocs/prediction/prediction_bloc.dart';
import 'package:swin/ui/blocs/wood_detail/wood_detail_bloc.dart';
import 'package:swin/ui/screens/prediction/result_detail_screen.dart';
import 'package:swin/ui/widgets/shared/swin_top_bar.dart';

import '../../../constants/colors_lib.dart';
import '../../../models/prediction_result.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final List<PredictionResult> predictions;

  const ResultScreen({super.key, required this.image, required this.predictions});

  @override
  Widget build(BuildContext context) {
    final displayList = predictions.take(5).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SwinTopBar(title: "Kết quả dự đoán"),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    image,
                    width: double.infinity,
                    height: 200, // nhỏ hơn
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final prediction = displayList[index];
                    return PredictionItem(
                      prediction: prediction,
                      isBest: index == 0,
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BlocProvider(
                                create: (_) => WoodDetailBloc(),
                                child: ResultDetailScreen(image: image, result: prediction)
                            ))
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}

class PredictionItem extends StatefulWidget {
  final bool isBest;
  final PredictionResult prediction;
  final VoidCallback? onTap;

  const PredictionItem({super.key, this.isBest = false, required this.prediction, this.onTap});

  @override
  State<PredictionItem> createState() => _PredictionItemState();
}

class _PredictionItemState extends State<PredictionItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isBest) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat();
    }
  }

  @override
  void dispose() {
    if (widget.isBest) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseContainer = Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              widget.prediction.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.isBest ? ColorsLib.greenMain : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${(widget.prediction.confidence * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isBest ? ColorsLib.greenMain : Colors.blueAccent,
            ),
          ),
        ],
      ),
    );

    if (!widget.isBest) {
      return InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: baseContainer,
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final gradient = SweepGradient(
          colors: [
            ColorsLib.greenMain,
            ColorsLib.greenMain.withOpacity(0.7),
            ColorsLib.greenMain.withOpacity(0.4),
            ColorsLib.greenMain.withOpacity(0.2),
            ColorsLib.greenMain.withOpacity(0.1),
            ColorsLib.greenMain.withOpacity(0.0),
            ColorsLib.greenMain.withOpacity(0.1),
            ColorsLib.greenMain.withOpacity(0.2),
            ColorsLib.greenMain.withOpacity(0.4),
            ColorsLib.greenMain.withOpacity(0.7),
            ColorsLib.greenMain,
          ],
          stops: [
            0.0,
            0.05,
            0.10,
            0.15,
            0.20,
            0.25,
            0.30,
            0.35,
            0.40,
            0.45,
            0.5
          ], // dải màu dài, mượt, không gap
          transform: GradientRotation(_controller.value * 2 * 3.1416),
        );

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            child: baseContainer,
          ),
        );
      },
    );
  }
}


