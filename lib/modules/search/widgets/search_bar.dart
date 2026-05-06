import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class UnifiedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmit;
  final VoidCallback onClear;
  final String hint;

  const UnifiedSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmit,
    required this.onClear,
    required this.hint,
  });

  @override
  State<UnifiedSearchBar> createState() => _UnifiedSearchBarState();
}


class _UnifiedSearchBarState extends State<UnifiedSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onListen);
  }

  @override
  void didUpdateWidget(covariant UnifiedSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hint != widget.hint) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onListen);
    super.dispose();
  }

  void _onListen() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: cs.mutedForeground.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(FIcons.search,
              size: 16, color: cs.mutedForeground.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmit,
              style: context.theme.typography.sm.copyWith(color: cs.foreground),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: context.theme.typography.sm.copyWith(
                  color: cs.mutedForeground.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: widget.onClear,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(FIcons.x,
                    size: 14,
                    color: cs.mutedForeground.withValues(alpha: 0.5)),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
