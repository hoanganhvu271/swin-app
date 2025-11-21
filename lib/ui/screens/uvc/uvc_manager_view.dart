import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swin/constants/colors_lib.dart';
import 'package:swin/ui/blocs/prediction/prediction_bloc.dart';
import 'package:swin/ui/widgets/shared/button_filled.dart';
import 'package:swin/ui/widgets/shared/dialog_component.dart';
import 'package:uvc_manager/uvc_manager.dart';
import 'package:path/path.dart' as p;

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
  State<StatefulWidget> createState() => _UVCManagerViewState();
}

class _UVCManagerViewState extends State<UVCManagerView> {
  late VoidCallback _listener;
  int _deviceCount = 0;
  int _deviceId = 0;

  _UVCManagerViewState() {
    _deviceCount = 0;
    _listener = () {
      final int newDeviceCount = UVCManagerPlatform.instance.getAvailableCount();
      final connected = (newDeviceCount > 0);
      keepScreenOn(connected);

      if (_deviceCount != newDeviceCount) {
        setState(() {
          _deviceCount = newDeviceCount;
          _deviceId = connected ? UVCManagerPlatform.instance.getControllerAt(0).deviceId : 0;
        });
      }
    };
  }

  @override
  void initState() {
    super.initState();
    UVCManagerPlatform.instance.addListener(_listener);
  }

  @override
  void dispose() {
    UVCManagerPlatform.instance.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoViewKey = GlobalObjectKey<UVCVideoViewState>(context);

    if (_deviceId == 0) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: widget.noDeviceMessage ??
            const Text(
              "No device connected",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
      );
    }

    return Stack(
      children: [
        // Video container
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.symmetric(vertical: BorderSide(color: Colors.white, width: 2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: UVCVideoView(
              key: videoViewKey,
              deviceId: _deviceId,
              frameType: widget.frameType,
              videoWidth: widget.videoWidth,
              videoHeight: widget.videoHeight,
              waitingMessage: widget.waitingMessage,
            ),
          ),
        ),
        // Controls overlay
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: UVCCtrlView(
            deviceId: _deviceId,
            onSelected: (size) {
              if (size != null) {
                videoViewKey.currentState?.setSize(size);
              }
            },
          ),
        ),
      ],
    );
  }
}

class UVCCtrlView extends StatefulWidget {
  final int deviceId;
  final ValueChanged<VideoSize?>? onSelected;

  const UVCCtrlView({
    super.key,
    required this.deviceId,
    required this.onSelected,
  });

  @override
  State<StatefulWidget> createState() => _UVCCtrlViewState();
}

class _UVCCtrlViewState extends State<UVCCtrlView> {
  late UVCControllerInterface _controller;
  List<VideoSize> _supportedSize = <VideoSize>[];

  @override
  void initState() {
    super.initState();
    _controller = UVCManagerPlatform.instance.getController(widget.deviceId);
    _controller.getSupportedSize().then(
          (supported) => setState(() {
        _supportedSize = supported;
      }),
    );
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_supportedSize.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DropdownMenu<VideoSize>(
                label: const Text(
                  'Supported video size',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                width: double.infinity,
                menuHeight: 150,
                menuStyle: MenuStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
                textStyle: const TextStyle(color: Colors.white, fontSize: 14),
                onSelected: (VideoSize? size) {
                  if (size != null) widget.onSelected?.call(size);
                },
                dropdownMenuEntries: _supportedSize.map((size) {
                  return DropdownMenuEntry<VideoSize>(
                      value: size,
                      label: size.toShortString(),
                      style: ButtonStyle(textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)))
                  );
                }).toList(),
              ),
            ),
          ButtonFilled(
            defaultLabel: "Capture",
            onTap: () => onCapturePressed(_controller),
            backgroundColor: ColorsLib.greenMain,
          ),
        ],
      ),
    );
  }

  void onCapturePressed(UVCControllerInterface controller) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return;

      final filePath = p.join(
        directory.path,
        "uvc_capture_tmp.jpg",
      );

      final saved = await controller.capture(filePath);

      showDialog(
        context: context,
        builder: (ctx) => DialogComponent(
            title: "Captured Image",
            widgetContent: Image.file(File(saved), fit: BoxFit.contain),
            buttonLabel: "Pick",
            subButtonLabel: "Close",
            buttonOnTap: () {
              context.read<PredictionBloc>().add(PredictionInputChanged(File(saved)));
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            subButtonOnTap: () => Navigator.of(ctx).pop(),
        )
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Capture Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    // _controller.stop();
    super.dispose();
  }
}
