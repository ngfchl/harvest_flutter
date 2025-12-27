import 'dart:math';

import 'package:dio/dio.dart';
import 'package:harvest/models/common_response.dart';

import 'logger_helper.dart';

Future<CommonResponse<ResponseInfo?>> fetchFasterGithubProxy() async {
  List<String> proxies = [
    "https://gh-proxy.net/",
    "https://github.cnxiaobai.com/",
    "https://hub.gitmirror.com/",
    "https://www.5555.cab/",
    // "https://git.tangbai.cc/",
    "https://gh.ddlc.top/",
    "https://ghproxy.xiaopa.cc/",
    "https://ghproxy.cfd/",
    "https://ghproxy.cc/",
    "https://ghproxy.monkeyray.net/",
    "https://cf.ghproxy.cc/",
    "https://gitproxy.mrhjx.cn/",
    "https://gh.xxooo.cf/",
    // "https://github.xxlab.tech/",
    "https://ghproxy.1888866.xyz/",
    "https://github.mlmle.cn/",
    "https://fastgit.cc/",
    "https://gh.1k.ink/",
    "https://ghproxy.net/",
    "https://github.boringhex.top/",
    "https://ghfast.top/",
    "https://y.whereisdoge.work/",
    "https://ghproxy.imciel.com/",
    // "https://gh.jdck.fun/",
    "https://xiaomo-station.top/",
    "https://gh.monlor.com/",
    "https://g.blfrp.cn/",
    "https://gh.con.sh/",
    "https://gh.b52m.cn/",
    "https://github.dpik.top/",
    "https://github.geekery.cn/",
    "https://gh.halonice.com/",
    "https://github.limoruirui.com/",
    "https://git.yylx.win/",
    "https://github.tbedu.top/",
    "https://ghproxy.vansour.top/",
    "https://tvv.tw/",
    "https://ghproxy.xzhouqd.com/",
    "https://github-proxy.memory-echoes.cn/",
    "https://gh.catmak.name/",
    "https://hub.ddayh.com/",
    "https://github.ruojian.space/",
    "https://ghproxy.cxkpro.top/",
    "https://ghp.keleyaa.com/",
    "https://ghf.无名氏.top/",
    "https://github-proxy.lixxing.top/",
    "https://gh.padao.fun/",
    "https://gp.871201.xyz/",
    "https://gh.wsmdn.dpdns.org/",
    "https://ggg.clwap.dpdns.org/",
    "https://gh-proxy.com/",
    "https://gh.dpik.top/",
    "https://gp.zkitefly.eu.org/",
    "https://gh.bugdey.us.kg/",
    "https://code-hub-hk.freexy.top/",
    "https://github.chenc.dev/",
    "https://ghfile.geekertao.top/",
    "https://kenyu.ggff.net/",
    "https://gh.nxnow.top/",
    "https://github.bullb.net/",
    "https://gitproxy.197545.xyz/",
    "https://gitproxy.127731.xyz/",
    "https://gitproxy1.127731.xyz/",
    "https://jiashu.1win.eu.org/",
    "https://ghproxy.mf-dust.dpdns.org/",
    "https://j.1lin.dpdns.org/",
    "https://gh.jasonzeng.dev/",
    "https://proxy.baguoyuyan.com/",
    "https://github.1ms.xx.kg/",
    "https://gh.198962.xyz/",
    "https://github.880824.xyz/",
    "https://ghps.cc/",
    "https://30006000.xyz/",
    "https://github.tianrld.top/",
    "https://getgit.love8yun.eu.org/",
    "https://github.788787.xyz/",
    "https://ghm.078465.xyz/",
    "https://github-proxy.com/",
    "https://proxy.yaoyaoling.net/",
    "https://ghproxy.sakuramoe.dev/",
    "https://ghproxy.053000.xyz/",
    "https://gh.chjina.com/",
    "https://git.zeas.cc/",
    "https://ghpxy.hwinzniej.top/",
    "https://gh.echofree.xyz/",
    "https://github.zzrbk.xyz/",
    "https://git.669966.xyz/",
    "https://github.ihnic.com/",
    "https://gh.996986.xyz/",
    "https://gh.idayer.com/",
    "https://github.ednovas.xyz/",
    "https://gh.chalin.tk/",
    "https://j.1win.ggff.net/",
    "https://github.lsdfxdk.nyc.mn/",
    "https://gh.aaa.team/",
    "https://github.crdz.eu.org/",
    "https://gh.shiina-rimo.cafe/",
    "https://ghproxy.mirror.skybyte.me/",
    "https://gh.llkk.cc/",
    "https://git.40609891.xyz/",
    "https://github.oterea.top/",
    "https://gh.noki.icu/",
    "https://gh.39.al/",
    "https://ghproxy.cn/",
    "https://down.npee.cn/",
    "https://github.kkproxy.dpdns.org/",
    "https://free.cn.eu.org/",
    "https://git.951959483.xyz/",
    "https://git.820828.xyz/",
    "https://ghproxy.fangkuai.fun/",
    "https://github.cn86.dev/",
    "https://github.zjzzy.cloudns.org/",
    "https://ghb.nilive.top/",
    "https://gitproxy.click/",
    "https://proxy.atoposs.com/"
  ];
// 创建 Dio 实例
  final dio = Dio();
  // 设置 Dio 请求的超时时间为 1500ms
  dio.options.connectTimeout = Duration(milliseconds: 1500); // 请求连接超时
  dio.options.receiveTimeout = Duration(milliseconds: 1500); // 响应超时
  Logger.instance.i('开始随机代理地址... ${proxies.length}');

  // 随机选取10个代理地址
  final random = Random();
  var selectedProxies = List<String>.generate(10, (index) => proxies[random.nextInt(proxies.length)]);
  Logger.instance.i('随机选择的代理地址: $selectedProxies');
  // 最大重试次数
  const maxRetries = 3;
  int retryCount = 0;
  String? selectedProxy;
  // 重新测速逻辑
  while (retryCount < maxRetries) {
    retryCount++;
    Logger.instance.i('第 $retryCount 次测速...');
    // 测试这些地址的响应时间
    var responseTimes = await Future.wait(selectedProxies.map((url) async {
      final stopwatch = Stopwatch()..start();
      try {
        final response = await dio.get(url);
        stopwatch.stop();
        return ResponseInfo(url: url, time: stopwatch.elapsedMilliseconds, status: response.statusCode!);
      } catch (e) {
        stopwatch.stop();
        return ResponseInfo(url: url, time: stopwatch.elapsedMilliseconds, status: 500); // 失败的请求
      }
    }));
    responseTimes = responseTimes.where((entry) => entry.status < 500).toList();
    // 如果所有站点的响应时间都超过 1500ms，重新选取一组站点
    final allOver1500ms = responseTimes.every((entry) => entry.time > 1500);
    if (allOver1500ms) {
      Logger.instance.i('所有站点的响应时间超过 1500ms，重新选取一组站点...');
      selectedProxies = List<String>.generate(10, (index) => proxies[random.nextInt(proxies.length)]);
    } else {
      // 找到最快的站点并返回
      final fastestProxy = responseTimes.reduce((a, b) {
        return a.time < b.time ? a : b;
      });
      String msg = '第 $retryCount 次测速，最快的代理地址是：${fastestProxy.url}，响应时间：${fastestProxy.time} ms';
      Logger.instance.i(msg);
      return CommonResponse.success(data: fastestProxy, msg: msg);
    }
  }

  // 如果重试次数达到最大值，返回提示信息
  Logger.instance.i('重试次数达到最大值，所有代理响应时间均过长。');
  return CommonResponse.error(msg: '所有代理响应时间均过长。');
}

class ResponseInfo {
  final String url;
  final int time;
  final int status;

  ResponseInfo({
    required this.url,
    required this.time,
    required this.status,
  });

  // 从 JSON Map 创建实例
  factory ResponseInfo.fromJson(Map<String, dynamic> json) {
    return ResponseInfo(
      url: json['url'] as String,
      time: json['time'] as int,
      status: json['status'] as int,
    );
  }

  // 转换为 JSON Map
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'time': time,
      'status': status,
    };
  }
}
