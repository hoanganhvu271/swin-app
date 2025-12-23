import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uvc_manager/uvc_manager.dart';

import 'package:swin/constants/colors_lib.dart';
import 'package:swin/ui/blocs/prediction/prediction_bloc.dart';
import 'package:swin/ui/widgets/shared/button_filled.dart';
import 'package:swin/ui/widgets/shared/dialog_component.dart';

class UVCManagerView extends StatefulWidget {
  final int frameType;
  final int videoWidth;
  final int videoHeight;
  final Widget? noDeviceMessage;
  final Widget? waitingMessage;

  const UVCManagerView({
    super.key,
    this.frameType = 7,
    this.videoWidth = 640,
    this.videoHeight = 480,
    this.noDeviceMessage,
    this.waitingMessage,
  });

  @override
  State<UVCManagerView> createState() => _UVCManagerViewState();
}

class _UVCManagerViewState extends State<UVCManagerView> {
  late VoidCallback _listener;

  UVCControllerInterface? _controller;

  int _deviceId = 0;
  int _deviceCount = 0;

  bool _cameraReady = false;
  int _videoKeySeed = 0;

  @override
  void initState() {
    super.initState();

    _listener = _onDeviceChanged;
    UVCManagerPlatform.instance.addListener(_listener);

    _onDeviceChanged(); // init ngay nếu đã cắm cam
  }

  void _onDeviceChanged() {
    if (!mounted) return;

    final newCount = UVCManagerPlatform.instance.getAvailableCount();
    final connected = newCount > 0;

    keepScreenOn(connected);

    if (newCount == _deviceCount) return;

    if (connected) {
      _initCamera();
    } else {
      _disposeCamera();
    }

    setState(() {
      _deviceCount = newCount;
    });
  }

  void _initCamera() {
    try {
      final ctrl = UVCManagerPlatform.instance.getControllerAt(0);
      _deviceId = ctrl.deviceId;
      _controller = UVCManagerPlatform.instance.getController(_deviceId);

      _cameraReady = true;
      _videoKeySeed++; // force recreate texture

      debugPrint('UVC camera init: deviceId=$_deviceId');
    } catch (e) {
      debugPrint('UVC init error: $e');
      _cameraReady = false;
    }
  }

  void _disposeCamera() {
    try {
      if (_cameraReady && _controller != null) {
        _controller!.stop();
        _controller!.releaseTexture();
      }
    } catch (e) {
      debugPrint('UVC dispose error: $e');
    }

    _controller = null;
    _deviceId = 0;
    _cameraReady = false;
    _videoKeySeed++;

    debugPrint('UVC camera disposed');
  }

  @override
  void dispose() {
    UVCManagerPlatform.instance.removeListener(_listener);
    _disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraReady || _deviceId == 0) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: widget.noDeviceMessage ??
            const Text(
              'No device connected',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
      );
    }

    return Stack(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: const Border.symmetric(
                vertical: BorderSide(color: Colors.white, width: 2),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: UVCVideoView(
              key: ValueKey('uvc_video_$_videoKeySeed'),
              deviceId: _deviceId,
              frameType: widget.frameType,
              videoWidth: widget.videoWidth,
              videoHeight: widget.videoHeight,
              waitingMessage: widget.waitingMessage,
            ),
          ),
        ),

        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: UVCCtrlView(
            controller: _controller!,
            onCameraError: _handleCameraError,
          ),
        ),
      ],
    );
  }

  /// Khi capture fail / camera freeze → reset toàn bộ
  void _handleCameraError(Object error) {
    debugPrint('Camera error: $error');

    _disposeCamera();

    // thử init lại sau 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (UVCManagerPlatform.instance.getAvailableCount() > 0) {
        setState(_initCamera);
      }
    });
  }
}

/* -------------------------------------------------------------------------- */
/*                                  CONTROL                                   */
/* -------------------------------------------------------------------------- */

class UVCCtrlView extends StatefulWidget {
  final UVCControllerInterface controller;
  final ValueChanged<Object> onCameraError;

  const UVCCtrlView({
    super.key,
    required this.controller,
    required this.onCameraError,
  });

  @override
  State<UVCCtrlView> createState() => _UVCCtrlViewState();
}

class _UVCCtrlViewState extends State<UVCCtrlView> {
  List<VideoSize> _supportedSizes = [];

  @override
  void initState() {
    super.initState();

    widget.controller.getSupportedSize().then((sizes) {
      if (!mounted) return;
      setState(() => _supportedSizes = sizes);
    }).catchError(widget.onCameraError);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_supportedSizes.isNotEmpty)
            DropdownMenu<VideoSize>(
              label: const Text(
                'Supported video size',
                style: TextStyle(color: Colors.white),
              ),
              textStyle: const TextStyle(color: Colors.white),
              onSelected: (size) {
                if (size != null) {
                  widget.controller.setSize(size.frameType, size.width, size.height);
                }
              },
              dropdownMenuEntries: _supportedSizes
                  .map(
                    (s) => DropdownMenuEntry(
                  value: s,
                  label: s.toShortString(),
                ),
              )
                  .toList(),
            ),
          const SizedBox(height: 8),
          ButtonFilled(
            defaultLabel: 'Capture',
            backgroundColor: ColorsLib.greenMain,
            onTap: _onCapture,
          ),
        ],
      ),
    );
  }

  Future<void> _onCapture() async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return;

      final path = p.join(dir.path, 'uvc_capture_tmp.jpg');

      final saved = await widget.controller
          .capture(path)
          .timeout(const Duration(seconds: 3));

      if (!mounted) return;

      final imageProvider = FileImage(File(saved));
      await imageProvider.evict();
      showDialog(
        context: context,
        builder: (ctx) => DialogComponent(
          title: 'Captured Image',
          widgetContent: Image.file(File(saved), fit: BoxFit.contain),
          buttonLabel: 'Pick',
          subButtonLabel: 'Close',
          buttonOnTap: () {
            context
                .read<PredictionBloc>()
                .add(PredictionInputChanged(File(saved)));
            Navigator.of(ctx).pop();
            Navigator.of(context).pop();
          },
          subButtonOnTap: () => Navigator.of(ctx).pop(),
        ),
      );
    } catch (e) {
      widget.onCameraError(e);
    }
  }
}
