import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelectableImage extends StatefulWidget {
  final double size;
  final double borderRadius;
  final BoxFit fit;
  final void Function(File file)? onImageSelected;

  const SelectableImage({
    super.key,
    this.size = 200,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
    this.onImageSelected,
  });

  @override
  State<SelectableImage> createState() => _SelectableImageState();
}

class _SelectableImageState extends State<SelectableImage>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _isLoading = false;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnim = Tween<double>(begin: 0.97, end: 1.0).animate(_fadeAnim);
    _controller.forward();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final file = File(image.path);

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = FileImage(file);
      await precacheImage(provider, context);

      setState(() {
        _selectedImage = file;
        _isLoading = false;
      });

      // Phát lại animation
      _controller.forward(from: 0);

      widget.onImageSelected?.call(file);
    } catch (e) {
      // Xử lý lỗi nếu precacheImage thất bại
      debugPrint('Lỗi khi precacheImage: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final shouldAnimate = _selectedImage != null && !_isLoading;
          return Transform.scale(
            scale: shouldAnimate ? _scaleAnim.value : 1.0,
            child: Opacity(
              opacity: shouldAnimate ? _fadeAnim.value : 1.0,
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
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    fit: widget.fit,
                  ),

                if (_isLoading)
                  Center(
                    child: SizedBox(
                      width: widget.size * 0.2,
                      height: widget.size * 0.2,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                
                if (_selectedImage == null && !_isLoading)
                  Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: 0.8,
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        size: widget.size * 0.3,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}