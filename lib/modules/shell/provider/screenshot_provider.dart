import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 截图模式：true 时页面切换为全量渲染（shrinkWrap），截图完成后恢复
final screenshotModeProvider = StateProvider<bool>((ref) => false);
/// 各页面注册的 ScrollController
final activeScrollControllerProvider = StateProvider<ScrollController?>((ref) => null);