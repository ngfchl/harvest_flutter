import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/widgets/escape_back_scope.dart';

import '../provider/update_provider.dart';
import 'update_panel.dart';

class UpdatePage extends ConsumerWidget {
  const UpdatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = FTheme.of(context).colors;
    final state = ref.watch(updateProvider);

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(
          backgroundColor: cs.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(FIcons.arrowLeft, size: 20, color: cs.foreground),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '程序更新',
            style: TextStyle(
              color: cs.foreground,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              tooltip: '检查全部',
              icon: state.isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.foreground.withOpacity(0.55),
                      ),
                    )
                  : Icon(FIcons.refreshCw, size: 18, color: cs.foreground),
              onPressed: state.isLoading || state.isUpdating
                  ? null
                  : () => ref.read(updateProvider.notifier).refresh(),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.read(updateProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            children: const [UpdatePanel(maxCommitCount: 12)],
          ),
        ),
      ),
    );
  }
}
