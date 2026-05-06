import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../core/theme/theme_presets.dart';
import '../../../core/theme/theme_provider.dart';

class ThemeDialog extends ConsumerWidget {
  const ThemeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeNotifierProvider);

    return FDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text('主题设置'),

          /// =====================
          /// 🌗 Mode
          /// =====================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 8,
            children: [
              _modeIcon(ref, ThemeMode.light, Icons.light_mode),
              _modeIcon(ref, ThemeMode.dark, Icons.dark_mode),
              _modeIcon(ref, ThemeMode.system, Icons.brightness_auto),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child:  Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppThemes.list.map((theme) {
            final selected = theme.name == current.theme.name;

            return GestureDetector(
              onTap: () {
                ref.read(themeNotifierProvider.notifier).setTheme(theme);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [theme.light.colors.primary, theme.dark.colors.primary]),
                  border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 2),
                  boxShadow: selected
                      ? [BoxShadow(color: theme.light.colors.primary.withOpacity(0.5), blurRadius: 8)]
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [],
    );
  }

  Widget _modeIcon(WidgetRef ref, ThemeMode mode, IconData icon) {
    final current = ref.watch(themeNotifierProvider);

    final selected = current.mode == mode;

    return GestureDetector(
      onTap: () {
        ref.read(themeNotifierProvider.notifier).setMode(mode);
      },
      child: Icon(icon, color: selected ? current.theme.seedColor : null),
    );
  }
}
