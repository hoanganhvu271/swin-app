import 'package:flutter/material.dart';

import '../../../constants/colors_lib.dart';
import '../../../constants/text_dimensions.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/generated/app_localizations_vi.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context) ?? AppLocalizationsVi();

    return Material(
      color: ColorsLib.primary2050,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                localizations.history,
                style: TextDimensions.titleBold28.copyWith(color: ColorsLib.primary2950),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  spacing: 16,
                  children: [
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
