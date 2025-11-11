import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swin/constants/colors_lib.dart';
import 'package:swin/constants/text_dimensions.dart';
import 'package:swin/ui/blocs/prediction/prediction_bloc.dart';
import 'package:swin/ui/widgets/shared/button_filled.dart';

import '../../widgets/shared/disable_widget.dart';
import '../../widgets/shared/swin_top_bar.dart';

class ModelListScreen extends StatefulWidget {
  const ModelListScreen({super.key});

  @override
  State<ModelListScreen> createState() => _ModelListScreenState();
}

class _ModelListScreenState extends State<ModelListScreen> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    context.read<PredictionBloc>().add(PredictionModelListFetched());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Material(
        color: ColorsLib.primary2050,
        child: SafeArea(
          child: BlocBuilder<PredictionBloc, PredictionState>(
            builder: (context, state) {
              return Scaffold(
                backgroundColor: ColorsLib.primary2050,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwinTopBar(
                      title: "Model and Dataset",
                      iconRightPath: "assets/icons/icon_setting.svg",
                      iconRightOnTap: () {},
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.separated(
                          itemCount: state.models.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final model = state.models[index];
                            final isSelected = selectedIndex == index;
                            return DisableWidget(
                              disable: !model.isDownloaded,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setState(() => selectedIndex = index);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected ? ColorsLib.greenMain : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: isSelected ? ColorsLib.greenMain.withOpacity(0.05) : Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                        value: index,
                                        groupValue: selectedIndex,
                                        activeColor: ColorsLib.greenMain,
                                        onChanged: (val) {
                                          setState(() => selectedIndex = val);
                                        },
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              model.dataset,
                                              style: TextDimensions.bodyBold15
                                                  .copyWith(color: Colors.black),
                                            ),
                                            Text(
                                              "Model: ${model.name}",
                                              style: TextDimensions.footnote13
                                                  .copyWith(
                                                color: Colors.black54,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    InkWell(
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (_) {
                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                            insetPadding: const EdgeInsets.all(24), // khoảng cách so với viền màn hình
                                            child: Padding(
                                              padding: const EdgeInsets.all(30),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min, // chỉ vừa đủ nội dung
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    model.name,
                                                    style: TextDimensions.titleBold22,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "Dataset: ${model.dataset}",
                                                    style: TextDimensions.body17,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    model.description,
                                                    style: TextDimensions.body15.copyWith(color: Colors.black87),
                                                  ),
                                                  const SizedBox(height: 40),
                                                  Align(
                                                    alignment: Alignment.centerRight,
                                                    child: ButtonFilled(
                                                      defaultLabel: "Close",
                                                      backgroundColor: ColorsLib.greenMain,
                                                      onTap: () => Navigator.of(context).pop(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: model.isDownloaded
                                            ? SvgPicture.asset("assets/icons/icon_info.svg", width: 24, height: 24)
                                            : SvgPicture.asset("assets/icons/icon_download.svg", width: 24, height: 24),
                                      ),
                                    )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: ButtonFilled(
                    defaultLabel: "Choose",
                    backgroundColor: ColorsLib.greenMain,
                    isDisable: selectedIndex == null,
                    onTap: () {
                      if (selectedIndex != null) {
                        final selectedModel = state.models[selectedIndex!];
                        Navigator.of(context).pop();
                        context.read<PredictionBloc>().add(PredictionModelLoaded(selectedModel));
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
