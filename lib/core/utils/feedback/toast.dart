import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../navigation/navigator_key.dart';

// ══════════════════════════════════════════════════════════
//  Toast 类型
// ══════════════════════════════════════════════════════════

enum ToastType {
  success(Icons.check_circle_outline_outlined, Color(0xFF22C55E), '成功'),
  error(Icons.error_outline_outlined, Color(0xFFF87171), '失败'),
  warning(Icons.warning_amber_outlined, Color(0xFFFBBF24), '警告'),
  info(Icons.info_outlined, Color(0xFF94A3B8), '提示');

  final IconData icon;
  final Color color;
  final String label;

  const ToastType(this.icon, this.color, this.label);
}

// ══════════════════════════════════════════════════════════
//  Toast 工具
// ══════════════════════════════════════════════════════════

class Toast {
  static OverlayEntry? _current;
  static Timer? _timer;

  /// 通过类型调用
  static void show(String msg, {required ToastType type, Duration? duration}) =>
      _show(msg, icon: type.icon, color: type.color, duration: duration);

  static void success(String msg) => _show(msg, icon: ToastType.success.icon, color: ToastType.success.color);

  static void error(String msg) => _show(msg, icon: ToastType.error.icon, color: ToastType.error.color);

  static void warning(String msg) => _show(msg, icon: ToastType.warning.icon, color: ToastType.warning.color);

  static void info(String msg) => _show(msg, icon: ToastType.info.icon, color: ToastType.info.color);

  static void _show(
    String msg, {
    required IconData icon,
    required Color color,
    Duration? duration = const Duration(seconds: 2),
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _dismiss();

    _current = OverlayEntry(
      builder: (_) => _ToastWidget(message: msg, icon: icon, color: color),
    );

    overlay.insert(_current!);
    _timer = Timer(duration!, _dismiss);
  }

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _ToastWidget({required this.message, required this.icon, required this.color});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scale = Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 20),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
