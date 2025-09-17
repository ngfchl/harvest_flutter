import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/utils/storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../common/card_view.dart';
import 'theme_controller.dart';

class ThemeTag extends StatelessWidget {
  const ThemeTag({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();
    double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);

    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            '跟随系统',
            style: TextStyle(color: ShadTheme.of(context).colorScheme.foreground),
          ),
          leading: ShadIconButton.ghost(
            icon: Icon(LucideIcons.palette, size: 20, color: ShadTheme.of(context).colorScheme.foreground), // 可以自定义图标
            onPressed: () {
              showShadDialog(
                context: context,
                builder: (context) => ShadDialog(
                  title: const Text("主题设置"),
                  backgroundColor: ShadTheme.of(context).cardTheme.backgroundColor?.withOpacity(opacity),
                  actions: [
                    ShadButton(
                      child: const Text("关闭"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 手动切换亮暗（仅在不跟随系统时显示）
                      Obx(() => controller.followSystem.value
                          ? const SizedBox.shrink()
                          : ShadButton.outline(
                              onPressed: () => controller.toggleDarkMode(),
                              child: Text(
                                controller.isDark.value ? "切换到亮色" : "切换到暗黑",
                              ),
                            )),

                      const SizedBox(height: 20),
                      const Text("主题颜色"),
                      const SizedBox(height: 10),

                      /// 颜色块选择 + Tooltip 中文名
                      Obx(() => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Center(
                              child: Wrap(
                                spacing: 30,
                                runSpacing: 20,
                                alignment: WrapAlignment.center,
                                children: controller.shadThemeColorNames.keys.map((name) {
                                  final isSelected = controller.colorSchemeName.value == name;
                                  final scheme = ShadColorScheme.fromName(name);
                                  final cnName = controller.shadThemeColorNames[name] ?? name;

                                  return Tooltip(
                                    message: cnName,
                                    child: GestureDetector(
                                      onTap: () => controller.changeColorScheme(name),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: scheme.primary,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected ? scheme.foreground : const Color(0x00000000),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
          trailing: ShadSwitch(
              value: controller.followSystem.value,
              onChanged: (bool v) async {
                await controller.toggleFollowSystem(v);
                await SPUtil.setBool('followSystem', v);
              }),
        ),
      );
    });
  }
}
