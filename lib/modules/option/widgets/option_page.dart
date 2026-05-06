import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/common/style.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/option/widgets/app_upgrade_page.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../provider/option_provider.dart';
import '../service/option_service.dart';
import 'option_form_card.dart';
import 'update_page.dart';
import 'update_panel.dart';

// ══════════════════════════════════════════════════════════
//  表单配置表
// ══════════════════════════════════════════════════════════

final _formConfigs = <String, FormConfig>{
  'monkey_token': FormConfig(
    title: '安全Token',
    icon: FIcons.key,
    textFields: [FormFieldDef('token', '令牌', (v) => v?.token)],
    extraBuilder: (c) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: FButton(
              style: FButtonStyle.destructive(),
              onPress: () {
                c['token']!.text = _randomString(8);
                Clipboard.setData(ClipboardData(text: c['token']!.text));
                Toast.success('已复制到剪贴板');
              },
              child: const Text('随机Token'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FButton(
              style: FButtonStyle.outline(),
              onPress: () {
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
    icon: FIcons.messageCircle,
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
    icon: FIcons.send,
    textFields: [
      FormFieldDef('app_id', '应用 ID', (v) => v?.appId),
      FormFieldDef('token', '令牌', (v) => v?.token),
      FormFieldDef('uids', '接收人', (v) => v?.uids),
    ],
    buildValue: (c, _, v) => v.copyWith(appId: c['app_id']!.text, token: c['token']!.text, uids: c['uids']!.text),
  ),

  'pushdeer_push': FormConfig(
    title: 'PushDeer',
    icon: FIcons.send,
    textFields: [FormFieldDef('key', 'Key', (v) => v?.key), FormFieldDef('proxy', '服务器', (v) => v?.proxy)],
    buildValue: (c, _, v) => v.copyWith(key: c['key']!.text, proxy: c['proxy']!.text),
  ),

  'bark_push': FormConfig(
    title: 'Bark',
    icon: FIcons.bell,
    textFields: [
      FormFieldDef('device_key', '设备ID', (v) => v?.deviceKey),
      FormFieldDef('server', '服务器', (v) => v?.server),
    ],
    buildValue: (c, _, v) => v.copyWith(deviceKey: c['device_key']!.text, server: c['server']!.text),
  ),

  'iyuu_push': FormConfig(
    title: '爱语飞飞',
    icon: FIcons.heart,
    textFields: [FormFieldDef('token', '令牌', (v) => v?.token)],
    switchFields: [SwitchFieldDef('repeat', '辅种开关', (v) => v?.repeat ?? false)],
    buildValue: (c, s, v) => v.copyWith(token: c['token']!.text, repeat: s['repeat']),
  ),

  'meow_push': FormConfig(
    title: '喵呜通知',
    icon: FIcons.bell,
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
    icon: FIcons.bell,
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
    icon: FIcons.send,
    textFields: [FormFieldDef('token', '令牌', (v) => v?.token)],
    buildValue: (c, _, v) => v.copyWith(token: c['token']!.text, template: 'markdown'),
  ),

  'telegram_push': FormConfig(
    title: 'Telegram配置',
    icon: FIcons.send,
    textFields: [
      FormFieldDef('chat_id', 'ID', (v) => v?.telegramChatId),
      FormFieldDef('token', '令牌', (v) => v?.telegramToken),
      FormFieldDef('proxy', '代理', (v) => v?.proxy),
    ],
    buildValue: (c, _, v) =>
        v.copyWith(telegramChatId: c['chat_id']!.text, telegramToken: c['token']!.text, proxy: c['proxy']!.text),
  ),

  'aliyun_drive': FormConfig(
    title: '阿里云盘',
    icon: FIcons.hardDrive,
    textFields: [FormFieldDef('refresh_token', '保存令牌', (v) => v?.refreshToken, maxLines: 3)],
    switchFields: [SwitchFieldDef('welfare', '领取福利', (v) => v?.welfare ?? true)],
    buildValue: (c, s, v) => v.copyWith(refreshToken: c['refresh_token']!.text, welfare: s['welfare']),
  ),

  'baidu_ocr': FormConfig(
    title: '百度 OCR',
    icon: FIcons.scanLine,
    textFields: [
      FormFieldDef('app_id', '应用 ID', (v) => v?.appId),
      FormFieldDef('api_key', 'APIKey', (v) => v?.apiKey),
      FormFieldDef('secret_key', 'Secret', (v) => v?.secretKey),
    ],
    buildValue: (c, _, v) =>
        v.copyWith(appId: c['app_id']!.text, apiKey: c['api_key']!.text, secretKey: c['secret_key']!.text),
  ),

  'ssdforum': FormConfig(
    title: 'SSDForum',
    icon: FIcons.globe,
    textFields: [
      FormFieldDef('cookie', 'Cookie', (v) => v?.cookie, maxLines: 5),
      FormFieldDef('user_agent', 'UserAgent', (v) => v?.userAgent, maxLines: 3),
      FormFieldDef('today_say', '今天想说', (v) => v?.todaySay, maxLines: 5),
    ],
    buildValue: (c, _, v) =>
        v.copyWith(cookie: c['cookie']!.text, userAgent: c['user_agent']!.text, todaySay: c['today_say']!.text),
  ),

  'cookie_cloud': FormConfig(
    title: 'CookieCloud',
    icon: FIcons.cookie,
    textFields: [
      FormFieldDef('server', '服务器', (v) => v?.server),
      FormFieldDef('key', 'Key', (v) => v?.key),
      FormFieldDef('password', '密码', (v) => v?.password),
    ],
    buildValue: (c, _, v) => v.copyWith(server: c['server']!.text, key: c['key']!.text, password: c['password']!.text),
  ),

  'FileList': FormConfig(
    title: 'FileList',
    icon: FIcons.file,
    textFields: [
      FormFieldDef('username', '账号', (v) => v?.username),
      FormFieldDef('password', '密码', (v) => v?.password),
    ],
    buildValue: (c, _, v) => v.copyWith(username: c['username']!.text, password: c['password']!.text),
  ),

  'tmdb_api_auth': FormConfig(
    title: '影视Token配置',
    icon: FIcons.film,
    textFields: [
      FormFieldDef('api_key', 'TMDB密钥', (v) => v?.apiKey),
      FormFieldDef('secret_key', '豆瓣Cookie', (v) => v?.secretKey),
      FormFieldDef('proxy', '代理地址', (v) => v?.proxy),
    ],
    buildValue: (c, _, v) =>
        v.copyWith(apiKey: c['api_key']!.text, secretKey: c['secret_key']!.text, proxy: c['proxy']!.text),
  ),

  'aggregation_search': FormConfig(
    title: '聚合搜索配置',
    icon: FIcons.search,
    textFields: [
      FormFieldDef('max_count', '站点数量限制', (v) => v?.maxCount?.toString(), helperText: '单次搜索的站点数量，0表示不限制'),
      FormFieldDef('limit', '并发数量限制', (v) => v?.limit?.toString(), helperText: '并发搜索站点数量，0表示不限制'),
    ],
    buildValue: (c, _, v) =>
        v.copyWith(maxCount: int.tryParse(c['max_count']!.text) ?? 30, limit: int.tryParse(c['limit']!.text) ?? 30),
  ),

  'notice_category_enable': FormConfig(
    title: '通知开关',
    icon: FIcons.bellRing,
    textFields: const [],
    switchFields: [
      SwitchFieldDef('aliyundrive_notice', '阿里云盘', (v) => v?.aliyundriveNotice ?? true),
      SwitchFieldDef('site_data', '站点数据', (v) => v?.siteData ?? true),
      SwitchFieldDef('site_data_success', '成功站点消息', (v) => v?.siteDataSuccess ?? true),
      SwitchFieldDef('today_data', '今日数据', (v) => v?.todayData ?? true),
      SwitchFieldDef('package_torrent', '拆包', (v) => v?.packageTorrent ?? true),
      SwitchFieldDef('delete_torrent', '删种', (v) => v?.deleteTorrent ?? true),
      SwitchFieldDef('rss_torrent', 'RSS', (v) => v?.rssTorrent ?? true),
      SwitchFieldDef('push_torrent', '种子推送', (v) => v?.pushTorrent ?? true),
      SwitchFieldDef('program_upgrade', 'Docker 升级', (v) => v?.programUpgrade ?? true),
      SwitchFieldDef('ptpp_import', 'PTPP 导入', (v) => v?.ptppImport ?? true),
      SwitchFieldDef('announcement', '公告详情', (v) => v?.announcement ?? true),
      SwitchFieldDef('message', '短消息详情', (v) => v?.message ?? true),
      SwitchFieldDef('sign_in_success', '签到成功消息', (v) => v?.signInSuccess ?? true),
      SwitchFieldDef('cookie_sync', 'CookieCloud 同步', (v) => v?.cookieSync ?? true),
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
    icon: FIcons.layoutList,
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
    icon: FIcons.tags,
    textFields: const [],
    switchFields: [SwitchFieldDef('repeat', '自动添加标签', (v) => v?.repeat ?? false)],
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
    final cs = FTheme.of(context).colors;

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
            '选项设置',
            style: TextStyle(color: cs.foreground, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: Icon(FIcons.refreshCw, size: 18, color: cs.foreground),
              onPressed: () => ref.read(optionProvider.notifier).fetchOptions(),
            ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: FProgress.circularIcon())
            : RefreshIndicator(
                onRefresh: () => ref.read(optionProvider.notifier).fetchOptions(),
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  children: [
                    // ── 版本信息 ──
                    _buildVersionCard(context),
                    _buildAppUpgradeCard(context),
                    _buildUpdateCard(context),
                    const _CookieBackupImportCard(),
                    _buildSpeedTest(context, ref),
                    // ── 通知测试 ──
                    _buildNoticeTest(context, ref),
                    _buildTelegramWebhook(context, ref),
                    // ── 所有配置项 ──
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
      icon: FIcons.download,
      builder: (collapse) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const UpdatePanel(maxCommitCount: 12),
          const SizedBox(height: 8),
          SizedBox(
            width: 190,
            child: FButton(
              style: FButtonStyle.outline(_compactButtonBase),
              onPress: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UpdatePage())),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [Icon(FIcons.externalLink, size: 15), SizedBox(width: 6), Text('打开完整更新页面')],
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
      icon: FIcons.gauge,
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
      icon: FIcons.send,
      builder: (collapse) {
        final urlCtrl = TextEditingController();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FTextField(controller: urlCtrl, hint: 'WebHook地址 (https://...)'),
            const SizedBox(height: 6),
            Text(
              '请仅输入域名部分，端口必须是【80、443、8080、8443】之一',
              style: TextStyle(color: FTheme.of(context).colors.foreground.withOpacity(0.35), fontSize: 11),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FButton(
                style: FButtonStyle.destructive(),
                onPress: () async {
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
                  if (!host.contains('.') || host.startsWith('.') || host.endsWith('.')) {
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
                  final success = await ref.read(optionProvider.notifier).setTelegramWebhook(normalized);
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
      icon: FIcons.bellRing,
      builder: (collapse) {
        final titleCtrl = TextEditingController(text: '这是一个消息标题');
        final msgCtrl = TextEditingController(text: '*这是一条测试消息*\n__这是二号标题__\n```这是消息```');
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

// ══════════════════════════════════════════════════════════
//  站点备份导入
// ══════════════════════════════════════════════════════════

class _CookieBackupImportCard extends ConsumerStatefulWidget {
  const _CookieBackupImportCard();

  @override
  ConsumerState<_CookieBackupImportCard> createState() => _CookieBackupImportCardState();
}

class _CookieBackupImportCardState extends ConsumerState<_CookieBackupImportCard> {
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
      AppLogger.info('提交 ${source.label} 备份导入: file=${file.name}, size=${file.size}');
      final message = await ref.read(optionProvider.notifier).importCookieBackup(file: file, source: source);
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
      icon: FIcons.fileUp,
      builder: (_) => FTileGroup(
        style: fTileGroupStyle(context, borderRadius: 8).call,
        children: [
          _buildSourceTile(context, CookieBackupSource.ptpp),
          _buildSourceTile(context, CookieBackupSource.ptd),
          _buildCookieCloudTile(context),
        ],
      ),
    );
  }

  FTile _buildSourceTile(BuildContext context, CookieBackupSource source) {
    final cs = FTheme.of(context).colors;
    final isUploading = _uploading == source;
    final enabled = !_busy;
    final color = isUploading
        ? cs.primary
        : enabled
        ? cs.foreground.withOpacity(0.62)
        : cs.mutedForeground;

    return FTile(
      enabled: enabled,
      onPress: enabled ? () => _pickAndUpload(source) : null,
      prefix: Icon(FIcons.cookie, size: 18, color: color),
      title: Text('${source.label} 导入'),
      subtitle: const Text('从备份文件导入站点'),
      suffix: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: isUploading
              ? const SizedBox(width: 16, height: 16, child: FProgress.circularIcon())
              : Icon(FIcons.fileUp, size: 17, color: color),
        ),
      ),
    );
  }

  FTile _buildCookieCloudTile(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final enabled = !_busy;
    final color = _syncingCookieCloud
        ? cs.primary
        : enabled
        ? cs.foreground.withOpacity(0.62)
        : cs.mutedForeground;

    return FTile(
      enabled: enabled,
      onPress: enabled ? _syncCookieCloud : null,
      prefix: Icon(FIcons.cloud, size: 18, color: color),
      title: const Text('CookieCloud 同步'),
      subtitle: const Text('直接从 CookieCloud 同步站点'),
      suffix: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: _syncingCookieCloud
              ? const SizedBox(width: 16, height: 16, child: FProgress.circularIcon())
              : Icon(FIcons.refreshCw, size: 17, color: color),
        ),
      ),
    );
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
    final cs = FTheme.of(context).colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '提交后端网络测速任务，任务完成后请留意通知。',
          style: TextStyle(color: cs.foreground.withOpacity(0.52), fontSize: 12, height: 1.35),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FButton(
            onPress: _running
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
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(FIcons.gauge, size: 15), SizedBox(width: 6), Text('开始测速')],
                  ),
          ),
        ),
      ],
    );
  }
}

FButtonStyle _compactButtonBase(FButtonStyle style) {
  return style.copyWith(
    contentStyle: (content) => content.copyWith(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
  );
}

// ══════════════════════════════════════════════════════════
//  通知测试表单
// ══════════════════════════════════════════════════════════

class _TestNoticeForm extends StatefulWidget {
  final TextEditingController titleCtrl;
  final TextEditingController msgCtrl;
  final VoidCallback onSend;

  const _TestNoticeForm({required this.titleCtrl, required this.msgCtrl, required this.onSend});

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
        FTextField(controller: widget.titleCtrl, hint: '消息标题'),
        const SizedBox(height: 10),
        FTextField(controller: widget.msgCtrl, hint: '消息内容', maxLines: 5),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FButton(
            style: FButtonStyle.destructive(),
            onPress: _sending
                ? null
                : () async {
                    setState(() => _sending = true);
                    widget.onSend();
                    if (mounted) setState(() => _sending = false);
                  },
            child: _sending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
    final cs = FTheme.of(context).colors;
    return ExpandableCard(
      title: _info == null ? '关于收割机' : '关于${_info!.appName}',
      icon: FIcons.info,
      builder: (_) {
        final info = _info;
        if (info == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(child: FProgress.circularIcon()),
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
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/avatar.png', height: 50, width: 50),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              info.appName,
              style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${info.appName} 版本: ${info.version}',
              style: TextStyle(
                color: cs.foreground.withOpacity(0.45),
                fontSize: 12,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: cs.foreground.withOpacity(0.04), borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Harvest 本义收割,收获，本软件致力于让你更轻松的玩转国内 PT 站点，与收割机有异曲同工之妙，故此得名。',
                style: TextStyle(color: cs.foreground, fontSize: 12, height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cs.foreground.withOpacity(0.04), borderRadius: BorderRadius.circular(8)),
              child: Column(children: [_infoRow(context, '包名', info.packageName)]),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, PackageInfo info) {
    showAboutDialog(
      context: context,
      applicationName: info.appName,
      applicationVersion: info.version,
      applicationLegalese: '© ${DateTime.now().year} ${info.appName}',
      applicationIcon: Image.asset('assets/images/avatar.png', height: 50, width: 50),
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Harvest 本义收割,收获，本软件致力于让你更轻松的玩转国内 PT 站点，与收割机有异曲同工之妙，故此得名。',
            style: TextStyle(color: FTheme.of(context).colors.foreground),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final cs = FTheme.of(context).colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: cs.foreground.withOpacity(0.4), fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: cs.foreground.withOpacity(0.7),
            fontSize: 12,
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
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
}
