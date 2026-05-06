import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

class ShellBottomNavigation extends StatefulWidget {
  final int index;
  final ValueChanged<int> onChange;

  static const _barHeight = 58.0;
  static const _horizontalMargin = 12.0;
  static const _topGap = 6.0;
  static const _bottomGap = 8.0;
  static const _switchOverflow = 10.0;

  const ShellBottomNavigation({
    super.key,
    required this.index,
    required this.onChange,
  });

  static double reservedHeight(BuildContext context) {
    return _topGap +
        _barHeight +
        _bottomGap +
        MediaQuery.viewPaddingOf(context).bottom;
  }

  @override
  State<ShellBottomNavigation> createState() => _ShellBottomNavigationState();
}

class ShellBottomControls extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChange;
  final VoidCallback onSearchPress;

  static const _maxWidth = 720.0;

  const ShellBottomControls({
    super.key,
    required this.index,
    required this.onChange,
    required this.onSearchPress,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ShellBottomNavigation(index: index, onChange: onChange),
            ),
            ShellSearchButton(onPress: onSearchPress),
          ],
        ),
      ),
    );
  }
}

class _ShellBottomNavigationState extends State<ShellBottomNavigation>
    with SingleTickerProviderStateMixin {
  static const _items = [
    _ShellNavItem(label: '资讯', icon: FIcons.newspaper),
    _ShellNavItem(label: '站点', icon: FIcons.globe),
    _ShellNavItem(label: '仪表', icon: FIcons.layoutDashboard),
    _ShellNavItem(label: '下载', icon: FIcons.download),
    _ShellNavItem(label: '任务', icon: FIcons.listTodo),
  ];
  static const _dragDwellDuration = Duration(milliseconds: 420);

  late final AnimationController _controller;
  late Animation<double> _position;
  late int _selectedIndex;
  double? _dragVisualPosition;
  int? _dragTargetIndex;
  Timer? _dragDwellTimer;

  int get _widgetIndex => widget.index.clamp(0, _items.length - 1).toInt();

  @override
  void initState() {
    super.initState();
    _selectedIndex = _widgetIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      value: 1,
    );
    _position = AlwaysStoppedAnimation(_selectedIndex.toDouble());
  }

  @override
  void didUpdateWidget(covariant ShellBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _widgetIndex;
    if (next == _selectedIndex) return;

    _animateTo(next);
  }

  void _animateTo(int next, {double? from}) {
    _position = Tween<double>(
      begin: from ?? _position.value,
      end: next.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _selectedIndex = next;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _dragDwellTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        ShellBottomNavigation._horizontalMargin,
        ShellBottomNavigation._topGap,
        ShellBottomNavigation._horizontalMargin,
        ShellBottomNavigation._bottomGap + bottomInset,
      ),
      child: SizedBox(
        height: ShellBottomNavigation._barHeight,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final selectionOpacity = _selectionOpacity(_controller.value);
            final dragging = _dragVisualPosition != null;
            final showGlass = dragging || _controller.value < 1;
            final animationEffect =
                1 - Curves.easeInOutCubic.transform(_controller.value);
            final switchEffect = dragging ? 0.62 : animationEffect;
            final viewportHeight =
                ShellBottomNavigation._barHeight +
                ShellBottomNavigation._switchOverflow * switchEffect;
            final barScale = 1 + 0.014 * switchEffect;

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final itemWidth = width / _items.length;
                final lensWidth =
                    math.min(math.max(itemWidth + 2, 58), 84) +
                    4 * switchEffect;
                final lensHeight =
                    48.0 +
                    ((ShellBottomNavigation._barHeight + 4) - 48) *
                        switchEffect;
                final visualPosition = _dragVisualPosition ?? _position.value;
                final lensLeft =
                    (visualPosition * itemWidth) + (itemWidth - lensWidth) / 2;
                final maxLensLeft = math.max(0.0, width - lensWidth);

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    _clearDragVisual();
                    _handleChange(
                      _indexAt(details.localPosition.dx, itemWidth),
                    );
                  },
                  onPanStart: (details) {
                    _handleDragMove(details.localPosition.dx, itemWidth);
                  },
                  onPanUpdate: (details) {
                    _handleDragMove(details.localPosition.dx, itemWidth);
                  },
                  onPanEnd: (_) => _handleDragEnd(),
                  onPanCancel: _clearDragVisual,
                  child: OverflowBox(
                    alignment: Alignment.bottomCenter,
                    minHeight: viewportHeight,
                    maxHeight: viewportHeight,
                    child: SizedBox(
                      height: viewportHeight,
                      child: Transform.scale(
                        scale: barScale,
                        alignment: Alignment.center,
                        child: LiquidGlassView(
                          pixelRatio: 0.75,
                          realTimeCapture: showGlass,
                          refreshRate: LiquidGlassRefreshRate.high,
                          backgroundWidget: Center(
                            child: SizedBox(
                              height: ShellBottomNavigation._barHeight,
                              child: _NavigationChrome(
                                items: _items,
                                selectedIndex: _selectedIndex,
                                selectedBackgroundOpacity: selectionOpacity,
                              ),
                            ),
                          ),
                          children: [
                            LiquidGlass(
                              width: lensWidth.toDouble(),
                              height: lensHeight,
                              visibility: showGlass,
                              position: LiquidGlassOffsetPosition(
                                left: lensLeft
                                    .clamp(0.0, maxLensLeft)
                                    .toDouble(),
                                top: (viewportHeight - lensHeight) / 2,
                              ),
                              magnification: 1.04,
                              distortion: 0.18,
                              distortionWidth: 42,
                              chromaticAberration: 0.002,
                              saturation: 1.08,
                              color: FTheme.of(
                                context,
                              ).colors.background.withValues(alpha: 0.1),
                              blur: const LiquidGlassBlur(
                                sigmaX: 0.65,
                                sigmaY: 0.65,
                              ),
                              shape: const RoundedRectangleShape(
                                cornerRadius: 24,
                                borderWidth: 1,
                                borderSoftness: 3,
                                lightIntensity: 1.35,
                                oneSideLightIntensity: 0.7,
                                lightDirection: 42,
                              ),
                              outOfBoundaries: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  double _selectionOpacity(double value) {
    if (value <= 0.5) return 0;
    return ((value - 0.5) / 0.5).clamp(0.0, 1.0).toDouble();
  }

  void _handleChange(int index) {
    _clearDragVisual();
    _commitChange(index);
  }

  void _commitChange(int index, {double? animationFrom}) {
    final next = index.clamp(0, _items.length - 1).toInt();
    if (next == _selectedIndex) return;
    _animateTo(next, from: animationFrom);
    widget.onChange(next);
  }

  void _handleDragMove(double dx, double itemWidth) {
    if (itemWidth <= 0) return;

    final visualPosition = (dx / itemWidth)
        .clamp(0.0, (_items.length - 1).toDouble())
        .toDouble();

    setState(() => _dragVisualPosition = visualPosition);
    _trackDragTarget(_indexAt(dx, itemWidth));
  }

  void _trackDragTarget(int targetIndex) {
    if (targetIndex == _dragTargetIndex) return;

    _dragTargetIndex = targetIndex;
    _dragDwellTimer?.cancel();

    if (targetIndex == _selectedIndex) {
      _dragDwellTimer = null;
      return;
    }

    _dragDwellTimer = Timer(_dragDwellDuration, () {
      if (!mounted ||
          _dragVisualPosition == null ||
          _dragTargetIndex != targetIndex) {
        return;
      }

      _dragDwellTimer = null;
      _commitChange(targetIndex, animationFrom: _dragVisualPosition);
    });
  }

  void _handleDragEnd() {
    final targetIndex = _dragTargetIndex;
    final animationFrom = _dragVisualPosition;

    _dragDwellTimer?.cancel();
    _dragDwellTimer = null;
    _dragTargetIndex = null;

    if (targetIndex != null) {
      _commitChange(targetIndex, animationFrom: animationFrom);
    }

    _clearDragVisual();
  }

  void _clearDragVisual() {
    _dragDwellTimer?.cancel();
    _dragDwellTimer = null;
    _dragTargetIndex = null;

    if (_dragVisualPosition != null && mounted) {
      setState(() => _dragVisualPosition = null);
    }
  }

  int _indexAt(double dx, double itemWidth) {
    if (itemWidth <= 0) return _selectedIndex;
    return (dx / itemWidth).floor().clamp(0, _items.length - 1).toInt();
  }
}

class _NavigationChrome extends StatelessWidget {
  final List<_ShellNavItem> items;
  final int selectedIndex;
  final double selectedBackgroundOpacity;

  const _NavigationChrome({
    required this.items,
    required this.selectedIndex,
    required this.selectedBackgroundOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.colors;
    final radius = BorderRadius.circular(22);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.78),
        border: Border.all(color: colors.border.withValues(alpha: 0.38)),
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Row(
          children: [
            for (final (i, item) in items.indexed)
              Expanded(
                child: _NavigationItemButton(
                  item: item,
                  selected: i == selectedIndex,
                  selectedBackgroundOpacity: selectedBackgroundOpacity,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItemButton extends StatelessWidget {
  final _ShellNavItem item;
  final bool selected;
  final double selectedBackgroundOpacity;

  const _NavigationItemButton({
    required this.item,
    required this.selected,
    required this.selectedBackgroundOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.colors;
    final activeColor = colors.primary;
    final inactiveColor = colors.foreground.withValues(alpha: 0.58);
    final color = selected ? activeColor : inactiveColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBackgroundWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth - 8
            : 70.0;
        final maxBackgroundHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight - 6
            : 46.0;
        final backgroundWidth = math.min(
          76.0,
          math.max(44.0, maxBackgroundWidth),
        );
        final backgroundHeight = math.min(
          46.0,
          math.max(38.0, maxBackgroundHeight),
        );

        return Stack(
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          children: [
            Positioned(
              width: backgroundWidth,
              height: backgroundHeight,
              child: IgnorePointer(
                child: Opacity(
                  opacity: selected ? selectedBackgroundOpacity : 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                Icon(item.icon, size: 22, color: color),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xs.copyWith(
                    color: color,
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ShellSearchButton extends StatefulWidget {
  final VoidCallback onPress;

  static const _buttonSize = 58.0;
  static const _horizontalMargin = 12.0;
  static const _topGap = 6.0;
  static const _bottomGap = 8.0;

  const ShellSearchButton({super.key, required this.onPress});

  @override
  State<ShellSearchButton> createState() => _ShellSearchButtonState();
}

class _ShellSearchButtonState extends State<ShellSearchButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapCancel() {
    if (_opening) return;
    _pressController.reverse();
  }

  Future<void> _handleTap() async {
    if (_opening) return;
    _opening = true;
    _pressController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    widget.onPress();
    _pressController.reverse();
    _opening = false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = FTheme.of(context).colors;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        ShellSearchButton._topGap,
        ShellSearchButton._horizontalMargin,
        ShellSearchButton._bottomGap + bottomInset,
      ),
      child: Semantics(
        button: true,
        label: '搜索',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          child: SizedBox(
            width: ShellSearchButton._buttonSize,
            height: ShellSearchButton._buttonSize,
            child: AnimatedBuilder(
              animation: _pressController,
              builder: (context, _) {
                final effect = Curves.easeOutCubic.transform(
                  _pressController.value,
                );
                final viewportSize = ShellSearchButton._buttonSize + 8 * effect;
                final glassSize = ShellSearchButton._buttonSize + 4 * effect;
                final buttonScale = 1 + 0.008 * effect;

                return OverflowBox(
                  minWidth: viewportSize,
                  maxWidth: viewportSize,
                  minHeight: viewportSize,
                  maxHeight: viewportSize,
                  child: SizedBox.square(
                    dimension: viewportSize,
                    child: Transform.scale(
                      scale: buttonScale,
                      child: LiquidGlassView(
                        pixelRatio: 0.75,
                        realTimeCapture: effect > 0.04,
                        refreshRate: LiquidGlassRefreshRate.high,
                        backgroundWidget: Center(
                          child: SizedBox.square(
                            dimension: ShellSearchButton._buttonSize,
                            child: _SearchButtonChrome(
                              background: colors.background,
                              border: colors.border,
                              primary: colors.primary,
                            ),
                          ),
                        ),
                        children: [
                          LiquidGlass(
                            width: glassSize,
                            height: glassSize,
                            visibility: effect > 0.01,
                            position: LiquidGlassOffsetPosition(
                              left: (viewportSize - glassSize) / 2,
                              top: (viewportSize - glassSize) / 2,
                            ),
                            magnification: 1.04,
                            distortion: 0.18,
                            distortionWidth: 42,
                            chromaticAberration: 0.002,
                            saturation: 1.08,
                            color: colors.background.withValues(alpha: 0.10),
                            blur: const LiquidGlassBlur(
                              sigmaX: 0.65,
                              sigmaY: 0.65,
                            ),
                            shape: const RoundedRectangleShape(
                              cornerRadius: 24,
                              borderWidth: 1,
                              borderSoftness: 3,
                              lightIntensity: 1.35,
                              oneSideLightIntensity: 0.7,
                              lightDirection: 42,
                            ),
                            outOfBoundaries: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchButtonChrome extends StatelessWidget {
  final Color background;
  final Color border;
  final Color primary;

  const _SearchButtonChrome({
    required this.background,
    required this.border,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.78),
        border: Border.all(color: border.withValues(alpha: 0.42)),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: Icon(FIcons.search, size: 22, color: primary)),
    );
  }
}

class _ShellNavItem {
  final String label;
  final IconData icon;

  const _ShellNavItem({required this.label, required this.icon});
}
