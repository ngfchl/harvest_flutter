import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/my_site/controller.dart';
import 'package:harvest/common/form_widgets.dart';
import 'package:harvest/theme/theme_controller.dart';
import 'package:harvest/utils/platform.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../common/card_view.dart';
import '../common/corner_badge.dart';
import '../common/image_helper.dart';
import '../utils/calc_weeks.dart';
import '../utils/logger_helper.dart';
import '../utils/storage.dart';
import 'background_container.dart';
import 'color_storage.dart';

class ThemeIconButton extends StatelessWidget {
  final Icon icon; // Accepts an Icon widget as a parameter

  const ThemeIconButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final popoverController = ShadPopoverController();
    final controller = Get.find<ThemeController>();
    TextEditingController urlController = TextEditingController(text: controller.backgroundImage.value);

    if (kIsWeb) {
      controller.useLocalBackground.value = false;
    }
    final showPreview = false.obs;
    var shadColorScheme = ShadTheme.of(context).colorScheme;

    return GetBuilder<ThemeController>(builder: (controller) {
      return Obx(() {
        return ShadPopover(
          controller: popoverController,
          closeOnTapOutside: false,
          padding: EdgeInsets.zero,
          popover: (context) => ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 630, maxWidth: 450, minHeight: 300),
            child: BackgroundContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '主题设置',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: shadColorScheme.foreground),
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 15,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 颜色块选择 + Tooltip 中文名
                          Obx(() => Center(
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: controller.shadThemeColorNames.keys.map((name) {
                                    final isSelected = controller.colorSchemeName.value == name;
                                    final scheme = ShadColorScheme.fromName(name);
                                    final cnName = controller.shadThemeColorNames[name] ?? name;

                                    return Tooltip(
                                      message: cnName,
                                      child: GestureDetector(
                                        onTap: () => controller.changeColorScheme(name),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: scheme.primary,
                                            borderRadius: BorderRadius.circular(50),
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
                                () => ShadButton.secondary(
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
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ShadSwitch(
                                  label: Text('背景图片'),
                                  value: controller.useBackground.value,
                                  onChanged: (value) {
                                    controller.useBackground.value = value;
                                    SPUtil.setBool('useBackground', value);
                                  },
                                ),
                                if (controller.useBackground.value)
                                  ShadSwitch(
                                    label: Text('使用缓存'),
                                    value: controller.useImageCache.value,
                                    onChanged: (value) {
                                      controller.useImageCache.value = value;
                                      SPUtil.setBool('useImageCache', value);
                                    },
                                  ),
                              ],
                            );
                          }),
                          Obx(() {
                            return controller.useBackground.value && !kIsWeb
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ShadSwitch(
                                        label: Text(controller.useLocalBackground.value ? '本地图片' : '网络图片'),
                                        sublabel: Text(
                                          '默认网络图片',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        value: kIsWeb ? false : controller.useLocalBackground.value,
                                        onChanged: (value) {
                                          controller.useLocalBackground.value = value;
                                          SPUtil.setBool('useLocalBackground', value);
                                        },
                                      ),
                                      if (!controller.useLocalBackground.value)
                                        Obx(() {
                                          return ShadSwitch(
                                            label: Text('图片加速'),
                                            value: controller.useImageProxy.value,
                                            onChanged: (value) {
                                              controller.useImageProxy.value = value;
                                              SPUtil.setBool('useImageProxy', value);
                                            },
                                          );
                                        }),
                                    ],
                                  )
                                : SizedBox.shrink();
                          }),
                          controller.siteCardView
                              ? _siteCardView(context, controller.opacity.value)
                              : _siteCardForm(context, controller.opacity.value),
                          Obx(() {
                            return Column(spacing: 10, children: [
                              controller.useBackground.value && controller.useLocalBackground.value
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
                                if (showPreview.value && controller.backgroundImage.value.isNotEmpty) {
                                  Logger.instance.d(
                                      'backgroundImage: ${controller.backgroundImage.value} , useLocalBackground: ${controller.useLocalBackground.value}');
                                  return controller.useLocalBackground.value
                                      ? controller.backgroundImage.value.startsWith('http')
                                          ? SizedBox.shrink()
                                          : Image.file(
                                              File(controller.backgroundImage.value),
                                              width: double.infinity,
                                              fit: BoxFit.fitWidth,
                                            )
                                      : Obx(
                                          () {
                                            return CachedNetworkImage(
                                              imageUrl:
                                                  '${controller.useImageProxy.value ? 'https://images.weserv.nl/?url=' : ''}${controller.backgroundImage.value}',
                                              placeholder: (context, url) => Center(
                                                  child: CircularProgressIndicator(
                                                color: shadColorScheme.primary,
                                              )),
                                              errorWidget: (context, url, error) =>
                                                  Image.asset('assets/images/background.png'),
                                              fit: BoxFit.fitWidth,
                                            );
                                          },
                                        );
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
                                      min: 0.0,
                                      max: 1.0,
                                      // divisions: 10,
                                      label: controller.opacity.value.toString(),
                                      initialValue: controller.opacity.value,
                                      onChanged: (value) async {
                                        controller.opacity.value = value;
                                        controller.saveSettings();
                                      }),
                                ),
                              ],
                            );
                          }),
                          Obx(() {
                            return Row(
                              children: [
                                Text("背景模糊:", style: TextStyle(color: shadColorScheme.foreground)),
                                Expanded(
                                  child: ShadSlider(
                                    min: 0,
                                    max: 20,
                                    // divisions: 20,
                                    label: controller.blur.value.toStringAsFixed(1),
                                    initialValue: controller.blur.value,
                                    onChanged: (v) {
                                      controller.blur.value = v;
                                      controller.saveSettings();
                                    },
                                  ),
                                ),
                              ],
                            );
                          }),

                          CustomCard(
                            child: OverflowBar(
                              alignment: MainAxisAlignment.spaceAround,
                              children: [
                                ShadButton.ghost(
                                  size: ShadButtonSize.sm,
                                  onPressed: () {
                                    controller.siteCardView = !controller.siteCardView;
                                    SPUtil.setBool('mySite-siteCardView', controller.siteCardView);
                                    Get.find<MySiteController>().changeViewMode(controller.siteCardView);
                                    Get.forceAppUpdate();
                                  },
                                  child: Text('切换'),
                                ),
                                ShadButton.ghost(
                                  size: ShadButtonSize.sm,
                                  onPressed: () {
                                    SiteColorConfig.resetToDefault(scheme: shadColorScheme);
                                    controller.applyDefaultConfig();
                                    Get.forceAppUpdate();
                                  },
                                  child: Text('重置'),
                                ),
                                ShadButton.ghost(
                                  size: ShadButtonSize.sm,
                                  onPressed: () async {
                                    popoverController.hide();
                                    Get.defaultDialog(
                                      title: '导入主题',
                                      titleStyle: TextStyle(
                                          color: shadColorScheme.foreground, fontSize: 14, fontWeight: FontWeight.bold),
                                      backgroundColor: shadColorScheme.background,
                                      radius: 8,
                                      content: Column(
                                        children: [
                                          Text(
                                            '请复制主题JSON数据，然后点击导入按钮。',
                                            style: TextStyle(color: shadColorScheme.foreground, fontSize: 13),
                                          ),
                                          GetBuilder<ThemeController>(
                                              id: 'controller.replaceBackgroundImage',
                                              builder: (controller) {
                                                return SwitchTile(
                                                    title: '替换背景图片',
                                                    fontSize: 12,
                                                    value: controller.replaceBackgroundImage,
                                                    onChanged: (value) {
                                                      controller.replaceBackgroundImage = value;
                                                      controller.update(['controller.replaceBackgroundImage']);
                                                    });
                                              }),
                                        ],
                                      ),
                                      actions: [
                                        ShadButton.ghost(
                                          size: ShadButtonSize.sm,
                                          onPressed: () async {
                                            Get.back();
                                          },
                                          child: const Text('取消'),
                                        ),
                                        ShadButton.destructive(
                                          size: ShadButtonSize.sm,
                                          onPressed: () async {
                                            // 1️⃣ 读取剪贴板
                                            final ok = await controller.importFromClipboard();
                                            Get.back();
                                            if (ok.succeed) {
                                              Get.snackbar('成功', '主题已导入');
                                              Get.forceAppUpdate();
                                            } else {
                                              Get.snackbar('失败', ok.msg, colorText: shadColorScheme.destructive);
                                            }
                                          },
                                          child: const Text('导入'),
                                        )
                                      ],
                                    );
                                  },
                                  foregroundColor: shadColorScheme.primary,
                                  child: Text('导入'),
                                ),
                                ShadButton.ghost(
                                  size: ShadButtonSize.sm,
                                  child: Text('分享'),
                                  onPressed: () async {
                                    Get.defaultDialog(
                                      title: '分享主题',
                                      titleStyle: TextStyle(
                                          color: shadColorScheme.foreground, fontSize: 14, fontWeight: FontWeight.bold),
                                      backgroundColor: shadColorScheme.background,
                                      radius: 8,
                                      content: Text(
                                        '可选择仅分享配色方案，或者直接分享整个主题',
                                        style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                                      ),
                                      actions: [
                                        ShadButton.ghost(
                                          size: ShadButtonSize.sm,
                                          onPressed: () async {
                                            Get.back();
                                          },
                                          child: const Text('取消'),
                                        ),
                                        ShadButton.outline(
                                          size: ShadButtonSize.sm,
                                          onPressed: () async {
                                            String data = await controller.exportToClipboard(false);
                                            Get.back();
                                            Logger.instance.i('当前主题配置信息: $data');
                                            Get.snackbar(
                                              '已导出',
                                              '主题配置已复制到剪贴板',
                                              snackPosition: SnackPosition.BOTTOM,
                                            );
                                          },
                                          child: const Text('配色方案'),
                                        ),
                                        ShadButton.destructive(
                                          size: ShadButtonSize.sm,
                                          onPressed: () async {
                                            String data = await controller.exportToClipboard(true);
                                            Get.back();
                                            Logger.instance.i('当前主题配置信息: $data');
                                            Get.snackbar('已导出', '主题配置已复制到剪贴板');
                                          },
                                          child: const Text('主题配色'),
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (PlatformTool.isDesktopOS())
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                runAlignment: WrapAlignment.center,
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  ...[
                                    // {"width": 1024.0, "height": 768.0},
                                    {"width": 1366.0, "height": 768.0},
                                    // {"width": 1366.0, "height": 800.0},
                                    {"width": 1440.0, "height": 900.0},
                                    // {"width": 1600.0, "height": 900.0},
                                    {"width": 1920.0, "height": 1080.0},
                                    {"width": 2560.0, "height": 1536.0},
                                  ].map((item) => ShadButton.outline(
                                      size: ShadButtonSize.sm,
                                      child: Text('${item["width"]?.toInt()}x${item["height"]?.toInt()}',
                                          style: TextStyle(fontSize: 12)),
                                      onPressed: () {
                                        double width = item["width"]!;
                                        double height = item["height"]!;
                                        WindowOptions windowOptions = WindowOptions(
                                          // size: Size(1200, 900),
                                          size: Size(width, height + 28),
                                          center: true,
                                          backgroundColor: Colors.transparent,
                                          skipTaskbar: false,
                                          titleBarStyle: TitleBarStyle.normal,
                                          windowButtonVisibility: true,
                                        );
                                        windowManager.waitUntilReadyToShow(windowOptions, () async {
                                          await windowManager.show();
                                          await windowManager.focus();
                                        });
                                      }))
                                ],
                              ),
                            ),
                        ],
                      ),
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShadButton.ghost(
                          size: ShadButtonSize.sm,
                          onPressed: () => popoverController.hide(),
                          leading: Icon(
                            Icons.cancel_outlined,
                            size: 16,
                          ),
                          child: Text('关闭'),
                        ),
                        if (controller.useBackground.value)
                          ShadButton.secondary(
                            size: ShadButtonSize.sm,
                            leading: Icon(Icons.delete_outlined, size: 16),
                            foregroundColor: shadColorScheme.primary,
                            child: Text('预览'),
                            onPressed: () {
                              if (urlController.text.isNotEmpty) {
                                controller.backgroundImage.value = urlController.text;
                                showPreview.value = !showPreview.value;
                              } else {
                                showPreview.value = false;
                              }
                            },
                          ),
                        ShadButton.outline(
                          size: ShadButtonSize.sm,
                          leading: Icon(Icons.save_outlined, size: 16),
                          onPressed: () {
                            if (urlController.text.isNotEmpty) {
                              if (controller.useLocalBackground.value &&
                                  controller.backgroundImage.value.startsWith('http')) {
                                Get.snackbar(
                                  '出错啦',
                                  "请选择正确的背景图片！",
                                  colorText: shadColorScheme.destructive,
                                );
                                return;
                              }
                              controller.backgroundImage.value = urlController.text;
                              Logger.instance.d('backgroundImage: ${urlController.text}');
                              controller.saveSettings();
                              Get.forceAppUpdate();
                              Get.back();
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: ShadIconButton.ghost(
            icon: icon, // Use the passed icon
            onPressed: () {
              if (!popoverController.isOpen) {
                controller.onInit();
              }
              popoverController.toggle();
            },
          ),
        );
      });
    });
  }

  void _openColorPicker(ShadColorScheme shadColorScheme, Rx<Color> rxColor, String key) {
    Get.defaultDialog(
      title: '选择颜色',
      radius: 8,
      titleStyle: TextStyle(color: shadColorScheme.foreground, fontSize: 14),
      backgroundColor: shadColorScheme.background,
      content: MaterialPicker(
        // 使用 `flutter_colorpicker` 包
        pickerColor: rxColor.value,
        // labelTypes: [],
        onColorChanged: (color) async {
          Logger.instance.d('选择的颜色: ${color.toARGB32()}');
          rxColor.value = color;
          await SiteColorConfig.update(scheme: shadColorScheme, key: key, color: color);
        },
      ),
    );
  }

  Widget _siteCardView(BuildContext context, double opacity) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    RxBool signed = true.obs;
    RxBool siteRefreshing = true.obs;
    SiteColorConfig siteColorConfig = SiteColorConfig.load(shadColorScheme);
    return Obx(() {
      return GestureDetector(
        onTap: () {
          _openColorPicker(shadColorScheme, siteColorConfig.siteCardColor, SiteColorKeys.siteCardColor);
        },
        child: CustomCard(
            color: siteColorConfig.siteCardColor.value.withOpacity(opacity),
            child: Column(
              spacing: 5,
              children: [
                CustomCard(
                  color: siteColorConfig.siteNameColor.value.withOpacity(opacity),
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: ListTile(
                    // dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/avatar.png'),
                    ),

                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _openColorPicker(
                              shadColorScheme, siteColorConfig.siteNameColor, SiteColorKeys.siteNameColor),
                          child: Text(
                            '站点名称',
                            style: TextStyle(
                              fontSize: 13,
                              color: siteColorConfig.siteNameColor.value,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _openColorPicker(shadColorScheme, siteColorConfig.mailColor, SiteColorKeys.mailColor),
                          child: Row(
                            children: [
                              Icon(
                                Icons.mail,
                                size: 12,
                                color: siteColorConfig.mailColor.value,
                              ),
                              Text(
                                '2',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: siteColorConfig.mailColor.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _openColorPicker(shadColorScheme, siteColorConfig.noticeColor, SiteColorKeys.noticeColor),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                size: 12,
                                color: siteColorConfig.noticeColor.value,
                              ),
                              Text(
                                '1',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: siteColorConfig.noticeColor.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomPopup(
                          showArrow: false,
                          barrierColor: Colors.transparent,
                          backgroundColor: shadColorScheme.background,
                          content: SingleChildScrollView(
                            child: SizedBox(
                                width: 200,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...[
                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text("下一等级：EliteUser",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF008B8B),
                                            )),
                                      ),
                                      // if (status.uploaded < nextLevelToUploadedByte)
                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('上传量：100GB/750GB',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),
                                      // if (status.downloaded < nextLevelToDownloadedByte)
                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('下载量：100GB/150GB',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('需发种数量：0/40',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('做种积分：4W/8W',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('魔力值：15W/20W',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child:
                                            Text('升级日期：${DateFormat('yyyy-MM-dd').format(DateTime.now())}/2036-01-01',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: shadColorScheme.destructive,
                                                )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('保留账号：true',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('毕业：false',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),
                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('即将获得：即将获得的权益',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),
                                    ],
                                    Text('已经获得的权益',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: shadColorScheme.foreground,
                                        )),
                                  ],
                                )),
                          ),
                          child: Text(
                            'PowerUser',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFDAA520),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _openColorPicker(
                                  shadColorScheme, siteColorConfig.regTimeColor, SiteColorKeys.regTimeColor),
                              child: Text(
                                '⌚️${calcWeeksDays('2025-02-01')}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: siteColorConfig.regTimeColor.value,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _openColorPicker(
                                  shadColorScheme, siteColorConfig.keepAccountColor, SiteColorKeys.keepAccountColor),
                              child: Text(
                                '🔥保号',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: siteColorConfig.keepAccountColor.value,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _openColorPicker(
                                  shadColorScheme, siteColorConfig.graduationColor, SiteColorKeys.graduationColor),
                              child: Text(
                                '🎓毕业',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: siteColorConfig.graduationColor.value,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _openColorPicker(
                                  shadColorScheme, siteColorConfig.inviteColor, SiteColorKeys.inviteColor),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_add_alt_outlined,
                                    size: 12,
                                    color: siteColorConfig.inviteColor.value,
                                  ),
                                  Text(
                                    '8',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: siteColorConfig.inviteColor.value,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _openColorPicker(shadColorScheme, siteColorConfig.hrColor, SiteColorKeys.hrColor),
                              child: Text(
                                'HR: 0/0/20',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: siteColorConfig.hrColor.value,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Obx(() {
                      return siteRefreshing.value
                          ? GestureDetector(
                              onLongPress: () {
                                siteRefreshing.value = false;
                              },
                              onTap: () {
                                _openColorPicker(
                                    shadColorScheme, siteColorConfig.loadingColor, SiteColorKeys.loadingColor);
                              },
                              child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    color: siteColorConfig.loadingColor.value,
                                    strokeWidth: 2,
                                  ))),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 30),
                                  child: ShadButton.outline(
                                    size: ShadButtonSize.sm,
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    onPressed: () {
                                      siteRefreshing.value = false;
                                    },
                                    child: Text(signed.value ? '已签到' : '未签到'),
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 18),
                                  child: ShadButton.ghost(
                                    size: ShadButtonSize.sm,
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      '1小时前',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: siteColorConfig.updatedAtColor.value,
                                      ),
                                    ),
                                    onPressed: () => _openColorPicker(
                                        shadColorScheme, siteColorConfig.updatedAtColor, SiteColorKeys.updatedAtColor),
                                  ),
                                ),
                              ],
                            );
                    }),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: CustomCard(
                      color: siteColorConfig.uploadedIconColor.value.withOpacity(opacity),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.uploadedIconColor, SiteColorKeys.uploadedIconColor);
                            },
                            child: CustomTextTag(
                              backgroundColor: Colors.transparent,
                              labelText: '上传',
                              labelColor: siteColorConfig.uploadedColor.value,
                              fontSize: 13,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              icon: Icon(
                                Icons.cloud_upload_outlined,
                                color: siteColorConfig.uploadedIconColor.value,
                                size: 16,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.uploadedColor, SiteColorKeys.uploadedColor);
                            },
                            child: Text(
                              '今日：15 GB',
                              style: TextStyle(
                                fontSize: 14,
                                color: siteColorConfig.uploadedColor.value,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.uploadedColor, SiteColorKeys.uploadedColor);
                            },
                            child: Text(
                              '总计：12 TB',
                              style: TextStyle(
                                fontSize: 14,
                                color: siteColorConfig.uploadedColor.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      color: siteColorConfig.downloadedIconColor.value.withOpacity(opacity),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(shadColorScheme, siteColorConfig.downloadedIconColor,
                                  SiteColorKeys.downloadedIconColor);
                            },
                            child: CustomTextTag(
                              backgroundColor: Colors.transparent,
                              labelText: '下载',
                              fontSize: 13,
                              labelColor: siteColorConfig.downloadedColor.value,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              icon: Icon(
                                Icons.cloud_upload_outlined,
                                color: siteColorConfig.downloadedIconColor.value,
                                size: 16,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.downloadedColor, SiteColorKeys.downloadedColor);
                            },
                            child: Text(
                              '今日：1 GB',
                              style: TextStyle(
                                fontSize: 14,
                                color: siteColorConfig.downloadedColor.value,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.downloadedColor, SiteColorKeys.downloadedColor);
                            },
                            child: Text(
                              '总计：7.6 TB',
                              style: TextStyle(
                                fontSize: 14,
                                color: siteColorConfig.downloadedColor.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: CustomCard(
                      color: siteColorConfig.seedVolumeIconColor.value.withOpacity(opacity),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(shadColorScheme, siteColorConfig.seedVolumeIconColor,
                                  SiteColorKeys.seedVolumeIconColor);
                            },
                            child: CustomTextTag(
                              backgroundColor: Colors.transparent,
                              labelText: '做种量',
                              labelColor: siteColorConfig.seedVolumeNumColor.value,
                              fontSize: 12,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              icon: Icon(
                                Icons.cloud_upload_outlined,
                                color: siteColorConfig.seedVolumeIconColor.value,
                                size: 16,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(shadColorScheme, siteColorConfig.seedVolumeNumColor,
                                  SiteColorKeys.seedVolumeNumColor);
                            },
                            child: Text(
                              '8.7 TB',
                              style: TextStyle(
                                fontSize: 14,
                                color: siteColorConfig.seedVolumeNumColor.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      color: siteColorConfig.seedIconColor.value.withOpacity(opacity),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.seedIconColor, SiteColorKeys.seedIconColor);
                            },
                            child: CustomTextTag(
                              backgroundColor: Colors.transparent,
                              labelText: '做种数',
                              labelColor: siteColorConfig.seedNumColor.value,
                              fontSize: 12,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              icon: Icon(
                                Icons.arrow_upward_outlined,
                                color: siteColorConfig.seedIconColor.value,
                                size: 16,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.seedNumColor, SiteColorKeys.uploadNumColor);
                            },
                            child: Text(
                              '234',
                              style: TextStyle(
                                fontSize: 14,
                                color: siteColorConfig.seedNumColor.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      color: siteColorConfig.bonusIconColor.value.withOpacity(opacity),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.bonusIconColor, SiteColorKeys.bonusIconColor);
                            },
                            child: CustomTextTag(
                              backgroundColor: Colors.transparent,
                              labelText: '魔力值',
                              labelColor: siteColorConfig.bonusNumColor.value,
                              fontSize: 12,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              icon: Icon(
                                Icons.score_outlined,
                                color: siteColorConfig.bonusIconColor.value,
                                size: 14,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.bonusNumColor, SiteColorKeys.bonusNumColor);
                            },
                            child: Text(
                              '133W',
                              style: TextStyle(
                                fontSize: 14,
                                color: siteColorConfig.bonusNumColor.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      color: siteColorConfig.scoreIconColor.value.withOpacity(opacity),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.scoreIconColor, SiteColorKeys.scoreIconColor);
                            },
                            child: CustomTextTag(
                              backgroundColor: Colors.transparent,
                              labelText: '积分',
                              labelColor: siteColorConfig.scoreNumColor.value,
                              fontSize: 12,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              icon: Icon(
                                Icons.score_outlined,
                                color: siteColorConfig.scoreIconColor.value,
                                size: 14,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.scoreNumColor, SiteColorKeys.scoreNumColor);
                            },
                            child: Text(
                              '89W',
                              style: TextStyle(
                                fontSize: 14,
                                color: siteColorConfig.scoreNumColor.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: CustomCard(
                      color: siteColorConfig.publishedIconColor.value.withOpacity(opacity),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(shadColorScheme, siteColorConfig.publishedIconColor,
                                  SiteColorKeys.publishedIconColor);
                            },
                            child: CustomTextTag(
                              backgroundColor: Colors.transparent,
                              labelText: '发种数',
                              labelColor: siteColorConfig.publishedNumColor.value,
                              fontSize: 12,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              icon: Icon(
                                Icons.upload_outlined,
                                color: siteColorConfig.publishedIconColor.value,
                                size: 14,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.publishedNumColor, SiteColorKeys.publishedNumColor);
                            },
                            child: Text(
                              '11',
                              style: TextStyle(
                                fontSize: 14,
                                color: siteColorConfig.publishedNumColor.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      color: siteColorConfig.downloadIconColor.value.withOpacity(opacity),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.downloadIconColor, SiteColorKeys.downloadIconColor);
                            },
                            child: CustomTextTag(
                              backgroundColor: Colors.transparent,
                              labelText: '下载中',
                              labelColor: siteColorConfig.downloadNumColor.value,
                              fontSize: 12,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              icon: Icon(
                                Icons.arrow_downward_outlined,
                                color: siteColorConfig.downloadIconColor.value,
                                size: 14,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.downloadNumColor, SiteColorKeys.downloadNumColor);
                            },
                            child: Text(
                              '2',
                              style: TextStyle(
                                fontSize: 14,
                                color: siteColorConfig.downloadNumColor.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      color: siteColorConfig.ratioIconColor.value.withOpacity(opacity),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.ratioIconColor, SiteColorKeys.ratioIconColor);
                            },
                            child: CustomTextTag(
                              backgroundColor: Colors.transparent,
                              labelText: '分享率',
                              labelColor: siteColorConfig.ratioNumColor.value,
                              fontSize: 12,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              icon: Icon(
                                Icons.screen_share_outlined,
                                color: siteColorConfig.ratioIconColor.value,
                                size: 14,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.ratioNumColor, SiteColorKeys.ratioNumColor);
                            },
                            child: Text(
                              '5.5',
                              style: TextStyle(
                                fontSize: 14,
                                color: siteColorConfig.ratioNumColor.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      color: siteColorConfig.perBonusIconColor.value.withOpacity(opacity),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.perBonusIconColor, SiteColorKeys.perBonusIconColor);
                            },
                            child: CustomTextTag(
                              backgroundColor: Colors.transparent,
                              labelText: '时魔',
                              labelColor: siteColorConfig.perBonusNumColor.value,
                              fontSize: 12,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              icon: Icon(
                                Icons.timer_outlined,
                                color: siteColorConfig.perBonusIconColor.value,
                                size: 14,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _openColorPicker(
                                  shadColorScheme, siteColorConfig.perBonusNumColor, SiteColorKeys.perBonusNumColor);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '138',
                                  // '(${  status.siteSpFull != null && status.siteSpFull! > 0 ? ((status.statusBonusHour! / status.siteSpFull!) * 100).toStringAsFixed(2) : '0'}%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: siteColorConfig.perBonusNumColor.value,
                                  ),
                                ),
                                Text(
                                  '(88%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: siteColorConfig.perBonusNumColor.value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ],
            )),
      );
    });
  }

  Widget _siteCardForm(BuildContext context, double opacity) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    RxBool signed = true.obs;
    SiteColorConfig siteColorConfig = SiteColorConfig.load(shadColorScheme);
    return Obx(() {
      return Column(
        children: [
          GestureDetector(
            onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.siteCardColor, SiteColorKeys.siteCardColor),
            child: CustomCard(
              color: siteColorConfig.siteCardColor.value.withOpacity(opacity),
              child: Column(children: [
                CornerBadge(
                  color: signed.value == true ? siteColorConfig.signedColor.value : siteColorConfig.toSignColor.value,
                  label: signed.value == true ? '已签到' : '未签到',
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/avatar.png'),
                    ),
                    onTap: () => signed.value = !signed.value,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _openColorPicker(
                              shadColorScheme, siteColorConfig.siteNameColor, SiteColorKeys.siteNameColor),
                          child: Text(
                            '站点名称',
                            style: TextStyle(
                              fontSize: 13,
                              color: siteColorConfig.siteNameColor.value,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _openColorPicker(shadColorScheme, siteColorConfig.mailColor, SiteColorKeys.mailColor),
                          child: Row(
                            children: [
                              Icon(
                                Icons.mail,
                                size: 12,
                                color: siteColorConfig.mailColor.value,
                              ),
                              Text(
                                '2',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: siteColorConfig.mailColor.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _openColorPicker(shadColorScheme, siteColorConfig.noticeColor, SiteColorKeys.noticeColor),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                size: 12,
                                color: siteColorConfig.noticeColor.value,
                              ),
                              Text(
                                '1',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: siteColorConfig.noticeColor.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomPopup(
                          showArrow: false,
                          barrierColor: Colors.transparent,
                          backgroundColor: shadColorScheme.background,
                          content: SingleChildScrollView(
                            child: SizedBox(
                                width: 200,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...[
                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text("下一等级：EliteUser",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF008B8B),
                                            )),
                                      ),
                                      // if (status.uploaded < nextLevelToUploadedByte)
                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('上传量：100GB/750GB',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),
                                      // if (status.downloaded < nextLevelToDownloadedByte)
                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('下载量：100GB/150GB',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('需发种数量：0/40',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('做种积分：4W/8W',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('魔力值：15W/20W',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child:
                                            Text('升级日期：${DateFormat('yyyy-MM-dd').format(DateTime.now())}/2036-01-01',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: shadColorScheme.destructive,
                                                )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('保留账号：true',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),

                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('毕业：false',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),
                                      PopupMenuItem<String>(
                                        height: 13,
                                        child: Text('即将获得：即将获得的权益',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: shadColorScheme.destructive,
                                            )),
                                      ),
                                    ],
                                    Text('已经获得的权益',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: shadColorScheme.foreground,
                                        )),
                                  ],
                                )),
                          ),
                          child: Text(
                            'PowerUser',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFDAA520),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _openColorPicker(
                              shadColorScheme, siteColorConfig.regTimeColor, SiteColorKeys.regTimeColor),
                          child: Text(
                            '⌚️${calcWeeksDays('2025-02-01')}',
                            style: TextStyle(
                              fontSize: 10,
                              color: siteColorConfig.regTimeColor.value,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openColorPicker(
                              shadColorScheme, siteColorConfig.keepAccountColor, SiteColorKeys.keepAccountColor),
                          child: Text(
                            '🔥保号',
                            style: TextStyle(
                              fontSize: 10,
                              color: siteColorConfig.keepAccountColor.value,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openColorPicker(
                              shadColorScheme, siteColorConfig.graduationColor, SiteColorKeys.graduationColor),
                          child: Text(
                            '🎓毕业',
                            style: TextStyle(
                              fontSize: 10,
                              color: siteColorConfig.graduationColor.value,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _openColorPicker(shadColorScheme, siteColorConfig.inviteColor, SiteColorKeys.inviteColor),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_add_alt_outlined,
                                size: 12,
                                color: siteColorConfig.inviteColor.value,
                              ),
                              Text(
                                '8',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: siteColorConfig.inviteColor.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: GestureDetector(
                      onTap: () =>
                          _openColorPicker(shadColorScheme, siteColorConfig.loadingColor, SiteColorKeys.loadingColor),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: siteColorConfig.loadingColor.value,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  textBaseline: TextBaseline.ideographic,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.uploadIconColor,
                                          SiteColorKeys.uploadIconColor),
                                      child: Icon(
                                        Icons.upload_outlined,
                                        color: siteColorConfig.uploadIconColor.value,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    GestureDetector(
                                      onTap: () => _openColorPicker(
                                          shadColorScheme, siteColorConfig.uploadedColor, SiteColorKeys.uploadedColor),
                                      child: Text(
                                        '1.97 TB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.uploadedColor.value,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.uploadNumColor,
                                          SiteColorKeys.uploadNumColor),
                                      child: Text(
                                        '(120)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.uploadNumColor.value,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.downloadIconColor,
                                          SiteColorKeys.downloadIconColor),
                                      child: Icon(
                                        Icons.download_outlined,
                                        color: siteColorConfig.downloadIconColor.value,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    GestureDetector(
                                      onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.downloadedColor,
                                          SiteColorKeys.downloadedColor),
                                      child: Text(
                                        '305.65 GB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.downloadedColor.value,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.downloadNumColor,
                                          SiteColorKeys.downloadNumColor),
                                      child: Text(
                                        '(0)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.downloadNumColor.value,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 90,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.ratioIconColor,
                                          SiteColorKeys.ratioIconColor),
                                      child: Icon(
                                        Icons.ios_share,
                                        color: siteColorConfig.ratioIconColor.value,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    GestureDetector(
                                      onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.publishedNumColor,
                                          SiteColorKeys.publishedNumColor),
                                      child: Text(
                                        '3',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.publishedNumColor.value,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _openColorPicker(
                                          shadColorScheme, siteColorConfig.ratioNumColor, SiteColorKeys.ratioNumColor),
                                      child: Text(
                                        '(6.61)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.ratioNumColor.value,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _openColorPicker(
                                          shadColorScheme, siteColorConfig.seedIconColor, SiteColorKeys.seedIconColor),
                                      child: Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 14,
                                        color: siteColorConfig.seedIconColor.value,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    GestureDetector(
                                      onTap: () => _openColorPicker(
                                          shadColorScheme, siteColorConfig.seedNumColor, SiteColorKeys.seedNumColor),
                                      child: Text(
                                        '2.38 TB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.seedNumColor.value,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  textBaseline: TextBaseline.ideographic,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.perBonusIconColor,
                                          SiteColorKeys.perBonusIconColor),
                                      child: Icon(
                                        Icons.timer_outlined,
                                        size: 14,
                                        color: siteColorConfig.perBonusIconColor.value,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    GestureDetector(
                                      onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.perBonusNumColor,
                                          SiteColorKeys.perBonusNumColor),
                                      child: Text(
                                        '149.50',
                                        // '(${  status.siteSpFull != null && status.siteSpFull! > 0 ? ((status.statusBonusHour! / status.siteSpFull!) * 100).toStringAsFixed(2) : '0'}%)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.perBonusNumColor.value,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.perBonusNumColor,
                                          SiteColorKeys.perBonusNumColor),
                                      child: Text(
                                        // formatNumber(status.bonusHour),
                                        '(73%)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.perBonusNumColor.value,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  textBaseline: TextBaseline.ideographic,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.bonusIconColor,
                                          SiteColorKeys.bonusIconColor),
                                      child: Icon(
                                        Icons.score,
                                        size: 14,
                                        color: siteColorConfig.bonusIconColor.value,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    GestureDetector(
                                      onTap: () => _openColorPicker(
                                          shadColorScheme, siteColorConfig.bonusNumColor, SiteColorKeys.bonusNumColor),
                                      child: Text(
                                        '322W',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.bonusNumColor.value,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _openColorPicker(
                                          shadColorScheme, siteColorConfig.scoreNumColor, SiteColorKeys.scoreNumColor),
                                      child: Text(
                                        '(267W)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.scoreNumColor.value,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _openColorPicker(
                                shadColorScheme, siteColorConfig.updatedAtColor, SiteColorKeys.updatedAtColor),
                            child: Text(
                              '最近更新：1小时前',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: siteColorConfig.updatedAtColor.value,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _openColorPicker(shadColorScheme, siteColorConfig.hrColor, SiteColorKeys.hrColor),
                                child: Text(
                                  'HR: 0/0/20',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: siteColorConfig.hrColor.value,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      );
    });
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
            icon: Icon(Icons.palette_outlined, size: 20, color: shadColorScheme.foreground),
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
