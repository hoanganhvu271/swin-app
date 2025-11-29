import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swin/constants/base_status.dart';
import 'package:swin/constants/colors_lib.dart';
import 'package:swin/l10n/generated/app_localizations.dart';
import 'package:swin/l10n/generated/app_localizations_vi.dart';
import 'package:swin/ui/blocs/wood_detail/wood_detail_bloc.dart';
import 'package:swin/ui/blocs/wood_detail/wood_detail_event.dart';
import 'package:swin/ui/blocs/wood_detail/wood_detail_state.dart';
import '../../../constants/text_dimensions.dart';
import '../../../models/prediction_result.dart';
import '../../widgets/shared/swin_top_bar.dart';

class ResultDetailScreen extends StatefulWidget {
  final File image;
  final PredictionResult result;

  const ResultDetailScreen({super.key, required this.image, required this.result});

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    context.read<WoodDetailBloc>().add(GetWoodById(widget.result.index));

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(_fadeAnim);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context) ?? AppLocalizationsVi();

    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SwinTopBar(
                title: "Prediction Result",
                iconRightPath: "assets/icons/icon_setting.svg",
                iconRightOnTap: () {},
              ),
              const SizedBox(height: 12),

              /// Card chứa ảnh và thông tin dự đoán
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnim.value,
                    child: Opacity(
                      opacity: _fadeAnim.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade50,
                        Colors.white,
                        Colors.green.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          widget.image,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.result.label,
                              style: TextDimensions.bodyBold15.copyWith(color: Colors.black, fontSize: 17),
                            ),
                            Row(
                              spacing: 4,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/icon_checked.svg",
                                  width: 16, height: 16,
                                  colorFilter: ColorFilter.mode(ColorsLib.greenMain, BlendMode.srcIn),
                                ),
                                Flexible(
                                  child: Text(
                                    "${localization.confidence}: ${(widget.result.confidence * 100).toStringAsFixed(1)}",
                                    style: TextDimensions.footnote13.copyWith(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    BlocBuilder<WoodDetailBloc, WoodDetailState>(
                      builder: (context, state) {
                        if (state.status == BaseStatus.loading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state.status == BaseStatus.failure) {
                          return Center(child: Text("Error: ${state.error}"));
                        }
                        return Html(data: state.woodPiece?.description ?? "");
                      }
                    )
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
