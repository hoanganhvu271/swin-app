import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swin/constants/assets_path.dart';
import 'package:swin/ui/screens/prediction/result_screen.dart';

import '../../../constants/base_status.dart';
import '../../../constants/colors_lib.dart';
import '../../../constants/text_dimensions.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/generated/app_localizations_vi.dart';
import '../../blocs/history/history_bloc.dart';
import '../../blocs/history/history_event.dart';
import '../../blocs/history/history_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizationsVi();

    return BlocProvider(
      create: (_) => HistoryBloc()..add(LoadHistory()),
      child: Material(
        color: ColorsLib.primary2050,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Text(
                  localizations.history,
                  style: TextDimensions.titleBold28.copyWith(
                    color: ColorsLib.primary2950,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: BlocBuilder<HistoryBloc, HistoryState>(
                    builder: (context, state) {
                      if (state.status == BaseStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.status == BaseStatus.failure) {
                        return Center(child: Text('Lỗi khi load lịch sử'));
                      }

                      if (state.history.isEmpty) {
                        return Center(child: Text('Chưa có lịch sử'));
                      }

                      return Column(
                      children:
                        state.history.map((item) {
                          final prediction = item.result.isNotEmpty ? item.result[0] : null;

                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ResultScreen(
                                image: File(item.imgPath),
                                predictions: item.result
                              ))
                            ),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(item.imgPath),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.image_not_supported,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Prediction info
                                    Expanded(
                                      child:
                                          prediction != null
                                              ? Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    prediction.label,
                                                    style: TextDimensions.bodyBold15,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${localizations.confidence}: ${(prediction.confidence * 100).toStringAsFixed(2)}%',
                                                    style: TextDimensions.footnote13.copyWith(color: Colors.grey[700]),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(item.timestamp, style: TextDimensions.footnote13.copyWith(color: Colors.grey[700])),
                                                ],
                                              )
                                              : Text('Không có prediction', style: TextDimensions.footnote13),
                                    ),
                                    InkWell(
                                      onTap: () {},
                                      child: SvgPicture.asset(AssetsPath.iconDelete, width: 24, height: 24)
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
