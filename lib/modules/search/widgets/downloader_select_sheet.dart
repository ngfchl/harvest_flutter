import 'package:flutter/material.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class DownloaderSelectSheet extends ConsumerWidget {
  static const double desktopWidth = 560;

  final ValueChanged<Downloader> onSelected;

  const DownloaderSelectSheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(downloaderListProvider);
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : desktopWidth,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cs.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('选择下载器', style: typo.base.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: shadcn.CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text('加载失败', style: typo.small.copyWith(color: cs.mutedForeground)),
                  ),
                ),
                data: (downloaders) {
                  if (downloaders.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(shadcn.LucideIcons.cloudOff, size: 32, color: cs.mutedForeground.withValues(alpha: 0.3)),
                            const SizedBox(height: 8),
                            Text('暂无可用下载器', style: typo.small.copyWith(color: cs.mutedForeground)),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: downloaders.map((d) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => onSelected(d),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(shadcn.LucideIcons.download, size: 18, color: cs.primary),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(d.name, style: typo.small.copyWith(fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 2),
                                        Text(
                                          d.isQb
                                              ? 'qBittorrent'
                                              : d.isTr
                                              ? 'Transmission'
                                              : d.category,
                                          style: typo.xSmall.copyWith(color: cs.mutedForeground),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(shadcn.LucideIcons.chevronRight, size: 16, color: cs.mutedForeground),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: shadcn.Button.outline(onPressed: () => closeAppSheet(context), child: const Text('取消')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
