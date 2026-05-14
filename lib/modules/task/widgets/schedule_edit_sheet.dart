import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/crontab.dart';
import '../model/schedule.dart';
import '../provider/crontab_provider.dart';
import '../provider/schedule_provider.dart';

class ScheduleEditSheet extends ConsumerStatefulWidget {
  final Schedule? task;

  const ScheduleEditSheet({super.key, this.task});

  @override
  ConsumerState<ScheduleEditSheet> createState() => _ScheduleEditSheetState();
}

class _ScheduleEditSheetState extends ConsumerState<ScheduleEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _minuteCtrl;
  late final TextEditingController _hourCtrl;
  late final TextEditingController _dayOfWeekCtrl;
  late final TextEditingController _dayOfMonthCtrl;
  late final TextEditingController _monthOfYearCtrl;

  String? _selectedTaskType;
  bool _enabled = true;
  bool _advance = false;
  bool _saving = false;

  bool get _isEdit => widget.task != null;

  CrontabItem? _findCrontab(List<CrontabItem> list) {
    final id = widget.task?.crontabId;
    if (id == null) return null;
    return list.firstWhereOrNull((c) => c.id == id);
  }

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _nameCtrl = TextEditingController(text: task?.name ?? '');
    _minuteCtrl = TextEditingController(text: task?.crontab?.minute ?? '1');
    _hourCtrl = TextEditingController(text: task?.crontab?.hour ?? '*');
    _dayOfWeekCtrl = TextEditingController(text: task?.crontab?.dayOfWeek ?? '*');
    _dayOfMonthCtrl = TextEditingController(text: task?.crontab?.dayOfMonth ?? '*');
    _monthOfYearCtrl = TextEditingController(text: task?.crontab?.monthOfYear ?? '*');
    _selectedTaskType = task?.task.isNotEmpty == true ? task?.task : null;
    _enabled = task?.enabled ?? true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cron = _findCrontab(ref.read(crontabListProvider).valueOrNull ?? []);
    if (cron != null) {
      _minuteCtrl.text = cron.minute;
      _hourCtrl.text = cron.hour;
      _dayOfWeekCtrl.text = cron.dayOfWeek;
      _dayOfMonthCtrl.text = cron.dayOfMonth;
      _monthOfYearCtrl.text = cron.monthOfYear;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minuteCtrl.dispose();
    _hourCtrl.dispose();
    _dayOfWeekCtrl.dispose();
    _dayOfMonthCtrl.dispose();
    _monthOfYearCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_nameCtrl.text.trim().isEmpty) return _err('请填写任务名称');
    if (_selectedTaskType == null) return _err('请选择任务类型');
    if (_minuteCtrl.text.trim().isEmpty) return _err('请填写分钟');
    if (_hourCtrl.text.trim().isEmpty) return _err('请填写小时');
    return true;
  }

  bool _err(String msg) {
    Toast.error(msg);
    return false;
  }

  Future<void> _save() async {
    if (_saving || !_validate()) return;
    setState(() => _saving = true);

    try {
      final schedule = Schedule(
        id: widget.task?.id ?? 0,
        name: _nameCtrl.text.trim(),
        task: _selectedTaskType!,
        description: widget.task?.description ?? '',
        crontab: CrontabItem(
          id: widget.task?.crontabId ?? 0,
          express: '',
          minute: _minuteCtrl.text.trim(),
          hour: _hourCtrl.text.trim(),
          dayOfWeek: _dayOfWeekCtrl.text.trim(),
          dayOfMonth: _dayOfMonthCtrl.text.trim(),
          monthOfYear: _monthOfYearCtrl.text.trim(),
        ),
        args: widget.task?.args ?? '[]',
        kwargs: widget.task?.kwargs ?? '{}',
        enabled: _enabled,
      );

      await ref.read(scheduleProvider.notifier).save(schedule);
      if (mounted) closeAppSheet(context);
    } catch (e) {
      // if (mounted) _err('保存失败: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSelectSheet<T>({
    required String title,
    required List<T> options,
    required T? selected,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onSelected,
  }) {
    if (!context.isMobile) {
      shadcn.showDialog<void>(
        context: context,
        builder: (dialogContext) => shadcn.ModalContainer(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360, maxHeight: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      shadcn.IconButton.ghost(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(shadcn.LucideIcons.x, size: 16),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    children: [
                      for (final option in options) ...[
                        Builder(
                          builder: (context) {
                            final selectedOption = option == selected;
                            return _SheetTile(
                              title: _selectedOptionTitle(dialogContext, labelBuilder(option), selectedOption),
                              onTap: () {
                                onSelected(option);
                                Navigator.of(dialogContext).pop();
                              },
                              trailing: selectedOption
                                  ? Icon(
                                      shadcn.LucideIcons.check,
                                      size: 18,
                                      color: shadcn.Theme.of(dialogContext).colorScheme.primary,
                                    )
                                  : null,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    showAppSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: options.map((t) {
                    final selectedOption = t == selected;
                    return _SheetTile(
                      title: _selectedOptionTitle(context, labelBuilder(t), selectedOption),
                      onTap: () {
                        onSelected(t);
                        closeAppSheet(ctx);
                      },
                      trailing: selectedOption
                          ? Icon(
                              shadcn.LucideIcons.check,
                              size: 18,
                              color: shadcn.Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _selectedOptionTitle(BuildContext context, String label, bool selected) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Text(
      label,
      style: TextStyle(color: selected ? cs.primary : null, fontWeight: selected ? FontWeight.w700 : FontWeight.w400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final taskTypesAsync = ref.watch(taskTypeListProvider);

    return shadcn.OverlayManagerLayer(
      popoverHandler: const shadcn.PopoverOverlayHandler(),
      tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
      menuHandler: const shadcn.PopoverOverlayHandler(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(child: _buildForm(taskTypesAsync)),
              const Divider(height: 1),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_isEdit ? '编辑任务' : '添加任务', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Row(
            children: [
              const Text('高级', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Switch(value: _advance, onChanged: (v) => setState(() => _advance = v)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AsyncValue<List<String>> taskTypesAsync) {
    return taskTypesAsync.when(
      loading: () => const Center(child: shadcn.CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (types) {
        final cs = shadcn.Theme.of(context).colorScheme;
        final filtered = types.where((t) => !t.contains('种子迁移')).toList();
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              _SheetGroup(
                children: [
                  _SheetTile(
                    title: const Text('选择任务'),
                    subtitle: Text(
                      _selectedTaskType ?? '请选择',
                      style: TextStyle(
                        color: _selectedTaskType == null ? cs.mutedForeground : cs.foreground,
                        fontSize: _selectedTaskType == null ? 12 : 18,
                        fontWeight: _selectedTaskType == null ? FontWeight.w400 : FontWeight.w900,
                      ),
                    ),
                    helper: _selectedTaskType != null ? null : const Text('选择要执行的后台任务类型'),
                    trailing: const Icon(shadcn.LucideIcons.chevronRight, size: 18),
                    onTap: () => _showSelectSheet<String>(
                      title: '选择任务',
                      options: filtered,
                      selected: _selectedTaskType,
                      labelBuilder: (v) => v,
                      onSelected: (v) => setState(() => _selectedTaskType = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SheetTextField(
                controller: _nameCtrl,
                label: '任务名称',
                hintText: '例如：每日签到、每小时同步数据',
                helperText: '用于列表展示，建议填写清晰易懂的名称',
              ),
              const SizedBox(height: 12),
              _SheetTextField(
                controller: _minuteCtrl,
                label: '分钟',
                hintText: '1 或 */5',
                helperText: 'Cron 分钟位，支持 *、*/5、1,15,30 这类写法',
              ),
              const SizedBox(height: 12),
              _SheetTextField(controller: _hourCtrl, label: '小时', hintText: '* 或 0-23', helperText: 'Cron 小时位，* 表示每小时'),
              const SizedBox(height: 8),
              _SheetGroup(
                children: [
                  _SheetTile(
                    title: const Text('开启任务'),
                    helper: const Text('关闭后任务不会被调度执行'),
                    trailing: Switch(value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
                  ),
                ],
              ),
              if (_advance) ...[
                const SizedBox(height: 12),
                _SheetTextField(
                  controller: _dayOfWeekCtrl,
                  label: '周几',
                  hintText: '* 或 0-6',
                  helperText: 'Cron 星期位，0/7 一般表示周日',
                ),
                const SizedBox(height: 12),
                _SheetTextField(
                  controller: _dayOfMonthCtrl,
                  label: '几号',
                  hintText: '* 或 1-31',
                  helperText: 'Cron 日期位，指定每月的第几天执行',
                ),
                const SizedBox(height: 12),
                _SheetTextField(
                  controller: _monthOfYearCtrl,
                  label: '几月',
                  hintText: '* 或 1-12',
                  helperText: 'Cron 月份位，* 表示每月',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: shadcn.Button.outline(
              onPressed: () => closeAppSheet(context),
              child: Center(child: const Text('取消')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: shadcn.Button.primary(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: Center(child: shadcn.CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : Center(child: const Text('保存')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? helperText;

  const _SheetTextField({required this.controller, required this.label, required this.hintText, this.helperText});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(helperText!, style: TextStyle(fontSize: 12, color: cs.mutedForeground)),
        ],
        const SizedBox(height: 8),
        ShadTextField(
          controller: controller,
          hintText: hintText,
          onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
      ],
    );
  }
}

class _SheetGroup extends StatelessWidget {
  final List<Widget> children;

  const _SheetGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? helper;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SheetTile({required this.title, this.subtitle, this.helper, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return InkWell(
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
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
