import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasText = widget.controller.text.isNotEmpty;

    return AnimatedContainer(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      duration: Duration(milliseconds: 100),
      child: Row(
        children: [
          Expanded(
            child: ShadTextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              maxLines: 1,
              onChanged: widget.onChanged,
              onSubmitted: (value) {
                widget.onSubmit(value);
                FocusManager.instance.primaryFocus?.unfocus();
              },
              placeholder: Text(widget.hint),
              style: theme.typography.small,
              features: [
                InputFeature.leading(Icon(LucideIcons.search, size: 16, color: cs.mutedForeground)),
                // InputFeature.clear(visibility: InputFeatureVisibility.textNotEmpty,),
              ],
            ),
          ),
          if (hasText)
            IconButton.ghost(size: ButtonSize.small, onPressed: widget.onClear, icon: Icon(LucideIcons.x, size: 14)),
        ],
      ),
    );
  }
}
