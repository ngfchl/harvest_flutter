import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class ShellBottomNavigation extends StatefulWidget {
  final int index;
  final ValueChanged<int> onChange;
  final bool dashboardChrome;
  final bool showNews;
  final bool useShaderLiquidGlass;

  static const _barHeight = 58.0;
  static const _horizontalMargin = 12.0;
  static const _topGap = 6.0;
  static const _bottomGap = 8.0;
  static const _switchOverflow = 10.0;

  const ShellBottomNavigation({
    super.key,
    required this.index,
    required this.onChange,
    this.dashboardChrome = false,
    this.showNews = true,
    this.useShaderLiquidGlass = false,
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
  final bool dashboardChrome;
  final bool showNews;
  final bool useShaderLiquidGlass;

  static const _maxWidth = 720.0;

  const ShellBottomControls({
    super.key,
    required this.index,
    required this.onChange,
    required this.onSearchPress,
    this.dashboardChrome = false,
    this.showNews = true,
    this.useShaderLiquidGlass = false,
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
              child: ShellBottomNavigation(
                index: index,
                onChange: onChange,
                dashboardChrome: dashboardChrome,
                showNews: showNews,
                useShaderLiquidGlass: useShaderLiquidGlass,
              ),
            ),
            ShellSearchButton(
              onPress: onSearchPress,
              dashboardChrome: dashboardChrome,
              useShaderLiquidGlass: useShaderLiquidGlass,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellBottomNavigationState extends State<ShellBottomNavigation>
    with SingleTickerProviderStateMixin {
  static const _allItems = [
    _ShellNavItem(
      label: '资讯',
      icon: shadcn.LucideIcons.newspaper,
      pageIndex: 0,
    ),
    _ShellNavItem(label: '站点', icon: shadcn.LucideIcons.globe, pageIndex: 1),
    _ShellNavItem(
      label: '仪表',
      icon: shadcn.LucideIcons.layoutDashboard,
      pageIndex: 2,
    ),
    _ShellNavItem(label: '下载', icon: shadcn.LucideIcons.download, pageIndex: 3),
    _ShellNavItem(label: '任务', icon: shadcn.LucideIcons.listTodo, pageIndex: 4),
  ];
  static const _dragDwellDuration = Duration(milliseconds: 420);
  static const _dashboardPanel = Color(0xFF0D1B2E);
  static const _dashboardPanelSoft = Color(0xFF10243B);
  static const _dashboardMuted = Color(0xFF88A4C4);
  static const _dashboardCyan = Color(0xFF22D3EE);

  late final AnimationController _controller;
  late Animation<double> _position;
  late int _selectedIndex;
  double? _dragVisualPosition;
  int? _dragTargetIndex;
  Timer? _dragDwellTimer;

  List<_ShellNavItem> get _items =>
      widget.showNews ? _allItems : _allItems.skip(1).toList(growable: false);

  int get _widgetIndex {
    final index = _items.indexWhere((item) => item.pageIndex == widget.index);
    return index >= 0 ? index : 0;
  }

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
                  child: widget.useShaderLiquidGlass
                      ? _buildLiquidNavigation(
                          context: context,
                          viewportHeight: viewportHeight,
                          barScale: barScale,
                          showGlass: showGlass,
                          selectionOpacity: selectionOpacity,
                          lensWidth: lensWidth.toDouble(),
                          lensHeight: lensHeight,
                          lensLeft: lensLeft.clamp(0.0, maxLensLeft).toDouble(),
                        )
                      : _buildCompositedLiquidNavigation(
                          viewportHeight: viewportHeight,
                          barScale: barScale,
                          selectionOpacity: selectionOpacity,
                          lensWidth: lensWidth.toDouble(),
                          lensHeight: lensHeight,
                          lensLeft: lensLeft.clamp(0.0, maxLensLeft).toDouble(),
                        ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompositedLiquidNavigation({
    required double viewportHeight,
    required double barScale,
    required double selectionOpacity,
    required double lensWidth,
    required double lensHeight,
    required double lensLeft,
  }) {
    return OverflowBox(
      alignment: Alignment.bottomCenter,
      minHeight: viewportHeight,
      maxHeight: viewportHeight,
      child: SizedBox(
        height: viewportHeight,
        child: Transform.scale(
          scale: barScale,
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: SizedBox(
                  height: ShellBottomNavigation._barHeight,
                  child: _NavigationChrome(
                    items: _items,
                    selectedIndex: _selectedIndex,
                    selectedBackgroundOpacity: 0,
                    dashboardChrome: widget.dashboardChrome,
                    showItems: false,
                  ),
                ),
              ),
              Positioned(
                left: lensLeft,
                top: (viewportHeight - lensHeight) / 2,
                width: lensWidth,
                height: lensHeight,
                child: IgnorePointer(
                  child: _CompositedLiquidLens(
                    dashboardChrome: widget.dashboardChrome,
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  height: ShellBottomNavigation._barHeight,
                  child: _NavigationItemsLayer(
                    items: _items,
                    selectedIndex: _selectedIndex,
                    selectedBackgroundOpacity: 0.32,
                    dashboardChrome: widget.dashboardChrome,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidNavigation({
    required BuildContext context,
    required double viewportHeight,
    required double barScale,
    required bool showGlass,
    required double selectionOpacity,
    required double lensWidth,
    required double lensHeight,
    required double lensLeft,
  }) {
    return OverflowBox(
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
                  dashboardChrome: widget.dashboardChrome,
                ),
              ),
            ),
            children: [
              LiquidGlass(
                width: lensWidth,
                height: lensHeight,
                visibility: showGlass,
                position: LiquidGlassOffsetPosition(
                  left: lensLeft,
                  top: (viewportHeight - lensHeight) / 2,
                ),
                magnification: 1.04,
                distortion: 0.18,
                distortionWidth: 42,
                chromaticAberration: 0.002,
                saturation: 1.08,
                color: widget.dashboardChrome
                    ? _dashboardPanelSoft.withValues(alpha: 0.28)
                    : shadcn.Theme.of(
                        context,
                      ).colorScheme.background.withValues(alpha: 0.1),
                blur: const LiquidGlassBlur(sigmaX: 0.65, sigmaY: 0.65),
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
    widget.onChange(_items[next].pageIndex);
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
  final bool dashboardChrome;
  final bool showItems;

  const _NavigationChrome({
    required this.items,
    required this.selectedIndex,
    required this.selectedBackgroundOpacity,
    required this.dashboardChrome,
    this.showItems = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = shadcn.Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(22);
    final background = dashboardChrome
        ? _ShellBottomNavigationState._dashboardPanel
        : colors.card;
    final border = dashboardChrome
        ? _ShellBottomNavigationState._dashboardCyan.withValues(alpha: 0.26)
        : colors.border.withValues(alpha: 0.38);
    final shadows = dashboardChrome
        ? [
            BoxShadow(
              color: _ShellBottomNavigationState._dashboardCyan.withValues(
                alpha: 0.14,
              ),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.42),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ]
        : const [
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
          ];

    final chrome = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: radius,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: showItems
            ? _NavigationItemsLayer(
                items: items,
                selectedIndex: selectedIndex,
                selectedBackgroundOpacity: selectedBackgroundOpacity,
                dashboardChrome: dashboardChrome,
              )
            : const SizedBox.expand(),
      ),
    );

    return chrome;
  }
}

class _NavigationItemsLayer extends StatelessWidget {
  final List<_ShellNavItem> items;
  final int selectedIndex;
  final double selectedBackgroundOpacity;
  final bool dashboardChrome;

  const _NavigationItemsLayer({
    required this.items,
    required this.selectedIndex,
    required this.dashboardChrome,
    this.selectedBackgroundOpacity = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, item) in items.indexed)
          Expanded(
            child: _NavigationItemButton(
              item: item,
              selected: i == selectedIndex,
              selectedBackgroundOpacity: selectedBackgroundOpacity,
              dashboardChrome: dashboardChrome,
            ),
          ),
      ],
    );
  }
}

class _CompositedLiquidLens extends StatelessWidget {
  final bool dashboardChrome;

  const _CompositedLiquidLens({required this.dashboardChrome});

  @override
  Widget build(BuildContext context) {
    final colors = shadcn.Theme.of(context).colorScheme;
    final tint = dashboardChrome
        ? _ShellBottomNavigationState._dashboardPanelSoft
        : colors.background;
    final highlight = dashboardChrome
        ? _ShellBottomNavigationState._dashboardCyan
        : colors.primary;
    final border = dashboardChrome
        ? _ShellBottomNavigationState._dashboardCyan.withValues(alpha: 0.36)
        : colors.foreground.withValues(alpha: 0.18);
    final radius = BorderRadius.circular(24);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint.withValues(alpha: dashboardChrome ? 0.28 : 0.16),
        borderRadius: radius,
        border: Border.all(color: border, width: 0.8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: 0.32),
            tint.withValues(alpha: 0.08),
            highlight.withValues(alpha: dashboardChrome ? 0.14 : 0.09),
          ],
          stops: const [0.0, 0.52, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            right: 10,
            top: 7,
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.52),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            right: 9,
            top: 9,
            width: 7,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.38),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItemButton extends StatelessWidget {
  final _ShellNavItem item;
  final bool selected;
  final double selectedBackgroundOpacity;
  final bool dashboardChrome;

  const _NavigationItemButton({
    required this.item,
    required this.selected,
    required this.selectedBackgroundOpacity,
    required this.dashboardChrome,
  });

  @override
  Widget build(BuildContext context) {
    final colors = shadcn.Theme.of(context).colorScheme;
    final activeColor = dashboardChrome
        ? _ShellBottomNavigationState._dashboardCyan
        : colors.primary;
    final inactiveColor = dashboardChrome
        ? _ShellBottomNavigationState._dashboardMuted.withValues(alpha: 0.82)
        : colors.foreground.withValues(alpha: 0.58);
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
        final highlightOpacity = selected
            ? math.max(selectedBackgroundOpacity, 0.24)
            : 0.0;
        final indicatorOpacity = selected
            ? math.max(selectedBackgroundOpacity, 0.62)
            : 0.0;

        return Stack(
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          children: [
            Positioned(
              width: backgroundWidth,
              height: backgroundHeight,
              child: IgnorePointer(
                child: Opacity(
                  opacity: highlightOpacity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFFFFF).withValues(alpha: 0.26),
                          activeColor.withValues(alpha: 0.08),
                          activeColor.withValues(alpha: 0.16),
                        ],
                      ),
                      border: Border.all(
                        color: activeColor.withValues(alpha: 0.24),
                        width: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              width: 18,
              height: 2,
              child: IgnorePointer(
                child: Opacity(
                  opacity: indicatorOpacity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.34),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedSlide(
              offset: selected ? const Offset(0, -0.025) : Offset.zero,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 2,
                children: [
                  Icon(item.icon, size: selected ? 23 : 22, color: color),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: shadcn.Theme.of(context).typography.xSmall.copyWith(
                      color: color,
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ShellSearchButton extends StatefulWidget {
  final VoidCallback onPress;
  final bool dashboardChrome;
  final bool useShaderLiquidGlass;

  static const _buttonSize = 58.0;
  static const _horizontalMargin = 12.0;
  static const _topGap = 6.0;
  static const _bottomGap = 8.0;

  const ShellSearchButton({
    super.key,
    required this.onPress,
    this.dashboardChrome = false,
    this.useShaderLiquidGlass = false,
  });

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
    final colors = shadcn.Theme.of(context).colorScheme;
    final background = widget.dashboardChrome
        ? _ShellBottomNavigationState._dashboardPanel
        : colors.card;
    final border = widget.dashboardChrome
        ? _ShellBottomNavigationState._dashboardCyan.withValues(alpha: 0.26)
        : colors.border;
    final primary = widget.dashboardChrome
        ? _ShellBottomNavigationState._dashboardCyan
        : colors.primary;
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
                final buttonScale = 1 + 0.008 * effect;

                if (widget.useShaderLiquidGlass) {
                  return _buildLiquidSearchButton(
                    effect: effect,
                    buttonScale: buttonScale,
                    background: background,
                    border: border,
                    primary: primary,
                  );
                }

                return Transform.scale(
                  scale: buttonScale,
                  child: _CompositedLiquidSearchButton(
                    background: background,
                    border: border,
                    primary: primary,
                    dashboardChrome: widget.dashboardChrome,
                    pressEffect: effect,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidSearchButton({
    required double effect,
    required double buttonScale,
    required Color background,
    required Color border,
    required Color primary,
  }) {
    final viewportSize = ShellSearchButton._buttonSize + 8 * effect;
    final glassSize = ShellSearchButton._buttonSize + 4 * effect;

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
                  background: background,
                  border: border,
                  primary: primary,
                  dashboardChrome: widget.dashboardChrome,
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
                color: background.withValues(
                  alpha: widget.dashboardChrome ? 0.26 : 0.10,
                ),
                blur: const LiquidGlassBlur(sigmaX: 0.65, sigmaY: 0.65),
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
  }
}

class _SearchButtonChrome extends StatelessWidget {
  final Color background;
  final Color border;
  final Color primary;
  final bool dashboardChrome;
  final bool showIcon;

  const _SearchButtonChrome({
    required this.background,
    required this.border,
    required this.primary,
    required this.dashboardChrome,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: border.withValues(alpha: dashboardChrome ? 1 : 0.42),
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: dashboardChrome
            ? [
                BoxShadow(
                  color: _ShellBottomNavigationState._dashboardCyan.withValues(
                    alpha: 0.14,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.42),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : const [
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
      child: showIcon
          ? Center(
              child: Icon(shadcn.LucideIcons.search, size: 22, color: primary),
            )
          : const SizedBox.expand(),
    );
  }
}

class _CompositedLiquidSearchButton extends StatelessWidget {
  final Color background;
  final Color border;
  final Color primary;
  final bool dashboardChrome;
  final double pressEffect;

  const _CompositedLiquidSearchButton({
    required this.background,
    required this.border,
    required this.primary,
    required this.dashboardChrome,
    required this.pressEffect,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    final effect = pressEffect.clamp(0.0, 1.0).toDouble();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                _SearchButtonChrome(
                  background: background,
                  border: border,
                  primary: primary,
                  dashboardChrome: dashboardChrome,
                  showIcon: false,
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFFFFFF).withValues(alpha: 0.34),
                            background.withValues(alpha: 0.04),
                            primary.withValues(
                              alpha: dashboardChrome ? 0.18 : 0.12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 13,
                  right: 13,
                  top: 8,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  width: 6,
                  height: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.36),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (effect > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: Transform.scale(
                scale: 1 + 0.16 * effect,
                child: Opacity(
                  opacity: effect,
                  child: _SearchPressLiquidLayer(
                    primary: primary,
                    background: background,
                    dashboardChrome: dashboardChrome,
                  ),
                ),
              ),
            ),
          ),
        Center(
          child: Icon(shadcn.LucideIcons.search, size: 22, color: primary),
        ),
      ],
    );
  }
}

class _SearchPressLiquidLayer extends StatelessWidget {
  final Color primary;
  final Color background;
  final bool dashboardChrome;

  const _SearchPressLiquidLayer({
    required this.primary,
    required this.background,
    required this.dashboardChrome,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: primary.withValues(alpha: dashboardChrome ? 0.34 : 0.24),
            width: 0.8,
          ),
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.45),
            radius: 1.05,
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.42),
              primary.withValues(alpha: dashboardChrome ? 0.20 : 0.14),
              background.withValues(alpha: 0.04),
            ],
            stops: const [0.0, 0.48, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: dashboardChrome ? 0.24 : 0.16),
              blurRadius: 18,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 12,
              right: 12,
              top: 7,
              height: 1.2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              width: 8,
              height: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.50),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellNavItem {
  final String label;
  final IconData icon;
  final int pageIndex;

  const _ShellNavItem({
    required this.label,
    required this.icon,
    required this.pageIndex,
  });
}
