import 'package:flutter/material.dart';

/// Widget giúp giữ trạng thái [state] của widget [child]
/// ngay cả khi nó không còn hiển thị trên màn hình.
///
/// Widget này hoạt động như một lớp bao (wrapper) của [child],
/// sử dụng cơ chế của [AutomaticKeepAliveClientMixin] với [wantKeepAlive] = true.
/// Nhờ vậy, [child] sẽ không bị huỷ ([dispose]) ngay cả khi không còn hiển thị,
/// thường gặp trong [ListView], [PageView], hoặc các trường hợp cần điều hướng.
///
/// ⚠️ Cân nhắc sử dụng widget này hợp lý. Việc giữ trạng thái của widget con có
/// thể khiến ứng dụng tốn nhiều tài nguyên hơn.
///
/// ### Ví dụ:
/// ```dart
/// KeepAliveComponent(
///   child: NeedKeepAliveWidget()
/// );
/// ```
class KeepAliveComponent extends StatefulWidget {
  /// Widget cần được giữ trạng thái khi không còn hiển thị.
  final Widget child;

  /// Tạo một [KeepAliveComponent] giữ trạng thái của [child] khỏi bị [dispose]
  ///
  /// [KeepAliveComponent] chỉ hiệu quả nếu [child]
  /// là một [StatefulWidget] hoặc tương tự.
  ///
  /// ⚠️ **Lưu ý:** chỉ nên sử dụng khi thực sự cần thiết, tránh gây lãng phí bộ nhớ.
  const KeepAliveComponent({
    super.key,
    required this.child
  });

  @override
  State<KeepAliveComponent> createState() => _KeepAliveComponentState();
}

class _KeepAliveComponentState extends State<KeepAliveComponent> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}