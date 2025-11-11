part of 'loading_widget.dart';

/// Widget biểu diễn trạng thái đang tải dưới dạng vòng tròn quay.
///
/// [LoadingIndicator] có thể quay vô hạn hoặc hiển thị tiến trình với [value].
class LoadingIndicator extends StatefulWidget {
  /// Tiến độ tải (0.0 đến 1.0). Nếu [null], vòng quay sẽ không dừng.
  final double? value;

  /// Đường kính của vòng tròn loading.
  final double size;

  /// Màu nền của vòng tròn.
  final Color? backgroundColor;

  /// Màu của phần vòng quay (vùng đã tải).
  final Color? indicatorColor;

  /// Độ dày nét của vòng tròn, mặc định là 1.5.
  final double? strokeWidth;

  /// Tạo một vòng tròn loading indicator có thể tùy chỉnh.
  ///
  /// Thường dùng trong các widget như [LoadingWidget], hoặc hiển thị độc lập.
  const LoadingIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.indicatorColor,
    this.strokeWidth,
    this.size = 24,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  final Duration animationDuration = const Duration(seconds: 2);

  bool get hasValue => widget.value != null;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    if (!hasValue) {
      controller.repeat(min: 0, max: 1, period: animationDuration);
    } else {
      controller.animateTo(widget.value ?? 0, duration: animationDuration);
    }
  }

  @override
  void didUpdateWidget(covariant LoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (hasValue) {
      if (oldWidget.value == null) controller.stop();
      controller.animateTo(widget.value!, duration: animationDuration);
    } else {
      controller.repeat(min: 0, max: 1, period: animationDuration);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _LoadingIndicatorPainter(
            offset: hasValue ? 0 : controller.value,
            turn: hasValue ? controller.value : null,
            backgroundColor: widget.backgroundColor ?? _defaultBackgroundColor,
            indicatorColor: widget.indicatorColor ?? _defaultIndicatorColor,
            strokeWidth: widget.strokeWidth
          )
        );
      }
    );
  }

  static const Color _defaultBackgroundColor = ColorsLib.primary2100;
  static const Color _defaultIndicatorColor = ColorsLib.primary2600;
}

class _LoadingIndicatorPainter extends CustomPainter {
  final double offset;
  final double _turn;
  final Color backgroundColor;
  final Color indicatorColor;
  final double _strokeWidth;

  _LoadingIndicatorPainter({
    required this.offset,
    double? turn,
    required this.backgroundColor,
    required this.indicatorColor,
    double? strokeWidth,
  }) : _turn = turn ?? 3 / 4, _strokeWidth = strokeWidth ?? 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paddingForStroke = _strokeWidth / 2 + 1.8;
    final drawRadius = size.shortestSide / 2 - paddingForStroke;
    final center = size.center(Offset.zero);
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = backgroundColor
      ..strokeWidth = _strokeWidth;
    final indicatorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = indicatorColor
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, drawRadius, backgroundPaint);
    canvas.drawArc(
      Offset(paddingForStroke, paddingForStroke) & (Size(drawRadius, drawRadius) * 2),
      (offset - 0.25) * 2 * math.pi,
      _turn * 2 * math.pi,
      false,
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(_LoadingIndicatorPainter oldDelegate) {
    return offset != oldDelegate.offset ||
      _turn != oldDelegate._turn ||
      backgroundColor != oldDelegate.backgroundColor ||
      indicatorColor != oldDelegate.indicatorColor;
  }
}
