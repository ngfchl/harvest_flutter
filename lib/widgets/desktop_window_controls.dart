import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

class DesktopWindowControlsOverlay extends StatelessWidget {
  final Widget child;

  const DesktopWindowControlsOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final showControls = PlatformTool.isDesktopOS() && !context.isMobile;
    if (!showControls) return child;

    final controlsOnLeft = PlatformTool.isMacOS() || PlatformTool.isLinux();

    final content = PlatformTool.isWindows() ? _WindowsTitleBarDragListener(child: child) : child;

    return Stack(
      children: [
        content,
        Positioned(
          top: MediaQuery.paddingOf(context).top,
          left: controlsOnLeft ? kDesktopWindowControlsInset : null,
          right: controlsOnLeft ? null : kDesktopWindowControlsInset,
          height: kAppHeaderHeight,
          child: Align(
            alignment: controlsOnLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: DesktopWindowControls(isMacStyle: controlsOnLeft),
          ),
        ),
      ],
    );
  }
}

class _WindowsTitleBarDragListener extends StatefulWidget {
  final Widget child;

  const _WindowsTitleBarDragListener({required this.child});

  @override
  State<_WindowsTitleBarDragListener> createState() => _WindowsTitleBarDragListenerState();
}

class _WindowsTitleBarDragListenerState extends State<_WindowsTitleBarDragListener> {
  static const double _dragSlop = 8;
  static const double _leadingInteractiveGuard = 72;
  static const double _extraTrailingInteractiveGuard = 180;

  int? _dragPointer;
  Offset? _dragStart;
  bool _dragStarted = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: (event) => _clearDragCandidate(event.pointer),
      onPointerCancel: (event) => _clearDragCandidate(event.pointer),
      child: widget.child,
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if ((event.buttons & kPrimaryMouseButton) == 0) return;
    if (!_isInDraggableTitleBar(event.position)) return;

    _dragPointer = event.pointer;
    _dragStart = event.position;
    _dragStarted = false;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_dragPointer != event.pointer || _dragStarted) return;

    final start = _dragStart;
    if (start == null) return;
    if ((event.position - start).distance < _dragSlop) return;

    _dragStarted = true;
    _clearDragCandidate(event.pointer);
    unawaited(windowManager.startDragging());
  }

  bool _isInDraggableTitleBar(Offset position) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return false;

    final top = mediaQuery.padding.top;
    if (position.dy < top || position.dy > top + kAppHeaderHeight) {
      return false;
    }

    final width = mediaQuery.size.width;
    if (width <= 0) return false;

    final trailingGuard = (kDesktopWindowControlsReservedWidth + _extraTrailingInteractiveGuard)
        .clamp(kDesktopWindowControlsReservedWidth, width * 0.42)
        .toDouble();

    if (position.dx < _leadingInteractiveGuard) return false;
    if (position.dx > width - trailingGuard) return false;

    return true;
  }

  void _clearDragCandidate(int pointer) {
    if (_dragPointer != pointer) return;
    _dragPointer = null;
    _dragStart = null;
    _dragStarted = false;
  }
}

class DesktopWindowControls extends StatelessWidget {
  final bool isMacStyle;

  const DesktopWindowControls({super.key, this.isMacStyle = false});

  @override
  Widget build(BuildContext context) {
    final closeButton = DesktopTrafficLightButton(
      color: const Color(0xFFFF5F57),
      icon: LucideIcons.x,
      tooltip: '关闭',
      onPressed: () => windowManager.close(),
    );
    final minimizeButton = DesktopTrafficLightButton(
      color: const Color(0xFFFFBD2E),
      icon: LucideIcons.minus,
      tooltip: '最小化',
      onPressed: () async {
        final minimized = await windowManager.isMinimized();
        if (minimized) {
          await windowManager.restore();
        } else {
          await windowManager.minimize();
        }
      },
    );
    final maximizeButton = DesktopTrafficLightButton(
      color: const Color(0xFF28C840),
      icon: LucideIcons.maximize2,
      tooltip: '最大化',
      onPressed: () async {
        if (await windowManager.isMaximized()) {
          await windowManager.unmaximize();
        } else {
          await windowManager.maximize();
        }
      },
    );

    return SizedBox(
      width: 72,
      height: 28,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isMacStyle
            ? [closeButton, minimizeButton, maximizeButton]
            : [minimizeButton, maximizeButton, closeButton],
      ),
    );
  }
}

class DesktopTrafficLightButton extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const DesktopTrafficLightButton({
    super.key,
    required this.color,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<DesktopTrafficLightButton> createState() => _DesktopTrafficLightButtonState();
}

class _DesktopTrafficLightButtonState extends State<DesktopTrafficLightButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final foreground = Color.lerp(Colors.black, widget.color, 0.18)!.withValues(alpha: 0.72);
    final circleColor = _pressed
        ? Color.lerp(widget.color, Colors.black, 0.10)!
        : _hovered
        ? Color.lerp(widget.color, Colors.white, 0.12)!
        : widget.color;

    return Tooltip(
      tooltip: (_) => Text(widget.tooltip),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: SizedBox(
            width: 24,
            height: 28,
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 100),
                scale: _pressed ? 0.92 : (_hovered ? 1.08 : 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.border.withValues(alpha: _hovered ? 0.24 : 0.14), width: 0.6),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: _hovered ? 0.32 : 0.18),
                        blurRadius: _hovered ? 8 : 3,
                        spreadRadius: _hovered ? 0.5 : 0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, size: 8, color: foreground),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
