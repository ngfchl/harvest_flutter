import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:share_plus/share_plus.dart';

import '../model/site_config.dart';
import '../provider/site_provider.dart';
import '../service/site_service.dart';
import 'site_theme.dart';

void showSiteConfigGenerator(BuildContext context) {
  final dialog = const SiteConfigGeneratorDialog();
  if (context.isMobile) {
    showAppSheet<void>(
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
    return name.isEmpty ? (_templateName ?? '未命名配置') : name;
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
            onPressed: () => closeAppSheet(ctx, null),
            child: const Text('取消'),
          ),
          shadcn.Button.outline(
            onPressed: () => closeAppSheet(ctx, false),
            child: const Text('不覆盖'),
          ),
          shadcn.Button.primary(
            onPressed: () => closeAppSheet(ctx, true),
            child: const Text('覆盖'),
          ),
        ],
      ),
    );
  }

  String _safeFileName(String value) {
    final safe = value.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return safe.isEmpty ? 'config' : safe;
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
            ? BorderRadius.vertical(
                top: siteRadius(context, size: "xl").topLeft,
              )
            : siteRadius(context, size: "xl"),
      ),
      child: configsAsync.when(
        loading: () => Center(
          child: shadcn.CircularProgressIndicator(
            strokeWidth: 2.4,
            color: cs.primary,
          ),
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
    final cs = shadcn.Theme.of(context).colorScheme;
    final template = _template;

    Widget buildConfigNamePanel() {
      return _FieldPanel(
        title: const _PanelTitleText(label: '配置名称', required: true),
        child: ShadTextField(
          controller: _configNameController,
          placeholder: const Text('配置名称'),
          hintText: '保存和下载时使用该名称作为文件名',
          onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
      );
    }

    Widget buildTemplatePanel() {
      return _FieldPanel(
        title: const _PanelTitleText(label: '配置模板'),
        child: _TemplateSelectField(
          templateName: _templateName,
          loading: _loadingTemplate,
          configs: configs,
          onSelected: _loadTemplate,
        ),
      );
    }

    final fieldCount =
        template?.orderedFields
            .where((field) => !_hiddenTopLevelFieldKeys.contains(field.key))
            .length ??
        0;
    final heroSubtitle = template == null
        ? '${_templateName ?? '未选择模板'} · 加载中'
        : '${_templateName ?? '未选择模板'} · $fieldCount 字段 / ${template.levels.length} 等级';

    return Column(
      children: [
        _DialogHeroCard(
          icon: shadcn.LucideIcons.fileCode,
          title: '生成站点配置',
          subtitle: heroSubtitle,
        ),
        const SizedBox(height: 8),
        if (template != null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: shadcn.Theme.of(
                context,
              ).colorScheme.background.withValues(alpha: 0.56),
              borderRadius: siteRadius(context, size: "lg"),
              border: Border.all(
                color: shadcn.Theme.of(context).colorScheme.border,
                width: 0.8,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth < 420
                    ? 420.0
                    : constraints.maxWidth;
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: contentWidth,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: buildConfigNamePanel()),
                        const SizedBox(width: 8),
                        Expanded(child: buildTemplatePanel()),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: shadcn.Theme.of(context).typography.xSmall.copyWith(
              color: shadcn.Theme.of(context).colorScheme.destructive,
            ),
          ),
        ],
        const SizedBox(height: 8),
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
                  levelAutocompleteOptions:
                      _TomlLevelAutocompleteOptions.fromConfigs(configs),
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
    final cs = shadcn.Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.background.withValues(alpha: 0.72),
        borderRadius: siteRadius(context, size: "lg"),
        border: Border.all(color: cs.border, width: 0.8),
      ),
      child: Row(
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
      ),
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
                      color: filled
                          ? siteColors(context).background
                          : effectiveColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: typo.small.copyWith(
                        color: filled
                            ? siteColors(context).background
                            : effectiveColor,
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
  final _TomlLevelAutocompleteOptions levelAutocompleteOptions;
  final VoidCallback onChanged;

  const _TomlFieldList({
    required this.template,
    required this.controller,
    required this.selectOptions,
    required this.levelAutocompleteOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final consumedKeys = <String>{};
    final sections = <Widget?>[
      _buildSection(
        title: '基础信息',
        icon: shadcn.LucideIcons.badgeInfo,
        description: '站点标识、域名、分类与基础参数',
        fields: _baseInfoFields(consumedKeys),
      ),
      _buildSection(
        title: 'HR 相关信息',
        icon: shadcn.LucideIcons.timerReset,
        description: 'HR 开关、考核时长与分享率要求',
        fields: _fieldsForKeys(_hrFieldKeys, consumedKeys: consumedKeys),
      ),
      _buildSection(
        title: '功能开关',
        icon: shadcn.LucideIcons.toggleLeft,
        description: '签到、刷流、辅种、搜索等功能控制',
        fields: _fieldsForKeys(
          _functionSwitchFieldKeys,
          consumedKeys: consumedKeys,
        ),
      ),
      _buildSection(
        title: '各种页面链接',
        icon: shadcn.LucideIcons.link2,
        description: '站点各页面路径配置',
        fields: _fieldsWhere(
          (field) => field.key.startsWith('page_'),
          consumedKeys: consumedKeys,
        ),
      ),
      _buildSection(
        title: '个人信息 XPath',
        icon: shadcn.LucideIcons.userRoundSearch,
        description: '用户信息与签到信息解析规则',
        fields: _fieldsWhere(
          (field) =>
              (field.key.startsWith('my_') && field.key.endsWith('_rule')) ||
              field.key.startsWith('sign_info_'),
          consumedKeys: consumedKeys,
        ),
      ),
      _buildSection(
        title: '种子列表 XPath',
        icon: shadcn.LucideIcons.listTree,
        description: '种子列表页字段解析规则',
        fields: _torrentListRuleFields(consumedKeys),
      ),
      _buildSection(
        title: '种子详情页 XPath',
        icon: shadcn.LucideIcons.fileSearch,
        description: '详情页字段与下载入口解析规则',
        fields: _fieldsWhere(
          (field) =>
              field.key.startsWith('detail_') && field.key.endsWith('_rule'),
          consumedKeys: consumedKeys,
        ),
      ),
      _buildSection(
        title: '其他字段',
        icon: shadcn.LucideIcons.ellipsis,
        description: '未归类但仍保留在模板中的字段',
        fields: _remainingFields(consumedKeys),
      ),
      _TomlSectionCard(
        title: '等级信息',
        icon: shadcn.LucideIcons.layers,
        description: '用户等级要求与权益配置',
        child: _TomlLevelListSection(
          template: template,
          autocompleteOptions: levelAutocompleteOptions,
          onChanged: onChanged,
        ),
      ),
    ].whereType<Widget>().toList();

    return ListView.separated(
      controller: controller,
      itemCount: sections.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => sections[index],
    );
  }

  List<_TomlField> _baseInfoFields(Set<String> consumedKeys) {
    final fields = <_TomlField>[];
    for (final key in _baseInfoFieldKeys) {
      final field = _selectFieldKeys.contains(key)
          ? template.ensureField(key)
          : template.fields[key];
      if (field == null || !consumedKeys.add(field.key)) continue;
      fields.add(field);
    }
    return fields;
  }

  List<_TomlField> _fieldsForKeys(
    List<String> keys, {
    required Set<String> consumedKeys,
  }) {
    final fields = <_TomlField>[];
    for (final key in keys) {
      final field = template.fields[key];
      if (field == null || !consumedKeys.add(field.key)) continue;
      fields.add(field);
    }
    return fields;
  }

  List<_TomlField> _fieldsWhere(
    bool Function(_TomlField field) predicate, {
    required Set<String> consumedKeys,
  }) {
    final fields = <_TomlField>[];
    for (final field in template.orderedFields) {
      if (_hiddenTopLevelFieldKeys.contains(field.key)) continue;
      if (!predicate(field) || !consumedKeys.add(field.key)) continue;
      fields.add(field);
    }
    return fields;
  }

  List<_TomlField> _torrentListRuleFields(Set<String> consumedKeys) {
    final fields = <_TomlField>[];
    final rowRule = template.fields['torrents_rule'];
    if (rowRule != null && consumedKeys.add(rowRule.key)) {
      fields.add(rowRule);
    }
    fields.addAll(
      _fieldsWhere(
        (field) =>
            field.key.startsWith('torrent_') && field.key.endsWith('_rule'),
        consumedKeys: consumedKeys,
      ),
    );
    return fields;
  }

  List<_TomlField> _remainingFields(Set<String> consumedKeys) {
    final fields = <_TomlField>[];
    for (final field in template.orderedFields) {
      if (_hiddenTopLevelFieldKeys.contains(field.key)) continue;
      if (!consumedKeys.add(field.key)) continue;
      fields.add(field);
    }
    return fields;
  }

  Widget? _buildSection({
    required String title,
    required IconData icon,
    required String description,
    required List<_TomlField> fields,
  }) {
    if (fields.isEmpty) return null;
    return _TomlSectionCard(
      title: title,
      icon: icon,
      description: description,
      child: Column(
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            _buildFieldWidget(fields[i]),
            if (i != fields.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldWidget(_TomlField field) {
    const required = true;
    if (field.kind == _TomlValueKind.boolean) {
      return _TomlSwitchTile(field: field, required: required);
    }
    if (_selectFieldKeys.contains(field.key)) {
      return _FieldPanel(
        title: _FieldTitle(field: field, required: required),
        child: _TomlSelectField(
          field: field,
          options: selectOptions.optionsFor(field.key),
        ),
      );
    }
    return _TomlFieldTile(field: field, required: required);
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
    shadcn.SelectItemList buildItems(String? searchQuery) {
      final keyword = searchQuery?.trim().toLowerCase() ?? '';
      final filtered = keyword.isEmpty
          ? configs
          : configs
                .where((config) {
                  final values = [
                    config.name,
                    config.nickname,
                    ...config.url,
                  ].map((value) => value.trim().toLowerCase());
                  return values.any((value) => value.contains(keyword));
                })
                .toList(growable: false);

      return shadcn.SelectItemList(
        children: [
          for (final config in filtered)
            shadcn.SelectItemButton<String>(
              value: config.name,
              child: Text(
                config.name == 'NP模板' ? '${config.name}（默认）' : config.name,
              ),
            ),
        ],
      );
    }

    return shadcn.Select<String>(
      key: ValueKey(templateName),
      value: templateName,
      placeholder: const Text('模板'),
      itemBuilder: (_, value) => Text(value),
      popup: shadcn.SelectPopup<String>.builder(
        searchPlaceholder: const Text('搜索模板'),
        emptyBuilder: (_) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Center(child: Text('未找到匹配模板')),
        ),
        builder: (_, searchQuery) => buildItems(searchQuery),
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

class _TomlLevelAutocompleteOptions {
  final Map<String, List<String>> values;

  const _TomlLevelAutocompleteOptions({required this.values});

  factory _TomlLevelAutocompleteOptions.fromConfigs(List<WebSite> configs) {
    final buckets = <String, Set<String>>{};

    void addValue(String key, Object? value) {
      final text = '$value'.trim();
      if (text.isEmpty) return;
      buckets.putIfAbsent(key, () => <String>{}).add(text);
    }

    for (final config in configs) {
      for (final level in config.level.values) {
        addValue('level', level.level);
        addValue('name', level.name);
        addValue('days', level.days);
        addValue('uploaded', level.uploaded);
        addValue('downloaded', level.downloaded);
        addValue('bonus', level.bonus);
        addValue('score', level.score);
        addValue('ratio', level.ratio);
        addValue('torrents', level.torrents);
        addValue('leeches', level.leeches);
        addValue('seeding_delta', level.seedingDelta);
        addValue('rights', level.rights);
      }
    }

    return _TomlLevelAutocompleteOptions(
      values: {
        for (final entry in buckets.entries) entry.key: entry.value.toList(),
      },
    );
  }

  List<String> optionsFor(String key) => values[key] ?? const <String>[];
}

const _selectFieldKeys = {'structure', 'type', 'nation'};
const _hiddenTopLevelFieldKeys = {'name'};
const _baseInfoFieldKeys = [
  'url',
  'nickname',
  'logo',
  'tracker',
  'sp_full',
  'limit_speed',
  'tags',
  'iyuu',
  'structure',
  'type',
  'nation',
];
const _hrFieldKeys = ['hr', 'hr_rate', 'hr_time'];
const _functionSwitchFieldKeys = [
  'sign_in',
  'get_info',
  'repeat_torrents',
  'brush_free',
  'brush_rss',
  'hr_discern',
  'search_torrents',
  'alive',
  'pieces_repeat',
  'proxy',
];

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
      return ShadTextField(
        controller: field.controller,
        hintText: '${field.hint} · ${field.key}',
        onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      );
    }
    return shadcn.Select<String>(
      key: ValueKey('${field.key}-$current-${values.join('|')}'),
      value: current.isEmpty ? values.first : current,
      itemBuilder: (_, value) =>
          Text(_tomlSelectDisplayLabel(field.key, value)),
      popup: shadcn.SelectPopup<String>(
        items: shadcn.SelectItemList(
          children: [
            for (final value in values)
              shadcn.SelectItemButton<String>(
                value: value,
                child: Text(_tomlSelectDisplayLabel(field.key, value)),
              ),
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

class _TomlSwitchTile extends StatelessWidget {
  final _TomlField field;
  final bool required;

  const _TomlSwitchTile({required this.field, this.required = false});

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
                _FieldTitle(field: field, required: required),
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
            builder: (_, value, _) {
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
        color: cs.background.withValues(alpha: 0.94),
        borderRadius: siteRadius(context, size: "md"),
        border: Border.all(
          color: cs.border.withValues(alpha: 0.82),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.foreground.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [title, const SizedBox(height: 8), child],
      ),
    );
  }
}

class _TomlSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final Widget child;

  const _TomlSectionCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.background.withValues(alpha: 0.92),
            cs.background.withValues(alpha: 0.72),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: siteRadius(context, size: "lg"),
        border: Border.all(
          color: cs.border.withValues(alpha: 0.88),
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: siteRadius(context, size: "sm"),
                ),
                child: Icon(icon, size: 15, color: cs.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typo.small.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: typo.xSmall.copyWith(color: cs.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TomlLevelListSection extends StatelessWidget {
  final _TomlTemplate template;
  final _TomlLevelAutocompleteOptions autocompleteOptions;
  final VoidCallback onChanged;

  const _TomlLevelListSection({
    required this.template,
    required this.autocompleteOptions,
    required this.onChanged,
  });

  Future<void> _addLevel(BuildContext context) async {
    final level = _TomlLevel.defaults(template.nextAvailableLevelId);
    final added = await _showTomlLevelDetail(
      context,
      template: template,
      autocompleteOptions: autocompleteOptions,
      level: level,
      onChanged: onChanged,
    );
    if (added == true) {
      template.levels.add(level);
      onChanged();
      return;
    }
    level.dispose();
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
    final levels = template.sortedLevels;

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
              '${levels.length} 条',
              style: typo.xSmall.copyWith(color: cs.mutedForeground),
            ),
            const SizedBox(width: 8),
            shadcn.IconButton.ghost(
              onPressed: () async => _addLevel(context),
              icon: shadcn.Tooltip(
                tooltip: (_) => const Text('添加用户等级'),
                child: const Icon(shadcn.LucideIcons.plus, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (levels.isEmpty)
          _LevelEmptyState(onAdd: () async => _addLevel(context))
        else
          Column(
            children: [
              for (var i = 0; i < levels.length; i++) ...[
                _LevelListTile(
                  level: levels[i],
                  onOpen: () => _showTomlLevelDetail(
                    context,
                    template: template,
                    autocompleteOptions: autocompleteOptions,
                    level: levels[i],
                    onChanged: onChanged,
                  ),
                  onRemove: () => _removeLevel(levels[i]),
                ),
                if (i != levels.length - 1) const SizedBox(height: 8),
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
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: siteRadius(context, size: "md"),
              ),
              child: Icon(
                shadcn.LucideIcons.medal,
                size: 16,
                color: cs.primary,
              ),
            ),
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
            const SizedBox(width: 4),
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
  final bool required;

  const _TomlFieldTile({required this.field, this.required = false});

  @override
  Widget build(BuildContext context) {
    return _FieldPanel(
      title: _FieldTitle(field: field, required: required),
      child: field.kind == _TomlValueKind.list
          ? _TomlListField(field: field)
          : ShadTextField(
              controller: field.controller,
              hintText: '${field.hint} · ${field.key}',
              maxLines: 1,
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
    );
  }
}

class _TomlListField extends StatefulWidget {
  final _TomlField field;

  const _TomlListField({required this.field});

  @override
  State<_TomlListField> createState() => _TomlListFieldState();
}

class _TomlListFieldState extends State<_TomlListField> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = _parseItems(
      widget.field.controller.text,
    ).map((item) => TextEditingController(text: item)).toList();
    if (_controllers.isEmpty) {
      _controllers.add(TextEditingController());
    }
    for (final controller in _controllers) {
      controller.addListener(_syncFieldValue);
    }
    _syncFieldValue();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_syncFieldValue);
      controller.dispose();
    }
    super.dispose();
  }

  void _syncFieldValue() {
    final value = _controllers
        .map((controller) => controller.text.trim())
        .where((item) => item.isNotEmpty)
        .join('\n');
    if (widget.field.controller.text == value) return;
    widget.field.controller.text = value;
  }

  void _addItem() {
    final controller = TextEditingController();
    controller.addListener(_syncFieldValue);
    setState(() {
      _controllers.add(controller);
    });
    _syncFieldValue();
  }

  void _removeItem(int index) {
    final controller = _controllers.removeAt(index);
    controller.removeListener(_syncFieldValue);
    controller.dispose();
    if (_controllers.isEmpty) {
      final next = TextEditingController();
      next.addListener(_syncFieldValue);
      _controllers.add(next);
    }
    setState(() {});
    _syncFieldValue();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.field.key == 'url'
              ? '支持多个地址，一行一个'
              : '${widget.field.hint}，一行一个',
          style: theme.typography.xSmall.copyWith(color: cs.mutedForeground),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _controllers.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ShadTextField(
                  controller: _controllers[i],
                  hintText: widget.field.key == 'url'
                      ? 'https://example.com'
                      : '${widget.field.hint} · ${widget.field.key}',
                  onSubmitted: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),
              const SizedBox(width: 8),
              shadcn.IconButton.ghost(
                onPressed: () => _removeItem(i),
                icon: Icon(
                  shadcn.LucideIcons.trash2,
                  size: 15,
                  color: cs.destructive,
                ),
              ),
            ],
          ),
          if (i != _controllers.length - 1) const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: shadcn.Button.outline(
            onPressed: _addItem,
            child: const Text('添加一项'),
          ),
        ),
      ],
    );
  }
}

class _AutocompleteTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final List<String> options;

  const _AutocompleteTextField({
    required this.controller,
    required this.hintText,
    required this.options,
  });

  @override
  State<_AutocompleteTextField> createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<_AutocompleteTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        final source = widget.options;
        if (source.isEmpty) return const Iterable<String>.empty();
        if (query.isEmpty) return source.take(8);
        return source
            .where((item) => item.toLowerCase().contains(query))
            .take(8);
      },
      onSelected: (value) => widget.controller.text = value,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return ShadTextField(
          controller: controller,
          focusNode: focusNode,
          hintText: widget.hintText,
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final items = options.toList(growable: false);
        if (items.isEmpty) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 240),
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: cs.background,
                borderRadius: siteRadius(context, size: "md"),
                border: Border.all(color: cs.border, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: cs.foreground.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: cs.border.withValues(alpha: 0.55),
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return InkWell(
                    onTap: () => onSelected(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(
                        item,
                        style: theme.typography.small.copyWith(
                          color: cs.foreground,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FieldTitle extends StatelessWidget {
  final _TomlField field;
  final bool required;

  const _FieldTitle({required this.field, this.required = true});

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
        if (required) ...[const SizedBox(width: 6), const _RequiredBadge()],
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

class _PanelTitleText extends StatelessWidget {
  final String label;
  final bool required;

  const _PanelTitleText({required this.label, this.required = true});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);

    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (required) ...[const SizedBox(width: 6), const _RequiredBadge()],
      ],
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge();

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return Text(
      '*',
      style: theme.typography.small.copyWith(
        color: cs.destructive,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _HeaderIdMark extends StatelessWidget {
  final String label;

  const _HeaderIdMark({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(shadcn.LucideIcons.hash, size: 13, color: cs.mutedForeground),
        const SizedBox(width: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.xSmall.copyWith(
            color: cs.mutedForeground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DialogHeroCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? titleTrailing;

  const _DialogHeroCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.titleTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final leading = Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.14),
            borderRadius: siteRadius(context, size: "md"),
          ),
          child: Icon(icon, size: 17, color: cs.primary),
        );
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: compact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (titleTrailing != null) ...[
                  const SizedBox(width: 10),
                  titleTrailing!,
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.xSmall.copyWith(
                color: cs.mutedForeground,
                height: 1.25,
              ),
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primary.withValues(alpha: 0.14),
                cs.background.withValues(alpha: 0.94),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: siteRadius(context, size: "lg"),
            border: Border.all(color: cs.border, width: 0.9),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        leading,
                        const SizedBox(width: 10),
                        Expanded(child: titleBlock),
                      ],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leading,
                    const SizedBox(width: 10),
                    Expanded(child: titleBlock),
                  ],
                ),
        );
      },
    );
  }
}

Future<bool?> _showTomlLevelDetail(
  BuildContext context, {
  required _TomlTemplate template,
  required _TomlLevelAutocompleteOptions autocompleteOptions,
  required _TomlLevel level,
  required VoidCallback onChanged,
}) {
  final editor = _TomlLevelDetail(
    template: template,
    autocompleteOptions: autocompleteOptions,
    level: level,
    onChanged: onChanged,
  );
  if (context.isMobile) {
    return showAppSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: siteTransparent(context),
      builder: (ctx) =>
          SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.9, child: editor),
    );
  }
  return shadcn.showDialog<bool>(
    context: context,
    builder: (_) => shadcn.AlertDialog(
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: editor,
      ),
    ),
  );
}

class _TomlLevelDetail extends StatefulWidget {
  final _TomlTemplate template;
  final _TomlLevelAutocompleteOptions autocompleteOptions;
  final _TomlLevel level;
  final VoidCallback onChanged;

  const _TomlLevelDetail({
    required this.template,
    required this.autocompleteOptions,
    required this.level,
    required this.onChanged,
  });

  @override
  State<_TomlLevelDetail> createState() => _TomlLevelDetailState();
}

class _TomlLevelDetailState extends State<_TomlLevelDetail> {
  final _scrollController = ScrollController();

  bool _hasDuplicateLevelId(String value) {
    if (int.tryParse(value) == 0) return false;
    for (final level in widget.template.levels) {
      if (identical(level, widget.level)) continue;
      final current = level.fields['level_id']?.controller.text.trim() ?? '';
      if (current == value) return true;
    }
    return false;
  }

  String? _fieldError(_TomlField field) {
    final text = field.controller.text.trim();
    if (text.isEmpty) {
      return '${_tomlFieldLabel(field.key)}不能为空';
    }
    if (field.key == 'level_id') {
      if (int.tryParse(text) == null) return '等级 ID 必须是数字';
      if (_hasDuplicateLevelId(text)) return '等级 ID 不可重复';
    }
    return null;
  }

  String? get _firstErrorMessage {
    for (final field in widget.level.orderedFields) {
      final error = _fieldError(field);
      if (error != null) return error;
    }
    return null;
  }

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
    widget.level.syncSectionWithLevel();
    widget.onChanged();
    if (mounted) setState(() {});
  }

  void _submit() {
    final error = _firstErrorMessage;
    if (error != null) {
      Toast.error(error);
      if (mounted) setState(() {});
      return;
    }
    Navigator.of(context).maybePop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final mobile = context.isMobile;
    final levelId = widget.level.fields['level_id']?.controller.text.trim();
    final levelIdLabel = levelId == null || levelId.isEmpty ? '-' : levelId;

    return Container(
      padding: EdgeInsets.fromLTRB(16, mobile ? 8 : 16, 16, 16),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: mobile
            ? BorderRadius.vertical(
                top: siteRadius(context, size: "xl").topLeft,
              )
            : siteRadius(context, size: "xl"),
      ),
      child: Column(
        children: [
          _DialogHeroCard(
            icon: shadcn.LucideIcons.medal,
            title: widget.level.displayName,
            subtitle: '* 为必填项，非 0 等级 ID 必须唯一且为数字',
            titleTrailing: _HeaderIdMark(label: levelIdLabel),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              controller: _scrollController,
              children: [
                ...widget.level.orderedFields.map((field) {
                  if (field.kind == _TomlValueKind.boolean) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _LevelBooleanField(
                        field: field,
                        errorText: _fieldError(field),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FieldPanel(
                      title: _FieldTitle(field: field, required: true),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          field.key == 'rights'
                              ? ShadTextField(
                                  controller: field.controller,
                                  hintText: '${field.hint} · ${field.key}',
                                  maxLines: 3,
                                  onSubmitted: (_) => FocusManager
                                      .instance
                                      .primaryFocus
                                      ?.unfocus(),
                                )
                              : _AutocompleteTextField(
                                  controller: field.controller,
                                  hintText: '${field.hint} · ${field.key}',
                                  options: widget.autocompleteOptions
                                      .optionsFor(field.key),
                                ),
                          if (_fieldError(field) case final error?) ...[
                            const SizedBox(height: 6),
                            Text(
                              error,
                              style: typo.xSmall.copyWith(
                                color: cs.destructive,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              shadcn.Button.ghost(
                onPressed: () => Navigator.of(context).maybePop(false),
                child: const Text('返回'),
              ),
              shadcn.Button.primary(
                onPressed: _submit,
                child: const Text('保存'),
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
  final String? errorText;

  const _LevelBooleanField({required this.field, this.errorText});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldTitle(field: field, required: true),
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
                builder: (_, value, _) {
                  final active = value.text.trim().toLowerCase() == 'true';
                  return shadcn.Switch(
                    value: active,
                    onChanged: (next) => field.controller.text = '$next',
                  );
                },
              ),
            ],
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: theme.typography.xSmall.copyWith(color: cs.destructive),
            ),
          ],
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
    for (final key in _levelFieldOrder)
      ?fields[key],
    for (final key in order)
      if (!_levelFieldOrder.contains(key))
        ?fields[key],
  ];

  List<_TomlLevel> get sortedLevels {
    final items = [...levels];
    items.sort((a, b) => a.sortLevelId.compareTo(b.sortLevelId));
    return items;
  }

  String fieldText(String key) => fields[key]?.controller.text ?? '';

  int get nextAvailableLevelId {
    final ids = levels
        .map(
          (level) => int.tryParse(
            level.fields['level_id']?.controller.text.trim() ?? '',
          ),
        )
        .whereType<int>()
        .where((id) => id > 0)
        .toSet();
    var next = 1;
    while (ids.contains(next)) {
      next++;
    }
    return next;
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

    fields.remove('site')?.dispose();
    order.removeWhere((key) => key == 'site');

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
      final orderedLevels = sortedLevels;
      for (var i = 0; i < orderedLevels.length; i++) {
        if (i > 0) buffer.writeln();
        orderedLevels[i].writeTo(buffer);
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
    level.syncSectionWithLevel();
    return level;
  }

  List<_TomlField> get orderedFields => [
    for (final key in _levelFieldOrder)
      ?fields[key],
    for (final key in order)
      if (!_levelFieldOrder.contains(key))
        ?fields[key],
  ];

  int get sortLevelId =>
      int.tryParse(fields['level_id']?.controller.text.trim() ?? '') ?? 1 << 30;

  String get effectiveSectionName {
    final levelName = fields['level']?.controller.text.trim();
    if (levelName != null && levelName.isNotEmpty) return levelName;
    final section = sectionController.text.trim();
    if (section.isNotEmpty) return section;
    return 'Level${fields['level_id']?.controller.text.trim().isEmpty ?? true ? '' : fields['level_id']?.controller.text.trim()}';
  }

  String get displayName {
    final displayName = fields['name']?.controller.text.trim();
    final levelName = fields['level']?.controller.text.trim();
    final section = sectionController.text.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
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
    if (days != null && days.isNotEmpty) parts.add('注册 $days 周');
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
    syncSectionWithLevel();
  }

  void syncSectionWithLevel() {
    final levelName = fields['level']?.controller.text.trim();
    if (levelName == null || levelName.isEmpty) return;
    if (sectionController.text == levelName) return;
    sectionController.text = levelName;
  }

  void writeTo(StringBuffer buffer) {
    final section = _safeTomlSectionName(effectiveSectionName);
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
  final key = match.group(1)!;
  if (_ignoredTomlKeys.contains(key)) return null;
  return _TomlField.fromRaw(key, match.group(2)!.trim());
}

const _ignoredTomlKeys = {'buy_page', 'buy_action'};

String _tomlSelectDisplayLabel(String key, String value) {
  return switch (key) {
    'nation' => _nationDisplayLabel(value),
    'type' => _siteTypeDisplayLabel(value),
    _ => value,
  };
}

String _nationDisplayLabel(String value) {
  final text = value.trim();
  final normalized = text.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
  return switch (normalized) {
    'cn' ||
    'china' ||
    'mainland' ||
    'zhongguo' ||
    '中国' ||
    '中国大陆' ||
    'hk' ||
    'hongkong' ||
    '香港' ||
    '中国香港' ||
    'mo' ||
    'macau' ||
    'macao' ||
    '澳门' ||
    '中国澳门' => '中国',
    'tw' || 'taiwan' || '台湾' || '中国台湾' => '中国台湾',
    'us' || 'usa' || 'america' || 'unitedstates' || '美国' => '美国',
    'uk' || 'gb' || 'britain' || 'unitedkingdom' || '英国' => '英国',
    'jp' || 'japan' || '日本' => '日本',
    'kr' || 'korea' || 'southkorea' || '韩国' => '韩国',
    'sg' || 'singapore' || '新加坡' => '新加坡',
    'my' || 'malaysia' || '马来西亚' => '马来西亚',
    'th' || 'thailand' || '泰国' => '泰国',
    'vn' || 'vietnam' || '越南' => '越南',
    'ca' || 'canada' || '加拿大' => '加拿大',
    'au' || 'australia' || '澳大利亚' => '澳大利亚',
    'de' || 'germany' || '德国' => '德国',
    'fr' || 'france' || '法国' => '法国',
    'nl' || 'netherlands' || '荷兰' => '荷兰',
    'ru' || 'russia' || '俄罗斯' => '俄罗斯',
    'eu' || 'europe' || '欧洲' => '欧洲',
    'other' || 'foreign' || 'others' || '其他' => '其他',
    _ => text,
  };
}

String _siteTypeDisplayLabel(String value) {
  final text = value.trim();
  final normalized = text.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
  return switch (normalized) {
    'pt' || 'tracker' || 'torrent' || 'private tracker' || 'pt站点' => 'PT站点',
    'forum' || 'bbs' || 'discuz' || '论坛' => '论坛',
    _ => text,
  };
}

String _defaultTopLevelRawValue(String key) {
  return switch (key) {
    'url' => '[]',
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
  'name',
  'days',
  'downloaded',
  'uploaded',
  'ratio',
  'bonus',
  'score',
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
    'name' => _quoteTomlString(section),
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
    'name': '名称',
    'torrents_rule': '种子列表行规则',
    'nickname': '站点昵称',
    'logo': '站点图标',
    'tracker': 'Tracker 域名',
    'sp_full': '满魔力阈值',
    'limit_speed': '限速阈值',
    'tags': '站点标签',
    'iyuu': 'IYUU ID',
    'page_index': '首页',
    'page_torrents': '种子列表页',
    'page_sign_in': '签到页',
    'page_control_panel': '控制面板页',
    'page_detail': '种子详情页',
    'page_download': '下载页',
    'page_user': '用户页',
    'page_search': '搜索页',
    'page_message': '消息页',
    'page_hr': 'HR 页面',
    'page_leeching': '下载中页面',
    'page_uploaded': '已发布页面',
    'page_seeding': '做种页面',
    'page_completed': '已完成页面',
    'page_mybonus': '魔力值页面',
    'page_viewfilelist': '文件列表页',
    'page_pieces_hash_api': '分片 Hash API',
    'sign_info_title': '签到标题',
    'sign_info_content': '签到内容',
    'my_invitation_rule': '邀请数量规则',
    'my_time_join_rule': '注册时间规则',
    'my_latest_active_rule': '最近活动规则',
    'my_uploaded_rule': '上传量规则',
    'my_downloaded_rule': '下载量规则',
    'my_ratio_rule': '分享率规则',
    'my_bonus_rule': '魔力值规则',
    'my_per_hour_bonus_rule': '每小时魔力规则',
    'my_score_rule': '积分规则',
    'my_level_rule': '用户等级规则',
    'my_passkey_rule': 'Passkey 规则',
    'my_uid_rule': '用户 ID 规则',
    'my_hr_rule': 'HR 规则',
    'my_leech_rule': '下载任务规则',
    'my_publish_rule': '发布种子规则',
    'my_seed_rule': '做种数量规则',
    'my_seed_vol_rule': '做种体积规则',
    'my_mailbox_rule': '站内信规则',
    'my_message_title': '消息标题',
    'my_notice_rule': '通知规则',
    'my_notice_title': '通知标题',
    'my_notice_content': '通知内容',
    'my_email_rule': '邮箱规则',
    'my_username_rule': '用户名规则',
    'torrent_title_rule': '种子标题规则',
    'torrent_subtitle_rule': '种子副标题规则',
    'torrent_detail_url_rule': '详情链接规则',
    'torrent_category_rule': '分类规则',
    'torrent_poster_rule': '海报规则',
    'torrent_magnet_url_rule': '磁力链接规则',
    'torrent_size_rule': '大小规则',
    'torrent_progress_rule': '进度规则',
    'torrent_hr_rule': 'HR 标记规则',
    'torrent_sale_rule': '促销规则',
    'torrent_sale_expire_rule': '促销到期规则',
    'torrent_release_rule': '发布时间规则',
    'torrent_seeders_rule': '做种人数规则',
    'torrent_leechers_rule': '下载人数规则',
    'torrent_completers_rule': '完成人数规则',
    'torrent_tags_rule': '标签规则',
    'detail_title_rule': '详情页标题规则',
    'detail_subtitle_rule': '详情页副标题规则',
    'detail_download_url_rule': '详情页下载链接规则',
    'detail_size_rule': '详情页大小规则',
    'detail_category_rule': '详情页分类规则',
    'detail_count_files_rule': '详情页文件数量规则',
    'detail_hash_rule': 'Hash 规则',
    'detail_free_rule': '详情页免费规则',
    'detail_free_expire_rule': '详情页免费到期规则',
    'detail_douban_rule': '详情页豆瓣链接规则',
    'detail_imdb_rule': '详情页 IMDb 链接规则',
    'detail_poster_rule': '详情页海报规则',
    'detail_tags_rule': '详情页标签规则',
    'detail_hr_rule': '详情页 HR 规则',
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
    'days': '注册周数要求',
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
    return _parseItems(inner).join('\n');
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
  final items = _parseItems(value).map(_quoteTomlString).join(', ');
  if (items.isEmpty) return '[]';
  return '[ $items,]';
}

List<String> _parseItems(String value) {
  return value
      .split(RegExp(r'[\n,]+'))
      .map((item) => _unquoteTomlString(item.trim()))
      .where((item) => item.isNotEmpty)
      .toList();
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
  Map<String, dynamic>? buyActionSection;

  for (final entry in map.entries) {
    final key = entry.key;
    final value = entry.value;
    if (key == 'buy_action') {
      if (value is Map && value.isNotEmpty) {
        buyActionSection = value.map(
          (entryKey, entryValue) =>
              MapEntry(entryKey.toString(), entryValue?.toString() ?? ''),
        );
      }
      continue;
    }
    if (_ignoredTomlKeys.contains(key)) continue;
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
            '${levelMap['name'] ?? levelMap['level'] ?? 'Level${i + 1}'}';
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
      if (_ignoredTomlKeys.contains(field.key) || field.value is Map) continue;
      buffer.writeln('${field.key} = ${_formatTomlDynamic(field.value)}');
    }
  }

  if (buyActionSection case final section?) {
    if (buffer.isNotEmpty) buffer.writeln();
    buffer.writeln('[buy_action]');
    for (final field in section.entries) {
      buffer.writeln(
        '${_quoteTomlString(field.key)} = ${_quoteTomlString(field.value.toString())}',
      );
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
