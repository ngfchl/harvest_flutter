import 'package:flutter/material.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/downloader.dart';
import '../model/downloader_category.dart';
import '../provider/downloader_provider.dart';
import '../service/downloader_service.dart';

class QbCategoryManagerSheet extends ConsumerWidget {
  final Downloader downloader;

  const QbCategoryManagerSheet({super.key, required this.downloader});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(downloaderCategoriesProvider(downloader.id));

    return _ManagerScaffold(
      title: '分类管理',
      subtitle: downloader.name,
      icon: shadcn.LucideIcons.tags,
      onAdd: () => _showCategoryEditor(context, ref),
      onRefresh: () => ref.invalidate(downloaderCategoriesProvider(downloader.id)),
      child: asyncCategories.when(
        loading: () => const Center(child: shadcn.CircularProgressIndicator(strokeWidth: 2)),
        error: (error, _) => _ManagerError(
          message: '加载分类失败',
          onRetry: () => ref.invalidate(downloaderCategoriesProvider(downloader.id)),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const _ManagerEmpty(text: '暂无分类');
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final category = categories[index];
              return _CategoryCard(
                category: category,
                onEdit: () => _showCategoryEditor(context, ref, category),
                onDelete: () => _confirmDeleteCategory(context, ref, category),
              );
            },
          );
        },
      ),
    );
  }

  void _showCategoryEditor(BuildContext context, WidgetRef ref, [DownloaderCategory? category]) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final pathCtrl = TextEditingController(text: category?.savePath ?? '');
    final editing = category != null;

    showDialog(
      context: context,
      builder: (ctx) => _InputDialog(
        title: editing ? '编辑分类' : '新增分类',
        primaryLabel: '分类名称',
        primaryController: nameCtrl,
        secondaryLabel: '保存路径',
        secondaryController: pathCtrl,
        primaryEnabled: !editing,
        onSubmit: () async {
          final name = nameCtrl.text.trim();
          if (name.isEmpty) {
            Toast.warning('请输入分类名称');
            return;
          }
          try {
            if (editing) {
              await DownloaderService.editCategory(downloader.id, category: name, savePath: pathCtrl.text.trim());
            } else {
              await DownloaderService.createCategory(downloader.id, category: name, savePath: pathCtrl.text.trim());
            }
            ref.invalidate(downloaderCategoriesProvider(downloader.id));
            if (ctx.mounted) closeAppSheet(ctx);
            Toast.success(editing ? '分类已更新' : '分类已创建');
          } catch (e, st) {
            AppLogger.error('保存 QB 分类失败', e, st);
            Toast.error('保存分类失败');
          }
        },
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, WidgetRef ref, DownloaderCategory category) {
    _showConfirmDialog(
      context,
      title: '删除分类',
      message: '确定删除「${category.name}」吗？不会删除种子文件。',
      destructive: true,
      onConfirm: () async {
        try {
          await DownloaderService.deleteCategory(downloader.id, category.name);
          ref.invalidate(downloaderCategoriesProvider(downloader.id));
          Toast.success('分类已删除');
        } catch (e, st) {
          AppLogger.error('删除 QB 分类失败', e, st);
          Toast.error('删除分类失败');
        }
      },
    );
  }
}

class QbTagManagerSheet extends ConsumerWidget {
  final Downloader downloader;

  const QbTagManagerSheet({super.key, required this.downloader});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTags = ref.watch(downloaderTagsProvider(downloader.id));

    return _ManagerScaffold(
      title: '标签管理',
      subtitle: downloader.name,
      icon: shadcn.LucideIcons.tag,
      onAdd: () => _showTagEditor(context, ref),
      onRefresh: () => ref.invalidate(downloaderTagsProvider(downloader.id)),
      child: asyncTags.when(
        loading: () => const Center(child: shadcn.CircularProgressIndicator(strokeWidth: 2)),
        error: (error, _) =>
            _ManagerError(message: '加载标签失败', onRetry: () => ref.invalidate(downloaderTagsProvider(downloader.id))),
        data: (tags) {
          if (tags.isEmpty) return const _ManagerEmpty(text: '暂无标签');
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
            itemCount: tags.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final tag = tags[index];
              return _TagCard(tag: tag, onDelete: () => _confirmDeleteTag(context, ref, tag));
            },
          );
        },
      ),
    );
  }

  void _showTagEditor(BuildContext context, WidgetRef ref) {
    final tagCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _InputDialog(
        title: '新增标签',
        primaryLabel: '标签名称',
        primaryController: tagCtrl,
        onSubmit: () async {
          final tag = tagCtrl.text.trim();
          if (tag.isEmpty) {
            Toast.warning('请输入标签名称');
            return;
          }
          try {
            await DownloaderService.createTag(downloader.id, tag);
            ref.invalidate(downloaderTagsProvider(downloader.id));
            if (ctx.mounted) closeAppSheet(ctx);
            Toast.success('标签已创建');
          } catch (e, st) {
            AppLogger.error('创建 QB 标签失败', e, st);
            Toast.error('创建标签失败');
          }
        },
      ),
    );
  }

  void _confirmDeleteTag(BuildContext context, WidgetRef ref, String tag) {
    _showConfirmDialog(
      context,
      title: '删除标签',
      message: '确定删除「$tag」吗？',
      destructive: true,
      onConfirm: () async {
        try {
          await DownloaderService.deleteTag(downloader.id, tag);
          ref.invalidate(downloaderTagsProvider(downloader.id));
          Toast.success('标签已删除');
        } catch (e, st) {
          AppLogger.error('删除 QB 标签失败', e, st);
          Toast.error('删除标签失败');
        }
      },
    );
  }
}

class _ManagerScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onAdd;
  final VoidCallback onRefresh;
  final Widget child;

  const _ManagerScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onAdd,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return SafeArea(
      child: ColoredBox(
        color: cs.background,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 18, color: cs.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: cs.mutedForeground, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    shadcn.IconButton.ghost(
                      onPressed: onRefresh,
                      icon: const Icon(shadcn.LucideIcons.refreshCw, size: 16),
                    ),
                    shadcn.IconButton.primary(onPressed: onAdd, icon: const Icon(shadcn.LucideIcons.plus, size: 16)),
                  ],
                ),
              ),
              Divider(height: 1, color: cs.border),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final DownloaderCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({required this.category, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.border, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(shadcn.LucideIcons.folder, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.foreground, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  category.savePath.isEmpty ? '未设置保存路径' : category.savePath,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.mutedForeground, fontSize: 12),
                ),
              ],
            ),
          ),
          shadcn.IconButton.ghost(onPressed: onEdit, icon: const Icon(shadcn.LucideIcons.pencil, size: 15)),
          shadcn.IconButton.ghost(
            onPressed: onDelete,
            icon: Icon(shadcn.LucideIcons.trash2, size: 15, color: cs.destructive),
          ),
        ],
      ),
    );
  }
}

class _TagCard extends StatelessWidget {
  final String tag;
  final VoidCallback onDelete;

  const _TagCard({required this.tag, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.border, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(shadcn.LucideIcons.tag, size: 18, color: const Color(0xFF14B8A6)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tag,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.foreground, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          shadcn.IconButton.ghost(
            onPressed: onDelete,
            icon: Icon(shadcn.LucideIcons.trash2, size: 15, color: cs.destructive),
          ),
        ],
      ),
    );
  }
}

class _InputDialog extends StatelessWidget {
  final String title;
  final String primaryLabel;
  final TextEditingController primaryController;
  final String? secondaryLabel;
  final TextEditingController? secondaryController;
  final bool primaryEnabled;
  final Future<void> Function() onSubmit;

  const _InputDialog({
    required this.title,
    required this.primaryLabel,
    required this.primaryController,
    required this.onSubmit,
    this.secondaryLabel,
    this.secondaryController,
    this.primaryEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: cs.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            shadcn.TextField(controller: primaryController, enabled: primaryEnabled, hintText: ""),
            if (secondaryController != null && secondaryLabel != null) ...[
              const SizedBox(height: 12),
              shadcn.TextField(controller: secondaryController!, hintText: ""),
            ],
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                shadcn.Button.ghost(onPressed: () => closeAppSheet(context), child: const Text('取消')),
                const SizedBox(width: 8),
                shadcn.Button.primary(onPressed: onSubmit, child: const Text('保存')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagerError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ManagerError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(shadcn.LucideIcons.cloudOff, size: 32, color: cs.mutedForeground),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: cs.mutedForeground)),
          const SizedBox(height: 12),
          shadcn.Button.primary(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

class _ManagerEmpty extends StatelessWidget {
  final String text;

  const _ManagerEmpty({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(shadcn.LucideIcons.inbox, size: 32, color: cs.mutedForeground),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: cs.mutedForeground)),
        ],
      ),
    );
  }
}

void _showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required Future<void> Function() onConfirm,
  bool destructive = false,
}) {
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = shadcn.Theme.of(ctx).colorScheme;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: destructive ? cs.destructive : cs.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(message, style: TextStyle(color: cs.mutedForeground, fontSize: 13)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  shadcn.Button.ghost(onPressed: () => closeAppSheet(ctx), child: const Text('取消')),
                  const SizedBox(width: 8),
                  destructive
                      ? shadcn.Button.destructive(
                          onPressed: () async {
                            closeAppSheet(ctx);
                            await onConfirm();
                          },
                          child: const Text('确认'),
                        )
                      : shadcn.Button.primary(
                          onPressed: () async {
                            closeAppSheet(ctx);
                            await onConfirm();
                          },
                          child: const Text('确认'),
                        ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
