import 'dart:convert';
import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/provider/app_auto_refresh_provider.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/news/provider/media_info_settings_provider.dart';
import 'package:harvest/modules/option/widgets/app_upgrade_page.dart';
import 'package:harvest/modules/shell/widgets/global_drawer_swipe_area.dart';
import 'package:harvest/widgets/debug_theme_button.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../provider/option_provider.dart';
import '../service/option_service.dart';
import 'option_form_card.dart';
import 'update_page.dart';
import 'update_panel.dart';

shadcn.ColorScheme _optionColors(BuildContext context) =>
    shadcn.Theme.of(context).colorScheme;

BorderRadius _optionRadius(BuildContext context, {String size = 'md'}) {
  final theme = shadcn.Theme.of(context);
  return switch (size) {
    'xs' => theme.borderRadiusXs,
    'sm' => theme.borderRadiusSm,
    'lg' => theme.borderRadiusLg,
    'xl' => theme.borderRadiusXl,
    _ => theme.borderRadiusMd,
  };
}

// ══════════════════════════════════════════════════════════
//  表单配置表
// ══════════════════════════════════════════════════════════

final _formConfigs = <String, FormConfig>{
  'monkey_token': FormConfig(
    title: '安全Token',
    icon: shadcn.LucideIcons.key,
    textFields: [FormFieldDef('token', '令牌', (v) => v?.token)],
    extraBuilder: (c) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: shadcn.Button.destructive(
              onPressed: () {
                c['token']!.text = _randomString(8);
                Clipboard.setData(ClipboardData(text: c['token']!.text));
                Toast.success('已复制到剪贴板');
              },
              child: const Text('随机Token'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: shadcn.Button.outline(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: c['token']!.text));
                Toast.success('已复制到剪贴板');
              },
              child: const Text('复制Token'),
            ),
          ),
        ],
      ),
    ),
    buildValue: (c, _, v) => v.copyWith(token: c['token']!.text),
  ),

  'wechat_work_push': FormConfig(
    title: '企业微信',
    icon: shadcn.LucideIcons.messageCircle,
    textFields: [
      FormFieldDef('corp_id', '企业 ID', (v) => v?.corpId),
      FormFieldDef('corp_secret', '企业密钥', (v) => v?.corpSecret),
      FormFieldDef('agent_id', '应用 ID', (v) => v?.agentId),
      FormFieldDef('to_uid', '接收 ID', (v) => v?.toUid),
      FormFieldDef('refresh_token', 'EncodingAESKey', (v) => v?.refreshToken),
      FormFieldDef('token', 'Token', (v) => v?.token),
      FormFieldDef('server', '背景图地址', (v) => v?.server),
      FormFieldDef('proxy', '固定代理', (v) => v?.proxy),
    ],
    buildValue: (c, _, v) => v.copyWith(
      corpId: c['corp_id']!.text,
      corpSecret: c['corp_secret']!.text,
      agentId: c['agent_id']!.text,
      toUid: c['to_uid']!.text,
      refreshToken: c['refresh_token']!.text,
      token: c['token']!.text,
      server: c['server']!.text,
      proxy: c['proxy']!.text,
    ),
  ),

  'wxpusher_push': FormConfig(
    title: 'WxPusher',
    icon: shadcn.LucideIcons.send,
    textFields: [
      FormFieldDef('app_id', '应用 ID', (v) => v?.appId),
      FormFieldDef('token', '令牌', (v) => v?.token),
      FormFieldDef('uids', '接收人', (v) => v?.uids),
    ],
    buildValue: (c, _, v) => v.copyWith(
      appId: c['app_id']!.text,
      token: c['token']!.text,
      uids: c['uids']!.text,
    ),
  ),

  'pushdeer_push': FormConfig(
    title: 'PushDeer',
    icon: shadcn.LucideIcons.send,
    textFields: [
      FormFieldDef('key', 'Key', (v) => v?.key),
      FormFieldDef('proxy', '服务器', (v) => v?.proxy),
    ],
    buildValue: (c, _, v) =>
        v.copyWith(key: c['key']!.text, proxy: c['proxy']!.text),
  ),

  'bark_push': FormConfig(
    title: 'Bark',
    icon: shadcn.LucideIcons.bell,
    textFields: [
      FormFieldDef('device_key', '设备ID', (v) => v?.deviceKey),
      FormFieldDef('server', '服务器', (v) => v?.server),
    ],
    buildValue: (c, _, v) =>
        v.copyWith(deviceKey: c['device_key']!.text, server: c['server']!.text),
  ),

  'iyuu_push': FormConfig(
    title: '爱语飞飞',
    icon: shadcn.LucideIcons.heart,
    textFields: [FormFieldDef('token', '令牌', (v) => v?.token)],
    switchFields: [SwitchFieldDef('repeat', '辅种开关', (v) => v?.repeat ?? false)],
    buildValue: (c, s, v) =>
        v.copyWith(token: c['token']!.text, repeat: s['repeat']),
  ),

  'meow_push': FormConfig(
    title: '喵呜通知',
    icon: shadcn.LucideIcons.bell,
    textFields: [
      FormFieldDef('token', '喵呜令牌', (v) => v?.token),
      FormFieldDef('max_count', 'HTML高度', (v) => v?.maxCount?.toString()),
      FormFieldDef('server', '服务器', (v) => v?.server),
    ],
    buildValue: (c, _, v) => v.copyWith(
      token: c['token']!.text,
      maxCount: int.tryParse(c['max_count']!.text) ?? 200,
      server: c['server']!.text,
    ),
  ),

  'server_chan_push': FormConfig(
    title: 'Server酱',
    icon: shadcn.LucideIcons.bell,
    textFields: [
      FormFieldDef('token', 'SendKey', (v) => v?.token),
      FormFieldDef('app_id', 'OpenId', (v) => v?.appId),
      FormFieldDef('server', '消息通道', (v) => v?.server),
      FormFieldDef('count', '隐藏调用IP', (v) => v?.count?.toString()),
    ],
    buildValue: (c, _, v) => v.copyWith(
      token: c['token']!.text,
      appId: c['app_id']!.text,
      server: c['server']!.text,
      count: int.tryParse(c['count']!.text) ?? 1,
    ),
  ),

  'pushplus_push': FormConfig(
    title: 'PushPlus',
    icon: shadcn.LucideIcons.send,
    textFields: [FormFieldDef('token', '令牌', (v) => v?.token)],
    buildValue: (c, _, v) =>
        v.copyWith(token: c['token']!.text, template: 'markdown'),
  ),

  'telegram_push': FormConfig(
    title: 'Telegram配置',
    icon: shadcn.LucideIcons.send,
    textFields: [
      FormFieldDef('chat_id', 'ID', (v) => v?.telegramChatId),
      FormFieldDef('token', '令牌', (v) => v?.telegramToken),
      FormFieldDef('proxy', '代理', (v) => v?.proxy),
    ],
    buildValue: (c, _, v) => v.copyWith(
      telegramChatId: c['chat_id']!.text,
      telegramToken: c['token']!.text,
      proxy: c['proxy']!.text,
    ),
  ),

  'aliyun_drive': FormConfig(
    title: '阿里云盘',
    icon: shadcn.LucideIcons.hardDrive,
    textFields: [
      FormFieldDef(
        'refresh_token',
        '保存令牌',
        (v) => v?.refreshToken,
        maxLines: 3,
      ),
    ],
    switchFields: [
      SwitchFieldDef('welfare', '领取福利', (v) => v?.welfare ?? true),
    ],
    buildValue: (c, s, v) => v.copyWith(
      refreshToken: c['refresh_token']!.text,
      welfare: s['welfare'],
    ),
  ),

  'baidu_ocr': FormConfig(
    title: '百度 OCR',
    icon: shadcn.LucideIcons.scanLine,
    textFields: [
      FormFieldDef('app_id', '应用 ID', (v) => v?.appId),
      FormFieldDef('api_key', 'APIKey', (v) => v?.apiKey),
      FormFieldDef('secret_key', 'Secret', (v) => v?.secretKey),
    ],
    buildValue: (c, _, v) => v.copyWith(
      appId: c['app_id']!.text,
      apiKey: c['api_key']!.text,
      secretKey: c['secret_key']!.text,
    ),
  ),

  'ssdforum': FormConfig(
    title: 'SSDForum',
    icon: shadcn.LucideIcons.globe,
    textFields: [
      FormFieldDef('cookie', 'Cookie', (v) => v?.cookie, maxLines: 5),
      FormFieldDef('user_agent', 'UserAgent', (v) => v?.userAgent, maxLines: 3),
      FormFieldDef('today_say', '今天想说', (v) => v?.todaySay, maxLines: 5),
    ],
    buildValue: (c, _, v) => v.copyWith(
      cookie: c['cookie']!.text,
      userAgent: c['user_agent']!.text,
      todaySay: c['today_say']!.text,
    ),
  ),

  'cookie_cloud': FormConfig(
    title: 'CookieCloud',
    icon: shadcn.LucideIcons.cookie,
    textFields: [
      FormFieldDef('server', '服务器', (v) => v?.server),
      FormFieldDef('key', 'Key', (v) => v?.key),
      FormFieldDef('password', '密码', (v) => v?.password),
    ],
    buildValue: (c, _, v) => v.copyWith(
      server: c['server']!.text,
      key: c['key']!.text,
      password: c['password']!.text,
    ),
  ),

  'FileList': FormConfig(
    title: 'FileList',
    icon: shadcn.LucideIcons.file,
    textFields: [
      FormFieldDef('username', '账号', (v) => v?.username),
      FormFieldDef('password', '密码', (v) => v?.password),
    ],
    buildValue: (c, _, v) => v.copyWith(
      username: c['username']!.text,
      password: c['password']!.text,
    ),
  ),

  'tmdb_api_auth': FormConfig(
    title: '影视Token配置',
    icon: shadcn.LucideIcons.film,
    textFields: [
      FormFieldDef('api_key', 'TMDB密钥', (v) => v?.apiKey),
      FormFieldDef('secret_key', '豆瓣Cookie', (v) => v?.secretKey),
      FormFieldDef('proxy', '代理地址', (v) => v?.proxy),
    ],
    buildValue: (c, _, v) => v.copyWith(
      apiKey: c['api_key']!.text,
      secretKey: c['secret_key']!.text,
      proxy: c['proxy']!.text,
    ),
  ),

  'aggregation_search': FormConfig(
    title: '聚合搜索配置',
    icon: shadcn.LucideIcons.search,
    textFields: [
      FormFieldDef(
        'max_count',
        '站点数量限制',
        (v) => v?.maxCount?.toString(),
        helperText: '单次搜索的站点数量，0表示不限制',
      ),
      FormFieldDef(
        'limit',
        '并发数量限制',
        (v) => v?.limit?.toString(),
        helperText: '并发搜索站点数量，0表示不限制',
      ),
    ],
    buildValue: (c, _, v) => v.copyWith(
      maxCount: int.tryParse(c['max_count']!.text) ?? 30,
      limit: int.tryParse(c['limit']!.text) ?? 30,
    ),
  ),

  'notice_category_enable': FormConfig(
    title: '通知开关',
    icon: shadcn.LucideIcons.bellRing,
    textFields: const [],
    switchFields: [
      SwitchFieldDef(
        'aliyundrive_notice',
        '阿里云盘',
        (v) => v?.aliyundriveNotice ?? true,
      ),
      SwitchFieldDef('site_data', '站点数据', (v) => v?.siteData ?? true),
      SwitchFieldDef(
        'site_data_success',
        '成功站点消息',
        (v) => v?.siteDataSuccess ?? true,
      ),
      SwitchFieldDef('today_data', '今日数据', (v) => v?.todayData ?? true),
      SwitchFieldDef('package_torrent', '拆包', (v) => v?.packageTorrent ?? true),
      SwitchFieldDef('delete_torrent', '删种', (v) => v?.deleteTorrent ?? true),
      SwitchFieldDef('rss_torrent', 'RSS', (v) => v?.rssTorrent ?? true),
      SwitchFieldDef('push_torrent', '种子推送', (v) => v?.pushTorrent ?? true),
      SwitchFieldDef(
        'program_upgrade',
        'Docker 升级',
        (v) => v?.programUpgrade ?? true,
      ),
      SwitchFieldDef('ptpp_import', 'PTPP 导入', (v) => v?.ptppImport ?? true),
      SwitchFieldDef('announcement', '公告详情', (v) => v?.announcement ?? true),
      SwitchFieldDef('message', '短消息详情', (v) => v?.message ?? true),
      SwitchFieldDef(
        'sign_in_success',
        '签到成功消息',
        (v) => v?.signInSuccess ?? true,
      ),
      SwitchFieldDef(
        'cookie_sync',
        'CookieCloud 同步',
        (v) => v?.cookieSync ?? true,
      ),
    ],
    buildValue: (_, s, v) => v.copyWith(
      aliyundriveNotice: s['aliyundrive_notice'],
      siteData: s['site_data'],
      siteDataSuccess: s['site_data_success'],
      todayData: s['today_data'],
      packageTorrent: s['package_torrent'],
      deleteTorrent: s['delete_torrent'],
      rssTorrent: s['rss_torrent'],
      pushTorrent: s['push_torrent'],
      programUpgrade: s['program_upgrade'],
      ptppImport: s['ptpp_import'],
      announcement: s['announcement'],
      message: s['message'],
      signInSuccess: s['sign_in_success'],
      cookieSync: s['cookie_sync'],
    ),
  ),

  'notice_content_item': FormConfig(
    title: '站点详情',
    icon: shadcn.LucideIcons.layoutList,
    textFields: const [],
    switchFields: [
      SwitchFieldDef('level', '等级', (v) => v?.level ?? true),
      SwitchFieldDef('bonus', '魔力', (v) => v?.bonus ?? true),
      SwitchFieldDef('per_bonus', '时魔', (v) => v?.perBonus ?? true),
      SwitchFieldDef('score', '积分', (v) => v?.score ?? true),
      SwitchFieldDef('ratio', '分享率', (v) => v?.ratio ?? true),
      SwitchFieldDef('seeding_vol', '做种体积', (v) => v?.seedingVol ?? true),
      SwitchFieldDef('uploaded', '上传量', (v) => v?.uploaded ?? true),
      SwitchFieldDef('downloaded', '下载量', (v) => v?.downloaded ?? true),
      SwitchFieldDef('seeding', '做种数量', (v) => v?.seeding ?? true),
      SwitchFieldDef('leeching', '吸血数量', (v) => v?.leeching ?? true),
      SwitchFieldDef('invite', '邀请', (v) => v?.invite ?? true),
      SwitchFieldDef('hr', 'HR', (v) => v?.hr ?? true),
    ],
    buildValue: (_, s, v) => v.copyWith(
      level: s['level'],
      bonus: s['bonus'],
      perBonus: s['per_bonus'],
      score: s['score'],
      ratio: s['ratio'],
      seedingVol: s['seeding_vol'],
      uploaded: s['uploaded'],
      downloaded: s['downloaded'],
      seeding: s['seeding'],
      leeching: s['leeching'],
      invite: s['invite'],
      hr: s['hr'],
    ),
  ),

  'auto_import_tags': FormConfig(
    title: '自动添加标签',
    icon: shadcn.LucideIcons.tags,
    textFields: const [],
    switchFields: [
      SwitchFieldDef('repeat', '自动添加标签', (v) => v?.repeat ?? false),
    ],
    buildValue: (_, s, v) => v.copyWith(repeat: s['repeat']),
  ),
};

// ══════════════════════════════════════════════════════════
//  设置页面
// ══════════════════════════════════════════════════════════

class OptionPage extends ConsumerWidget {
  const OptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(optionProvider);
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: GlobalDrawerSwipeArea(
        child: AppBackground(
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Row(
                    children: [
                      shadcn.IconButton.ghost(
                        icon: const Icon(shadcn.LucideIcons.arrowLeft, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          '选项设置',
                          style: typo.large.copyWith(
                            color: cs.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const DebugThemeButton.shadcn(),
                      shadcn.IconButton.ghost(
                        icon: const Icon(shadcn.LucideIcons.refreshCw, size: 18),
                        onPressed: () =>
                            ref.read(optionProvider.notifier).fetchOptions(),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: shadcn.CircularProgressIndicator(strokeWidth: 2),
                      )
                    : EasyRefresh(
                        onRefresh: () =>
                            ref.read(optionProvider.notifier).fetchOptions(),
                        header: appRefreshHeader(context),
                        child: ListView(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          children: [
                            _buildVersionCard(context),
                            if (!kIsWeb) _buildAppUpgradeCard(context),
                            _buildUpdateCard(context),
                            const _CookieBackupImportCard(),
                            const _AppAutoRefreshIntervalCard(),
                            const _MediaInfoSettingsCard(),
                            _buildSpeedTest(context, ref),
                            _buildNoticeTest(context, ref),
                            const _BulkUpgradeCard(),
                            _buildTelegramWebhook(context, ref),
                            ..._formConfigs.entries.map((entry) {
                              final optionName = entry.key;
                              final config = entry.value;
                              final serverOption = state.getOption(optionName);

                              return OptionFormCard(
                                key: ValueKey(optionName),
                                title: config.title,
                                optionName: optionName,
                                option: serverOption,
                                icon: config.icon,
                                textFields: config.textFields,
                                switchFields: config.switchFields,
                                extraBuilder: config.extraBuilder,
                                buildValue: config.buildValue,
                                onSave: (opt) async {
                                  return ref
                                      .read(optionProvider.notifier)
                                      .saveOption(opt);
                                },
                                onToggleActive: serverOption != null
                                    ? (opt) async {
                                        await ref
                                            .read(optionProvider.notifier)
                                            .saveOption(opt);
                                      }
                                    : null,
                              );
                            }),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────── 版本卡片 ──────────────────

  Widget _buildVersionCard(BuildContext context) {
    return const _VersionCard();
  }

  Widget _buildAppUpgradeCard(BuildContext context) {
    return const AppUpgradeSummaryCard();
  }

  Widget _buildUpdateCard(BuildContext context) {
    return ExpandableCard(
      title: '程序更新',
      icon: shadcn.LucideIcons.download,
      builder: (collapse) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const UpdatePanel(maxCommitCount: 12),
          const SizedBox(height: 8),
          SizedBox(
            width: 190,
            child: shadcn.Button.outline(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const UpdatePage())),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(shadcn.LucideIcons.externalLink, size: 15),
                  SizedBox(width: 6),
                  Text('打开完整更新页面'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedTest(BuildContext context, WidgetRef ref) {
    return ExpandableCard(
      title: '网络测速',
      icon: shadcn.LucideIcons.gauge,
      builder: (collapse) => _SpeedTestAction(
        onStart: () async {
          final success = await ref.read(optionProvider.notifier).speedTest();
          if (success) {
            Toast.success('测速任务已提交');
            collapse();
          } else {
            Toast.error('测速任务提交失败');
          }
        },
      ),
    );
  }

  Widget _buildTelegramWebhook(BuildContext context, WidgetRef ref) {
    return ExpandableCard(
      title: 'Telegram Webhook',
      icon: shadcn.LucideIcons.send,
      builder: (collapse) {
        final urlCtrl = TextEditingController();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadTextField(
              controller: urlCtrl,
              hintText: 'WebHook地址 (https://...)',
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const SizedBox(height: 6),
            Text(
              '请仅输入域名部分，端口必须是【80、443、8080、8443】之一',
              style: shadcn.Theme.of(context).typography.xSmall.copyWith(
                color: shadcn.Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: shadcn.Button.destructive(
                onPressed: () async {
                  final raw = urlCtrl.text.trim();

                  // 基础校验
                  if (raw.isEmpty) {
                    Toast.error('请输入 WebHook 地址');
                    return;
                  }
                  if (!raw.startsWith('https://')) {
                    Toast.error('必须使用 https 协议');
                    return;
                  }

                  // 补全尾部斜杠
                  final normalized = raw.endsWith('/') ? raw : '$raw/';

                  // 解析
                  Uri? uri;
                  try {
                    uri = Uri.parse(normalized);
                  } catch (_) {
                    Toast.error('地址格式不正确');
                    return;
                  }

                  // 协议二次确认
                  if (uri.scheme != 'https') {
                    Toast.error('必须使用 https 协议');
                    return;
                  }

                  // 不允许携带认证信息
                  if (uri.userInfo.isNotEmpty) {
                    Toast.error('地址中不允许包含用户名或密码');
                    return;
                  }

                  // 必须有合法域名
                  final host = uri.host;
                  if (host.isEmpty) {
                    Toast.error('请输入有效的域名');
                    return;
                  }
                  if (host.contains(' ') || host.contains('..')) {
                    Toast.error('域名格式不正确');
                    return;
                  }
                  // 域名必须包含 . 且不能以 . 开头或结尾
                  if (!host.contains('.') ||
                      host.startsWith('.') ||
                      host.endsWith('.')) {
                    Toast.error('请输入有效的域名，如 example.com');
                    return;
                  }

                  // 不允许携带 query 或 fragment
                  if (uri.query.isNotEmpty || uri.fragment.isNotEmpty) {
                    Toast.error('地址中不允许包含查询参数或锚点');
                    return;
                  }

                  // 端口校验
                  const allowedPorts = [0, 80, 443, 8080, 8443];
                  if (!allowedPorts.contains(uri.port)) {
                    Toast.error('端口必须是 80、443、8080、8443 之一');
                    return;
                  }

                  // 全部通过，发送请求
                  final success = await ref
                      .read(optionProvider.notifier)
                      .setTelegramWebhook(normalized);
                  if (success) {
                    Toast.success('设置成功');
                    collapse();
                  } else {
                    Toast.error('设置失败');
                  }
                },
                child: const Text('保存'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ────────────────── 通知测试 ──────────────────

  Widget _buildNoticeTest(BuildContext context, WidgetRef ref) {
    return ExpandableCard(
      title: '通知测试',
      icon: shadcn.LucideIcons.bellRing,
      builder: (collapse) {
        final titleCtrl = TextEditingController(text: '这是一个消息标题');
        final msgCtrl = TextEditingController(
          text: '*这是一条测试消息*\n__这是二号标题__\n```这是消息```',
        );
        return _TestNoticeForm(
          titleCtrl: titleCtrl,
          msgCtrl: msgCtrl,
          onSend: () async {
            final success = await ref.read(optionProvider.notifier).testNotice({
              'title': titleCtrl.text,
              'message': msgCtrl.text,
            });
            if (success) {
              Toast.success('测试消息发送完成');
              collapse();
            } else {
              Toast.error('发送失败');
            }
          },
        );
      },
    );
  }
}

class _MediaInfoSettingsCard extends ConsumerWidget {
  const _MediaInfoSettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(mediaInfoSettingsProvider);
    final notifier = ref.read(mediaInfoSettingsProvider.notifier);
    final theme = shadcn.Theme.of(context);
    final cs = _optionColors(context);
    final typo = theme.typography;

    Widget row({
      required String title,
      required String subtitle,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) {
      return AppSurfaceContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: _optionRadius(context),
        color: appSurfaceColor(context, cs.card),
        borderColor: cs.border.withValues(alpha: 0.7),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typo.small.copyWith(
                      color: cs.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: typo.xSmall.copyWith(color: cs.mutedForeground),
                  ),
                ],
              ),
            ),
            shadcn.Switch(value: value, onChanged: onChanged),
          ],
        ),
      );
    }

    return ExpandableCard(
      title: '影视资讯',
      icon: shadcn.LucideIcons.newspaper,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row(
            title: 'TMDB',
            subtitle: '开启后显示 TMDB 影视资讯入口与内容',
            value: settings.tmdbEnabled,
            onChanged: notifier.setTmdbEnabled,
          ),
          const SizedBox(height: 8),
          row(
            title: '豆瓣',
            subtitle: '开启后显示豆瓣影视资讯入口与内容',
            value: settings.doubanEnabled,
            onChanged: notifier.setDoubanEnabled,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  站点备份导入
// ══════════════════════════════════════════════════════════

class _CookieBackupImportCard extends ConsumerStatefulWidget {
  const _CookieBackupImportCard();

  @override
  ConsumerState<_CookieBackupImportCard> createState() =>
      _CookieBackupImportCardState();
}

class _CookieBackupImportCardState
    extends ConsumerState<_CookieBackupImportCard> {
  CookieBackupSource? _uploading;
  bool _syncingCookieCloud = false;

  bool get _busy => _uploading != null || _syncingCookieCloud;

  Future<void> _pickAndUpload(CookieBackupSource source) async {
    if (_busy) return;

    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(allowMultiple: false, withData: true);
    } on PlatformException catch (e) {
      AppLogger.error('选择 ${source.label} 备份文件失败', e);
      if (e.code == 'ENTITLEMENT_NOT_FOUND') {
        Toast.error('缺少文件读取权限，请重启应用后重试');
      } else {
        Toast.error('选择文件失败: ${e.message ?? e.code}');
      }
      return;
    } catch (e, st) {
      AppLogger.error('选择 ${source.label} 备份文件失败', e, st);
      Toast.error('选择文件失败');
      return;
    }

    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    final file = result.files.single;
    if (file.path == null && file.bytes == null) {
      Toast.error('无法读取所选文件');
      return;
    }

    setState(() => _uploading = source);
    try {
      AppLogger.info(
        '提交 ${source.label} 备份导入: file=${file.name}, size=${file.size}',
      );
      final message = await ref
          .read(optionProvider.notifier)
          .importCookieBackup(file: file, source: source);
      if (!mounted) return;

      if (message == null) {
        Toast.error('${source.label} 导入失败');
      } else {
        Toast.success(message);
      }
    } catch (e, st) {
      AppLogger.error('${source.label} 备份导入失败', e, st);
      if (mounted) Toast.error('${source.label} 导入失败');
    } finally {
      if (mounted) setState(() => _uploading = null);
    }
  }

  Future<void> _syncCookieCloud() async {
    if (_busy) return;

    setState(() => _syncingCookieCloud = true);
    try {
      AppLogger.info('提交 CookieCloud 同步');
      final success = await ref.read(optionProvider.notifier).syncCookieCloud();
      if (!mounted) return;

      if (success) {
        Toast.success('CookieCloud 同步任务已提交');
      } else {
        Toast.error('CookieCloud 同步失败');
      }
    } catch (e, st) {
      AppLogger.error('CookieCloud 同步失败', e, st);
      if (mounted) Toast.error('CookieCloud 同步失败');
    } finally {
      if (mounted) setState(() => _syncingCookieCloud = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      title: '站点导入',
      icon: shadcn.LucideIcons.fileUp,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSourceTile(context, CookieBackupSource.ptpp),
          const SizedBox(height: 8),
          _buildSourceTile(context, CookieBackupSource.ptd),
          const SizedBox(height: 8),
          _buildCookieCloudTile(context),
        ],
      ),
    );
  }

  Widget _buildSourceTile(BuildContext context, CookieBackupSource source) {
    final cs = _optionColors(context);
    final isUploading = _uploading == source;
    final enabled = !_busy;
    final color = isUploading
        ? cs.primary
        : enabled
        ? cs.foreground.withValues(alpha: 0.62)
        : cs.mutedForeground;

    return _ImportActionTile(
      enabled: enabled,
      onTap: enabled ? () => _pickAndUpload(source) : null,
      leading: Icon(shadcn.LucideIcons.cookie, size: 18, color: color),
      title: '${source.label} 导入',
      subtitle: '从备份文件导入站点',
      trailing: isUploading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: shadcn.CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(shadcn.LucideIcons.fileUp, size: 17, color: color),
    );
  }

  Widget _buildCookieCloudTile(BuildContext context) {
    final cs = _optionColors(context);
    final enabled = !_busy;
    final color = _syncingCookieCloud
        ? cs.primary
        : enabled
        ? cs.foreground.withValues(alpha: 0.62)
        : cs.mutedForeground;

    return _ImportActionTile(
      enabled: enabled,
      onTap: enabled ? _syncCookieCloud : null,
      leading: Icon(shadcn.LucideIcons.cloud, size: 18, color: color),
      title: 'CookieCloud 同步',
      subtitle: '直接从 CookieCloud 同步站点',
      trailing: _syncingCookieCloud
          ? const SizedBox(
              width: 16,
              height: 16,
              child: shadcn.CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(shadcn.LucideIcons.refreshCw, size: 17, color: color),
    );
  }
}

class _ImportActionTile extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _ImportActionTile({
    required this.enabled,
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = _optionColors(context);

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: shadcn.Button.ghost(
        onPressed: enabled ? onTap : null,
        child: AppSurfaceContainer(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: _optionRadius(context),
          color: appSurfaceColor(context, cs.card),
          borderColor: cs.border.withValues(alpha: 0.7),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: shadcn.Theme.of(context).typography.small.copyWith(
                        color: cs.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: shadcn.Theme.of(
                        context,
                      ).typography.xSmall.copyWith(color: cs.mutedForeground),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 28, height: 28, child: Center(child: trailing)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppAutoRefreshIntervalCard extends ConsumerStatefulWidget {
  const _AppAutoRefreshIntervalCard();

  @override
  ConsumerState<_AppAutoRefreshIntervalCard> createState() =>
      _AppAutoRefreshIntervalCardState();
}

class _AppAutoRefreshIntervalCardState
    extends ConsumerState<_AppAutoRefreshIntervalCard> {
  static const _presets = [5, 10, 15, 30, 60];

  late final TextEditingController _minutesCtrl;
  final FocusNode _minutesFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _minutesCtrl = TextEditingController(
      text: '${ref.read(appAutoRefreshIntervalProvider)}',
    );
  }

  @override
  void dispose() {
    _minutesCtrl.dispose();
    _minutesFocus.dispose();
    super.dispose();
  }

  Future<void> _setMinutes(int value) async {
    final next = normalizeAppAutoRefreshMinutes(value);
    _minutesCtrl.text = '$next';
    await ref.read(appAutoRefreshIntervalProvider.notifier).update(next);
  }

  Future<void> _commitInput() async {
    final parsed = int.tryParse(_minutesCtrl.text.trim());
    if (parsed == null) {
      _minutesCtrl.text = '${ref.read(appAutoRefreshIntervalProvider)}';
      return;
    }
    await _setMinutes(parsed);
    _minutesFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = _optionColors(context);
    final theme = shadcn.Theme.of(context);
    final typo = theme.typography;
    final minutes = ref.watch(appAutoRefreshIntervalProvider);

    if (!_minutesFocus.hasFocus && _minutesCtrl.text != '$minutes') {
      _minutesCtrl.text = '$minutes';
    }

    return ExpandableCard(
      title: '自动刷新频率',
      icon: shadcn.LucideIcons.timerReset,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'APP 在前台每隔设定时间自动刷新一次数据；从后台回到前台时也会按同一间隔节流刷新。',
            style: typo.small.copyWith(color: cs.mutedForeground, height: 1.35),
          ),
          const SizedBox(height: 12),
          AppSurfaceContainer(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            borderRadius: _optionRadius(context),
            color: appSurfaceColor(context, cs.card),
            borderColor: cs.border.withValues(alpha: 0.7),
            child: Row(
              children: [
                Icon(
                  shadcn.LucideIcons.clock,
                  size: 18,
                  color: cs.foreground.withValues(alpha: 0.62),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '刷新间隔',
                        style: typo.small.copyWith(
                          color: cs.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        minutes == kDefaultAppAutoRefreshMinutes
                            ? '当前 $minutes 分钟，默认频率'
                            : '当前 $minutes 分钟',
                        style: typo.xSmall.copyWith(color: cs.mutedForeground),
                      ),
                    ],
                  ),
                ),
                shadcn.IconButton.outline(
                  onPressed: minutes <= kMinAppAutoRefreshMinutes
                      ? null
                      : () => _setMinutes(minutes - 1),
                  icon: const Icon(shadcn.LucideIcons.minus, size: 16),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 78,
                  child: ShadTextField(
                    controller: _minutesCtrl,
                    focusNode: _minutesFocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => _commitInput(),
                    features: [
                      shadcn.InputFeature.trailing(
                        Text(
                          '分',
                          style: typo.xSmall.copyWith(
                            color: cs.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                shadcn.IconButton.outline(
                  onPressed: minutes >= kMaxAppAutoRefreshMinutes
                      ? null
                      : () => _setMinutes(minutes + 1),
                  icon: const Icon(shadcn.LucideIcons.plus, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in _presets)
                shadcn.Button.outline(
                  onPressed: minutes == preset
                      ? null
                      : () => _setMinutes(preset),
                  child: Text('$preset 分钟'),
                ),
              shadcn.Button.outline(
                onPressed: minutes == kDefaultAppAutoRefreshMinutes
                    ? null
                    : () => _setMinutes(kDefaultAppAutoRefreshMinutes),
                child: const Text('恢复默认'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BulkUpgradeCard extends ConsumerStatefulWidget {
  const _BulkUpgradeCard();

  @override
  ConsumerState<_BulkUpgradeCard> createState() => _BulkUpgradeCardState();
}

class _BulkUpgradeCardState extends ConsumerState<_BulkUpgradeCard> {
  static const _fieldOptions = <String, String>{
    'user_agent': 'User-Agent',
    'proxy': 'Proxy',
  };

  final _valueCtrl = TextEditingController();
  String _selectedKey = 'user_agent';
  bool _submitting = false;

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = _optionColors(context);

    return ExpandableCard(
      title: '批量替换',
      icon: shadcn.LucideIcons.replace,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '选择要批量更新的字段，并输入新的配置值。值会优先按 JSON 解析，解析失败时按普通字符串提交。',
            style: shadcn.Theme.of(context).typography.small.copyWith(
              color: cs.mutedForeground,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          shadcn.OverlayManagerLayer(
            popoverHandler: const shadcn.PopoverOverlayHandler(),
            tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
            menuHandler: const shadcn.PopoverOverlayHandler(),
            child: SizedBox(
              width: double.infinity,
              child: shadcn.Select<String>(
                value: _selectedKey,
                placeholder: const Text('选择字段'),
                itemBuilder: (_, value) => Text(_fieldOptions[value] ?? value),
                popup: shadcn.SelectPopup<String>(
                  items: shadcn.SelectItemList(
                    children: [
                      for (final entry in _fieldOptions.entries)
                        shadcn.SelectItemButton<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                    ],
                  ),
                ).call,
                onChanged: _submitting
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _selectedKey = value);
                      },
              ),
            ),
          ),
          const SizedBox(height: 10),
          ShadTextField(
            controller: _valueCtrl,
            enabled: !_submitting,
            hintText: _selectedKey == 'user_agent'
                ? 'Mozilla/5.0 ...'
                : 'http://127.0.0.1:7890 或 {"http":"..."}',
            maxLines: _selectedKey == 'user_agent' ? 3 : 2,
            onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: shadcn.Button.destructive(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: shadcn.CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primaryForeground,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(shadcn.LucideIcons.replace, size: 15),
                        SizedBox(width: 6),
                        Text('提交批量替换'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final raw = _valueCtrl.text.trim();
    if (raw.isEmpty) {
      Toast.error('请输入配置值');
      return;
    }

    setState(() => _submitting = true);
    try {
      final success = await ref
          .read(optionProvider.notifier)
          .bulkUpgrade(key: _selectedKey, value: _parseJsonOrReturnString(raw));
      if (success) {
        Toast.success('批量替换任务已提交');
      } else {
        Toast.error('批量替换提交失败');
      }
    } catch (e, st) {
      AppLogger.error('批量替换提交失败', e, st);
      Toast.error('批量替换提交失败');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  dynamic _parseJsonOrReturnString(String value) {
    try {
      return jsonDecode(value);
    } on FormatException {
      return value;
    }
  }
}

class _SpeedTestAction extends StatefulWidget {
  final Future<void> Function() onStart;

  const _SpeedTestAction({required this.onStart});

  @override
  State<_SpeedTestAction> createState() => _SpeedTestActionState();
}

class _SpeedTestActionState extends State<_SpeedTestAction> {
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    final cs = _optionColors(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '提交后端网络测速任务，任务完成后请留意通知。',
          style: shadcn.Theme.of(context).typography.small.copyWith(
            color: cs.foreground.withValues(alpha: 0.52),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: shadcn.Button.primary(
            onPressed: _running
                ? null
                : () async {
                    setState(() => _running = true);
                    try {
                      await widget.onStart();
                    } finally {
                      if (mounted) setState(() => _running = false);
                    }
                  },
            child: _running
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: shadcn.CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _optionColors(context).primaryForeground,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(shadcn.LucideIcons.gauge, size: 15),
                      SizedBox(width: 6),
                      Text('开始测速'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
//  通知测试表单
// ══════════════════════════════════════════════════════════

class _TestNoticeForm extends StatefulWidget {
  final TextEditingController titleCtrl;
  final TextEditingController msgCtrl;
  final VoidCallback onSend;

  const _TestNoticeForm({
    required this.titleCtrl,
    required this.msgCtrl,
    required this.onSend,
  });

  @override
  State<_TestNoticeForm> createState() => _TestNoticeFormState();
}

class _TestNoticeFormState extends State<_TestNoticeForm> {
  bool _sending = false;

  @override
  void dispose() {
    widget.titleCtrl.dispose();
    widget.msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShadTextField(
          controller: widget.titleCtrl,
          hintText: '消息标题',
          onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 10),
        ShadTextField(
          controller: widget.msgCtrl,
          hintText: '消息内容',
          maxLines: 5,
          onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: shadcn.Button.destructive(
            onPressed: _sending
                ? null
                : () async {
                    setState(() => _sending = true);
                    widget.onSend();
                    if (mounted) setState(() => _sending = false);
                  },
            child: _sending
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: shadcn.CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _optionColors(context).primaryForeground,
                    ),
                  )
                : const Text('发送'),
          ),
        ),
      ],
    );
  }
}

class _VersionCard extends StatefulWidget {
  const _VersionCard();

  @override
  State<_VersionCard> createState() => _VersionCardState();
}

class _VersionCardState extends State<_VersionCard> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _info = info);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = _optionColors(context);
    return ExpandableCard(
      title: _info == null ? '关于收割机' : '关于${_info!.appName}',
      icon: shadcn.LucideIcons.info,
      builder: (_) {
        final info = _info;
        if (info == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: shadcn.CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showAboutDialog(context, info),
              child: ClipRRect(
                borderRadius: _optionRadius(context, size: 'lg'),
                child: Image.asset(
                  'assets/images/avatar.png',
                  height: 50,
                  width: 50,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              info.appName,
              style: shadcn.Theme.of(context).typography.large.copyWith(
                color: cs.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${info.appName} 版本: ${info.version}',
              style: shadcn.Theme.of(context).typography.small.copyWith(
                color: cs.foreground.withValues(alpha: 0.45),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.foreground.withValues(alpha: 0.04),
                borderRadius: _optionRadius(context),
              ),
              child: Text(
                'Harvest 本义收割,收获，本软件致力于让你更轻松的玩转国内 PT 站点，与收割机有异曲同工之妙，故此得名。',
                style: shadcn.Theme.of(
                  context,
                ).typography.small.copyWith(color: cs.foreground, height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.foreground.withValues(alpha: 0.04),
                borderRadius: _optionRadius(context),
              ),
              child: Column(
                children: [_infoRow(context, '包名', info.packageName)],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, PackageInfo info) {
    shadcn.showDialog(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        title: Text(info.appName),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/avatar.png', height: 50, width: 50),
              const SizedBox(height: 12),
              Text(
                '版本: ${info.version}',
                style: shadcn.Theme.of(ctx).typography.small.copyWith(
                  color: _optionColors(ctx).mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '© ${DateTime.now().year} ${info.appName}',
                style: shadcn.Theme.of(ctx).typography.xSmall.copyWith(
                  color: _optionColors(ctx).mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Harvest 本义收割,收获，本软件致力于让你更轻松的玩转国内 PT 站点，与收割机有异曲同工之妙，故此得名。',
                style: shadcn.Theme.of(ctx).typography.small.copyWith(
                  color: _optionColors(ctx).foreground,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          shadcn.Button.primary(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final cs = _optionColors(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: shadcn.Theme.of(context).typography.small.copyWith(
            color: cs.foreground.withValues(alpha: 0.4),
          ),
        ),
        Text(
          value,
          style: shadcn.Theme.of(context).typography.small.copyWith(
            color: cs.foreground.withValues(alpha: 0.7),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
//  工具
// ══════════════════════════════════════════════════════════

String _randomString(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}
