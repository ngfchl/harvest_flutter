import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

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
    this.hint = '搜索电影、剧集',
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
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onListen);
      widget.controller.addListener(_onListen);
    }
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
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final hasText = widget.controller.text.isNotEmpty;

    return shadcn.AnimatedContainer(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      duration: Duration(milliseconds: 100),
      child: Row(
        children: [
          Expanded(
            child: shadcn.TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmit,
              placeholder: Text(widget.hint),
              style: theme.typography.small,
              features: [
                shadcn.InputFeature.leading(Icon(shadcn.LucideIcons.search, size: 16, color: cs.mutedForeground)),
                // shadcn.InputFeature.clear(visibility: shadcn.InputFeatureVisibility.textNotEmpty,),
              ],
            ),
          ),
          if (hasText)
            shadcn.IconButton.ghost(
              size: shadcn.ButtonSize.small,
              onPressed: widget.onClear,
              icon: Icon(shadcn.LucideIcons.x, size: 14),
            ),
        ],
      ),
    );
  }
}
