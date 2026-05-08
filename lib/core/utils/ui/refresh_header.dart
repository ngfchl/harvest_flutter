import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

ClassicHeader appRefreshHeader(
  BuildContext context, {
  bool showMessage = true,
  String messageText = '最后更新于 %T',
}) {
  final theme = shadcn.Theme.of(context);
  final color = theme.colorScheme.mutedForeground.withValues(alpha: 0.5);
  final textStyle = theme.typography.xSmall.copyWith(
    color: color,
    fontSize: 11,
  );

  return ClassicHeader(
    dragText: '下拉刷新',
    armedText: '释放刷新',
    readyText: '刷新中...',
    processingText: '刷新中...',
    processedText: '刷新完成',
    failedText: '刷新失败',
    noMoreText: '没有更多',
    messageText: messageText,
    showMessage: showMessage,
    iconTheme: IconThemeData(color: color, size: 18),
    textStyle: textStyle,
    messageStyle: textStyle.copyWith(fontSize: 10),
    progressIndicatorSize: 18,
    progressIndicatorStrokeWidth: 2,
  );
}
