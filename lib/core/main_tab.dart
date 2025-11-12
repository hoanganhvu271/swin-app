import 'package:flutter/cupertino.dart';

import '../constants/assets_path.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/generated/app_localizations_vi.dart';

enum MainTab {
  home, library, history, more;

  get imagePath => switch (this) {
    MainTab.home => AssetsPath.iconHome,
    MainTab.library => AssetsPath.iconLibrary,
    MainTab.history => AssetsPath.iconHistory,
    MainTab.more => AssetsPath.iconMenu,
  };

  String getLabel(BuildContext context) {
    final localization = AppLocalizations.of(context) ?? AppLocalizationsVi();

    return switch (this) {
      MainTab.home => localization.home,
      MainTab.library => localization.library,
      MainTab.history => localization.history,
      MainTab.more => localization.more,
    };
  }
}
