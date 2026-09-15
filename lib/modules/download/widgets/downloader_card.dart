import 'package:harvest/widgets/shadcn_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/dashboard/provider/privacy_provider.dart';
import 'package:harvest/modules/torrents/torrent_list_page.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/downloader.dart';
import '../model/downloader_speed.dart';
import '../provider/downloader_speed_provider.dart';
import 'downloader_card_menu.dart';
import 'downloader_live_info.dart';

class DownloaderCard extends ConsumerStatefulWidget {
  final Downloader downloader;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleBrush;

  const DownloaderCard({
    super.key,
    required this.downloader,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onToggleBrush,
  });

  @override
  ConsumerState<DownloaderCard> createState() => _DownloaderCardState();
}

class _DownloaderCardState extends ConsumerState<DownloaderCard> {
  bool _hovered = false;

  Downloader get d => widget.downloader;

  bool get isQb => d.isQb;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typeColor = isQb ? cs.primary : const Color(0xFFF97316);
    final successColor = const Color(0xFF10B981);
    final inactiveColor = cs.destructive;
    final active = d.isActive;
    final privacy = ref.watch(privacyModeProvider);
    final typeLabel = isQb ? 'QB' : 'TR';
    final typeName = isQb ? 'qBittorrent' : 'Transmission';

    final speedMap = ref.watch(downloaderSpeedProvider);
    DownloaderSpeedData? liveData;
    DownloaderInfo? liveInfo;
    for (final entry in speedMap.entries) {
      final key = entry.key.toLowerCase();
      if (key == d.wsKey.toLowerCase() || key == d.id.toString()) {
        liveData = entry.value;
        liveInfo = liveData.info;
        break;
      }
    }

    final connected = liveInfo != null;
    final version = _versionFor(liveInfo, liveData);
    final cardBorder = active
        ? typeColor.withValues(alpha: _hovered ? 0.28 : 0.14)
        : cs.border.withValues(alpha: 0.72);
    final tokens = _DownloaderCardTokens.of(context);
    final cardRadius = BorderRadius.circular(theme.radiusMd);

    final menu = DownloaderCardMenu(
      downloader: d,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      onToggleActive: widget.onToggleActive,
      onToggleBrush: widget.onToggleBrush,
    );

    final card = shadcn.ContextMenu(
      items: menu.buildContextMenuItems(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: _openTorrentList,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: cs.card,
              borderRadius: cardRadius,
              border: Border.all(color: cardBorder),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withValues(alpha: _hovered ? 0.045 : 0.018),
                  blurRadius: tokens.size(_hovered ? 12 : 8),
                  offset: Offset(0, tokens.size(_hovered ? 5 : 3)),
                ),
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.12
                        : 0.022,
                  ),
                  blurRadius: tokens.size(8),
                  offset: Offset(0, tokens.size(3)),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: cardRadius,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: tokens.size(3),
                      color: active
                          ? typeColor
                          : cs.mutedForeground.withValues(alpha: 0.24),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact =
                          context.isMobile || constraints.maxWidth < 360;
                      final tokens = _DownloaderCardTokens.of(
                        context,
                        compact: compact,
                      );
                      return Padding(
                        padding: tokens.edgeFromLTRB(12, 12, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _header(
                              typeLabel: typeLabel,
                              typeColor: typeColor,
                              successColor: successColor,
                              inactiveColor: inactiveColor,
                              active: active,
                              connected: connected,
                              version: version,
                              compact: compact,
                            ),
                            SizedBox(height: tokens.size(8)),
                            _connectionPanel(
                              context,
                              privacy: privacy,
                              typeName: typeName,
                              typeColor: typeColor,
                              compact: compact,
                            ),
                            SizedBox(height: tokens.size(8)),
                            if (liveInfo != null)
                              DownloaderLiveInfo(
                                info: liveInfo,
                                isQb: isQb,
                                compact: compact,
                              )
                            else
                              _emptyLivePanel(
                                context,
                                color: inactiveColor,
                                compact: compact,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!context.isMobile) return card;

    return OverlayManagerLayer(
      child: card,
    );
  }

  Widget _header({
    required String typeLabel,
    required Color typeColor,
    required Color successColor,
    required Color inactiveColor,
    required bool active,
    required bool connected,
    required String version,
    required bool compact,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final tokens = _DownloaderCardTokens.of(context, compact: compact);
    final title = d.name.isEmpty ? '未命名下载器' : d.name;
    final pills = [
      _statusPill(
        icon: connected ? shadcn.LucideIcons.link : shadcn.LucideIcons.unlink,
        label: connected ? '已连接' : '未连接',
        color: connected ? successColor : inactiveColor,
        compact: compact,
      ),
      _statusPill(
        icon: active ? shadcn.LucideIcons.power : shadcn.LucideIcons.powerOff,
        label: active ? '已启用' : '已停用',
        color: active ? successColor : inactiveColor,
        compact: compact,
      ),
      _statusPill(
        icon: shadcn.LucideIcons.zap,
        label: d.brush ? '辅种关闭' : '辅种开启',
        color: d.brush ? cs.mutedForeground : typeColor,
        compact: compact,
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _typeMark(typeLabel, typeColor, active, connected, compact: compact),
        SizedBox(width: tokens.size(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: typo.normal.copyWith(
                        color: cs.foreground,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (version.isNotEmpty) ...[
                    SizedBox(width: tokens.size(8)),
                    _miniBadge(version, typeColor, compact: compact),
                  ],
                ],
              ),
              SizedBox(height: tokens.size(5)),
              Wrap(
                spacing: tokens.size(5),
                runSpacing: tokens.size(4),
                children: pills,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _connectionPanel(
    BuildContext context, {
    required bool privacy,
    required String typeName,
    required Color typeColor,
    required bool compact,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final tokens = _DownloaderCardTokens.of(context, compact: compact);
    final address = _downloaderAddress(privacy);
    final path = d.torrentPath.isEmpty ? '-' : d.torrentPath;

    return Container(
      width: double.infinity,
      padding: tokens.edgeSymmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(color: cs.border.withValues(alpha: 0.62)),
      ),
      child: compact
          ? Column(
              children: [
                _infoLine(
                  icon: shadcn.LucideIcons.link,
                  label: typeName,
                  value: address,
                  accent: typeColor,
                  copyValue: address,
                  compact: compact,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: tokens.size(32),
                    top: tokens.size(5),
                    bottom: tokens.size(5),
                  ),
                  child: Divider(
                    height: 1,
                    color: cs.border.withValues(alpha: 0.55),
                  ),
                ),
                _infoLine(
                  icon: shadcn.LucideIcons.folder,
                  label: '种子路径',
                  value: path,
                  accent: cs.mutedForeground,
                  copyValue: d.torrentPath,
                  compact: compact,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _infoBlock(
                    icon: shadcn.LucideIcons.link,
                    label: typeName,
                    value: address,
                    accent: typeColor,
                    copyValue: address,
                    compact: compact,
                  ),
                ),
                SizedBox(width: tokens.size(8)),
                Expanded(
                  child: _infoBlock(
                    icon: shadcn.LucideIcons.folder,
                    label: '种子路径',
                    value: path,
                    accent: cs.mutedForeground,
                    copyValue: d.torrentPath,
                    compact: compact,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _emptyLivePanel(
    BuildContext context, {
    required Color color,
    required bool compact,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final tokens = _DownloaderCardTokens.of(context, compact: compact);
    final panel = Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: tokens.size(compact ? 70 : 84)),
      padding: tokens.edgeAll(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.024),
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: tokens.size(34),
            height: tokens.size(34),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.card.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(theme.radiusMd),
              border: Border.all(color: color.withValues(alpha: 0.12)),
            ),
            child: Icon(
              shadcn.LucideIcons.activity,
              size: tokens.icon(17),
              color: color,
            ),
          ),
          SizedBox(width: tokens.size(10)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '暂无实时状态',
                  style: theme.typography.small.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: tokens.size(2)),
                Text(
                  '等待实时连接后显示速度与累计数据',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(
                    color: cs.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (compact) return panel;
    return Expanded(child: panel);
  }

  Future<void> _openTorrentList() async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TorrentListPage(
          downloaderId: d.id,
          downloaderName: d.name,
          downloaderType: d.isQb
              ? DownloaderType.qbittorrent
              : DownloaderType.transmission,
        ),
      ),
    );
  }

  String _versionFor(DownloaderInfo? liveInfo, DownloaderSpeedData? liveData) {
    final candidates = <dynamic>[
      liveInfo?.version,
      liveData?.prefs['version'],
      liveData?.prefs['app_version'],
      liveData?.prefs['appVersion'],
      liveData?.prefs['qb_version'],
      liveData?.prefs['qbVersion'],
      d.status?['version'],
      d.status?['app_version'],
      d.status?['appVersion'],
      d.status?['qb_version'],
      d.status?['qbVersion'],
      _mapValue(d.status?['prefs'], 'version'),
      _mapValue(d.status?['preferences'], 'version'),
      d.prefs?['version'],
      d.prefs?['app_version'],
      d.prefs?['appVersion'],
      d.prefs?['qb_version'],
      d.prefs?['qbVersion'],
      isQb ? d.qbPrefs?.version : d.trPrefs?.version,
    ];
    for (final candidate in candidates) {
      final version = _normalizeVersion(candidate);
      if (version.isNotEmpty) return version;
    }
    return '';
  }

  dynamic _mapValue(dynamic value, String key) {
    if (value is Map<String, dynamic>) return value[key];
    if (value is Map) return value[key];
    return null;
  }

  String _normalizeVersion(dynamic value) {
    var text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    while (text.length >= 2 &&
        ((text.startsWith('"') && text.endsWith('"')) ||
            (text.startsWith("'") && text.endsWith("'")))) {
      text = text.substring(1, text.length - 1).trim();
    }
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    if (text.contains(' ')) text = text.substring(0, text.indexOf(' '));
    if (text.startsWith('v') || text.startsWith('V')) return text;
    return 'v$text';
  }

  String _downloaderAddress(bool privacy) {
    final address = '${d.protocol}://${d.host}:${d.port}';
    if (!privacy) return address;
    final uri = Uri.tryParse(address);
    if (uri == null || uri.host.isEmpty) return _maskText(address);
    final maskedHost = uri.host.split('.').map(_maskText).join('.');
    final authority = uri.hasPort ? '$maskedHost:${uri.port}' : maskedHost;
    return uri.hasScheme ? '${uri.scheme}://$authority' : authority;
  }

  String _maskText(String text) {
    if (text.length <= 1) return '*';
    if (text.length == 2) return '${text[0]}*';
    return '${text[0]}*${text[text.length - 1]}';
  }

  Future<void> _copyValue(String value) async {
    final text = value.trim();
    if (text.isEmpty || text == '-') return;
    await Clipboard.setData(ClipboardData(text: text));
    Toast.success('已复制');
  }

  Widget _typeMark(
    String label,
    Color color,
    bool active,
    bool connected, {
    required bool compact,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final tokens = _DownloaderCardTokens.of(context, compact: compact);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: tokens.size(52),
          height: tokens.size(52),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withValues(alpha: 0.78), color],
                  )
                : null,
            color: active ? null : cs.muted.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(theme.radiusMd),
            border: Border.all(
              color: active
                  ? color.withValues(alpha: 0.32)
                  : cs.border.withValues(alpha: 0.82),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.26),
                      blurRadius: tokens.size(12),
                      offset: Offset(0, tokens.size(6)),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.typography.normal.copyWith(
              color: active ? Colors.white : cs.mutedForeground,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Positioned(
          right: -tokens.size(1),
          bottom: -tokens.size(1),
          child: Container(
            width: tokens.size(14),
            height: tokens.size(14),
            decoration: BoxDecoration(
              color: connected ? const Color(0xFF10B981) : cs.mutedForeground,
              shape: BoxShape.circle,
              border: Border.all(color: cs.card, width: tokens.size(1.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusPill({
    required IconData icon,
    required String label,
    required Color color,
    required bool compact,
  }) {
    final theme = shadcn.Theme.of(context);
    final tokens = _DownloaderCardTokens.of(context, compact: compact);
    return Container(
      padding: tokens.edgeSymmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(theme.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: tokens.icon(12), color: color),
          SizedBox(width: tokens.size(4)),
          Text(
            label,
            style: theme.typography.xSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBadge(String label, Color color, {required bool compact}) {
    final theme = shadcn.Theme.of(context);
    final tokens = _DownloaderCardTokens.of(context, compact: compact);
    return Container(
      padding: tokens.edgeSymmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(theme.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: theme.typography.xSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoLine({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
    required String copyValue,
    required bool compact,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final tokens = _DownloaderCardTokens.of(context, compact: compact);
    return Row(
      children: [
        Container(
          width: tokens.size(24),
          height: tokens.size(24),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(theme.radiusSm),
            border: Border.all(color: accent.withValues(alpha: 0.10)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: tokens.icon(13), color: accent),
        ),
        SizedBox(width: tokens.size(10)),
        SizedBox(
          width: tokens.size(92),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.xSmall.copyWith(
              color: cs.foreground.withValues(alpha: 0.78),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: tokens.size(8)),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.xSmall.copyWith(
              color: cs.foreground.withValues(alpha: 0.88),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: tokens.size(6)),
        shadcn.IconButton.ghost(
          size: shadcn.ButtonSize.small,
          onPressed: copyValue.trim().isEmpty || copyValue == '-'
              ? null
              : () => _copyValue(copyValue),
          icon: Icon(
            shadcn.LucideIcons.copy,
            size: tokens.icon(14),
            color: cs.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _infoBlock({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
    required String copyValue,
    required bool compact,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final tokens = _DownloaderCardTokens.of(context, compact: compact);
    return Row(
      children: [
        Container(
          width: tokens.size(24),
          height: tokens.size(24),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(theme.radiusSm),
            border: Border.all(color: accent.withValues(alpha: 0.10)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: tokens.icon(13), color: accent),
        ),
        SizedBox(width: tokens.size(8)),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xSmall.copyWith(
                  color: cs.foreground.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: tokens.size(1)),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xSmall.copyWith(
                  color: cs.foreground.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: tokens.size(4)),
        shadcn.IconButton.ghost(
          size: shadcn.ButtonSize.small,
          onPressed: copyValue.trim().isEmpty || copyValue == '-'
              ? null
              : () => _copyValue(copyValue),
          icon: Icon(
            shadcn.LucideIcons.copy,
            size: tokens.icon(14),
            color: cs.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _DownloaderCardTokens {
  final double densityScale;
  final double iconScale;

  const _DownloaderCardTokens._({
    required this.densityScale,
    required this.iconScale,
  });

  factory _DownloaderCardTokens.of(
    BuildContext context, {
    bool compact = false,
  }) {
    final theme = shadcn.Theme.of(context);
    final densityScale =
        ((theme.density.baseContentPadding / 16.0) *
                theme.scaling *
                (compact ? 0.92 : 1.0))
            .clamp(0.68, 1.28)
            .toDouble();
    return _DownloaderCardTokens._(
      densityScale: densityScale,
      iconScale: theme.scaling.clamp(0.82, 1.24).toDouble(),
    );
  }

  double size(num value) => value * densityScale;

  double icon(num value) => value * iconScale;

  EdgeInsets edgeAll(num value) => EdgeInsets.all(size(value));

  EdgeInsets edgeFromLTRB(num left, num top, num right, num bottom) =>
      EdgeInsets.fromLTRB(size(left), size(top), size(right), size(bottom));

  EdgeInsets edgeSymmetric({num horizontal = 0, num vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: size(horizontal),
        vertical: size(vertical),
      );
}
