import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/torrent_model.dart';
import 'torrent_status_utils.dart';

// ── 可调整高度的筛选区段 ──

class DesktopResizableFilterSection extends StatelessWidget {
  final String title;
  final bool collapsed;
  final double height;
  final VoidCallback onToggle;
  final ValueChanged<double> onResize;
  final List<Widget> actions;
  final Widget child;

  const DesktopResizableFilterSection({
    super.key,
    required this.title,
    required this.collapsed,
    required this.height,
    required this.onToggle,
    required this.onResize,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final expanded = !collapsed;

    return SizedBox(
      height: expanded ? height : 48,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        decoration: BoxDecoration(
          color: cs.background,
          border: Border.all(color: cs.border, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SizedBox(
              height: 38,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 6, 0),
                    child: Row(
                      children: [
                        Icon(
                          expanded
                              ? shadcn.LucideIcons.chevronDown
                              : shadcn.LucideIcons.chevronRight,
                          size: 14,
                          color: cs.mutedForeground,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cs.mutedForeground,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ...actions,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (expanded) ...[
              Divider(height: 1, color: cs.border),
              Expanded(child: child),
              MouseRegion(
                cursor: SystemMouseCursors.resizeUpDown,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (d) => onResize(d.delta.dy),
                  child: SizedBox(
                    height: 8,
                    child: Center(
                      child: Container(
                        width: 34,
                        height: 3,
                        decoration: BoxDecoration(
                          color: cs.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 单个筛选项 ──

class DesktopFilterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final double indent;
  final List<Widget> trailingActions;

  const DesktopFilterItem({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.indent = 0,
    this.trailingActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 34,
          padding: EdgeInsets.only(left: 8 + indent, right: 8),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? cs.primary : cs.mutedForeground,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? cs.primary : cs.foreground,
                    fontSize: 12,
                    fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ...trailingActions,
              if (trailingActions.isNotEmpty) const SizedBox(width: 4),
              Container(
                constraints: const BoxConstraints(minWidth: 22),
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? cs.primary.withValues(alpha: 0.12)
                      : cs.mutedForeground.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? cs.primary : cs.mutedForeground,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 状态分组（可展开/收起子状态） ──

class DesktopStatusGroup extends StatefulWidget {
  final String title;
  final IconData icon;
  final DesktopTorrentStatusFilter group;
  final List<DesktopTorrentStatusFilter> children;
  final DesktopTorrentStatusFilter selected;
  final Map<DesktopTorrentStatusFilter, int> counts;
  final ValueChanged<DesktopTorrentStatusFilter> onTap;

  const DesktopStatusGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.group,
    required this.children,
    required this.selected,
    required this.counts,
    required this.onTap,
  });

  @override
  State<DesktopStatusGroup> createState() => _DesktopStatusGroupState();
}

class _DesktopStatusGroupState extends State<DesktopStatusGroup> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final selectedInGroup = widget.selected == widget.group ||
        widget.children.contains(widget.selected);
    return Column(
      children: [
        DesktopFilterItem(
          icon: widget.icon,
          label: widget.title,
          count: widget.counts[widget.group] ?? 0,
          selected: selectedInGroup,
          onTap: () => widget.onTap(widget.group),
          trailingActions: [
            DesktopInlineActionButton(
              icon: _expanded
                  ? shadcn.LucideIcons.chevronDown
                  : shadcn.LucideIcons.chevronRight,
              tooltip: _expanded ? '收起子状态' : '展开子状态',
              onTap: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ),
        if (_expanded)
          for (final child in widget.children)
            DesktopFilterItem(
              icon: desktopStatusIcon(child),
              label: child.label,
              count: widget.counts[child] ?? 0,
              selected: widget.selected == child,
              onTap: () => widget.onTap(child),
              indent: 18,
            ),
      ],
    );
  }
}

// ── 操作按钮 ──

class DesktopFilterActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const DesktopFilterActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return shadcn.Tooltip(
      tooltip: (_) => Text(tooltip).small,
      child: SizedBox(
        width: 26,
        height: 26,
        child: shadcn.IconButton.ghost(
          onPressed: onTap,
          icon: Icon(icon, size: 14),
        ),
      ),
    );
  }
}

class DesktopInlineActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool destructive;

  const DesktopInlineActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return shadcn.Tooltip(
      tooltip: (_) => Text(tooltip).small,
      child: SizedBox(
        width: 22,
        height: 22,
        child: shadcn.IconButton.ghost(
          onPressed: onTap,
          icon: Icon(
            icon,
            size: 13,
            color: destructive ? cs.destructive : null,
          ),
        ),
      ),
    );
  }
}
