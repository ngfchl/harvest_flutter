import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'site_theme.dart';
import 'package:share_plus/share_plus.dart';

import '../model/site_config.dart';
import '../provider/site_provider.dart';
import '../service/site_service.dart';

void showSiteConfigGenerator(BuildContext context) {
  final dialog = const SiteConfigGeneratorDialog();
  if (context.isMobile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: siteTransparent(context),
      builder: (ctx) =>
          SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.92, child: dialog),
    );
  } else {
    shadcn.showDialog(
      context: context,
      builder: (_) => shadcn.AlertDialog(
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 920,
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: SiteConfigGeneratorDialog(),
        ),
      ),
    );
  }
}

class SiteConfigGeneratorDialog extends ConsumerStatefulWidget {
  const SiteConfigGeneratorDialog({super.key});

  @override
  ConsumerState<SiteConfigGeneratorDialog> createState() =>
      _SiteConfigGeneratorDialogState();
}

class _SiteConfigGeneratorDialogState
    extends ConsumerState<SiteConfigGeneratorDialog> {
  final _scrollController = ScrollController();
  final _configNameController = TextEditingController();
  String? _templateName;
  _TomlTemplate? _template;
  bool _loadingTemplate = false;
  bool _initializingTemplate = false;
  bool _downloading = false;
  bool _uploading = false;
  bool _sharing = false;
  String? _error;

  @override
  void dispose() {
    _disposeTemplate();
    _configNameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _disposeTemplate() {
    final template = _template;
    if (template == null) return;
    template.dispose();
  }

  Future<void> _ensureTemplate(List<WebSite> configs) async {
    if (_templateName != null || configs.isEmpty || _initializingTemplate) {
      return;
    }
    if (!mounted) return;
    _initializingTemplate = true;
    final defaultConfig = _findDefaultTemplate(configs);
    _templateName = defaultConfig.name;
    try {
      await _loadTemplate(defaultConfig);
    } finally {
      _initializingTemplate = false;
    }
  }

  WebSite _findDefaultTemplate(List<WebSite> configs) {
    for (final config in configs) {
      if (config.name == 'NP模板') return config;
    }
    return configs.first;
  }

  Future<void> _loadTemplate(WebSite config) async {
    if (!mounted) return;
    setState(() {
      _templateName = config.name;
      _loadingTemplate = true;
      _error = null;
    });

    try {
      final raw = await SiteService.fetchWebsiteConfig(config.name);
      final content = _extractTemplateContent(raw) ?? _webSiteToToml(config);
      final next = _TomlTemplate.parse(content);
      _syncConfigNameFromTemplate(next, config.name);
      AppLogger.info(
        '站点配置模板解析完成: ${config.name}, fields=${next.fields.length}, levels=${next.levels.length}',
      );
      if (!mounted) return;
      setState(() {
        _disposeTemplate();
        _template = next;
        _loadingTemplate = false;
      });
    } catch (e, st) {
      AppLogger.error('加载站点配置模板失败: ${config.name}', e, st);
      final next = _TomlTemplate.parse(_webSiteToToml(config));
      _syncConfigNameFromTemplate(next, config.name);
      if (!mounted) return;
      setState(() {
        _disposeTemplate();
        _template = next;
        _loadingTemplate = false;
        _error = '模板接口加载失败，已使用列表数据生成基础模板';
      });
    }
  }

  String? _extractTemplateContent(Map<String, dynamic> raw) {
    return _extractTomlContent(raw);
  }

  String _configName() {
    final name = _configNameController.text.trim();
    return name.isEmpty ? (_templateName ?? 'site') : name;
  }

  void _syncConfigNameFromTemplate(_TomlTemplate template, String fallback) {
    final field = template.ensureField('name');
    final name = field.controller.text.trim();
    _configNameController.text = name.isEmpty ? fallback : name;
  }

  void _syncConfigNameToTemplate() {
    final template = _template;
    if (template == null) return;
    template.ensureField('name').controller.text = _configName();
  }

  String _configFileName() => '${_safeFileName(_configName())}.toml';

  Uint8List _configBytes() {
    _syncConfigNameToTemplate();
    final content = _template?.build() ?? '';
    return Uint8List.fromList(utf8.encode(content));
  }

  Future<void> _downloadTemplate() async {
    final template = _template;
    if (template == null || _downloading) return;
    setState(() => _downloading = true);
    try {
      final fileName = _configFileName();
      final bytes = _configBytes();
      final path = await _downloadTomlFile(fileName: fileName, bytes: bytes);
      AppLogger.info('站点配置下载完成: fileName=$fileName, path=$path');
      if (!mounted) return;
      if (path != null) Toast.success('配置文件已下载');
    } catch (e, st) {
      AppLogger.error('下载站点配置失败', e, st);
      if (mounted) Toast.error('下载站点配置失败');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _shareTemplate() async {
    final template = _template;
    if (template == null || _sharing) return;
    setState(() => _sharing = true);
    try {
      final fileName = _configFileName();
      final bytes = _configBytes();
      final tempDir = await getTemporaryDirectory();
      final file = File(p.join(tempDir.path, fileName));
      await file.writeAsBytes(bytes, flush: true);
      AppLogger.info('站点配置分享文件已生成: ${file.path}');
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: '站点配置: ${_configName()}'),
      );
    } catch (e, st) {
      AppLogger.error('分享站点配置失败', e, st);
      if (mounted) Toast.error('分享站点配置失败');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _saveTemplateToServer() async {
    final template = _template;
    if (template == null || _uploading) return;
    final overwrite = await _confirmUploadOverwrite(_configName());
    if (overwrite == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final bytes = _configBytes();
      final fileName = _configFileName();
      final file = PlatformFile(
        name: fileName,
        size: bytes.length,
        bytes: bytes,
      );
      await ref.read(siteInfoListProvider.notifier).importCustomSiteToml([
        file,
      ], overwrite: overwrite);
      if (!mounted) return;
      Toast.success('站点配置已保存到服务器');
    } catch (e, st) {
      AppLogger.error('保存站点配置到服务器失败', e, st);
      if (mounted) Toast.error('保存站点配置到服务器失败');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<bool?> _confirmUploadOverwrite(String configName) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        title: const Text('保存站点配置'),
        content: Text(
          '将以「${_safeFileName(configName)}.toml」保存到服务器。若存在同名配置，是否覆盖？',
        ),
        actions: [
          shadcn.Button.ghost(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('取消'),
          ),
          shadcn.Button.outline(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('不覆盖'),
          ),
          shadcn.Button.primary(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('覆盖'),
          ),
        ],
      ),
    );
  }

  String _safeFileName(String value) {
    final safe = value.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return safe.isEmpty ? 'site' : safe;
  }

  Future<String?> _downloadTomlFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final path = await FilePicker.saveFile(
        dialogTitle: '保存站点配置',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['toml'],
        bytes: bytes,
      );
      AppLogger.info('FilePicker 保存站点配置返回: fileName=$fileName, path=$path');
      return path;
    } on PlatformException catch (e) {
      AppLogger.error('FilePicker 保存站点配置失败: code=${e.code}', e);
      if (e.code != 'ENTITLEMENT_REQUIRED_WRITE') rethrow;
      final tempDir = await getTemporaryDirectory();
      final file = File(p.join(tempDir.path, fileName));
      await file.writeAsBytes(bytes, flush: true);
      AppLogger.info('站点配置保存到临时目录: ${file.path}');
      Toast.warning('缺少写入权限，已保存到临时目录: ${file.path}');
      return file.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final configsAsync = ref.watch(websiteListProvider);
    final mobile = context.isMobile;
    final cs = shadcn.Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(16, mobile ? 8 : 16, 16, 16),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: mobile
            ? BorderRadius.vertical(top: siteRadius(context, size: "xl").topLeft)
            : siteRadius(context, size: "xl"),
      ),
      child: configsAsync.when(
        loading: () => Center(
          child: shadcn.CircularProgressIndicator(strokeWidth: 2.4, color: cs.primary),
        ),
        error: (e, trace) => _GeneratorError(
          error: e,
          trace: trace,
          onRetry: () => ref.invalidate(websiteListProvider),
        ),
        data: (configs) {
          if (configs.isEmpty) {
            return const Center(child: Text('暂无站点配置模板'));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _ensureTemplate(configs);
          });
          return _buildContent(context, configs);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<WebSite> configs) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final template = _template;

    return Column(
      children: [
        if (context.isMobile) ...[
          buildHandle(context),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: siteRadius(context, size: "md"),
              ),
              child: Icon(
                shadcn.LucideIcons.fileCode,
                size: 18,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '生成站点配置',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typo.large.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Flexible(
              child: Text(
                '当前模板：${_templateName ?? '未选择'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: typo.xSmall.copyWith(color: cs.mutedForeground),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (template != null)
          Row(
            children: [
              Expanded(
                flex: 5,
                child: shadcn.TextField(
                  controller: _configNameController,
                  placeholder: const Text('配置名称'),
                  hintText: '保存和下载时使用该名称作为文件名',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _TemplateSelectField(
                  templateName: _templateName,
                  loading: _loadingTemplate,
                  configs: configs,
                  onSelected: _loadTemplate,
                ),
              ),
            ],
          ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: typo.xSmall.copyWith(color: cs.destructive)),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: _loadingTemplate || template == null
              ? Center(
                  child: shadcn.CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: cs.primary,
                  ),
                )
              : _TomlFieldList(
                  template: template,
                  controller: _scrollController,
                  selectOptions: _TomlSelectOptions.fromConfigs(configs),
                  onChanged: () {
                    if (mounted) setState(() {});
                  },
                ),
        ),
        const SizedBox(height: 12),
        _GeneratorFooter(
          downloading: _downloading,
          sharing: _sharing,
          uploading: _uploading,
          enabled: template != null && !_loadingTemplate,
          onDownload: _downloadTemplate,
          onShare: _shareTemplate,
          onSave: _saveTemplateToServer,
        ),
      ],
    );
  }
}

class _GeneratorFooter extends StatelessWidget {
  final bool downloading;
  final bool sharing;
  final bool uploading;
  final bool enabled;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const _GeneratorFooter({
    required this.downloading,
    required this.sharing,
    required this.uploading,
    required this.enabled,
    required this.onDownload,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FooterActionButton(
            label: '分享',
            icon: shadcn.LucideIcons.share2,
            color: siteAccent(context, 3),
            loading: sharing,
            onPress: !enabled || sharing ? null : onShare,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FooterActionButton(
            label: '下载',
            icon: shadcn.LucideIcons.download,
            color: siteInfo(context),
            loading: downloading,
            onPress: !enabled || downloading ? null : onDownload,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FooterActionButton(
            label: '保存',
            icon: shadcn.LucideIcons.save,
            color: siteSuccess(context),
            loading: uploading,
            filled: true,
            onPress: !enabled || uploading ? null : onSave,
          ),
        ),
      ],
    );
  }
}

class _FooterActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final bool filled;
  final VoidCallback? onPress;

  const _FooterActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onPress,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final enabled = onPress != null;
    final effectiveColor = enabled ? color : cs.mutedForeground;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: Opacity(
        opacity: enabled ? 1 : 0.48,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled
                ? effectiveColor
                : effectiveColor.withValues(alpha: enabled ? 0.12 : 0.06),
            borderRadius: siteRadius(context, size: "md"),
            border: Border.all(
              color: effectiveColor.withValues(alpha: enabled ? 0.48 : 0.22),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: shadcn.CircularProgressIndicator(strokeWidth: 2.2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: filled ? siteColors(context).background : effectiveColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: typo.small.copyWith(
                        color: filled ? siteColors(context).background : effectiveColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _TomlFieldList extends StatelessWidget {
  final _TomlTemplate template;
  final ScrollController controller;
  final _TomlSelectOptions selectOptions;
  final VoidCallback onChanged;

  const _TomlFieldList({
    required this.template,
    required this.controller,
    required this.selectOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectFields = [
      for (final key in _selectFieldKeys) template.ensureField(key),
    ];
    final switchFields = template.orderedFields
        .where((field) => field.kind == _TomlValueKind.boolean)
        .toList();
    final normalFields = template.orderedFields.where((field) {
      if (field.key == 'name') return false;
      if (field.kind == _TomlValueKind.boolean) return false;
      if (_selectFieldKeys.contains(field.key)) return false;
      return true;
    }).toList();
    final sections = <Widget>[
      if (selectFields.isNotEmpty)
        _TomlSelectFieldGroup(fields: selectFields, options: selectOptions),
      if (switchFields.isNotEmpty) _TomlSwitchGroup(fields: switchFields),
      for (final field in normalFields) _TomlFieldTile(field: field),
      _TomlLevelListSection(template: template, onChanged: onChanged),
    ];

    return ListView.separated(
      controller: controller,
      itemCount: sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => sections[index],
    );
  }
}

class _TemplateSelectField extends StatelessWidget {
  final String? templateName;
  final bool loading;
  final List<WebSite> configs;
  final ValueChanged<WebSite> onSelected;

  const _TemplateSelectField({
    required this.templateName,
    required this.loading,
    required this.configs,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return shadcn.Select<String>(
      key: ValueKey(templateName),
      value: templateName,
      placeholder: const Text('模板'),
      itemBuilder: (_, value) => Text(value),
      popup: shadcn.SelectPopup<String>(
        items: shadcn.SelectItemList(
          children: [
            for (final config in configs)
              shadcn.SelectItemButton<String>(
                value: config.name,
                child: Text(
                  config.name == 'NP模板' ? '${config.name}（默认）' : config.name,
                ),
              ),
          ],
        ),
      ).call,
      onChanged: (value) {
        if (loading || value == null) return;
        final selected = configs.where((e) => e.name == value).firstOrNull;
        if (selected != null) onSelected(selected);
      },
    );
  }
}

class _TomlSelectOptions {
  final List<String> structures;
  final List<String> types;
  final List<String> nations;

  const _TomlSelectOptions({
    required this.structures,
    required this.types,
    required this.nations,
  });

  factory _TomlSelectOptions.fromConfigs(List<WebSite> configs) {
    List<String> values(String Function(WebSite) getter) {
      final set = <String>{};
      for (final config in configs) {
        final value = getter(config).trim();
        if (value.isNotEmpty) set.add(value);
      }
      final list = set.toList()..sort();
      return list;
    }

    return _TomlSelectOptions(
      structures: values((config) => config.structure),
      types: values((config) => config.type),
      nations: values((config) => config.nation),
    );
  }

  List<String> optionsFor(String key) => switch (key) {
    'structure' => structures,
    'type' => types,
    'nation' => nations,
    _ => const <String>[],
  };
}

const _selectFieldKeys = {'structure', 'type', 'nation'};

class _TomlSelectFieldGroup extends StatelessWidget {
  final List<_TomlField> fields;
  final _TomlSelectOptions options;

  const _TomlSelectFieldGroup({required this.fields, required this.options});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          _FieldPanel(
            title: _FieldTitle(field: fields[i]),
            child: _TomlSelectField(
              field: fields[i],
              options: options.optionsFor(fields[i].key),
            ),
          ),
          if (i != fields.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _TomlSelectField extends StatelessWidget {
  final _TomlField field;
  final List<String> options;

  const _TomlSelectField({required this.field, required this.options});

  @override
  Widget build(BuildContext context) {
    final current = field.controller.text.trim();
    final values = [
      if (current.isNotEmpty) current,
      for (final option in options)
        if (option != current) option,
    ];
    if (values.isEmpty) {
      return shadcn.TextField(
        controller: field.controller,
        hintText: '${field.hint} · ${field.key}',
      );
    }
    return shadcn.Select<String>(
      key: ValueKey('${field.key}-$current-${values.join('|')}'),
      value: current.isEmpty ? values.first : current,
      itemBuilder: (_, value) => Text(value),
      popup: shadcn.SelectPopup<String>(
        items: shadcn.SelectItemList(
          children: [
            for (final value in values)
              shadcn.SelectItemButton<String>(value: value, child: Text(value)),
          ],
        ),
      ).call,
      onChanged: (value) {
        if (value == null) return;
        field.controller.text = value;
      },
    );
  }
}

class _TomlSwitchGroup extends StatelessWidget {
  final List<_TomlField> fields;

  const _TomlSwitchGroup({required this.fields});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.background,
              borderRadius: siteRadius(context, size: "md"),
              border: Border.all(color: cs.border, width: 0.6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldTitle(field: fields[i]),
                      const SizedBox(height: 4),
                      Text(
                        '${fields[i].key} · ${fields[i].hint}',
                        style: theme.typography.xSmall.copyWith(
                          color: cs.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: fields[i].controller,
                  builder: (_, value, __) {
                    final active = value.text.trim().toLowerCase() == 'true';
                    return shadcn.Switch(
                      value: active,
                      onChanged: (next) => fields[i].controller.text = '$next',
                    );
                  },
                ),
              ],
            ),
          ),
          if (i != fields.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _FieldPanel extends StatelessWidget {
  final Widget title;
  final Widget child;

  const _FieldPanel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: siteRadius(context, size: "md"),
        border: Border.all(color: cs.border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [title, const SizedBox(height: 8), child],
      ),
    );
  }
}

class _TomlLevelListSection extends StatelessWidget {
  final _TomlTemplate template;
  final VoidCallback onChanged;

  const _TomlLevelListSection({
    required this.template,
    required this.onChanged,
  });

  void _addLevel(BuildContext context) {
    final level = _TomlLevel.defaults(template.nextLevelId);
    template.levels.add(level);
    onChanged();
    _showTomlLevelDetail(context, level: level, onChanged: onChanged);
  }

  void _removeLevel(_TomlLevel level) {
    template.levels.remove(level);
    level.dispose();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(shadcn.LucideIcons.layers, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '用户等级',
                style: typo.small.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '${template.levels.length} 条',
              style: typo.xSmall.copyWith(color: cs.mutedForeground),
            ),
            const SizedBox(width: 8),
            shadcn.IconButton.ghost(
              onPressed: () => _addLevel(context),
              icon: shadcn.Tooltip(
                tooltip: (_) => const Text('添加用户等级'),
                child: const Icon(shadcn.LucideIcons.plus, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (template.levels.isEmpty)
          _LevelEmptyState(onAdd: () => _addLevel(context))
        else
          Column(
            children: [
              for (var i = 0; i < template.levels.length; i++) ...[
                _LevelListTile(
                  level: template.levels[i],
                  onOpen: () => _showTomlLevelDetail(
                    context,
                    level: template.levels[i],
                    onChanged: onChanged,
                  ),
                  onRemove: () => _removeLevel(template.levels[i]),
                ),
                if (i != template.levels.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
      ],
    );
  }
}

class _LevelListTile extends StatelessWidget {
  final _TomlLevel level;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  const _LevelListTile({
    required this.level,
    required this.onOpen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onOpen,
      borderRadius: siteRadius(context, size: "md"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.background,
          borderRadius: siteRadius(context, size: "md"),
          border: Border.all(color: cs.border, width: 0.6),
        ),
        child: Row(
          children: [
            Icon(shadcn.LucideIcons.medal, size: 16, color: cs.mutedForeground),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.small.copyWith(
                      color: cs.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    level.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.xSmall.copyWith(
                      color: cs.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            shadcn.IconButton.ghost(
              onPressed: onOpen,
              icon: const Icon(shadcn.LucideIcons.pencil, size: 15),
            ),
            shadcn.IconButton.ghost(
              onPressed: onRemove,
              icon: Icon(
                shadcn.LucideIcons.trash2,
                size: 15,
                color: cs.destructive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TomlFieldTile extends StatelessWidget {
  final _TomlField field;

  const _TomlFieldTile({required this.field});

  @override
  Widget build(BuildContext context) {
    return _FieldPanel(
      title: _FieldTitle(field: field),
      child: shadcn.TextField(
        controller: field.controller,
        hintText: '${field.hint} · ${field.key}',
        maxLines: field.kind == _TomlValueKind.list ? 2 : 1,
      ),
    );
  }
}

class _FieldTitle extends StatelessWidget {
  final _TomlField field;

  const _FieldTitle({required this.field});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final typo = theme.typography;
    final cs = theme.colorScheme;
    final label = _tomlFieldLabel(field.key);
    return Row(
      children: [
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        if (label != field.key) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              field.key,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.xSmall.copyWith(color: cs.mutedForeground),
            ),
          ),
        ],
      ],
    );
  }
}

void _showTomlLevelDetail(
  BuildContext context, {
  required _TomlLevel level,
  required VoidCallback onChanged,
}) {
  final editor = _TomlLevelDetail(level: level, onChanged: onChanged);
  if (context.isMobile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: siteTransparent(context),
      builder: (ctx) =>
          SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.9, child: editor),
    );
  } else {
    shadcn.showDialog(
      context: context,
      builder: (_) => shadcn.AlertDialog(
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
          child: editor,
        ),
      ),
    );
  }
}

class _TomlLevelDetail extends StatefulWidget {
  final _TomlLevel level;
  final VoidCallback onChanged;

  const _TomlLevelDetail({required this.level, required this.onChanged});

  @override
  State<_TomlLevelDetail> createState() => _TomlLevelDetailState();
}

class _TomlLevelDetailState extends State<_TomlLevelDetail> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.level.sectionController.addListener(_notifyChanged);
    for (final field in widget.level.fields.values) {
      field.controller.addListener(_notifyChanged);
    }
  }

  @override
  void dispose() {
    widget.level.sectionController.removeListener(_notifyChanged);
    for (final field in widget.level.fields.values) {
      field.controller.removeListener(_notifyChanged);
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final mobile = context.isMobile;

    return Container(
      padding: EdgeInsets.fromLTRB(16, mobile ? 8 : 16, 16, 16),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: mobile
            ? BorderRadius.vertical(top: siteRadius(context, size: "xl").topLeft)
            : siteRadius(context, size: "xl"),
      ),
      child: Column(
        children: [
          if (mobile) ...[buildHandle(context), const SizedBox(height: 12)],
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: siteRadius(context, size: "md"),
                ),
                child: Icon(
                  shadcn.LucideIcons.medal,
                  size: 18,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.level.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.large.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              controller: _scrollController,
              children: [
                shadcn.TextField(
                  controller: widget.level.sectionController,
                  placeholder: const Text('配置节点名称'),
                  hintText: '例如 User，对应 [level.User]',
                ),
                const SizedBox(height: 10),
                ...widget.level.orderedFields.map((field) {
                  if (field.kind == _TomlValueKind.boolean) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _LevelBooleanField(field: field),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: shadcn.TextField(
                      controller: field.controller,
                      placeholder: Text(_tomlFieldLabel(field.key)),
                      hintText: '${field.hint} · ${field.key}',
                      maxLines: field.key == 'rights' ? 3 : 1,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: shadcn.Button.ghost(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('完成'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelBooleanField extends StatelessWidget {
  final _TomlField field;

  const _LevelBooleanField({required this.field});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: siteRadius(context, size: "md"),
        border: Border.all(color: cs.border, width: 0.6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldTitle(field: field),
                const SizedBox(height: 4),
                Text(
                  '${field.key} · ${field.hint}',
                  style: theme.typography.xSmall.copyWith(
                    color: cs.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: field.controller,
            builder: (_, value, __) {
              final active = value.text.trim().toLowerCase() == 'true';
              return shadcn.Switch(
                value: active,
                onChanged: (next) => field.controller.text = '$next',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LevelEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _LevelEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(shadcn.LucideIcons.layers, size: 24, color: cs.mutedForeground),
          const SizedBox(height: 8),
          Text('暂无用户等级', style: typo.small.copyWith(color: cs.mutedForeground)),
          const SizedBox(height: 12),
          shadcn.Button.primary(onPressed: onAdd, child: const Text('添加等级')),
        ],
      ),
    );
  }
}

class _GeneratorError extends StatelessWidget {
  final Object error;
  final Object trace;
  final VoidCallback onRetry;

  const _GeneratorError({
    required this.error,
    required this.onRetry,
    required this.trace,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.error(error);
    AppLogger.error(trace);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('加载站点配置失败: $error'),
          const SizedBox(height: 12),
          shadcn.Button.primary(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

class _TomlTemplate {
  final List<String> order;
  final Map<String, _TomlField> fields;
  final List<String> suffixLines;
  final List<_TomlLevel> levels;

  const _TomlTemplate({
    required this.order,
    required this.fields,
    required this.suffixLines,
    required this.levels,
  });

  List<_TomlField> get orderedFields => [
    for (final key in order)
      if (fields[key] case final field?) field,
  ];

  String fieldText(String key) => fields[key]?.controller.text ?? '';

  int get nextLevelId {
    final ids = levels
        .map(
          (level) => int.tryParse(
            level.fields['level_id']?.controller.text.trim() ?? '',
          ),
        )
        .whereType<int>();
    var max = 0;
    for (final id in ids) {
      if (id > max) max = id;
    }
    return max + 1;
  }

  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    for (final level in levels) {
      level.dispose();
    }
  }

  _TomlField ensureField(String key) {
    final existing = fields[key];
    if (existing != null) return existing;
    final field = _TomlField.fromRaw(key, _defaultTopLevelRawValue(key));
    fields[key] = field;
    if (key == 'name') {
      order.insert(0, key);
    } else {
      order.add(key);
    }
    return field;
  }

  factory _TomlTemplate.parse(String content) {
    final order = <String>[];
    final fields = <String, _TomlField>{};
    final suffix = <String>[];
    final levels = <_TomlLevel>[];
    _TomlLevel? activeLevel;
    var inRawSection = false;

    for (final line in const LineSplitter().convert(content)) {
      final trimmed = line.trim();
      final sectionMatch = RegExp(r'^\[(.+)\]\s*(?:#.*)?$').firstMatch(trimmed);
      if (sectionMatch != null) {
        final section = sectionMatch.group(1)!.trim();
        final levelMatch = RegExp(r'^level\.(.+)$').firstMatch(section);
        if (levelMatch != null) {
          activeLevel = _TomlLevel.empty(levelMatch.group(1)!.trim());
          levels.add(activeLevel);
          inRawSection = false;
          continue;
        }
        activeLevel = null;
        inRawSection = true;
        suffix.add(line);
        continue;
      }

      if (activeLevel != null) {
        final field = _parseTomlField(line);
        if (field != null) activeLevel.addField(field);
        continue;
      }

      if (inRawSection) {
        suffix.add(line);
        continue;
      }

      final field = _parseTomlField(line);
      if (field == null) continue;

      order.add(field.key);
      fields[field.key] = field;
    }

    for (final level in levels) {
      level.ensureDefaults();
    }

    return _TomlTemplate(
      order: order,
      fields: fields,
      suffixLines: suffix,
      levels: levels,
    );
  }

  String build() {
    final buffer = StringBuffer();
    for (final field in orderedFields) {
      buffer.writeln('${field.key} = ${field.formattedValue}');
    }
    if (suffixLines.isNotEmpty) {
      buffer.writeln();
      for (final line in suffixLines) {
        buffer.writeln(line);
      }
    }
    if (levels.isNotEmpty) {
      buffer.writeln();
      for (var i = 0; i < levels.length; i++) {
        if (i > 0) buffer.writeln();
        levels[i].writeTo(buffer);
      }
    }
    return buffer.toString();
  }
}

class _TomlLevel {
  final TextEditingController sectionController;
  final List<String> order;
  final Map<String, _TomlField> fields;

  _TomlLevel({
    required this.sectionController,
    required this.order,
    required this.fields,
  });

  factory _TomlLevel.empty(String section) => _TomlLevel(
    sectionController: TextEditingController(text: section),
    order: [],
    fields: {},
  );

  factory _TomlLevel.defaults(int id) {
    final section = 'Level$id';
    final level = _TomlLevel.empty(section);
    for (final key in _levelFieldOrder) {
      level.addField(
        _TomlField.fromRaw(key, _defaultLevelRawValue(key, id, section)),
      );
    }
    return level;
  }

  List<_TomlField> get orderedFields => [
    for (final key in order)
      if (fields[key] case final field?) field,
  ];

  String get displayName {
    final levelName = fields['level']?.controller.text.trim();
    final section = sectionController.text.trim();
    if (levelName != null && levelName.isNotEmpty) return levelName;
    if (section.isNotEmpty) return section;
    return '未命名等级';
  }

  String get summary {
    final parts = <String>[];
    final id = fields['level_id']?.controller.text.trim();
    final days = fields['days']?.controller.text.trim();
    final uploaded = fields['uploaded']?.controller.text.trim();
    final downloaded = fields['downloaded']?.controller.text.trim();
    final ratio = fields['ratio']?.controller.text.trim();
    if (id != null && id.isNotEmpty) parts.add('ID $id');
    if (days != null && days.isNotEmpty) parts.add('注册 $days 天');
    if (uploaded != null && uploaded.isNotEmpty) parts.add('上传 $uploaded');
    if (downloaded != null && downloaded.isNotEmpty) {
      parts.add('下载 $downloaded');
    }
    if (ratio != null && ratio.isNotEmpty) parts.add('分享率 $ratio');
    return parts.isEmpty ? '未设置等级要求' : parts.join(' · ');
  }

  void addField(_TomlField field) {
    if (!fields.containsKey(field.key)) order.add(field.key);
    fields[field.key] = field;
  }

  void ensureDefaults() {
    final levelId =
        int.tryParse(fields['level_id']?.controller.text.trim() ?? '') ?? 1;
    final section = sectionController.text.trim().isEmpty
        ? 'Level$levelId'
        : sectionController.text.trim();
    for (final key in _levelFieldOrder) {
      if (fields.containsKey(key)) continue;
      addField(
        _TomlField.fromRaw(key, _defaultLevelRawValue(key, levelId, section)),
      );
    }
  }

  void writeTo(StringBuffer buffer) {
    final section = _safeTomlSectionName(sectionController.text);
    buffer.writeln('[level.$section]');
    for (final field in orderedFields) {
      buffer.writeln('${field.key} = ${field.formattedValue}');
    }
  }

  void dispose() {
    sectionController.dispose();
    for (final field in fields.values) {
      field.dispose();
    }
  }
}

class _TomlField {
  final String key;
  final String rawValue;
  final _TomlValueKind kind;
  final TextEditingController controller;

  const _TomlField({
    required this.key,
    required this.rawValue,
    required this.kind,
    required this.controller,
  });

  factory _TomlField.fromRaw(String key, String raw) => _TomlField(
    key: key,
    rawValue: raw,
    kind: _inferKind(raw),
    controller: TextEditingController(text: _editableValue(raw)),
  );

  String get hint => switch (kind) {
    _TomlValueKind.boolean => 'true / false',
    _TomlValueKind.number => '数字',
    _TomlValueKind.list => '用逗号分隔多个值',
    _TomlValueKind.string => '文本',
  };

  String get formattedValue {
    final text = controller.text.trim();
    return switch (kind) {
      _TomlValueKind.boolean => text.toLowerCase() == 'true' ? 'true' : 'false',
      _TomlValueKind.number => text.isEmpty ? '0' : text,
      _TomlValueKind.list => _formatTomlList(text),
      _TomlValueKind.string => _quoteTomlString(text),
    };
  }

  void dispose() {
    controller.dispose();
  }
}

enum _TomlValueKind { string, number, boolean, list }

_TomlField? _parseTomlField(String line) {
  final match = RegExp(r'^([A-Za-z0-9_]+)\s*=\s*(.*)$').firstMatch(line);
  if (match == null) return null;
  return _TomlField.fromRaw(match.group(1)!, match.group(2)!.trim());
}

String _defaultTopLevelRawValue(String key) {
  return switch (key) {
    'structure' => _quoteTomlString(''),
    'type' => _quoteTomlString(''),
    'nation' => _quoteTomlString(''),
    'name' => _quoteTomlString(''),
    _ => _quoteTomlString(''),
  };
}

const _levelFieldOrder = [
  'level_id',
  'level',
  'days',
  'uploaded',
  'downloaded',
  'bonus',
  'score',
  'ratio',
  'torrents',
  'leeches',
  'seeding_delta',
  'keep_account',
  'graduation',
  'rights',
];

String _defaultLevelRawValue(String key, int id, String section) {
  return switch (key) {
    'level_id' => '$id',
    'level' => _quoteTomlString(section),
    'days' => '0',
    'uploaded' => _quoteTomlString('0'),
    'downloaded' => _quoteTomlString('0'),
    'bonus' => '0.0',
    'score' => '0',
    'ratio' => '0.0',
    'torrents' => '0',
    'leeches' => '0',
    'seeding_delta' => '0.0',
    'keep_account' => 'false',
    'graduation' => 'false',
    'rights' => _quoteTomlString(''),
    _ => _quoteTomlString(''),
  };
}

String _safeTomlSectionName(String value) {
  final text = value.trim();
  if (text.isEmpty) return 'Level';
  return text.replaceAll(RegExp(r'[\[\]\s]'), '_');
}

String _tomlFieldLabel(String key) {
  const labels = <String, String>{
    'url': '站点地址',
    'name': '配置名称',
    'nickname': '站点昵称',
    'logo': '站点图标',
    'tracker': 'Tracker 域名',
    'sp_full': '满魔力阈值',
    'limit_speed': '限速阈值',
    'tags': '站点标签',
    'iyuu': 'IYUU ID',
    'sign_in': '启用签到',
    'get_info': '获取用户信息',
    'repeat_torrents': '辅种识别',
    'brush_free': '免费刷流',
    'brush_rss': 'RSS 刷流',
    'hr_discern': 'HR 识别',
    'search_torrents': '资源搜索',
    'hr': '启用 HR',
    'hr_rate': 'HR 分享率要求',
    'hr_time': 'HR 时间要求',
    'alive': '配置启用',
    'pieces_repeat': '分片辅种',
    'proxy': '使用代理',
    'structure': '站点架构',
    'type': '站点类型',
    'nation': '站点地区',
    'buy_page': '魔力兑换页面',
    'level_id': '等级 ID',
    'level': '等级名称',
    'days': '注册天数要求',
    'uploaded': '上传量要求',
    'downloaded': '下载量要求',
    'bonus': '魔力值要求',
    'score': '积分要求',
    'ratio': '分享率要求',
    'torrents': '发布种子要求',
    'leeches': '下载任务要求',
    'seeding_delta': '做种增量要求',
    'keep_account': '保留账号',
    'graduation': '毕业等级',
    'rights': '等级权益说明',
  };
  if (labels.containsKey(key)) return labels[key]!;
  if (key.startsWith('page_')) return '页面路径：${key.substring(5)}';
  if (key.startsWith('my_') && key.endsWith('_rule')) {
    return '用户信息规则：${key.substring(3, key.length - 5)}';
  }
  if (key.startsWith('torrent_') && key.endsWith('_rule')) {
    return '种子列表规则：${key.substring(8, key.length - 5)}';
  }
  if (key.startsWith('detail_') && key.endsWith('_rule')) {
    return '详情页规则：${key.substring(7, key.length - 5)}';
  }
  if (key.startsWith('sign_info_')) return '签到信息：${key.substring(10)}';
  if (key.startsWith('my_')) return '用户信息：${key.substring(3)}';
  if (key.startsWith('torrent_')) return '种子字段：${key.substring(8)}';
  if (key.startsWith('detail_')) return '详情字段：${key.substring(7)}';
  return key;
}

_TomlValueKind _inferKind(String raw) {
  final value = raw.trim();
  if (value == 'true' || value == 'false') return _TomlValueKind.boolean;
  if (value.startsWith('[')) return _TomlValueKind.list;
  if (num.tryParse(value) != null) return _TomlValueKind.number;
  return _TomlValueKind.string;
}

String _editableValue(String raw) {
  final value = raw.trim();
  if (value.startsWith('[') && value.endsWith(']')) {
    final inner = value.substring(1, value.length - 1).trim();
    if (inner.isEmpty) return '';
    return inner
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .map(_unquoteTomlString)
        .join(', ');
  }
  return _unquoteTomlString(value);
}

String _unquoteTomlString(String value) {
  final text = value.trim();
  if (text.length >= 2 && text.startsWith('"') && text.endsWith('"')) {
    return text.substring(1, text.length - 1).replaceAll(r'\"', '"');
  }
  return text;
}

String _quoteTomlString(String value) {
  final escaped = value.replaceAll('\\', '\\\\').replaceAll('"', r'\"');
  return '"$escaped"';
}

String _formatTomlList(String value) {
  final items = value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .map(_quoteTomlString)
      .join(', ');
  if (items.isEmpty) return '[]';
  return '[ $items,]';
}

String? _extractTomlContent(Map<String, dynamic> raw) {
  for (final key in ['content', 'toml', 'text', 'file']) {
    final value = raw[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  final config = raw['config'];
  if (config is String && config.trim().isNotEmpty) return config;
  if (config is Map) return _mapToToml(Map<String, dynamic>.from(config));
  final data = raw['data'];
  if (data is String && data.trim().isNotEmpty) return data;
  if (data is Map) return _extractTomlContent(Map<String, dynamic>.from(data));
  final result = raw['result'];
  if (result is String && result.trim().isNotEmpty) return result;
  if (result is Map) {
    return _extractTomlContent(Map<String, dynamic>.from(result));
  }
  if (raw.isNotEmpty) return _mapToToml(raw);
  return null;
}

String _mapToToml(Map<String, dynamic> map) {
  final buffer = StringBuffer();
  final sections = <String, Map<String, dynamic>>{};

  for (final entry in map.entries) {
    final key = entry.key;
    final value = entry.value;
    if (value is Map) {
      if (key == 'level') {
        for (final levelEntry in value.entries) {
          if (levelEntry.value is Map) {
            sections['level.${levelEntry.key}'] = Map<String, dynamic>.from(
              levelEntry.value as Map,
            );
          }
        }
      } else if (_isTomlSectionMap(value)) {
        sections[key] = Map<String, dynamic>.from(value);
      }
      continue;
    }
    if (key == 'level' && value is List) {
      for (var i = 0; i < value.length; i++) {
        final item = value[i];
        if (item is! Map) continue;
        final levelMap = Map<String, dynamic>.from(item);
        final section =
            '${levelMap['level'] ?? levelMap['name'] ?? 'Level${i + 1}'}';
        sections['level.$section'] = levelMap;
      }
      continue;
    }
    buffer.writeln('$key = ${_formatTomlDynamic(value)}');
  }

  for (final entry in sections.entries) {
    if (buffer.isNotEmpty) buffer.writeln();
    buffer.writeln('[${entry.key}]');
    for (final field in entry.value.entries) {
      if (field.value is Map) continue;
      buffer.writeln('${field.key} = ${_formatTomlDynamic(field.value)}');
    }
  }

  return buffer.toString();
}

bool _isTomlSectionMap(Map<dynamic, dynamic> map) {
  if (map.isEmpty) return false;
  return map.values.every((value) => value is! Map);
}

String _webSiteToToml(WebSite config) => _mapToToml(config.toJson());

String _formatTomlDynamic(dynamic value) {
  if (value is bool) return value ? 'true' : 'false';
  if (value is num) return '$value';
  if (value is List) {
    return '[ ${value.map((item) => _quoteTomlString('$item')).join(', ')},]';
  }
  return _quoteTomlString(value == null ? '' : '$value');
}
