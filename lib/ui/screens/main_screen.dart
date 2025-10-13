import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swin/constants/colors_lib.dart';
import 'package:swin/constants/text_dimensions.dart';
import 'package:swin/ui/blocs/prediction_bloc.dart';
import 'package:swin/ui/screens/loading_prediction_screen.dart';
import 'package:swin/ui/screens/model_list_screen.dart';
import 'package:swin/ui/widgets/button_filled.dart';
import 'package:swin/ui/widgets/selectable_image.dart';
import 'package:swin/ui/widgets/swin_top_bar.dart';

import '../../constants/base_status.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PredictionBloc>(
      create: (context) => PredictionBloc(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark
        ),
        child: Material(
          color: Colors.white,
          child: SafeArea(
            child: Builder(
              builder: (context) {
                return Column(
                  children: [
                    SwinTopBar(
                      title: "Safe Forest",
                      iconRightPath: "assets/icons/icon_setting.svg",
                      iconRightOnTap: () {}
                    ),
                    BlocBuilder<PredictionBloc, PredictionState>(
                      builder: (context, state) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                SelectableImage(
                                  onImageSelected: (image) {
                                    context.read<PredictionBloc>().add(PredictionInputChanged(image));
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 30),
                                  child: Divider(height: 0.1, color: Colors.grey),
                                ),
                                ModelInfoWidget(
                                  modelName: state.selectedModel.name,
                                  modelDescription: state.selectedModel.description,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => BlocProvider.value(
                                        value: context.read<PredictionBloc>(),
                                        child: ModelListScreen())
                                      )
                                    );
                                  },
                                ),
                                SizedBox(height: 80),
                                ButtonFilled(
                                  isDisable: state.status == BaseStatus.loading || state.input == null,
                                  defaultLabel: "Classify",
                                  onTap: () {
                                    context.read<PredictionBloc>().add(PredictionRequested());
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<PredictionBloc>(),
                                          child: LoadingPredictionScreen(image: state.input!)
                                        )
                                      )
                                    );
                                  },
                                  backgroundColor: Color(0xFF0B8543)
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset("assets/images/img_tree.png")
                      ),
                    )
                  ],
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}

class ModelInfoWidget extends StatelessWidget {
  final String modelName;
  final String modelDescription;
  final Function()? onTap;

  const ModelInfoWidget({
    super.key,
    required this.modelName,
    required this.modelDescription,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Current Model", style: TextDimensions.footnoteBold13.copyWith(color: ColorsLib.primary2950)),
        InkWell(
          onTap: () => onTap?.call(),
          child: Row(
            spacing: 16,
            children: [
              SvgPicture.asset("assets/icons/icon_robot.svg", width: 32, height: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      modelName,
                      style: TextDimensions.bodyBold15,
                    ),
                    Text(
                      modelDescription,
                      style: TextDimensions.footnote13.copyWith(color: Colors.grey),
                    )
                  ],
                )
              ),
              SvgPicture.asset("assets/icons/icon_expand.svg", width: 32, height: 32),
            ],
          ),
        ),
      ],
    );
  }
}
