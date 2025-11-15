import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swin/ui/screens/uvc/uvc_manager_view.dart';

import 'camera_permission_handler.dart';

class UvcScreen extends StatefulWidget {
  const UvcScreen({super.key});

  @override
  State<StatefulWidget> createState() => _UvcScreenState();
}

class _UvcScreenState extends State<UvcScreen> {
  bool hasCameraPermission = false;

  @override
  void initState() {
    super.initState();
    // XXX ユーザーがカメラパーミッションを拒絶したときは説明画面を表示and端末のアプリ設定へ移動してカメラパーミッションを設定するように促しそれでも拒絶するならアプリを終了させる必要がある
    CameraPermissionsHandler().request().then((status) => setState(() {
      hasCameraPermission = status.isGranted || status.isLimited;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Test UVC Connect'),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(width: 4),
              Expanded(
                  child: hasCameraPermission ? UVCManagerView(
                    videoWidth: 640, videoHeight: 480,
                    noDeviceMessage: Text(
                      "No UVC device",
                      style: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 32.0,
                      ),
                    ),
                    waitingMessage: Text(
                      "UVC device connected",
                      style: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 32.0,
                      ),
                    ),
                  )
                    : Container(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    alignment: Alignment.center,
                    child: Text(
                      "Has no camera permission",
                      style: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 32.0,
                      ),
                    )
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
