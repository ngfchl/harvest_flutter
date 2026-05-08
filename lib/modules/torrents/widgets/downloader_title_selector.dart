import 'package:flutter/material.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;

class DownloaderTitleSelector extends StatelessWidget {
  final List<Downloader> downloaders;
  final int currentDownloaderId;
  final String fallbackTitle;
  final ValueChanged<Downloader> onSelect;

  const DownloaderTitleSelector({
    super.key,
    required this.downloaders,
    required this.currentDownloaderId,
    required this.fallbackTitle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (downloaders.isEmpty) {
      return Text(fallbackTitle).small.bold;
    }

    final currentIndex = downloaders.indexWhere(
          (d) => d.id == currentDownloaderId,
    );
    final safeIndex = currentIndex >= 0 ? currentIndex : 0;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 104,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: shadcn.Tabs(
          index: safeIndex,
          onChanged: (index) => onSelect(downloaders[index]),
          children: [
            for (final d in downloaders)
              shadcn.TabItem(
                child: shadcn.Tooltip(
                  tooltip: (_) => Text(
                    d.isTr
                        ? '${d.name.isEmpty ? '未命名' : d.name} · Transmission'
                        : '${d.name.isEmpty ? '未命名' : d.name} · qBittorrent',
                  ).small,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        d.isTr
                            ? shadcn.LucideIcons.radioTower
                            : shadcn.LucideIcons.download,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          d.name.isEmpty ? '未命名下载器' : d.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
