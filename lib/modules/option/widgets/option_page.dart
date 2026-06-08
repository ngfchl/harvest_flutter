import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/provider/app_auto_refresh_provider.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/news/provider/media_info_settings_provider.dart';
import 'package:harvest/modules/option/widgets/app_upgrade_page.dart';
import 'package:harvest/modules/shell/widgets/global_drawer_swipe_area.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/debug_theme_button.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pasteboard/pasteboard.dart';
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

class _ButtonText extends StatelessWidget {
  final String text;

  const _ButtonText(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, textAlign: TextAlign.center));
  }
}

class _ActionButtonFrame extends StatelessWidget {
  final Widget child;
  final double minWidth;
  final double maxWidth;

  const _ActionButtonFrame({
    required this.child,
    this.minWidth = 160,
    this.maxWidth = 260,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return SizedBox(width: double.infinity, child: child);
    }

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
        child: child,
      ),
    );
  }
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
      child: Builder(
        builder: (context) {
          final randomButton = shadcn.Button.destructive(
            onPressed: () async {
              c['token']!.text = _randomString(8);
              await _copyOptionToken(c['token']!.text);
            },
            alignment: Alignment.center,
            child: const _ButtonText('随机Token'),
          );
          final copyButton = shadcn.Button.outline(
            onPressed: () => _copyOptionToken(c['token']!.text),
            alignment: Alignment.center,
            child: const _ButtonText('复制Token'),
          );

          if (context.isMobile) {
            return Row(
              children: [
                Expanded(child: randomButton),
                const SizedBox(width: 8),
                Expanded(child: copyButton),
              ],
            );
          }

          return Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 128),
                  child: randomButton,
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 128),
                  child: copyButton,
                ),
              ],
            ),
          );
        },
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

Future<void> _copyOptionToken(
  String token, {
  String emptyMessage = 'Token 为空',
  String logLabel = 'Token',
}) async {
  final value = token.trim();
  if (value.isEmpty) {
    Toast.error(emptyMessage);
    return;
  }

  try {
    if (kIsWeb) {
      Pasteboard.writeText(value);
    } else {
      await Clipboard.setData(ClipboardData(text: value));
    }
    Toast.success('已复制到剪贴板');
  } catch (e, st) {
    AppLogger.error('复制 $logLabel 失败', e, st);
    Toast.error('复制失败，请手动复制');
  }
}

// ══════════════════════════════════════════════════════════
//  设置页面
// ══════════════════════════════════════════════════════════

class OptionPage extends ConsumerStatefulWidget {
  const OptionPage({super.key});

  @override
  ConsumerState<OptionPage> createState() => _OptionPageState();
}

class _OptionPageState extends ConsumerState<OptionPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(optionProvider);
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final isServerTab = _tabIndex == 0;

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: GlobalDrawerSwipeArea(
        child: AppBackground(
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: SizedBox(
                  height: kAppHeaderHeight,
                  child: Padding(
                    padding: appHeaderPadding(context, top: 6, bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        shadcn.IconButton.ghost(
                          icon: const Icon(
                            shadcn.LucideIcons.arrowLeft,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            '选项设置',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typo.large.copyWith(
                              color: cs.foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const DebugThemeButton.shadcn(),
                        if (isServerTab)
                          shadcn.IconButton.ghost(
                            icon: const Icon(
                              shadcn.LucideIcons.refreshCw,
                              size: 18,
                            ),
                            onPressed: () => ref
                                .read(optionProvider.notifier)
                                .fetchOptions(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  context.isMobile ? 12 : 16,
                  2,
                  context.isMobile ? 12 : 16,
                  8,
                ),
                decoration: BoxDecoration(
                  color: appSurfaceColor(context, cs.background),
                  border: Border(
                    bottom: BorderSide(color: cs.border, width: 0.5),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: shadcn.Tabs(
                    index: _tabIndex,
                    onChanged: (index) => setState(() => _tabIndex = index),
                    children: const [
                      shadcn.TabItem(child: Text('服务器设置')),
                      shadcn.TabItem(child: Text('常用工具')),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: isServerTab
                    ? _buildServerSettings(context, state)
                    : _buildCommonTools(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerSettings(BuildContext context, OptionState state) {
    if (state.isLoading) {
      return const OptionLoadingState(label: '正在加载设置...');
    }

    return EasyRefresh(
      onRefresh: () => ref.read(optionProvider.notifier).fetchOptions(),
      header: appRefreshHeader(context),
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        children: [
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
                return ref.read(optionProvider.notifier).saveOption(opt);
              },
              onToggleActive: serverOption != null
                  ? (opt) async {
                      await ref.read(optionProvider.notifier).saveOption(opt);
                    }
                  : null,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommonTools(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      children: [
        _buildVersionCard(context),
        if (!kIsWeb) _buildAppUpgradeCard(context),
        _buildUpdateCard(context),
        const _DataImportExportCard(),
        const _AppAutoRefreshIntervalCard(),
        const _MediaInfoSettingsCard(),
        _buildSpeedTest(context, ref),
        _buildNoticeTest(context, ref),
        const _BulkUpgradeCard(),
        _buildTelegramWebhook(context, ref),
        const _InviteTokenToolCard(),
      ],
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
              alignment: Alignment.center,
              child: const Center(
                child: Row(
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
      builder: (collapse) => _TelegramWebhookForm(
        onSubmit: (normalized) async {
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
      ),
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

class _InviteTokenSite {
  final String label;
  final String baseUrl;

  const _InviteTokenSite({required this.label, required this.baseUrl});
}

const _inviteTokenSites = [
  _InviteTokenSite(label: '药丸', baseUrl: 'https://www.invites.fun/'),
  _InviteTokenSite(label: '蜂巢', baseUrl: 'https://pting.club/'),
];

class _InviteTokenToolCard extends StatefulWidget {
  const _InviteTokenToolCard();

  @override
  State<_InviteTokenToolCard> createState() => _InviteTokenToolCardState();
}

class _InviteTokenToolCardState extends State<_InviteTokenToolCard> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _dio = Dio();

  _InviteTokenSite _selectedSite = _inviteTokenSites.first;
  bool _loading = false;
  String? _token;
  String? _uid;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = _optionColors(context);
    final typo = shadcn.Theme.of(context).typography;

    return ExpandableCard(
      title: '药丸/蜂巢 Token',
      icon: shadcn.LucideIcons.keyRound,
      builder: (_) => OptionLoadingOverlay(
        loading: _loading,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            shadcn.OverlayManagerLayer(
              popoverHandler: const shadcn.PopoverOverlayHandler(),
              tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
              menuHandler: const shadcn.PopoverOverlayHandler(),
              child: shadcn.Select<String>(
                value: _selectedSite.baseUrl,
                placeholder: const Text('选择站点'),
                itemBuilder: (_, value) => Text(_siteLabel(value)),
                popup: shadcn.SelectPopup<String>(
                  items: shadcn.SelectItemList(
                    children: [
                      for (final site in _inviteTokenSites)
                        shadcn.SelectItemButton<String>(
                          value: site.baseUrl,
                          child: Text(site.label),
                        ),
                    ],
                  ),
                ).call,
                onChanged: _loading
                    ? null
                    : (value) {
                        final next = _inviteTokenSites
                            .where((site) => site.baseUrl == value)
                            .firstOrNull;
                        if (next == null) return;
                        setState(() => _selectedSite = next);
                      },
              ),
            ),
            const SizedBox(height: 10),
            ShadTextField(
              controller: _usernameCtrl,
              enabled: !_loading,
              labelText: '用户名',
              hintText: '请输入站点用户名',
              helperText: '用于登录所选站点的用户名或账号',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            ShadTextField(
              controller: _passwordCtrl,
              enabled: !_loading,
              labelText: '密码',
              hintText: '请输入站点密码',
              helperText: '用于登录所选站点的密码，仅用于本次请求',
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _fetchToken(),
            ),
            const SizedBox(height: 12),
            _ActionButtonFrame(
              child: shadcn.Button.primary(
                onPressed: _loading ? null : _fetchToken,
                alignment: Alignment.center,
                child: const _ButtonText('获取 Token'),
              ),
            ),
            if (_token != null || _uid != null) ...[
              const SizedBox(height: 12),
              AppSurfaceContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: _optionRadius(context),
                color: appSurfaceColor(context, cs.card),
                borderColor: cs.border.withValues(alpha: 0.7),
                child: Column(
                  children: [
                    if (_token != null)
                      _InviteTokenResultRow(
                        label: 'Token',
                        value: _token!,
                        onCopy: () => _copyOptionToken(_token!),
                      ),
                    if (_token != null && _uid != null)
                      Divider(color: cs.border.withValues(alpha: 0.7)),
                    if (_uid != null)
                      _InviteTokenResultRow(
                        label: 'UID',
                        value: _uid!,
                        onCopy: () => _copyOptionToken(
                          _uid!,
                          emptyMessage: 'UID 为空',
                          logLabel: 'UID',
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${_selectedSite.label} 接口: ${_tokenEndpoint(_selectedSite.baseUrl)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.xSmall.copyWith(color: cs.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  String _siteLabel(String? baseUrl) {
    return _inviteTokenSites
            .where((site) => site.baseUrl == baseUrl)
            .map((site) => site.label)
            .firstOrNull ??
        '选择站点';
  }

  Future<void> _fetchToken() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty) {
      Toast.error('请输入用户名');
      return;
    }
    if (password.isEmpty) {
      Toast.error('请输入密码');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _loading = true;
      _token = null;
      _uid = null;
    });

    try {
      final response = await _dio.post(
        _tokenEndpoint(_selectedSite.baseUrl),
        data: {'identification': username, 'password': password, 'remember': 1},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final data = _decodeResponseData(response.data);
      final token = _findValue(data, const [
        'token',
        'access_token',
        'api_token',
      ]);
      final uid = _findValue(data, const ['uid', 'userId', 'user_id', 'id']);

      if (token == null && uid == null) {
        Toast.error('获取成功，但未识别到 Token 或 UID');
        return;
      }

      if (!mounted) return;
      setState(() {
        _token = token;
        _uid = uid;
      });
      Toast.success('获取成功');
    } catch (e, st) {
      AppLogger.error('${_selectedSite.label} Token 获取失败', e, st);
      Toast.error(_errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _tokenEndpoint(String baseUrl) {
    return Uri.parse(baseUrl).resolve('/api/token').toString();
  }

  dynamic _decodeResponseData(dynamic data) {
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }

  String? _findValue(dynamic data, List<String> keys) {
    if (data is Map) {
      for (final entry in data.entries) {
        final key = entry.key.toString();
        if (keys.any(
          (candidate) => candidate.toLowerCase() == key.toLowerCase(),
        )) {
          final value = entry.value;
          if (value != null && value.toString().trim().isNotEmpty) {
            return value.toString();
          }
        }
      }
      for (final value in data.values) {
        final nested = _findValue(value, keys);
        if (nested != null) return nested;
      }
    } else if (data is List) {
      for (final item in data) {
        final nested = _findValue(item, keys);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final data = _decodeResponseData(error.response?.data);
      final message = _findValue(data, const ['message', 'msg', 'error']);
      if (message != null) return message;
      final statusCode = error.response?.statusCode;
      if (statusCode != null) return '请求失败: $statusCode';
    }
    return 'Token 获取失败';
  }
}

class _InviteTokenResultRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _InviteTokenResultRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final cs = _optionColors(context);
    final typo = shadcn.Theme.of(context).typography;

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: typo.small.copyWith(
              color: cs.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: typo.small.copyWith(color: cs.mutedForeground),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        shadcn.IconButton.outline(
          icon: const Icon(shadcn.LucideIcons.copy, size: 16),
          onPressed: onCopy,
        ),
      ],
    );
  }
}

class _TelegramWebhookForm extends StatefulWidget {
  final Future<void> Function(String normalized) onSubmit;

  const _TelegramWebhookForm({required this.onSubmit});

  @override
  State<_TelegramWebhookForm> createState() => _TelegramWebhookFormState();
}

class _TelegramWebhookFormState extends State<_TelegramWebhookForm> {
  final _urlCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OptionLoadingOverlay(
      loading: _saving,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShadTextField(
            controller: _urlCtrl,
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
          _ActionButtonFrame(
            child: shadcn.Button.destructive(
              onPressed: _saving ? null : _submit,
              alignment: Alignment.center,
              child: const _ButtonText('保存'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final raw = _urlCtrl.text.trim();
    if (raw.isEmpty) {
      Toast.error('请输入 WebHook 地址');
      return;
    }
    if (!raw.startsWith('https://')) {
      Toast.error('必须使用 https 协议');
      return;
    }

    final normalized = raw.endsWith('/') ? raw : '$raw/';
    Uri uri;
    try {
      uri = Uri.parse(normalized);
    } catch (_) {
      Toast.error('地址格式不正确');
      return;
    }

    if (uri.scheme != 'https') {
      Toast.error('必须使用 https 协议');
      return;
    }
    if (uri.userInfo.isNotEmpty) {
      Toast.error('地址中不允许包含用户名或密码');
      return;
    }

    final host = uri.host;
    if (host.isEmpty) {
      Toast.error('请输入有效的域名');
      return;
    }
    if (host.contains(' ') || host.contains('..')) {
      Toast.error('域名格式不正确');
      return;
    }
    if (!host.contains('.') || host.startsWith('.') || host.endsWith('.')) {
      Toast.error('请输入有效的域名，如 example.com');
      return;
    }
    if (uri.query.isNotEmpty || uri.fragment.isNotEmpty) {
      Toast.error('地址中不允许包含查询参数或锚点');
      return;
    }

    const allowedPorts = [0, 80, 443, 8080, 8443];
    if (!allowedPorts.contains(uri.port)) {
      Toast.error('端口必须是 80、443、8080、8443 之一');
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSubmit(normalized);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _MediaInfoSettingsCard extends ConsumerStatefulWidget {
  const _MediaInfoSettingsCard();

  @override
  ConsumerState<_MediaInfoSettingsCard> createState() =>
      _MediaInfoSettingsCardState();
}

class _MediaInfoSettingsCardState
    extends ConsumerState<_MediaInfoSettingsCard> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(mediaInfoSettingsProvider);
    final notifier = ref.read(mediaInfoSettingsProvider.notifier);
    final theme = shadcn.Theme.of(context);
    final cs = _optionColors(context);
    final typo = theme.typography;

    Widget row({
      required String title,
      required String subtitle,
      required bool value,
      required Future<void> Function(bool value) onChanged,
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
            shadcn.Switch(
              value: value,
              onChanged: _saving
                  ? null
                  : (next) async {
                      setState(() => _saving = true);
                      try {
                        await onChanged(next);
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
            ),
          ],
        ),
      );
    }

    return ExpandableCard(
      title: '影视资讯',
      icon: shadcn.LucideIcons.newspaper,
      builder: (_) => OptionLoadingOverlay(
        loading: _saving,
        child: Column(
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
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  数据导入导出
// ══════════════════════════════════════════════════════════

class _DataImportExportCard extends ConsumerStatefulWidget {
  const _DataImportExportCard();

  @override
  ConsumerState<_DataImportExportCard> createState() =>
      _DataImportExportCardState();
}

class _DataImportExportCardState extends ConsumerState<_DataImportExportCard> {
  final _baseUrlCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  CookieBackupSource? _uploading;
  PlatformFile? _sqliteFile;
  final _externalFiles = <CookieBackupSource, PlatformFile>{};
  bool _exportingBackup = false;
  bool _importingBackup = false;
  bool _syncingCookieCloud = false;
  bool _importingApi = false;
  bool _importingSqlite = false;

  bool get _busy =>
      _uploading != null ||
      _exportingBackup ||
      _importingBackup ||
      _syncingCookieCloud ||
      _importingApi ||
      _importingSqlite;

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

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
    setState(() => _externalFiles[source] = file);
    final confirmed = await _confirmFileImport(
      title: '${source.label} 导入',
      file: file,
      message: '确定导入「${file.name}」吗？',
      confirmText: '确认导入',
    );
    if (!confirmed) {
      if (mounted) {
        setState(() => _externalFiles.remove(source));
      }
      return;
    }
    if (!mounted) return;

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

    final confirmed = await _confirmAction(
      title: 'CookieCloud 同步',
      message: '确定从 CookieCloud 同步站点数据吗？',
      confirmText: '确认同步',
      icon: shadcn.LucideIcons.cloud,
    );
    if (!confirmed || !mounted) return;

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

  Future<void> _exportDataBackup() async {
    if (_busy) return;

    setState(() => _exportingBackup = true);
    try {
      AppLogger.info('开始导出数据备份');
      final backup = await ref.read(optionProvider.notifier).exportBackup();
      if (!mounted) return;

      if (backup == null) {
        Toast.error('导出数据备份失败');
        return;
      }

      final path = await FilePicker.saveFile(
        dialogTitle: '保存数据备份',
        fileName: backup.fileName,
        type: FileType.custom,
        allowedExtensions: const ['zip'],
        bytes: backup.bytes,
      );
      if (!mounted) return;

      if (path != null) {
        Toast.success('数据备份已导出');
      }
    } on PlatformException catch (e) {
      AppLogger.error('保存数据备份失败: code=${e.code}', e);
      if (mounted) Toast.error('保存数据备份失败: ${e.message ?? e.code}');
    } catch (e, st) {
      AppLogger.error('导出数据备份失败', e, st);
      if (mounted) Toast.error('导出数据备份失败');
    } finally {
      if (mounted) setState(() => _exportingBackup = false);
    }
  }

  Future<void> _pickAndImportDataBackup() async {
    if (_busy) return;

    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: const ['zip'],
      );
    } on PlatformException catch (e) {
      AppLogger.error('选择数据备份文件失败', e);
      Toast.error('选择文件失败: ${e.message ?? e.code}');
      return;
    } catch (e, st) {
      AppLogger.error('选择数据备份文件失败', e, st);
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

    setState(() => _importingBackup = true);
    try {
      AppLogger.info('提交数据备份导入: file=${file.name}, size=${file.size}');
      final message = await ref
          .read(optionProvider.notifier)
          .importBackup(file: file);
      if (!mounted) return;

      if (message == null) {
        Toast.error('导入数据备份失败');
      } else {
        Toast.success(message);
      }
    } catch (e, st) {
      AppLogger.error('导入数据备份失败', e, st);
      if (mounted) Toast.error('导入数据备份失败');
    } finally {
      if (mounted) setState(() => _importingBackup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      title: '数据导入导出',
      icon: shadcn.LucideIcons.databaseBackup,
      builder: (_) => OptionLoadingOverlay(
        loading: _busy,
        child: SizedBox(
          width: double.infinity,
          child: shadcn.Accordion(
            items: [
              shadcn.AccordionItem(
                expanded: true,
                trigger: const shadcn.AccordionTrigger(child: Text('导入导出')),
                content: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildImportExportContent(context),
                ),
              ),
              shadcn.AccordionItem(
                trigger: const shadcn.AccordionTrigger(child: Text('数据库文件导入')),
                content: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSqliteImportContent(context),
                ),
              ),
              shadcn.AccordionItem(
                trigger: const shadcn.AccordionTrigger(child: Text('外部数据导入')),
                content: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildExternalDataImportContent(context),
                ),
              ),
              shadcn.AccordionItem(
                trigger: const shadcn.AccordionTrigger(child: Text('旧版接口迁移')),
                content: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildLegacyApiMigrationContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportExportContent(BuildContext context) {
    if (context.isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDataBackupExportTile(context),
          const SizedBox(height: 8),
          _buildDataBackupImportTile(context),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildDataBackupExportTile(context)),
        const SizedBox(width: 8),
        Expanded(child: _buildDataBackupImportTile(context)),
      ],
    );
  }

  Widget _buildExternalDataImportContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSourceTile(context, CookieBackupSource.ptpp),
        const SizedBox(height: 8),
        _buildSourceTile(context, CookieBackupSource.ptd),
        const SizedBox(height: 8),
        _buildCookieCloudTile(context),
      ],
    );
  }

  Widget _buildSqliteImportContent(BuildContext context) {
    return _buildSqliteFilePickerTile(context);
  }

  Widget _buildSqliteFilePickerTile(BuildContext context) {
    final cs = _optionColors(context);
    final typo = shadcn.Theme.of(context).typography;
    final file = _sqliteFile;
    final fileColor = file == null ? cs.mutedForeground : cs.foreground;

    return Opacity(
      opacity: _busy ? 0.55 : 1,
      child: shadcn.Button.ghost(
        onPressed: _busy ? null : _pickSqliteFile,
        child: AppSurfaceContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: _optionRadius(context),
          color: appSurfaceColor(context, cs.card),
          borderColor: cs.border.withValues(alpha: 0.7),
          child: Row(
            children: [
              Icon(
                shadcn.LucideIcons.databaseZap,
                size: 18,
                color: fileColor.withValues(alpha: file == null ? 1 : 0.72),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file?.name ?? '未选择数据库文件',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.small.copyWith(
                        color: fileColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      file == null
                          ? '仅支持 .sqlite3 文件'
                          : '${formatBytes(file.size)}，仅会作为 file 字段上传',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.xSmall.copyWith(color: cs.mutedForeground),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                shadcn.LucideIcons.folderOpen,
                size: 17,
                color: _busy
                    ? cs.mutedForeground
                    : cs.foreground.withValues(alpha: 0.62),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegacyApiMigrationContent(BuildContext context) {
    final submitButton = _buildLegacyApiSubmitButton();

    final tokenRow = context.isMobile
        ? <Widget>[
            ShadTextField(
              controller: _tokenCtrl,
              enabled: !_busy,
              placeholder: const Text('安全 Token'),
              obscureText: true,
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const SizedBox(height: 10),
            submitButton,
          ]
        : <Widget>[
            Row(
              children: [
                Expanded(
                  child: ShadTextField(
                    controller: _tokenCtrl,
                    enabled: !_busy,
                    placeholder: const Text('安全 Token'),
                    obscureText: true,
                    onSubmitted: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 150,
                    maxWidth: 190,
                  ),
                  child: submitButton,
                ),
              ],
            ),
          ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadTextField(
          controller: _baseUrlCtrl,
          enabled: !_busy,
          placeholder: const Text('收割机服务器地址，例如 https://example.com'),
          keyboardType: TextInputType.url,
          onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 10),
        ...tokenRow,
      ],
    );
  }

  Widget _buildLegacyApiSubmitButton() {
    return shadcn.Button.destructive(
      onPressed: _busy ? null : _submitLegacyApiMigration,
      alignment: Alignment.center,
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(shadcn.LucideIcons.databaseBackup, size: 15),
            SizedBox(width: 6),
            Text('开始导入'),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBackupExportTile(BuildContext context) {
    final cs = _optionColors(context);
    final enabled = !_busy;
    final color = _exportingBackup
        ? cs.primary
        : enabled
        ? cs.foreground.withValues(alpha: 0.62)
        : cs.mutedForeground;

    return _ImportActionTile(
      enabled: enabled,
      onTap: enabled ? _exportDataBackup : null,
      leading: Icon(shadcn.LucideIcons.databaseBackup, size: 18, color: color),
      title: '导出数据备份',
      subtitle: '下载完整数据备份 .zip 文件',
      trailing: Icon(shadcn.LucideIcons.download, size: 17, color: color),
    );
  }

  Widget _buildDataBackupImportTile(BuildContext context) {
    final cs = _optionColors(context);
    final enabled = !_busy;
    final color = _importingBackup
        ? cs.primary
        : enabled
        ? cs.foreground.withValues(alpha: 0.62)
        : cs.mutedForeground;

    return _ImportActionTile(
      enabled: enabled,
      onTap: enabled ? _pickAndImportDataBackup : null,
      leading: Icon(shadcn.LucideIcons.archiveRestore, size: 18, color: color),
      title: '导入数据备份',
      subtitle: '从 .zip 文件恢复数据',
      trailing: Icon(shadcn.LucideIcons.upload, size: 17, color: color),
    );
  }

  Widget _buildSourceTile(BuildContext context, CookieBackupSource source) {
    final cs = _optionColors(context);
    final isUploading = _uploading == source;
    final enabled = !_busy;
    final file = _externalFiles[source];
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
      subtitle: file == null
          ? '从备份文件导入站点'
          : '${file.name} · ${formatBytes(file.size)}',
      trailing: Icon(shadcn.LucideIcons.fileUp, size: 17, color: color),
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
      trailing: Icon(shadcn.LucideIcons.refreshCw, size: 17, color: color),
    );
  }

  Future<bool> _confirmFileImport({
    required String title,
    required PlatformFile file,
    required String message,
    required String confirmText,
    IconData icon = shadcn.LucideIcons.fileUp,
  }) {
    return _confirmAction(
      title: title,
      message: '$message\n文件大小: ${formatBytes(file.size)}',
      confirmText: confirmText,
      icon: icon,
    );
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmText,
    required IconData icon,
  }) async {
    final result = await shadcn.showDialog<bool>(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        leading: Icon(icon),
        title: Text(title),
        content: SizedBox(width: 360, child: Text(message)),
        actions: [
          shadcn.Button.outline(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          shadcn.Button.primary(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _pickSqliteFile() async {
    if (_busy) return;

    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: const ['sqlite3'],
      );
    } on PlatformException catch (e) {
      AppLogger.error('选择 sqlite3 数据库文件失败', e);
      Toast.error('选择文件失败: ${e.message ?? e.code}');
      return;
    } catch (e, st) {
      AppLogger.error('选择 sqlite3 数据库文件失败', e, st);
      Toast.error('选择文件失败');
      return;
    }

    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    final file = result.files.single;
    if (!_isSqlite3File(file)) {
      Toast.error('请选择 .sqlite3 数据库文件');
      return;
    }
    if (file.path == null && file.bytes == null) {
      Toast.error('无法读取所选文件');
      return;
    }

    setState(() => _sqliteFile = file);
    final confirmed = await _confirmFileImport(
      title: '数据库文件导入',
      file: file,
      message: '确定导入旧版数据库「${file.name}」吗？',
      confirmText: '确认导入',
      icon: shadcn.LucideIcons.databaseZap,
    );
    if (!confirmed) {
      if (mounted) setState(() => _sqliteFile = null);
      return;
    }
    if (!mounted) return;

    await _submitSqlite(file);
  }

  bool _isSqlite3File(PlatformFile file) {
    return file.name.trim().toLowerCase().endsWith('.sqlite3');
  }

  Future<void> _submitSqlite(PlatformFile file) async {
    if (!_isSqlite3File(file)) {
      Toast.error('请选择 .sqlite3 数据库文件');
      return;
    }

    setState(() => _importingSqlite = true);
    try {
      AppLogger.info(
        '提交旧版 sqlite3 数据库导入: file=${file.name}, size=${file.size}',
      );
      final message = await ref
          .read(optionProvider.notifier)
          .importLegacySqlite(file: file);
      if (!mounted) return;

      if (message == null) {
        Toast.error('旧版数据库导入失败');
      } else {
        Toast.success(message);
      }
    } catch (e, st) {
      AppLogger.error('旧版数据库导入失败', e, st);
      if (mounted) Toast.error('旧版数据库导入失败');
    } finally {
      if (mounted) setState(() => _importingSqlite = false);
    }
  }

  Future<void> _submitLegacyApiMigration() async {
    final baseUrl = _baseUrlCtrl.text.trim();
    final token = _tokenCtrl.text.trim();
    if (baseUrl.isEmpty) {
      Toast.error('请输入收割机服务器地址');
      return;
    }
    if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
      Toast.error('服务器地址必须以 http:// 或 https:// 开头');
      return;
    }
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty) {
      Toast.error('请输入有效的收割机服务器地址');
      return;
    }
    if (token.isEmpty) {
      Toast.error('请输入安全 Token');
      return;
    }

    setState(() => _importingApi = true);
    try {
      final success = await ref
          .read(optionProvider.notifier)
          .importLegacyHarvestData(baseUrl: baseUrl, legacyToken: token);
      if (success) {
        Toast.success('收割机数据导入任务已提交');
      } else {
        Toast.error('收割机数据导入失败');
      }
    } catch (e, st) {
      AppLogger.error('收割机数据导入失败', e, st);
      Toast.error('收割机数据导入失败');
    } finally {
      if (mounted) setState(() => _importingApi = false);
    }
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
  bool _updating = false;

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
    if (_updating) return;
    final next = normalizeAppAutoRefreshMinutes(value);
    _minutesCtrl.text = '$next';
    setState(() => _updating = true);
    try {
      await ref.read(appAutoRefreshIntervalProvider.notifier).update(next);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
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
      builder: (_) => OptionLoadingOverlay(
        loading: _updating,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'APP 在前台每隔设定时间自动刷新一次数据；从后台回到前台时也会按同一间隔节流刷新。',
              style: typo.small.copyWith(
                color: cs.mutedForeground,
                height: 1.35,
              ),
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
                        Text(
                          minutes == kDefaultAppAutoRefreshMinutes
                              ? '当前 $minutes 分钟，默认频率'
                              : '当前 $minutes 分钟',
                          style: typo.xSmall.copyWith(
                            color: cs.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  shadcn.IconButton.outline(
                    onPressed: minutes <= kMinAppAutoRefreshMinutes || _updating
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
                    onPressed: minutes >= kMaxAppAutoRefreshMinutes || _updating
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
                    onPressed: minutes == preset || _updating
                        ? null
                        : () => _setMinutes(preset),
                    alignment: Alignment.center,
                    child: _ButtonText('$preset 分钟'),
                  ),
                shadcn.Button.outline(
                  onPressed:
                      minutes == kDefaultAppAutoRefreshMinutes || _updating
                      ? null
                      : () => _setMinutes(kDefaultAppAutoRefreshMinutes),
                  alignment: Alignment.center,
                  child: const _ButtonText('恢复默认'),
                ),
              ],
            ),
          ],
        ),
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
      builder: (_) => OptionLoadingOverlay(
        loading: _submitting,
        child: Column(
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
                  itemBuilder: (_, value) =>
                      Text(_fieldOptions[value] ?? value),
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
            _ActionButtonFrame(
              minWidth: 210,
              maxWidth: 260,
              child: shadcn.Button.destructive(
                onPressed: _submitting ? null : _submit,
                alignment: Alignment.center,
                child: const Center(
                  child: Row(
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final raw = _valueCtrl.text;

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

    return OptionLoadingOverlay(
      loading: _running,
      child: Column(
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
          _ActionButtonFrame(
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
              alignment: Alignment.center,
              child: const Center(
                child: Row(
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
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  通知测试表单
// ══════════════════════════════════════════════════════════

class _TestNoticeForm extends StatefulWidget {
  final TextEditingController titleCtrl;
  final TextEditingController msgCtrl;
  final Future<void> Function() onSend;

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
    return OptionLoadingOverlay(
      loading: _sending,
      child: Column(
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
          _ActionButtonFrame(
            child: shadcn.Button.destructive(
              onPressed: _sending
                  ? null
                  : () async {
                      setState(() => _sending = true);
                      await widget.onSend();
                      if (mounted) setState(() => _sending = false);
                    },
              alignment: Alignment.center,
              child: const Center(child: _ButtonText('发送')),
            ),
          ),
        ],
      ),
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
            alignment: Alignment.center,
            child: const _ButtonText('确定'),
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
