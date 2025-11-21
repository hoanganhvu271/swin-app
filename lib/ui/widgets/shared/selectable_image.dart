import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../blocs/prediction/prediction_bloc.dart';

class SelectableImage extends StatefulWidget {
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const SelectableImage({
    super.key,
    this.size = 200,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
  });

  @override
  State<SelectableImage> createState() => _SelectableImageState();
}

class _SelectableImageState extends State<SelectableImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  File? _prevImage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnim = Tween(begin: 0.97, end: 1.0).animate(_fadeAnim);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final imageFile = File(file.path);

    context.read<PredictionBloc>().add(
      PredictionInputChanged(imageFile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: BlocConsumer<PredictionBloc, PredictionState>(
        listenWhen: (prev, next) => prev.input != next.input,
        listener: (context, state) {
          // Khi ảnh thay đổi → chạy animation
          if (state.input != null && state.input != _prevImage) {
            _controller.forward(from: 0);
            _prevImage = state.input;
          }
        },
        builder: (context, state) {
          final image = state.input;
          final isShowingImage = image != null;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: isShowingImage ? _scaleAnim.value : 1.0,
                child: Opacity(
                  opacity: isShowingImage ? _fadeAnim.value : 1.0,
                  child: child,
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Container(
                width: widget.size,
                height: widget.size,
                color: Colors.grey.shade200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (image != null)
                      Image.file(image, fit: widget.fit),

                    if (image == null)
                      Center(
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          size: widget.size * 0.3,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
