import 'dart:math';

import 'package:dio/dio.dart';
import 'package:harvest/core/utils/logging/logging.dart';

const _githubProbePath = 'https://github.com/favicon.ico';

const List<String> githubProxyCandidates = [
  'https://gh-proxy.net/',
  'https://github.cnxiaobai.com/',
  'https://hub.gitmirror.com/',
  'https://www.5555.cab/',
  'https://ghproxy.xiaopa.cc/',
  'https://ghproxy.cfd/',
  'https://ghproxy.cc/',
  'https://ghproxy.monkeyray.net/',
  'https://cf.ghproxy.cc/',
  'https://gitproxy.mrhjx.cn/',
  'https://ghproxy.1888866.xyz/',
  'https://github.mlmle.cn/',
  'https://fastgit.cc/',
  'https://gh.1k.ink/',
  'https://ghproxy.net/',
  'https://github.boringhex.top/',
  'https://ghfast.top/',
  'https://y.whereisdoge.work/',
  'https://ghproxy.imciel.com/',
  'https://xiaomo-station.top/',
  'https://gh.monlor.com/',
  'https://g.blfrp.cn/',
  'https://gh.con.sh/',
  'https://gh.b52m.cn/',
  'https://github.dpik.top/',
  'https://github.geekery.cn/',
  'https://gh.halonice.com/',
  'https://github.limoruirui.com/',
  'https://git.yylx.win/',
  'https://github.tbedu.top/',
  'https://ghproxy.vansour.top/',
  'https://tvv.tw/',
  'https://ghproxy.xzhouqd.com/',
  'https://github-proxy.memory-echoes.cn/',
  'https://gh.catmak.name/',
  'https://hub.ddayh.com/',
  'https://github.ruojian.space/',
  'https://ghproxy.cxkpro.top/',
  'https://ghp.keleyaa.com/',
  'https://github-proxy.lixxing.top/',
  'https://gh.padao.fun/',
  'https://gp.871201.xyz/',
  'https://gh.wsmdn.dpdns.org/',
  'https://ggg.clwap.dpdns.org/',
  'https://gh-proxy.com/',
  'https://gh.dpik.top/',
  'https://gp.zkitefly.eu.org/',
  'https://gh.bugdey.us.kg/',
  'https://code-hub-hk.freexy.top/',
  'https://github.chenc.dev/',
  'https://ghfile.geekertao.top/',
  'https://kenyu.ggff.net/',
  'https://gh.nxnow.top/',
  'https://github.bullb.net/',
  'https://gitproxy.197545.xyz/',
  'https://gitproxy.127731.xyz/',
  'https://gitproxy1.127731.xyz/',
  'https://jiashu.1win.eu.org/',
  'https://ghproxy.mf-dust.dpdns.org/',
  'https://j.1lin.dpdns.org/',
  'https://gh.jasonzeng.dev/',
  'https://proxy.baguoyuyan.com/',
  'https://github.1ms.xx.kg/',
  'https://gh.198962.xyz/',
  'https://github.880824.xyz/',
  'https://ghps.cc/',
  'https://30006000.xyz/',
  'https://github.tianrld.top/',
  'https://getgit.love8yun.eu.org/',
  'https://github.788787.xyz/',
  'https://ghm.078465.xyz/',
  'https://github-proxy.com/',
  'https://proxy.yaoyaoling.net/',
  'https://ghproxy.sakuramoe.dev/',
  'https://ghproxy.053000.xyz/',
  'https://gh.chjina.com/',
  'https://git.zeas.cc/',
  'https://ghpxy.hwinzniej.top/',
  'https://gh.echofree.xyz/',
  'https://github.zzrbk.xyz/',
  'https://git.669966.xyz/',
  'https://github.ihnic.com/',
  'https://gh.996986.xyz/',
  'https://gh.idayer.com/',
  'https://github.ednovas.xyz/',
  'https://gh.chalin.tk/',
  'https://j.1win.ggff.net/',
  'https://gh.aaa.team/',
  'https://github.crdz.eu.org/',
  'https://gh.shiina-rimo.cafe/',
  'https://ghproxy.mirror.skybyte.me/',
  'https://gh.llkk.cc/',
  'https://git.40609891.xyz/',
  'https://github.oterea.top/',
  'https://gh.noki.icu/',
  'https://gh.39.al/',
  'https://ghproxy.cn/',
  'https://down.npee.cn/',
  'https://github.kkproxy.dpdns.org/',
  'https://free.cn.eu.org/',
  'https://git.951959483.xyz/',
  'https://git.820828.xyz/',
  'https://ghproxy.fangkuai.fun/',
  'https://github.cn86.dev/',
  'https://github.zjzzy.cloudns.org/',
  'https://ghb.nilive.top/',
  'https://gitproxy.click/',
  'https://proxy.atoposs.com/',
];

Future<GithubProxyTestResult> fetchFasterGithubProxy({
  Dio? dio,
  int sampleSize = 12,
  int maxRetries = 3,
  Duration timeout = const Duration(milliseconds: 1800),
  List<String> proxies = githubProxyCandidates,
}) async {
  final normalized = _uniqueNormalizedProxies(proxies);
  if (normalized.isEmpty) {
    return const GithubProxyTestResult.error('没有可用的 GitHub 加速地址');
  }

  final client = dio ?? Dio();
  client.options
    ..connectTimeout = timeout
    ..receiveTimeout = timeout
    ..sendTimeout = timeout
    ..followRedirects = false
    ..validateStatus = (status) => status != null && status < 500;

  final random = Random();
  final effectiveSampleSize = sampleSize.clamp(1, normalized.length).toInt();
  final results = <ResponseInfo>[];

  for (var retry = 1; retry <= maxRetries; retry++) {
    final selected = _sample(normalized, effectiveSampleSize, random);
    AppLogger.info('GitHub 代理测速第 $retry 次，候选 ${selected.length} 个');

    final tested = await Future.wait(
      selected.map((proxy) => _testProxy(client, proxy)),
    );
    results.addAll(tested);

    final available = tested
        .where((entry) => entry.available && entry.time <= timeout.inMilliseconds)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    if (available.isNotEmpty) {
      final fastest = available.first;
      final msg = '最快 GitHub 加速地址：${fastest.url}，响应 ${fastest.time} ms';
      AppLogger.info(msg);
      return GithubProxyTestResult.success(fastest, results, msg);
    }
  }

  results.sort((a, b) => a.time.compareTo(b.time));
  AppLogger.warn('GitHub 代理测速失败，未找到可用地址');
  return GithubProxyTestResult.error('未找到可用的 GitHub 加速地址', results: results);
}

String buildGithubProxyUrl(String proxy, String githubUrl) {
  final base = _normalizeProxy(proxy);
  if (!_isGithubUrl(githubUrl)) return githubUrl;
  return '$base$githubUrl';
}

bool isGithubDownloadUrl(String url) {
  return _isGithubUrl(url);
}

Future<ResponseInfo> _testProxy(Dio dio, String proxy) async {
  final stopwatch = Stopwatch()..start();
  final url = buildGithubProxyUrl(proxy, _githubProbePath);
  try {
    Response<dynamic> response;
    try {
      response = await dio.head<dynamic>(url);
    } on DioException {
      response = await dio.get<dynamic>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
    }
    stopwatch.stop();
    return ResponseInfo(
      url: proxy,
      time: stopwatch.elapsedMilliseconds,
      status: response.statusCode ?? 0,
    );
  } catch (_) {
    stopwatch.stop();
    return ResponseInfo(
      url: proxy,
      time: stopwatch.elapsedMilliseconds,
      status: 0,
    );
  }
}

List<String> _uniqueNormalizedProxies(List<String> proxies) {
  return {
    for (final proxy in proxies)
      if (proxy.trim().isNotEmpty) _normalizeProxy(proxy),
  }.toList();
}

List<String> _sample(List<String> proxies, int count, Random random) {
  final copy = proxies.toList()..shuffle(random);
  return copy.take(count).toList();
}

String _normalizeProxy(String proxy) {
  final value = proxy.trim();
  if (value.endsWith('/')) return value;
  return '$value/';
}

bool _isGithubUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  final host = uri.host.toLowerCase();
  return host == 'github.com' ||
      host == 'raw.githubusercontent.com' ||
      host == 'objects.githubusercontent.com' ||
      host.endsWith('.githubusercontent.com');
}

class GithubProxyTestResult {
  final ResponseInfo? data;
  final List<ResponseInfo> results;
  final String msg;
  final bool success;

  const GithubProxyTestResult({
    required this.data,
    required this.results,
    required this.msg,
    required this.success,
  });

  const GithubProxyTestResult.success(this.data, this.results, this.msg)
      : success = true;

  const GithubProxyTestResult.error(
    this.msg, {
    this.results = const [],
  })  : data = null,
        success = false;
}

class ResponseInfo {
  final String url;
  final int time;
  final int status;

  const ResponseInfo({
    required this.url,
    required this.time,
    required this.status,
  });

  bool get available => status >= 200 && status < 500;

  factory ResponseInfo.fromJson(Map<String, dynamic> json) {
    return ResponseInfo(
      url: json['url'] as String? ?? '',
      time: (json['time'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'time': time,
      'status': status,
    };
  }
}
