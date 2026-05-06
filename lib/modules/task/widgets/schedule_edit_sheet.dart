import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

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
    _dayOfWeekCtrl =
        TextEditingController(text: task?.crontab?.dayOfWeek ?? '*');
    _dayOfMonthCtrl =
        TextEditingController(text: task?.crontab?.dayOfMonth ?? '*');
    _monthOfYearCtrl =
        TextEditingController(text: task?.crontab?.monthOfYear ?? '*');
    _selectedTaskType = task?.task.isNotEmpty == true ? task?.task : null;
    _enabled = task?.enabled ?? true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cron =
    _findCrontab(ref.read(crontabListProvider).valueOrNull ?? []);
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
      if (mounted) Navigator.pop(context);
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.theme.colors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: FTileGroup(
                  children: options
                      .map((t) => FTile(
                    title: Text(labelBuilder(t)),
                    onPress: () {
                      onSelected(t);
                      Navigator.pop(ctx);
                    },
                    suffix: t == selected
                        ? Icon(FIcons.check,
                        size: 18,
                        color: context.theme.colors.primary)
                        : null,
                  ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final taskTypesAsync = ref.watch(taskTypeListProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(child: _buildForm(taskTypesAsync)),
          const FDivider(),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_isEdit ? '编辑任务' : '添加任务',
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Row(
            children: [
              const Text('高级', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              FSwitch(
                  value: _advance,
                  onChange: (v) => setState(() => _advance = v)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AsyncValue<List<String>> taskTypesAsync) {
    return taskTypesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (types) {
        final filtered =
        types.where((t) => !t.contains('种子迁移')).toList();
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              FTileGroup(
                children: [
                  FTile(
                    title: const Text('选择任务'),
                    subtitle: Text(_selectedTaskType ?? '请选择'),
                    suffix: const Icon(FIcons.chevronRight, size: 18),
                    onPress: () => _showSelectSheet<String>(
                      title: '选择任务',
                      options: filtered,
                      selected: _selectedTaskType,
                      labelBuilder: (v) => v,
                      onSelected: (v) =>
                          setState(() => _selectedTaskType = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FTextField(controller: _nameCtrl, label: const Text('任务名称')),
              const SizedBox(height: 12),
              FTextField(controller: _minuteCtrl, label: const Text('分钟')),
              const SizedBox(height: 12),
              FTextField(controller: _hourCtrl, label: const Text('小时')),
              const SizedBox(height: 8),
              FTileGroup(
                children: [
                  FTile(
                    title: const Text('开启任务'),
                    suffix: FSwitch(
                        value: _enabled,
                        onChange: (v) => setState(() => _enabled = v)),
                  ),
                ],
              ),
              if (_advance) ...[
                const SizedBox(height: 12),
                FTextField(
                    controller: _dayOfWeekCtrl, label: const Text('周几')),
                const SizedBox(height: 12),
                FTextField(
                    controller: _dayOfMonthCtrl, label: const Text('几号')),
                const SizedBox(height: 12),
                FTextField(
                    controller: _monthOfYearCtrl, label: const Text('几月')),
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
            child: FButton(
              style: FButtonStyle.outline(),
              onPress: () => Navigator.pop(context),
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
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('保存'),
            ),
          ),
        ],
      ),
    );
  }
}
