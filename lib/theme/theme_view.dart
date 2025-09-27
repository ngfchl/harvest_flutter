import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/theme/theme_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../app/home/controller/home_controller.dart';
import '../common/card_view.dart';
import '../common/image_helper.dart';
import '../utils/logger_helper.dart';
import '../utils/storage.dart';

class ThemeIconButton extends StatelessWidget {
  final Icon icon; // Accepts an Icon widget as a parameter

  const ThemeIconButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();
    RxString? baseUrl = SPUtil.getString('backgroundImage', defaultValue: 'https://bing.img.run/rand_uhd.php').obs;
    RxDouble? opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7).obs;
    RxBool useLocalBackground = SPUtil.getBool('useLocalBackground', defaultValue: false).obs;
    RxBool useBackground = SPUtil.getBool('useBackground', defaultValue: false).obs;
    RxBool useImageProxy = SPUtil.getBool('useImageProxy', defaultValue: false).obs;
    TextEditingController urlController = TextEditingController(
      text: baseUrl.value,
    );
    if (kIsWeb) {
      useLocalBackground.value = false;
    }
    final isEdit = false.obs;
    final showPreview = false.obs;
    HomeController homeController = Get.find();
    return ShadIconButton.ghost(
      icon: icon, // Use the passed icon
      onPressed: () {
        showShadDialog(
          context: context,
          builder: (context) => Obx(() {
            var shadColorScheme = ShadTheme.of(context).colorScheme;

            return ShadDialog(
              title: Center(child: const Text("主题设置")),
              alignment: Alignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              backgroundColor: ShadTheme.of(context).cardTheme.backgroundColor?.withOpacity(opacity.value),
              actions: [
                if (useBackground.value)
                  ShadButton.secondary(
                    child: Text('预览'),
                    onPressed: () {
                      if (urlController.text.isNotEmpty) {
                        baseUrl.value = urlController.text;
                        showPreview.value = !showPreview.value;
                      } else {
                        showPreview.value = false;
                      }
                    },
                  ),
                ShadButton(
                  onPressed: () {
                    if (urlController.text.isNotEmpty) {
                      if (useLocalBackground.value && baseUrl.value.startsWith('http')) {
                        Get.snackbar(
                          '出错啦',
                          "请选择正确的背景图片！",
                          colorText: shadColorScheme.destructive,
                        );
                        return;
                      }
                      baseUrl.value = urlController.text;
                      Logger.instance.d('backgroundImage: ${urlController.text}');
                      SPUtil.setString('backgroundImage', urlController.text);
                      homeController.backgroundImage = urlController.text;
                      homeController.update(['home_view_background_image']);
                      Get.back();
                      homeController.onInit();
                    } else {
                      Get.snackbar(
                        '出错啦',
                        "请选择或输入正确的图片地址！",
                        colorText: shadColorScheme.destructive,
                      );
                    }
                  },
                  child: Text('保存'),
                ),
                ShadButton.destructive(
                  child: const Text("关闭"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
              child: Builder(builder: (context) {
                return Material(
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 15,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 颜色块选择 + Tooltip 中文名
                          Obx(() => Center(
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
                              )),

                          /// 手动切换亮暗（仅在不跟随系统时显示）
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(
                                () => ShadSwitch(
                                  value: controller.followSystem.value,
                                  onChanged: (bool v) async {
                                    await controller.toggleFollowSystem(v);
                                    await SPUtil.setBool('followSystem', v);
                                  },
                                  label: Text('跟随系统'),
                                ),
                              ),
                              Obx(
                                () => ShadButton(
                                  size: ShadButtonSize.sm,
                                  onPressed: () => controller.followSystem.value ? null : controller.toggleDarkMode(),
                                  child: Text(
                                    controller.isDark.value ? "暗黑模式" : "明亮模式",
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Obx(() {
                            return ShadSwitch(
                              label: Text('背景图片'),
                              value: useBackground.value,
                              onChanged: (value) {
                                useBackground.value = value;
                                SPUtil.setBool('useBackground', value);
                              },
                            );
                          }),
                          if (useBackground.value && !kIsWeb)
                            Obx(() {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ShadSwitch(
                                    label: Text(useLocalBackground.value ? '本地图片' : '网络图片'),
                                    sublabel: Text(
                                      '默认网络图片',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    value: kIsWeb ? false : useLocalBackground.value,
                                    onChanged: (value) {
                                      useLocalBackground.value = value;
                                      SPUtil.setBool('useLocalBackground', value);
                                    },
                                  ),
                                  if (!useLocalBackground.value)
                                    Obx(() {
                                      return ShadSwitch(
                                        label: Text('网络图片加速'),
                                        value: useImageProxy.value,
                                        onChanged: (value) {
                                          useImageProxy.value = value;
                                          SPUtil.setBool('useImageProxy', value);
                                        },
                                      );
                                    }),
                                ],
                              );
                            }),

                          if (useBackground.value)
                            Obx(() {
                              return Column(spacing: 10, children: [
                                useLocalBackground.value
                                    ? ImagePickerRow(
                                        onImagePicked: (String? path) {
                                          if (path != null) {
                                            urlController.text = path;
                                          }
                                        },
                                      )
                                    : ShadInput(
                                        controller: urlController,
                                        placeholder: Text('背景图片地址'),
                                        keyboardType: TextInputType.url,
                                      ),
                                Obx(() {
                                  if (showPreview.value && baseUrl.value.isNotEmpty) {
                                    Logger.instance
                                        .d('backgroundImage: $baseUrl , useLocalBackground: $useLocalBackground');
                                    return useLocalBackground.value
                                        ? baseUrl.value.startsWith('http')
                                            ? SizedBox.shrink()
                                            : Image.file(
                                                File(baseUrl.value),
                                                width: double.infinity,
                                                fit: BoxFit.fitWidth,
                                              )
                                        : Obx(() {
                                            return CachedNetworkImage(
                                              imageUrl:
                                                  '${useImageProxy.value ? 'https://images.weserv.nl/?url=' : ''}${baseUrl.value}',
                                              placeholder: (context, url) => Center(
                                                  child: CircularProgressIndicator(
                                                color: shadColorScheme.primary,
                                              )),
                                              errorWidget: (context, url, error) =>
                                                  Image.asset('assets/images/background.png'),
                                              fit: BoxFit.fitWidth,
                                            );
                                          });
                                  }
                                  return SizedBox.shrink();
                                }),
                              ]);
                            }),
                          Obx(() {
                            return Row(
                              children: [
                                Text(
                                  '卡片透明度',
                                  style: TextStyle(color: shadColorScheme.foreground),
                                ),
                                Expanded(
                                  child: ShadSlider(
                                      min: 0.1,
                                      max: 1,
                                      // divisions: 10,
                                      label: opacity.value.toString(),
                                      initialValue: opacity.value,
                                      onChanged: (value) async {
                                        opacity.value = value;
                                        SPUtil.setDouble('cardOpacity', opacity.value);
                                      }),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        );
      },
    );
  }
}

class ThemeTag extends StatelessWidget {
  const ThemeTag({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();
    var shadColorScheme = ShadTheme.of(context).colorScheme;

    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            '跟随系统',
            style: TextStyle(color: shadColorScheme.foreground),
          ),
          leading: ThemeIconButton(
            // Pass an icon as a parameter
            icon: Icon(LucideIcons.palette, size: 20, color: shadColorScheme.primary),
          ),
          trailing: ShadSwitch(
            value: controller.followSystem.value,
            onChanged: (bool v) async {
              await controller.toggleFollowSystem(v);
              await SPUtil.setBool('followSystem', v);
            },
          ),
        ),
      );
    });
  }
}
