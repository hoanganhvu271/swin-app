import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:swin/l10n/generated/app_localizations.dart';
import 'package:swin/l10n/generated/app_localizations_vi.dart';
import 'package:swin/models/wood_piece.dart';
import '../../widgets/shared/swin_top_bar.dart';

class WoodDetailScreen extends StatelessWidget {
  final WoodPiece piece;

  const WoodDetailScreen({super.key, required this.piece});

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
                title: localization.details,
                iconRightPath: "assets/icons/icon_setting.svg",
                iconRightOnTap: () {},
              ),
              Expanded(
                child: ListView(
                  children: [
                    Html(data: piece.description)
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
