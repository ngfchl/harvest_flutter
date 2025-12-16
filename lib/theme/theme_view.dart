import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:harvest/theme/theme_controller.dart';
import 'package:harvest/theme/theme_service.dart';
import 'package:harvest/utils/platform.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:window_manager/window_manager.dart';

import '../app/home/controller/home_controller.dart';
import '../app/home/pages/models/color_storage.dart';
import '../common/card_view.dart';
import '../common/corner_badge.dart';
import '../common/image_helper.dart';
import '../utils/calc_weeks.dart';
import '../utils/logger_helper.dart';
import '../utils/storage.dart';

class ThemeIconButton extends StatelessWidget {
  final Icon icon; // Accepts an Icon widget as a parameter

  const ThemeIconButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final popoverController = ShadPopoverController();
    final bg = Get.find<BackgroundService>();
    TextEditingController urlController = TextEditingController(text: bg.backgroundImage.value);

    if (kIsWeb) {
      bg.useLocalBackground.value = false;
    }
    final showPreview = false.obs;
    var shadColorScheme = ShadTheme.of(context).colorScheme;

    return GetBuilder<ThemeController>(builder: (controller) {
      return Obx(() {
        return ShadPopover(
          controller: popoverController,
          closeOnTapOutside: false,
          decoration: ShadDecoration(
            color: shadColorScheme.background.withOpacity(bg.opacity.value),
          ),
          popover: (context) => ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 630, maxWidth: 450, minHeight: 300),
            child: Material(
              color: Colors.transparent,
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
                                  value: bg.useBackground.value,
                                  onChanged: (value) {
                                    bg.useBackground.value = value;
                                    SPUtil.setBool('useBackground', value);
                                  },
                                ),
                                if (bg.useBackground.value)
                                  ShadSwitch(
                                    label: Text('使用缓存'),
                                    value: bg.useImageCache.value,
                                    onChanged: (value) {
                                      bg.useImageCache.value = value;
                                      SPUtil.setBool('useImageCache', value);
                                    },
                                  ),
                              ],
                            );
                          }),
                          Obx(() {
                            return bg.useBackground.value && !kIsWeb
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ShadSwitch(
                                        label: Text(bg.useLocalBackground.value ? '本地图片' : '网络图片'),
                                        sublabel: Text(
                                          '默认网络图片',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        value: kIsWeb ? false : bg.useLocalBackground.value,
                                        onChanged: (value) {
                                          bg.useLocalBackground.value = value;
                                          SPUtil.setBool('useLocalBackground', value);
                                        },
                                      ),
                                      if (!bg.useLocalBackground.value)
                                        Obx(() {
                                          return ShadSwitch(
                                            label: Text('图片加速'),
                                            value: bg.useImageProxy.value,
                                            onChanged: (value) {
                                              bg.useImageProxy.value = value;
                                              SPUtil.setBool('useImageProxy', value);
                                            },
                                          );
                                        }),
                                    ],
                                  )
                                : SizedBox.shrink();
                          }),

                          Obx(() {
                            return Column(spacing: 10, children: [
                              bg.useBackground.value && bg.useLocalBackground.value
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
                                if (showPreview.value && bg.backgroundImage.value.isNotEmpty) {
                                  Logger.instance.d(
                                      'backgroundImage: ${bg.backgroundImage.value} , useLocalBackground: ${bg.useLocalBackground.value}');
                                  return bg.useLocalBackground.value
                                      ? bg.backgroundImage.value.startsWith('http')
                                          ? SizedBox.shrink()
                                          : Image.file(
                                              File(bg.backgroundImage.value),
                                              width: double.infinity,
                                              fit: BoxFit.fitWidth,
                                            )
                                      : Obx(
                                          () {
                                            return CachedNetworkImage(
                                              imageUrl:
                                                  '${bg.useImageProxy.value ? 'https://images.weserv.nl/?url=' : ''}${bg.backgroundImage.value}',
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
                                      min: 0.1,
                                      max: 1,
                                      // divisions: 10,
                                      label: bg.opacity.value.toString(),
                                      initialValue: bg.opacity.value,
                                      onChanged: (value) async {
                                        bg.opacity.value = value;
                                        bg.save();
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
                                    divisions: 20,
                                    label: bg.blur.value.toStringAsFixed(1),
                                    initialValue: bg.blur.value,
                                    onChanged: (v) {
                                      bg.blur.value = v;
                                      bg.save();
                                    },
                                  ),
                                ),
                              ],
                            );
                          }),
                          _siteCardForm(context, bg.opacity.value),
                          if (PlatformTool.isDesktopOS())
                            Wrap(
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
                            )
                        ],
                      ),
                    )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShadButton.outline(
                          size: ShadButtonSize.sm,
                          onPressed: () => popoverController.hide(),
                          child: Text('关闭'),
                        ),
                        if (bg.useBackground.value)
                          ShadButton.secondary(
                            size: ShadButtonSize.sm,
                            child: Text('预览'),
                            onPressed: () {
                              if (urlController.text.isNotEmpty) {
                                bg.backgroundImage.value = urlController.text;
                                showPreview.value = !showPreview.value;
                              } else {
                                showPreview.value = false;
                              }
                            },
                          ),
                        ShadButton.destructive(
                          size: ShadButtonSize.sm,
                          onPressed: () {
                            if (urlController.text.isNotEmpty) {
                              if (bg.useLocalBackground.value && bg.backgroundImage.value.startsWith('http')) {
                                Get.snackbar(
                                  '出错啦',
                                  "请选择正确的背景图片！",
                                  colorText: shadColorScheme.destructive,
                                );
                                return;
                              }
                              bg.backgroundImage.value = urlController.text;
                              Logger.instance.d('backgroundImage: ${urlController.text}');
                              SPUtil.setString('backgroundImage', urlController.text);
                              HomeController homeController = Get.find();
                              homeController.onInit();
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
          Logger.instance.d('选择的颜色: ${color.value}');
          rxColor.value = color;
          await SiteColorConfig.save(scheme: shadColorScheme, key: key, color: color);
        },
      ),
    );
  }

  Widget _siteCardForm(BuildContext context, double opacity) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    RxBool signed = true.obs;
    SiteColorConfig siteColorConfig = SiteColorConfig.load(shadColorScheme);
    // Rx<Color> toSignColor = Color(0xFFF44336).obs;
    // Rx<Color> signedColor = Color(0xFF388E3C).obs;
    // Rx<Color> siteCardColor = shadColorScheme.foreground.obs;
    // Rx<Color> siteNameColor = shadColorScheme.foreground.obs;
    // Rx<Color> mailColor = shadColorScheme.foreground.obs;
    // Rx<Color> noticeColor = shadColorScheme.foreground.obs;
    // Rx<Color> regTimeColor = shadColorScheme.foreground.obs;
    // Rx<Color> keepAccountColor = shadColorScheme.destructive.obs;
    // Rx<Color> graduationColor = shadColorScheme.destructive.obs;
    // Rx<Color> inviteColor = shadColorScheme.foreground.obs;
    // Rx<Color> loadingColor = shadColorScheme.foreground.obs;
    // Rx<Color> uploadIconColor = shadColorScheme.primary.obs;
    // Rx<Color> uploadNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> downloadIconColor = shadColorScheme.destructive.obs;
    // Rx<Color> downloadNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> ratioIconColor = shadColorScheme.primary.obs;
    // Rx<Color> ratioNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> seedIconColor = shadColorScheme.foreground.obs;
    // Rx<Color> seedNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> perBonusIconColor = shadColorScheme.foreground.obs;
    // Rx<Color> perBonusNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> bonusIconColor = shadColorScheme.foreground.obs;
    // Rx<Color> bonusNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> updatedAtColor = shadColorScheme.foreground.obs;
    // Rx<Color> hrColor = shadColorScheme.destructive.obs;
    return Obx(() {
      return GestureDetector(
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
                      onTap: () =>
                          _openColorPicker(shadColorScheme, siteColorConfig.siteNameColor, SiteColorKeys.siteNameColor),
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
                                    child: Text('升级日期：${DateFormat('yyyy-MM-dd').format(DateTime.now())}/2036-01-01',
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
                      onTap: () =>
                          _openColorPicker(shadColorScheme, siteColorConfig.regTimeColor, SiteColorKeys.regTimeColor),
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
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.uploadIconColor, SiteColorKeys.uploadIconColor),
                                  child: Icon(
                                    Icons.upload_outlined,
                                    color: siteColorConfig.uploadIconColor.value,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.uploadNumColor, SiteColorKeys.uploadNumColor),
                                  child: Text(
                                    '1.97 TB(120)',
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
                                  onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.downloadNumColor,
                                      SiteColorKeys.downloadNumColor),
                                  child: Text(
                                    '305.65 GB (0)',
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
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.ratioIconColor, SiteColorKeys.ratioIconColor),
                                  child: Icon(
                                    Icons.ios_share,
                                    color: siteColorConfig.ratioIconColor.value,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.ratioNumColor, SiteColorKeys.ratioNumColor),
                                  child: Text(
                                    '3 (6.61)',
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
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.bonusIconColor, SiteColorKeys.bonusNumColor),
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
                                    '322W(267W)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: siteColorConfig.bonusNumColor.value,
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
