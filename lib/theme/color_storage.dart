import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:harvest/models/common_response.dart';
import 'package:harvest/utils/logger_helper.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../utils/storage.dart';

class SiteColorConfig {
  static const String spKey = 'site_color_config';

  // 颜色方案
  final Rx<Color> toSignColor;
  final Rx<Color> signedColor;
  final Rx<Color> siteCardColor;
  final Rx<Color> siteNameColor;
  final Rx<Color> mailColor;
  final Rx<Color> noticeColor;
  final Rx<Color> regTimeColor;
  final Rx<Color> keepAccountColor;
  final Rx<Color> graduationColor;
  final Rx<Color> inviteColor;
  final Rx<Color> loadingColor;
  final Rx<Color> uploadIconColor;
  final Rx<Color> uploadNumColor;
  final Rx<Color> uploadedColor;
  final Rx<Color> uploadedIconColor;
  final Rx<Color> downloadIconColor;
  final Rx<Color> downloadNumColor;
  final Rx<Color> downloadedColor;
  final Rx<Color> downloadedIconColor;
  final Rx<Color> ratioIconColor;
  final Rx<Color> ratioNumColor;
  final Rx<Color> publishedNumColor;
  final Rx<Color> publishedIconColor;
  final Rx<Color> seedIconColor;
  final Rx<Color> seedNumColor;
  final Rx<Color> seedVolumeIconColor;
  final Rx<Color> seedVolumeNumColor;
  final Rx<Color> perBonusIconColor;
  final Rx<Color> perBonusNumColor;
  final Rx<Color> bonusIconColor;
  final Rx<Color> bonusNumColor;
  final Rx<Color> scoreNumColor;
  final Rx<Color> scoreIconColor;
  final Rx<Color> updatedAtColor;
  final Rx<Color> hrColor;

  SiteColorConfig({
    required this.toSignColor,
    required this.signedColor,
    required this.siteCardColor,
    required this.siteNameColor,
    required this.mailColor,
    required this.noticeColor,
    required this.regTimeColor,
    required this.keepAccountColor,
    required this.graduationColor,
    required this.inviteColor,
    required this.loadingColor,
    required this.uploadIconColor,
    required this.uploadedIconColor,
    required this.uploadNumColor,
    required this.downloadIconColor,
    required this.downloadedIconColor,
    required this.downloadNumColor,
    required this.ratioIconColor,
    required this.ratioNumColor,
    required this.seedIconColor,
    required this.seedNumColor,
    required this.seedVolumeIconColor,
    required this.seedVolumeNumColor,
    required this.perBonusIconColor,
    required this.perBonusNumColor,
    required this.bonusIconColor,
    required this.bonusNumColor,
    required this.updatedAtColor,
    required this.hrColor,
    required this.uploadedColor,
    required this.downloadedColor,
    required this.publishedNumColor,
    required this.publishedIconColor,
    required this.scoreNumColor,
    required this.scoreIconColor,
  });

  static SiteColorConfig load(ShadColorScheme scheme) {
    final map = SPUtil.getMap(spKey);
    // print("加载配置,当前卡片颜色：${map[SiteColorKeys.siteCardColor]}");
    if (map.isEmpty) {
      return SiteColorConfig.defaults(scheme);
    }

    return SiteColorConfig.fromJson(
      Map<String, dynamic>.from(map),
      scheme,
    );
  }

  static Future<void> update({
    required ShadColorScheme scheme,
    required String key,
    required Color color,
  }) async {
    // 1️⃣ 先 load 当前配置（保证完整）
    final current = SiteColorConfig.load(scheme);

    // 2️⃣ 转成 Map
    final map = current.toJson();
    // print('更新前的配置：${map[key]}');
    print('准备更新的内容：${key} ==== ${color.value}');
    // 3️⃣ 只更新指定 key
    map[key] = color.toARGB32();
    print('准备更新的内容：$key ==== ${color.toARGB32()}');
    // print('更新后的配置：$map');
    // 4️⃣ 整体写回 SP
    await SPUtil.setMap(spKey, map);
  }

  static Future<CommonResponse> save({
    required ShadColorScheme scheme,
    required Map<String, dynamic> theme,
  }) async {
    try {
      // 1️⃣ 先 load 当前配置（保证完整）
      final current = SiteColorConfig.load(scheme);

      // 2️⃣ 转成 Map
      final map = current.toJson();
      // print('更新前的配置：${map[key]}');
      // print('准备更新的内容：${key} ==== ${color.value}');
      // 3️⃣
      /// 只允许已知 key（防止脏数据）
      for (final entry in theme.entries) {
        if (map.containsKey(entry.key)) {
          map[entry.key] = entry.value;
        }
      }
      // print('更新后的配置：$map');
      // 4️⃣ 整体写回 SP
      await SPUtil.setMap(spKey, map);
      String msg = '主题已导入';
      Logger.instance.i(msg);
      return CommonResponse.success(msg: msg);
    } catch (e, trace) {
      String error = '保存失败：${e.toString()}';
      Logger.instance.e(error);
      Logger.instance.e(trace);
      return CommonResponse.error(msg: error);
    }
  }

  /// 重置为默认主题（基于 ShadColorScheme）
  static Future<void> resetToDefault({
    required ShadColorScheme scheme,
  }) async {
    // 1️⃣ 直接使用默认配置
    final defaults = SiteColorConfig.defaults(scheme);

    // 2️⃣ 写入 SP（完全覆盖）
    await SPUtil.setMap(spKey, defaults.toJson());
  }

  factory SiteColorConfig.defaults(ShadColorScheme scheme) {
    return SiteColorConfig(
      toSignColor: const Color(0xFFF44336).obs,
      signedColor: const Color(0xFF388E3C).obs,
      siteCardColor: scheme.background.obs,
      siteNameColor: scheme.foreground.obs,
      mailColor: scheme.foreground.obs,
      noticeColor: scheme.foreground.obs,
      regTimeColor: scheme.foreground.obs,
      keepAccountColor: scheme.destructive.obs,
      graduationColor: scheme.destructive.obs,
      inviteColor: scheme.foreground.obs,
      loadingColor: scheme.foreground.obs,
      uploadIconColor: scheme.primary.obs,
      uploadedIconColor: scheme.primary.obs,
      uploadNumColor: scheme.foreground.obs,
      downloadIconColor: scheme.destructive.obs,
      downloadNumColor: scheme.foreground.obs,
      ratioIconColor: scheme.primary.obs,
      ratioNumColor: scheme.foreground.obs,
      seedIconColor: scheme.foreground.obs,
      seedNumColor: scheme.foreground.obs,
      seedVolumeIconColor: scheme.foreground.obs,
      seedVolumeNumColor: scheme.foreground.obs,
      perBonusIconColor: scheme.foreground.obs,
      perBonusNumColor: scheme.foreground.obs,
      bonusIconColor: scheme.foreground.obs,
      bonusNumColor: scheme.foreground.obs,
      updatedAtColor: scheme.foreground.obs,
      hrColor: scheme.destructive.obs,
      uploadedColor: scheme.foreground.obs,
      downloadedColor: scheme.foreground.obs,
      publishedNumColor: scheme.foreground.obs,
      scoreNumColor: scheme.foreground.obs,
      scoreIconColor: scheme.foreground.obs,
      publishedIconColor: scheme.foreground.obs,
      downloadedIconColor: scheme.foreground.obs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SiteColorKeys.toSignColor: toSignColor.value.toARGB32(),
      SiteColorKeys.signedColor: signedColor.value.toARGB32(),
      SiteColorKeys.siteCardColor: siteCardColor.value.toARGB32(),
      SiteColorKeys.siteNameColor: siteNameColor.value.toARGB32(),
      SiteColorKeys.mailColor: mailColor.value.toARGB32(),
      SiteColorKeys.noticeColor: noticeColor.value.toARGB32(),
      SiteColorKeys.regTimeColor: regTimeColor.value.toARGB32(),
      SiteColorKeys.keepAccountColor: keepAccountColor.value.toARGB32(),
      SiteColorKeys.graduationColor: graduationColor.value.toARGB32(),
      SiteColorKeys.inviteColor: inviteColor.value.toARGB32(),
      SiteColorKeys.loadingColor: loadingColor.value.toARGB32(),
      SiteColorKeys.uploadIconColor: uploadIconColor.value.toARGB32(),
      SiteColorKeys.uploadNumColor: uploadNumColor.value.toARGB32(),
      SiteColorKeys.downloadIconColor: downloadIconColor.value.toARGB32(),
      SiteColorKeys.downloadNumColor: downloadNumColor.value.toARGB32(),
      SiteColorKeys.ratioIconColor: ratioIconColor.value.toARGB32(),
      SiteColorKeys.ratioNumColor: ratioNumColor.value.toARGB32(),
      SiteColorKeys.seedIconColor: seedIconColor.value.toARGB32(),
      SiteColorKeys.seedNumColor: seedNumColor.value.toARGB32(),
      SiteColorKeys.perBonusIconColor: perBonusIconColor.value.toARGB32(),
      SiteColorKeys.perBonusNumColor: perBonusNumColor.value.toARGB32(),
      SiteColorKeys.bonusIconColor: bonusIconColor.value.toARGB32(),
      SiteColorKeys.bonusNumColor: bonusNumColor.value.toARGB32(),
      SiteColorKeys.updatedAtColor: updatedAtColor.value.toARGB32(),
      SiteColorKeys.hrColor: hrColor.value.toARGB32(),
      SiteColorKeys.uploadedColor: uploadedColor.value.toARGB32(),
      SiteColorKeys.uploadedIconColor: uploadedIconColor.value.toARGB32(),
      SiteColorKeys.downloadedColor: downloadedColor.value.toARGB32(),
      SiteColorKeys.downloadedIconColor: downloadedIconColor.value.toARGB32(),
      SiteColorKeys.publishedNumColor: publishedNumColor.value.toARGB32(),
      SiteColorKeys.scoreNumColor: scoreNumColor.value.toARGB32(),
      SiteColorKeys.seedVolumeIconColor: seedVolumeIconColor.value.toARGB32(),
      SiteColorKeys.seedVolumeNumColor: seedVolumeNumColor.value.toARGB32(),
      SiteColorKeys.scoreIconColor: scoreIconColor.value.toARGB32(),
      SiteColorKeys.publishedIconColor: publishedIconColor.value.toARGB32(),
    };
  }

  factory SiteColorConfig.fromJson(
    Map<String, dynamic> json,
    ShadColorScheme scheme,
  ) {
    Color c(String key, Color def) => json.containsKey(key) ? Color(json[key]) : def;
    return SiteColorConfig(
      toSignColor: c(SiteColorKeys.toSignColor, const Color(0xFFF44336)).obs,
      signedColor: c(SiteColorKeys.signedColor, const Color(0xFF388E3C)).obs,
      siteCardColor: c(SiteColorKeys.siteCardColor, scheme.foreground).obs,
      siteNameColor: c(SiteColorKeys.siteNameColor, scheme.foreground).obs,
      mailColor: c(SiteColorKeys.mailColor, scheme.foreground).obs,
      noticeColor: c(SiteColorKeys.noticeColor, scheme.foreground).obs,
      regTimeColor: c(SiteColorKeys.regTimeColor, scheme.foreground).obs,
      keepAccountColor: c(SiteColorKeys.keepAccountColor, scheme.destructive).obs,
      graduationColor: c(SiteColorKeys.graduationColor, scheme.destructive).obs,
      inviteColor: c(SiteColorKeys.inviteColor, scheme.foreground).obs,
      loadingColor: c(SiteColorKeys.loadingColor, scheme.foreground).obs,
      uploadIconColor: c(SiteColorKeys.uploadIconColor, scheme.primary).obs,
      uploadNumColor: c(SiteColorKeys.uploadNumColor, scheme.foreground).obs,
      downloadIconColor: c(SiteColorKeys.downloadIconColor, scheme.destructive).obs,
      uploadedIconColor: c(SiteColorKeys.uploadedIconColor, scheme.foreground).obs,
      downloadNumColor: c(SiteColorKeys.downloadNumColor, scheme.foreground).obs,
      ratioIconColor: c(SiteColorKeys.ratioIconColor, scheme.primary).obs,
      ratioNumColor: c(SiteColorKeys.ratioNumColor, scheme.foreground).obs,
      seedIconColor: c(SiteColorKeys.seedIconColor, scheme.foreground).obs,
      seedNumColor: c(SiteColorKeys.seedNumColor, scheme.foreground).obs,
      seedVolumeIconColor: c(SiteColorKeys.seedVolumeIconColor, scheme.foreground).obs,
      seedVolumeNumColor: c(SiteColorKeys.seedVolumeNumColor, scheme.foreground).obs,
      perBonusIconColor: c(SiteColorKeys.perBonusIconColor, scheme.foreground).obs,
      perBonusNumColor: c(SiteColorKeys.perBonusNumColor, scheme.foreground).obs,
      bonusIconColor: c(SiteColorKeys.bonusIconColor, scheme.foreground).obs,
      bonusNumColor: c(SiteColorKeys.bonusNumColor, scheme.foreground).obs,
      updatedAtColor: c(SiteColorKeys.updatedAtColor, scheme.foreground).obs,
      hrColor: c(SiteColorKeys.hrColor, scheme.destructive).obs,
      uploadedColor: c(SiteColorKeys.uploadedColor, scheme.foreground).obs,
      downloadedColor: c(SiteColorKeys.downloadedColor, scheme.foreground).obs,
      publishedNumColor: c(SiteColorKeys.publishedNumColor, scheme.foreground).obs,
      publishedIconColor: c(SiteColorKeys.publishedIconColor, scheme.foreground).obs,
      scoreNumColor: c(SiteColorKeys.scoreNumColor, scheme.foreground).obs,
      scoreIconColor: c(SiteColorKeys.scoreIconColor, scheme.foreground).obs,
      downloadedIconColor: c(SiteColorKeys.downloadedIconColor, scheme.foreground).obs,
    );
  }

  SiteColorConfig copyWith({
    Rx<Color>? toSignColor,
    Rx<Color>? signedColor,
    Rx<Color>? siteCardColor,
    Rx<Color>? siteNameColor,
    Rx<Color>? mailColor,
    Rx<Color>? noticeColor,
    Rx<Color>? regTimeColor,
    Rx<Color>? keepAccountColor,
    Rx<Color>? graduationColor,
    Rx<Color>? inviteColor,
    Rx<Color>? loadingColor,
    Rx<Color>? uploadIconColor,
    Rx<Color>? uploadNumColor,
    Rx<Color>? downloadIconColor,
    Rx<Color>? downloadNumColor,
    Rx<Color>? ratioIconColor,
    Rx<Color>? ratioNumColor,
    Rx<Color>? seedIconColor,
    Rx<Color>? seedNumColor,
    Rx<Color>? perBonusIconColor,
    Rx<Color>? perBonusNumColor,
    Rx<Color>? bonusIconColor,
    Rx<Color>? bonusNumColor,
    Rx<Color>? updatedAtColor,
    Rx<Color>? hrColor,
    Rx<Color>? uploadedColor,
    Rx<Color>? downloadedColor,
    Rx<Color>? downloadedIconColor,
    Rx<Color>? publishedNumColor,
    Rx<Color>? scoreNumColor,
    Rx<Color>? scoreIconColor,
    Rx<Color>? seedVolumeIconColor,
    Rx<Color>? seedVolumeNumColor,
    Rx<Color>? publishedIconColor,
    Rx<Color>? uploadedIconColor,
  }) {
    return SiteColorConfig(
      toSignColor: toSignColor ?? this.toSignColor,
      signedColor: signedColor ?? this.signedColor,
      siteCardColor: siteCardColor ?? this.siteCardColor,
      siteNameColor: siteNameColor ?? this.siteNameColor,
      mailColor: mailColor ?? this.mailColor,
      noticeColor: noticeColor ?? this.noticeColor,
      regTimeColor: regTimeColor ?? this.regTimeColor,
      keepAccountColor: keepAccountColor ?? this.keepAccountColor,
      graduationColor: graduationColor ?? this.graduationColor,
      inviteColor: inviteColor ?? this.inviteColor,
      loadingColor: loadingColor ?? this.loadingColor,
      uploadIconColor: uploadIconColor ?? this.uploadIconColor,
      uploadNumColor: uploadNumColor ?? this.uploadNumColor,
      downloadIconColor: downloadIconColor ?? this.downloadIconColor,
      downloadNumColor: downloadNumColor ?? this.downloadNumColor,
      ratioIconColor: ratioIconColor ?? this.ratioIconColor,
      ratioNumColor: ratioNumColor ?? this.ratioNumColor,
      seedIconColor: seedIconColor ?? this.seedIconColor,
      seedNumColor: seedNumColor ?? this.seedNumColor,
      seedVolumeNumColor: seedVolumeNumColor ?? this.seedVolumeNumColor,
      seedVolumeIconColor: seedVolumeIconColor ?? this.seedVolumeIconColor,
      perBonusIconColor: perBonusIconColor ?? this.perBonusIconColor,
      perBonusNumColor: perBonusNumColor ?? this.perBonusNumColor,
      bonusIconColor: bonusIconColor ?? this.bonusIconColor,
      bonusNumColor: bonusNumColor ?? this.bonusNumColor,
      updatedAtColor: updatedAtColor ?? this.updatedAtColor,
      hrColor: hrColor ?? this.hrColor,
      uploadedColor: uploadedColor ?? this.uploadedColor,
      downloadedColor: downloadedColor ?? this.downloadedColor,
      publishedNumColor: publishedNumColor ?? this.publishedNumColor,
      publishedIconColor: publishedIconColor ?? this.publishedIconColor,
      scoreNumColor: scoreNumColor ?? this.scoreNumColor,
      scoreIconColor: scoreIconColor ?? this.scoreIconColor,
      downloadedIconColor: downloadedIconColor ?? this.downloadedIconColor,
      uploadedIconColor: uploadedIconColor ?? this.uploadedIconColor,
    );
  }
}

class SiteColorKeys {
  static const toSignColor = 'toSignColor';
  static const signedColor = 'signedColor';
  static const siteCardColor = 'siteCardColor';
  static const siteNameColor = 'siteNameColor';
  static const mailColor = 'mailColor';
  static const noticeColor = 'noticeColor';
  static const regTimeColor = 'regTimeColor';
  static const keepAccountColor = 'keepAccountColor';
  static const graduationColor = 'graduationColor';
  static const inviteColor = 'inviteColor';
  static const loadingColor = 'loadingColor';
  static const uploadIconColor = 'uploadIconColor';
  static const uploadNumColor = 'uploadNumColor';
  static const downloadIconColor = 'downloadIconColor';
  static const downloadNumColor = 'downloadNumColor';
  static const ratioIconColor = 'ratioIconColor';
  static const ratioNumColor = 'ratioNumColor';
  static const seedIconColor = 'seedIconColor';
  static const seedNumColor = 'seedNumColor';
  static const perBonusIconColor = 'perBonusIconColor';
  static const perBonusNumColor = 'perBonusNumColor';
  static const bonusIconColor = 'bonusIconColor';
  static const bonusNumColor = 'bonusNumColor';
  static const updatedAtColor = 'updatedAtColor';
  static const hrColor = 'hrColor';
  static const uploadedColor = 'uploadedColor';
  static const downloadedColor = 'downloadedColor';
  static const publishedNumColor = 'publishedNumColor';
  static const publishedIconColor = 'publishedIconColor';
  static const scoreNumColor = 'scoreNumColor';
  static const scoreIconColor = 'scoreIconColor';
  static const seedVolumeNumColor = 'seedVolumeNumColor';
  static const seedVolumeIconColor = 'seedVolumeIconColor';
  static const downloadedIconColor = 'downloadedIconColor';
  static const uploadedIconColor = 'uploadedIconColor';
}
