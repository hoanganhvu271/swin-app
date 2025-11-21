// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'WoodSwin';

  @override
  String get app_name_subtitle => 'Identify wood species with AI';

  @override
  String get home => 'Home';

  @override
  String get library => 'Library';

  @override
  String get history => 'History';

  @override
  String get more => 'More';

  @override
  String get details => 'Details';

  @override
  String get predictions => 'Predictions';

  @override
  String get settings => 'Settings';

  @override
  String get connect_camera => 'Connect to UVC camera';

  @override
  String get select_model => 'Select model';

  @override
  String get select_model_description => 'Choose an AI model to identify wood species';

  @override
  String get classify => 'Classify';

  @override
  String get current_model => 'Current Model';

  @override
  String get or_use_uvc_camera => 'Or use UVC camera';

  @override
  String get confidence => 'Confidence';
}
