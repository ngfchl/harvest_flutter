import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/downloader.dart';
import '../model/transmission_preferences.dart';
import '../service/downloader_service.dart';

class TrSettingsDialog extends ConsumerStatefulWidget {
  final Downloader downloader;
  final int initialIndex;

  const TrSettingsDialog({
    super.key,
    required this.downloader,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<TrSettingsDialog> createState() => _TrSettingsDialogState();
}

class _TrSettingsDialogState extends ConsumerState<TrSettingsDialog> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  TransmissionPreferences? _prefs;

  // ── 存储 ──
  final _downloadDirCtrl = TextEditingController();
  final _incompleteDirCtrl = TextEditingController();
  bool _incompleteDirEnabled = false;
  bool _renamePartial = true;

  // ── 限速 ──
  final _speedDownCtrl = TextEditingController();
  final _speedUpCtrl = TextEditingController();
  bool _speedDownEnabled = false;
  bool _speedUpEnabled = false;
  final _altSpeedDownCtrl = TextEditingController();
  final _altSpeedUpCtrl = TextEditingController();
  bool _altSpeedEnabled = false;

  // ── 备用带宽调度 ──
  bool _altSpeedTimeEnabled = false;
  int _altSpeedTimeBegin = 540;
  int _altSpeedTimeEnd = 1020;
  int _altSpeedTimeDay = 127;
  final _altTimeBeginCtrl = TextEditingController();
  final _altTimeEndCtrl = TextEditingController();

  // ── 连接 ──
  final _peerLimitGlobalCtrl = TextEditingController();
  final _peerLimitPerTorrentCtrl = TextEditingController();
  final _peerPortCtrl = TextEditingController();
  bool _portForwarding = true;
  bool _peerPortRandomOnStart = false;
  bool _tcpEnabled = true;

  // ── 队列 ──
  bool _downloadQueueEnabled = true;
  final _downloadQueueSizeCtrl = TextEditingController();
  bool _seedQueueEnabled = false;
  final _seedQueueSizeCtrl = TextEditingController();
  bool _queueStalledEnabled = true;
  final _queueStalledMinutesCtrl = TextEditingController();

  // ── 做种 ──
  bool _seedRatioLimited = false;
  final _seedRatioLimitCtrl = TextEditingController();
  bool _idleSeedingLimitEnabled = false;
  final _idleSeedingLimitCtrl = TextEditingController();

  // ── 网络 ──
  bool _dht = true;
  bool _pex = true;
  bool _lpd = false;
  bool _utp = false;
  String _encryption = 'preferred';

  // ── 黑名单 ──
  bool _blocklistEnabled = false;
  final _blocklistUrlCtrl = TextEditingController();

  // ── 其他 ──
  bool _startAddedTorrents = true;
  bool _trashOriginal = false;
  final _cacheSizeCtrl = TextEditingController();

  Downloader get d => widget.downloader;

  bool get _isMobile => PlatformTool.isSmallScreenPortrait();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await DownloaderService.fetchPrefs(d.id);
      if (prefs == null) {
        setState(() {
          _loading = false;
          _error = '无法获取设置';
        });
        return;
      }
      _prefs = TransmissionPreferences.fromJson(prefs);
      _fillControllers();
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '加载失败: $e';
      });
    }
  }

  void _fillControllers() {
    final p = _prefs!;

    // 存储
    _downloadDirCtrl.text = p.downloadDir;
    _incompleteDirCtrl.text = p.incompleteDir;
    _incompleteDirEnabled = p.incompleteDirEnabled;
    _renamePartial = p.renamePartialFiles;

    // 限速
    _speedDownCtrl.text = p.speedLimitDown.toString();
    _speedUpCtrl.text = p.speedLimitUp.toString();
    _speedDownEnabled = p.speedLimitDownEnabled;
    _speedUpEnabled = p.speedLimitUpEnabled;
    _altSpeedDownCtrl.text = p.altSpeedDown.toString();
    _altSpeedUpCtrl.text = p.altSpeedUp.toString();
    _altSpeedEnabled = p.altSpeedEnabled;

    // 备用带宽调度
    _altSpeedTimeEnabled = p.altSpeedTimeEnabled;
    _altSpeedTimeBegin = p.altSpeedTimeBegin;
    _altSpeedTimeEnd = p.altSpeedTimeEnd;
    _altSpeedTimeDay = p.altSpeedTimeDay;
    _altTimeBeginCtrl.text = _minutesToHHMM(_altSpeedTimeBegin);
    _altTimeEndCtrl.text = _minutesToHHMM(_altSpeedTimeEnd);

    // 连接
    _peerLimitGlobalCtrl.text = p.peerLimitGlobal.toString();
    _peerLimitPerTorrentCtrl.text = p.peerLimitPerTorrent.toString();
    _peerPortCtrl.text = p.peerPort.toString();
    _portForwarding = p.portForwardingEnabled;
    _peerPortRandomOnStart = p.peerPortRandomOnStart;
    _tcpEnabled = p.tcpEnabled;

    // 队列
    _downloadQueueEnabled = p.downloadQueueEnabled;
    _downloadQueueSizeCtrl.text = p.downloadQueueSize.toString();
    _seedQueueEnabled = p.seedQueueEnabled;
    _seedQueueSizeCtrl.text = p.seedQueueSize.toString();
    _queueStalledEnabled = p.queueStalledEnabled;
    _queueStalledMinutesCtrl.text = p.queueStalledMinutes.toString();

    // 做种
    _seedRatioLimited = p.seedRatioLimited;
    _seedRatioLimitCtrl.text = p.seedRatioLimit.toString();
    _idleSeedingLimitEnabled = p.idleSeedingLimitEnabled;
    _idleSeedingLimitCtrl.text = p.idleSeedingLimit.toString();

    // 网络
    _dht = p.dhtEnabled;
    _pex = p.pexEnabled;
    _lpd = p.lpdEnabled;
    _utp = p.utpEnabled;
    _encryption = p.encryption;

    // 黑名单
    _blocklistEnabled = p.blocklistEnabled;
    _blocklistUrlCtrl.text = p.blocklistUrl;

    // 其他
    _startAddedTorrents = p.startAddedTorrents;
    _trashOriginal = p.trashOriginalTorrentFiles;
    _cacheSizeCtrl.text = p.cacheSizeMb.toString();
  }

  // ── 时间工具 ──

  String _minutesToHHMM(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  int? _parseHHMMToMinutes(String text) {
    final parts = text.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return h * 60 + m;
  }

  bool _isDaySelected(int dayIndex) =>
      (_altSpeedTimeDay & (1 << dayIndex)) != 0;

  void _toggleDay(int dayIndex, bool value) {
    setState(() {
      if (value) {
        _altSpeedTimeDay |= (1 << dayIndex);
      } else {
        _altSpeedTimeDay &= ~(1 << dayIndex);
      }
    });
  }

  // ── 保存 ──

  Future<void> _save() async {
    final begin = _parseHHMMToMinutes(_altTimeBeginCtrl.text.trim());
    final end = _parseHHMMToMinutes(_altTimeEndCtrl.text.trim());
    if (_altSpeedTimeEnabled && (begin == null || end == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('备用带宽时间段格式无效，请使用 HH:MM')));
      return;
    }

    setState(() => _saving = true);
    try {
      await DownloaderService.savePrefs(d.id, {
        'download-dir': _downloadDirCtrl.text.trim(),
        'incomplete-dir': _incompleteDirCtrl.text.trim(),
        'incomplete-dir-enabled': _incompleteDirEnabled,
        'rename-partial-files': _renamePartial,
        'speed-limit-down': int.tryParse(_speedDownCtrl.text.trim()) ?? 100,
        'speed-limit-up': int.tryParse(_speedUpCtrl.text.trim()) ?? 100,
        'speed-limit-down-enabled': _speedDownEnabled,
        'speed-limit-up-enabled': _speedUpEnabled,
        'alt-speed-down': int.tryParse(_altSpeedDownCtrl.text.trim()) ?? 50,
        'alt-speed-up': int.tryParse(_altSpeedUpCtrl.text.trim()) ?? 50,
        'alt-speed-enabled': _altSpeedEnabled,
        'alt-speed-time-enabled': _altSpeedTimeEnabled,
        'alt-speed-time-begin': begin ?? _altSpeedTimeBegin,
        'alt-speed-time-end': end ?? _altSpeedTimeEnd,
        'alt-speed-time-day': _altSpeedTimeDay,
        'peer-limit-global':
            int.tryParse(_peerLimitGlobalCtrl.text.trim()) ?? 200,
        'peer-limit-per-torrent':
            int.tryParse(_peerLimitPerTorrentCtrl.text.trim()) ?? 50,
        'peer-port': int.tryParse(_peerPortCtrl.text.trim()) ?? 51413,
        'port-forwarding-enabled': _portForwarding,
        'peer-port-random-on-start': _peerPortRandomOnStart,
        'tcp-enabled': _tcpEnabled,
        'download-queue-enabled': _downloadQueueEnabled,
        'download-queue-size':
            int.tryParse(_downloadQueueSizeCtrl.text.trim()) ?? 5,
        'seed-queue-enabled': _seedQueueEnabled,
        'seed-queue-size': int.tryParse(_seedQueueSizeCtrl.text.trim()) ?? 10,
        'queue-stalled-enabled': _queueStalledEnabled,
        'queue-stalled-minutes':
            int.tryParse(_queueStalledMinutesCtrl.text.trim()) ?? 30,
        'seedRatioLimited': _seedRatioLimited,
        'seedRatioLimit':
            double.tryParse(_seedRatioLimitCtrl.text.trim()) ?? 2.0,
        'idle-seeding-limit-enabled': _idleSeedingLimitEnabled,
        'idle-seeding-limit':
            int.tryParse(_idleSeedingLimitCtrl.text.trim()) ?? 30,
        'dht-enabled': _dht,
        'pex-enabled': _pex,
        'lpd-enabled': _lpd,
        'utp-enabled': _utp,
        'encryption': _encryption,
        'blocklist-enabled': _blocklistEnabled,
        'blocklist-url': _blocklistUrlCtrl.text.trim(),
        'start-added-torrents': _startAddedTorrents,
        'trash-original-torrent-files': _trashOriginal,
        'cache-size-mb': int.tryParse(_cacheSizeCtrl.text.trim()) ?? 4,
      });
      if (mounted) {
        Navigator.of(context).pop();
        Toast.success('设置已保存');
      }
    } catch (e, trace) {
      String msg = "Tr 设置保存失败！$e";
      AppLogger.error(msg);
      AppLogger.error("Tr 设置保存失败！$trace");
      if (mounted) {
        Toast.error(msg);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _downloadDirCtrl.dispose();
    _incompleteDirCtrl.dispose();
    _speedDownCtrl.dispose();
    _speedUpCtrl.dispose();
    _altSpeedDownCtrl.dispose();
    _altSpeedUpCtrl.dispose();
    _altTimeBeginCtrl.dispose();
    _altTimeEndCtrl.dispose();
    _peerLimitGlobalCtrl.dispose();
    _peerLimitPerTorrentCtrl.dispose();
    _peerPortCtrl.dispose();
    _downloadQueueSizeCtrl.dispose();
    _seedQueueSizeCtrl.dispose();
    _queueStalledMinutesCtrl.dispose();
    _seedRatioLimitCtrl.dispose();
    _idleSeedingLimitCtrl.dispose();
    _blocklistUrlCtrl.dispose();
    _cacheSizeCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Dialog(
      insetPadding: _isMobile
          ? const EdgeInsets.all(8)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * (_isMobile ? 0.95 : 0.9),
          maxWidth: _isMobile ? double.infinity : 560,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            Divider(height: 1, color: theme.colors.border),
            Expanded(
              child: _loading
                  ? Center(child: FProgress.circularIcon())
                  : _error != null
                  ? _buildError(theme)
                  : _buildTabbedBody(theme),
            ),
            if (!_loading && _error == null) _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  // ── Header ──

  Widget _buildHeader(FThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              FIcons.arrowUpDown,
              size: 14,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${d.name} · 参数设置',
              style: theme.typography.sm.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          FButton.icon(
            style: FButtonStyle.ghost(),
            onPress: () => Navigator.of(context).pop(),
            child: const Icon(FIcons.x, size: 16),
          ),
        ],
      ),
    );
  }

  // ── Error ──

  Widget _buildError(FThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FIcons.info,
            size: 32,
            color: theme.colors.mutedForeground.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ──

  Widget _buildFooter(FThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        child: Row(
          children: [
            Expanded(
              child: FButton(
                style: FButtonStyle.outline(),
                onPress: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FButton(
                onPress: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  标签页主体 — 手机用 FAccordion / 其他用 FTabs
  // ═══════════════════════════════════════════

  Widget _buildTabbedBody(FThemeData theme) {
    // 手机端：FAccordion，可折叠展开
    if (_isMobile) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: FAccordion(
          children: [
            FAccordionItem(
              title: const Text('下载设置'),
              initiallyExpanded: widget.initialIndex == 0,
              child: _buildDownloadSection(theme),
            ),
            FAccordionItem(
              title: const Text('带宽设置'),
              initiallyExpanded: widget.initialIndex == 1,
              child: _buildBandwidthSection(theme),
            ),
            FAccordionItem(
              title: const Text('网络设置'),
              initiallyExpanded: widget.initialIndex == 2,
              child: _buildNetworkSection(theme),
            ),
            FAccordionItem(
              title: const Text('队列设置'),
              initiallyExpanded: widget.initialIndex == 3,
              child: _buildQueueSection(theme),
            ),
            // FAccordionItem(title: const Text('其他设置'), child: _buildOtherSection(theme)),
          ],
        ),
      );
    }

    // 桌面端 / 平板：FTabs，标签页切换
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.7;
        final bodyHeight = (availableHeight - 76).clamp(120.0, double.infinity).toDouble();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: FTabs(
            initialIndex: widget.initialIndex.clamp(0, 3).toInt(),
            children: [
              FTabEntry(
                label: const Text('下载设置'),
                child: _ScrollableSection(height: bodyHeight, child: _buildDownloadSection(theme)),
              ),
              FTabEntry(
                label: const Text('带宽设置'),
                child: _ScrollableSection(height: bodyHeight, child: _buildBandwidthSection(theme)),
              ),
              FTabEntry(
                label: const Text('网络设置'),
                child: _ScrollableSection(height: bodyHeight, child: _buildNetworkSection(theme)),
              ),
              FTabEntry(
                label: const Text('队列设置'),
                child: _ScrollableSection(height: bodyHeight, child: _buildQueueSection(theme)),
              ),
              // FTabEntry(
              //   label: const Text('其他设置'),
              //   child: _ScrollableSection(height: bodyHeight, child: _buildOtherSection(theme)),
              // ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  //  各标签页内容
  // ═══════════════════════════════════════════

  // ── 下载设置 ──

  Widget _buildDownloadSection(FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FTextFormField(
          controller: _downloadDirCtrl,
          label: const Text('默认保存目录'),
          hint: '/downloads/complete',
        ),
        const SizedBox(height: 10),
        _switchTile(
          theme,
          FIcons.fileText,
          '在未完成的文件名后加上 ".part" 后缀',
          _renamePartial,
          (v) => setState(() => _renamePartial = v),
        ),
        const SizedBox(height: 4),
        _switchTile(
          theme,
          FIcons.folderOpen,
          '启用临时目录',
          _incompleteDirEnabled,
          (v) => setState(() => _incompleteDirEnabled = v),
        ),
        if (_incompleteDirEnabled) ...[
          const SizedBox(height: 6),
          FTextFormField(
            controller: _incompleteDirCtrl,
            label: const Text('临时目录'),
            hint: '/downloads/incomplete',
          ),
        ],
        const SizedBox(height: 10),
        _switchTile(
          theme,
          FIcons.play,
          '自动开始添加的种子',
          _startAddedTorrents,
          (v) => setState(() => _startAddedTorrents = v),
        ),
        const SizedBox(height: 4),
        _switchTile(
          theme,
          FIcons.trash2,
          '完成后删除原始种子文件',
          _trashOriginal,
          (v) => setState(() => _trashOriginal = v),
        ),
        _sectionLabel(theme, '做种限制'),
        _switchTile(
          theme,
          FIcons.ratio,
          '限制分享率',
          _seedRatioLimited,
          (v) => setState(() => _seedRatioLimited = v),
        ),
        if (_seedRatioLimited) ...[
          const SizedBox(height: 6),
          FTextFormField(
            controller: _seedRatioLimitCtrl,
            label: const Text('默认分享率上限'),
            hint: '2.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        const SizedBox(height: 4),
        _switchTile(
          theme,
          FIcons.clock,
          '限制空闲做种时间',
          _idleSeedingLimitEnabled,
          (v) => setState(() => _idleSeedingLimitEnabled = v),
        ),
        if (_idleSeedingLimitEnabled) ...[
          const SizedBox(height: 6),
          FTextFormField(
            controller: _idleSeedingLimitCtrl,
            label: const Text('默认停止无流量种子持续时间 (分钟)'),
            hint: '30',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),

        _sectionLabel(theme, '磁盘'),
        FTextFormField(
          controller: _cacheSizeCtrl,
          label: const Text('磁盘缓存大小 (MB)'),
          hint: '4',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  // ── 带宽设置 ──

  Widget _buildBandwidthSection(FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 正常限速
        _sectionLabel(theme, '正常限速'),
        _switchTile(
          theme,
          FIcons.arrowDown,
          '启用下载限速',
          _speedDownEnabled,
          (v) => setState(() => _speedDownEnabled = v),
        ),
        if (_speedDownEnabled) ...[
          const SizedBox(height: 6),
          FTextFormField(
            controller: _speedDownCtrl,
            label: const Text('最大下载速度 (KB/s)'),
            hint: '100',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
        const SizedBox(height: 4),
        _switchTile(
          theme,
          FIcons.arrowUp,
          '启用上传限速',
          _speedUpEnabled,
          (v) => setState(() => _speedUpEnabled = v),
        ),
        if (_speedUpEnabled) ...[
          const SizedBox(height: 6),
          FTextFormField(
            controller: _speedUpCtrl,
            label: const Text('最大上传速度 (KB/s)'),
            hint: '100',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),

        // 备用限速
        _sectionLabel(theme, '备用限速'),
        _switchTile(
          theme,
          FIcons.zap,
          '启用备用带宽',
          _altSpeedEnabled,
          (v) => setState(() => _altSpeedEnabled = v),
        ),
        if (_altSpeedEnabled) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: FTextFormField(
                  controller: _altSpeedDownCtrl,
                  label: const Text('备用下载 (KB/s)'),
                  hint: '50',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FTextFormField(
                  controller: _altSpeedUpCtrl,
                  label: const Text('备用上传 (KB/s)'),
                  hint: '50',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),

        // 自动调度
        _switchTile(
          theme,
          FIcons.calendar,
          '自动启用备用带宽设置 (时间段内)',
          _altSpeedTimeEnabled,
          (v) => setState(() => _altSpeedTimeEnabled = v),
        ),
        if (_altSpeedTimeEnabled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FTextFormField(
                  controller: _altTimeBeginCtrl,
                  label: const Text('从'),
                  hint: '09:00',
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FTextFormField(
                  controller: _altTimeEndCtrl,
                  label: const Text('到'),
                  hint: '17:00',
                  keyboardType: TextInputType.datetime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '启用日期',
            style: theme.typography.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: List.generate(7, (i) {
              const labels = ['星期天', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
              return SizedBox(
                width: 100,
                child: FTile(
                  title: Text(labels[i], style: theme.typography.xs),
                  suffix: FSwitch(
                    value: _isDaySelected(i),
                    onChange: (v) => _toggleDay(i, v),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  // ── 网络设置 ──

  Widget _buildNetworkSection(FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FTextFormField(
          controller: _peerPortCtrl,
          label: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: const Text('连接端口号'),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 4),
        _switchTile(
          theme,
          FIcons.dices,
          '启用随机端口',
          _peerPortRandomOnStart,
          (v) => setState(() => _peerPortRandomOnStart = v),
        ),
        _switchTile(
          theme,
          FIcons.router,
          '启用端口转发 (UPnP)',
          _portForwarding,
          (v) => setState(() => _portForwarding = v),
        ),

        const SizedBox(height: 10),
        _encryptionSelect(theme),

        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FTextFormField(
                controller: _peerLimitGlobalCtrl,
                label: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: const Text('全局最大连接数'),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FTextFormField(
                controller: _peerLimitPerTorrentCtrl,
                label: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: const Text('单种最大连接数'),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        _switchTile(
          theme,
          FIcons.share2,
          '启用用户交换 (PEX)',
          _pex,
          (v) => setState(() => _pex = v),
        ),
        _switchTile(
          theme,
          FIcons.network,
          '启用分布式哈希表 (DHT)',
          _dht,
          (v) => setState(() => _dht = v),
        ),
        _switchTile(
          theme,
          FIcons.radio,
          '启用本地用户发现 (LPD)',
          _lpd,
          (v) => setState(() => _lpd = v),
        ),
        _switchTile(
          theme,
          FIcons.zap,
          '启用带宽管理 (μTP)',
          _utp,
          (v) => setState(() => _utp = v),
        ),
        _switchTile(
          theme,
          FIcons.globe,
          '启用 TCP',
          _tcpEnabled,
          (v) => setState(() => _tcpEnabled = v),
        ),

        const SizedBox(height: 10),
        _switchTile(
          theme,
          FIcons.shieldBan,
          '启用黑名单列表',
          _blocklistEnabled,
          (v) => setState(() => _blocklistEnabled = v),
        ),
        if (_blocklistEnabled) ...[
          const SizedBox(height: 6),
          FTextFormField(
            controller: _blocklistUrlCtrl,
            label: const Text('黑名单 URL'),
            hint: 'http://www.example.com/blocklist',
          ),
        ],
      ],
    );
  }

  // ── 队列设置 ──

  Widget _buildQueueSection(FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _switchTile(
          theme,
          FIcons.download,
          '启用下载队列',
          _downloadQueueEnabled,
          (v) => setState(() => _downloadQueueEnabled = v),
        ),
        if (_downloadQueueEnabled) ...[
          const SizedBox(height: 6),
          FTextFormField(
            controller: _downloadQueueSizeCtrl,
            label: const Text('最大同时下载数'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
        const SizedBox(height: 4),
        _switchTile(
          theme,
          FIcons.upload,
          '启用上传队列',
          _seedQueueEnabled,
          (v) => setState(() => _seedQueueEnabled = v),
        ),
        if (_seedQueueEnabled) ...[
          const SizedBox(height: 6),
          FTextFormField(
            controller: _seedQueueSizeCtrl,
            label: const Text('最大同时上传数'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
        const SizedBox(height: 10),
        _switchTile(
          theme,
          FIcons.clock,
          '启用停滞判定',
          _queueStalledEnabled,
          (v) => setState(() => _queueStalledEnabled = v),
        ),
        if (_queueStalledEnabled) ...[
          const SizedBox(height: 6),
          FTextFormField(
            controller: _queueStalledMinutesCtrl,
            label: const Text('种子超过该时间无流量，移出队列 (分钟)'),
            hint: '30',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════
  //  公共组件
  // ═══════════════════════════════════════════

  Widget _encryptionSelect(FThemeData theme) {
    return FTile(
      prefix: const Icon(FIcons.lock, size: 14),
      title: const Text('加密'),
      suffix: FSelect<String>(
        initialValue: _encryption,
        format: (v) {
          switch (v) {
            case 'required':
              return '强制加密';
            case 'preferred':
              return '优先加密';
            default:
              return '允许明文';
          }
        },
        onChange: (v) {
          if (v != null) setState(() => _encryption = v);
        },
        children: [
          FSelectItem('允许明文', 'tolerated'),
          FSelectItem('优先加密', 'preferred'),
          FSelectItem('强制加密', 'required'),
        ],
      ),
    );
  }

  Widget _sectionLabel(FThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: theme.typography.sm.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _switchTile(
    FThemeData theme,
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChange,
  ) {
    return FTile(
      prefix: Icon(icon, size: 14),
      title: Text(title),
      suffix: FSwitch(value: value, onChange: onChange),
    );
  }
}

/// 桌面端 FTabs 内部可滚动容器
class _ScrollableSection extends StatelessWidget {
  final double height;
  final Widget child;

  const _ScrollableSection({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Scrollbar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 18),
          child: child,
        ),
      ),
    );
  }
}
