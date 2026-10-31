import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:harvest/core/utils/utils.dart';

import '../../../widgets/index.dart';

/// 打开一个移动端底部 / 桌面端对话框表单。
Future<T?> showRssSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  bool isScrollControlled = false,
  double desktopMaxWidth = 520,
  double desktopMaxHeight = 720,
}) {
  if (context.isMobile) {
    return showAppSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Theme.of(context).colorScheme.background,
      builder: (_) => builder(context),
    );
  }
  return appShowDialog<T>(
    context: context,
    builder: (_) => AlertDialog(
      title: title == null ? null : Text(title),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: desktopMaxWidth, maxHeight: desktopMaxHeight),
        child: builder(context),
      ),
    ),
  );
}

/// 表单分组卡片
class RssSheetGroup extends StatelessWidget {
  final List<Widget> children;

  const RssSheetGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }
}

/// 表单开关/展示行
class RssSheetTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? helper;
  final Widget? trailing;
  final VoidCallback? onTap;

  const RssSheetTile({super.key, required this.title, this.subtitle, this.helper, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (helper != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle.merge(
                      style: TextStyle(fontSize: 12, color: cs.mutedForeground),
                      child: helper!,
                    ),
                  ],
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle.merge(
                      style: TextStyle(fontSize: 12, color: cs.mutedForeground),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// 小节标题
class RssSectionTitle extends StatelessWidget {
  final String text;

  const RssSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.mutedForeground),
      ),
    );
  }
}
