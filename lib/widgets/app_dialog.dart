import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 以 shadcn 对话框形式弹出内容。
///
/// shadcn_flutter 0.0.54 移除了顶层 `showDialog`，统一为
/// `showOverlay` + [shadcn.DialogConfiguration]，此封装保持旧调用形态。
Future<T?> appShowDialog<T>({required BuildContext context, required WidgetBuilder builder}) {
  return showOverlay<T>(context, const DialogConfiguration(), builder: builder).future;
}
