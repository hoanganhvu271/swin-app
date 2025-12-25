// performance/device_info.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<Map<String, dynamic>> getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return {
      'platform': 'android',
      'brand': androidInfo.brand,
      'model': androidInfo.model,
      'device': androidInfo.device,
      'product': androidInfo.product,
      'hardware': androidInfo.hardware,
      'sdk_version': androidInfo.version.sdkInt,
      'os_version': androidInfo.version.release,
      'cpu_cores': Platform.numberOfProcessors,
    };
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return {
      'platform': 'ios',
      'name': iosInfo.name,
      'model': iosInfo.model,
      'system_name': iosInfo.systemName,
      'system_version': iosInfo.systemVersion,
      'utsname': iosInfo.utsname.machine,
      'cpu_cores': Platform.numberOfProcessors,
    };
  }

  return {'platform': 'unknown'};
}

Future<String> getDeviceInfoString() async {
  final info = await getDeviceInfo();
  if (Platform.isAndroid) {
    return '${info['brand']} ${info['model']} (Android ${info['os_version']})';
  } else if (Platform.isIOS) {
    return '${info['name']} ${info['model']} (iOS ${info['system_version']})';
  }
  return 'Unknown Device';
}