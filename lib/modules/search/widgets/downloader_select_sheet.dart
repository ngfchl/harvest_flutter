import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart';

class DownloaderSelectSheet extends ConsumerWidget {
  final ValueChanged<Downloader> onSelected;

  const DownloaderSelectSheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(downloaderListProvider);
    final cs = context.theme.colors;
    final typo = context.theme.typography;

    return Container(
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: cs.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('选择下载器',
              style: typo.base.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: FProgress.circularIcon()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('加载失败',
                    style: typo.sm.copyWith(color: cs.mutedForeground)),
              ),
            ),
            data: (downloaders) {
              if (downloaders.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(FIcons.cloudOff,
                            size: 32,
                            color: cs.mutedForeground.withValues(alpha: 0.3)),
                        const SizedBox(height: 8),
                        Text('暂无可用下载器',
                            style: typo.sm.copyWith(color: cs.mutedForeground)),
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
                    child: FTile(
                      title: Text(d.name,
                          style: typo.sm.copyWith(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        d.isQb
                            ? 'qBittorrent'
                            : d.isTr
                            ? 'Transmission'
                            : d.category,
                        style: typo.xs.copyWith(color: cs.mutedForeground),
                      ),
                      prefix: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(FIcons.download, size: 18, color: cs.primary),
                      ),
                      suffix: Icon(FIcons.chevronRight,
                          size: 16, color: cs.mutedForeground),
                      onPress: () => onSelected(d),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FButton(
              style: FButtonStyle.outline(),
              onPress: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ),
        ],
      ),
    );
  }
}
