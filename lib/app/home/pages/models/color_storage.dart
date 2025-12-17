import 'dart:ui';

import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../utils/storage.dart';

class SiteColorConfig {
  static const String spKey = 'site_color_config';

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
  final Rx<Color> downloadIconColor;
  final Rx<Color> downloadNumColor;
  final Rx<Color> ratioIconColor;
  final Rx<Color> ratioNumColor;
  final Rx<Color> seedIconColor;
  final Rx<Color> seedNumColor;
  final Rx<Color> perBonusIconColor;
  final Rx<Color> perBonusNumColor;
  final Rx<Color> bonusIconColor;
  final Rx<Color> bonusNumColor;
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
    required this.uploadNumColor,
    required this.downloadIconColor,
    required this.downloadNumColor,
    required this.ratioIconColor,
    required this.ratioNumColor,
    required this.seedIconColor,
    required this.seedNumColor,
    required this.perBonusIconColor,
    required this.perBonusNumColor,
    required this.bonusIconColor,
    required this.bonusNumColor,
    required this.updatedAtColor,
    required this.hrColor,
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

  static Future<void> save({
    required ShadColorScheme scheme,
    required String key,
    required Color color,
  }) async {
    // 1️⃣ 先 load 当前配置（保证完整）
    final current = SiteColorConfig.load(scheme);

    // 2️⃣ 转成 Map
    final map = current.toJson();
    // print('更新前的配置：${map[key]}');
    // print('准备更新的内容：${key} ==== ${color.value}');
    // 3️⃣ 只更新指定 key
    map[key] = color.value;
    // print('更新后的配置：$map');
    // 4️⃣ 整体写回 SP
    await SPUtil.setMap(spKey, map);
  }

  factory SiteColorConfig.defaults(ShadColorScheme scheme) {
    return SiteColorConfig(
      toSignColor: const Color(0xFFF44336).obs,
      signedColor: const Color(0xFF388E3C).obs,
      siteCardColor: scheme.foreground.obs,
      siteNameColor: scheme.foreground.obs,
      mailColor: scheme.foreground.obs,
      noticeColor: scheme.foreground.obs,
      regTimeColor: scheme.foreground.obs,
      keepAccountColor: scheme.destructive.obs,
      graduationColor: scheme.destructive.obs,
      inviteColor: scheme.foreground.obs,
      loadingColor: scheme.foreground.obs,
      uploadIconColor: scheme.primary.obs,
      uploadNumColor: scheme.foreground.obs,
      downloadIconColor: scheme.destructive.obs,
      downloadNumColor: scheme.foreground.obs,
      ratioIconColor: scheme.primary.obs,
      ratioNumColor: scheme.foreground.obs,
      seedIconColor: scheme.foreground.obs,
      seedNumColor: scheme.foreground.obs,
      perBonusIconColor: scheme.foreground.obs,
      perBonusNumColor: scheme.foreground.obs,
      bonusIconColor: scheme.foreground.obs,
      bonusNumColor: scheme.foreground.obs,
      updatedAtColor: scheme.foreground.obs,
      hrColor: scheme.destructive.obs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SiteColorKeys.toSignColor: toSignColor.value.value,
      SiteColorKeys.signedColor: signedColor.value.value,
      SiteColorKeys.siteCardColor: siteCardColor.value.value,
      SiteColorKeys.siteNameColor: siteNameColor.value.value,
      SiteColorKeys.mailColor: mailColor.value.value,
      SiteColorKeys.noticeColor: noticeColor.value.value,
      SiteColorKeys.regTimeColor: regTimeColor.value.value,
      SiteColorKeys.keepAccountColor: keepAccountColor.value.value,
      SiteColorKeys.graduationColor: graduationColor.value.value,
      SiteColorKeys.inviteColor: inviteColor.value.value,
      SiteColorKeys.loadingColor: loadingColor.value.value,
      SiteColorKeys.uploadIconColor: uploadIconColor.value.value,
      SiteColorKeys.uploadNumColor: uploadNumColor.value.value,
      SiteColorKeys.downloadIconColor: downloadIconColor.value.value,
      SiteColorKeys.downloadNumColor: downloadNumColor.value.value,
      SiteColorKeys.ratioIconColor: ratioIconColor.value.value,
      SiteColorKeys.ratioNumColor: ratioNumColor.value.value,
      SiteColorKeys.seedIconColor: seedIconColor.value.value,
      SiteColorKeys.seedNumColor: seedNumColor.value.value,
      SiteColorKeys.perBonusIconColor: perBonusIconColor.value.value,
      SiteColorKeys.perBonusNumColor: perBonusNumColor.value.value,
      SiteColorKeys.bonusIconColor: bonusIconColor.value.value,
      SiteColorKeys.bonusNumColor: bonusNumColor.value.value,
      SiteColorKeys.updatedAtColor: updatedAtColor.value.value,
      SiteColorKeys.hrColor: hrColor.value.value,
    };
  }

  factory SiteColorConfig.fromJson(
    Map<String, dynamic> json,
    ShadColorScheme scheme,
  ) {
    Color _c(String key, Color def) => json.containsKey(key) ? Color(json[key]) : def;
    double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    return SiteColorConfig(
      toSignColor: _c(SiteColorKeys.toSignColor, const Color(0xFFF44336)).withOpacity(opacity).obs,
      signedColor: _c(SiteColorKeys.signedColor, const Color(0xFF388E3C)).obs,
      siteCardColor: _c(SiteColorKeys.siteCardColor, scheme.foreground).obs,
      siteNameColor: _c(SiteColorKeys.siteNameColor, scheme.foreground).obs,
      mailColor: _c(SiteColorKeys.mailColor, scheme.foreground).obs,
      noticeColor: _c(SiteColorKeys.noticeColor, scheme.foreground).obs,
      regTimeColor: _c(SiteColorKeys.regTimeColor, scheme.foreground).obs,
      keepAccountColor: _c(SiteColorKeys.keepAccountColor, scheme.destructive).obs,
      graduationColor: _c(SiteColorKeys.graduationColor, scheme.destructive).obs,
      inviteColor: _c(SiteColorKeys.inviteColor, scheme.foreground).obs,
      loadingColor: _c(SiteColorKeys.loadingColor, scheme.foreground).obs,
      uploadIconColor: _c(SiteColorKeys.uploadIconColor, scheme.primary).obs,
      uploadNumColor: _c(SiteColorKeys.uploadNumColor, scheme.foreground).obs,
      downloadIconColor: _c(SiteColorKeys.downloadIconColor, scheme.destructive).obs,
      downloadNumColor: _c(SiteColorKeys.downloadNumColor, scheme.foreground).obs,
      ratioIconColor: _c(SiteColorKeys.ratioIconColor, scheme.primary).obs,
      ratioNumColor: _c(SiteColorKeys.ratioNumColor, scheme.foreground).obs,
      seedIconColor: _c(SiteColorKeys.seedIconColor, scheme.foreground).obs,
      seedNumColor: _c(SiteColorKeys.seedNumColor, scheme.foreground).obs,
      perBonusIconColor: _c(SiteColorKeys.perBonusIconColor, scheme.foreground).obs,
      perBonusNumColor: _c(SiteColorKeys.perBonusNumColor, scheme.foreground).obs,
      bonusIconColor: _c(SiteColorKeys.bonusIconColor, scheme.foreground).obs,
      bonusNumColor: _c(SiteColorKeys.bonusNumColor, scheme.foreground).obs,
      updatedAtColor: _c(SiteColorKeys.updatedAtColor, scheme.foreground).obs,
      hrColor: _c(SiteColorKeys.hrColor, scheme.destructive).obs,
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
      perBonusIconColor: perBonusIconColor ?? this.perBonusIconColor,
      perBonusNumColor: perBonusNumColor ?? this.perBonusNumColor,
      bonusIconColor: bonusIconColor ?? this.bonusIconColor,
      bonusNumColor: bonusNumColor ?? this.bonusNumColor,
      updatedAtColor: updatedAtColor ?? this.updatedAtColor,
      hrColor: hrColor ?? this.hrColor,
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
}
