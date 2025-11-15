import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swin/constants/text_dimensions.dart';
import 'package:swin/ui/widgets/shared/button_filled.dart';

import '../../../constants/assets_path.dart';
import '../../../constants/colors_lib.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/generated/app_localizations_vi.dart';
import '../uvc/uvc_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                localizations.home,
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
                  ButtonFilled(defaultLabel: "UVC Camera", onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => UvcScreen())
                    ))
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
