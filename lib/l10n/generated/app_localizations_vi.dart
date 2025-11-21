// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get app_name => 'WoodSwin';

  @override
  String get app_name_subtitle => 'Nhận diện loài gỗ với AI';

  @override
  String get home => 'Trang chủ';

  @override
  String get library => 'Thư viện';

  @override
  String get history => 'Lịch sử';

  @override
  String get more => 'Mở rộng';

  @override
  String get details => 'Chi tiết';

  @override
  String get predictions => 'Dự đoán';

  @override
  String get settings => 'Cài đặt';

  @override
  String get connect_camera => 'Kết nối với uvc camera';

  @override
  String get select_model => 'Chọn mô hình';

  @override
  String get select_model_description => 'Chọn mô hình AI để nhận diện loài gỗ';

  @override
  String get classify => 'Phân loại';

  @override
  String get current_model => 'Mô hình hiện tại';

  @override
  String get or_use_uvc_camera => 'Hoặc sử dụng UVC camera';

  @override
  String get confidence => 'Độ tin cậy';
}
