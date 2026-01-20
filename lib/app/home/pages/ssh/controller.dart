import 'dart:async';
import 'dart:convert';

import 'package:dartssh2_plus/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/logger_helper.dart';
import '../../../../utils/storage.dart';
import 'models.dart';

class SshController extends GetxController {
  bool connected = false;
  bool remember = false;
  bool haveNewImage = false;
  Timer? periodicTimer;
  Timer? fiveMinutesTimer;
  bool isTimerActive = true; // 使用 RxBool 控制定时器是否激活

  late SSHClient client;
  TextEditingController usernameController =
      TextEditingController(text: 'root');
  TextEditingController passwordController = TextEditingController();
  TextEditingController hostController =
      TextEditingController(text: '192.168.1.1');
  TextEditingController portController = TextEditingController(text: '22');
  TextEditingController proxyController = TextEditingController(text: '');
  List<String> logList = ['SSHClient欢迎你！'];
  List<DockerContainer> containerList = [];
  String server = SPUtil.getString('server');

  // 使用StreamController来管理下载状态的流
  final StreamController<List<DockerContainer>> containerStreamController =
      StreamController<List<DockerContainer>>.broadcast();

  Stream<List<DockerContainer>> get containerStream =>
      containerStreamController.stream;

  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    String? hostname = SPUtil.getString('$server-SSH_CLIENT_HOSTNAME',
        defaultValue: '192.168.123.5');
    String? password =
        SPUtil.getString('$server-SSH_CLIENT_PASSWORD', defaultValue: '');
    String? port =
        SPUtil.getString('$server-SSH_CLIENT_PORT', defaultValue: '');
    String? username =
        SPUtil.getString('$server-SSH_CLIENT_USERNAME', defaultValue: 'root');
    String? proxy =
        SPUtil.getString('$server-SSH_CLIENT_PROXY', defaultValue: '');
    hostController.text = hostname;
    passwordController.text = password;
    proxyController.text = proxy;
    usernameController.text = username;
    portController.text = port;
    remember = SPUtil.getBool('$server-SSH_CLIENT_REMEMBER');
    super.onInit();
  }

  Future<void> connect() async {
    try {
      client = SSHClient(
        await SSHSocket.connect(
            hostController.text, int.parse(portController.text)),
        username: usernameController.text,
        onPasswordRequest: () => passwordController.text,
      );
      if (remember) {
        SPUtil.setLocalStorage(
            '$server-SSH_CLIENT_USERNAME', usernameController.text);
        SPUtil.setLocalStorage(
            '$server-SSH_CLIENT_HOSTNAME', hostController.text);
        SPUtil.setLocalStorage(
            '$server-SSH_CLIENT_PASSWORD', passwordController.text);
        SPUtil.setLocalStorage('$server-SSH_CLIENT_PORT', portController.text);
        SPUtil.setLocalStorage(
            '$server-SSH_CLIENT_PROXY', proxyController.text);
        SPUtil.setBool('$server-SSH_CLIENT_REMEMBER', remember);
      }
      String msg;
      if (client.isClosed) {
        msg = 'SSH 连接到 ${hostController.text} 失败！';
      } else {
        connected = !client.isClosed;
        msg = 'SSH 连接到 ${hostController.text} 用户：${await run('whoami')}';
        await getContainerList();
      }
      Logger.instance.i(msg);
      updateLogs(msg);
    } catch (e, trace) {
      Logger.instance.e(e);
      Logger.instance.e(trace);
    }
    update();
  }

  void updateLogs(String msg) {
    logList.add("${DateTime.now()} - $msg");
    if (logList.length > 12) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  void disconnect() {
    client.close();
    connected = false;
    cancelPeriodicTimer();
    update();
  }

  Future<String> generateNewContainerCommand(String name, String image) async {
    String command = "docker inspect --format='docker run -d "
        "--name {{(slice .Name 1)}} {{if .HostConfig.Privileged}}--privileged {{end}}"
        "{{range \$key, \$value := .Config.Labels}}--label {{\$key}}=\"{{\$value}}\" {{end}} "
        "{{range \$index, \$value := .Config.Env}}--env {{\$value}} {{end}} "
        "{{range \$index, \$value := .HostConfig.PortBindings}}-p {{(index \$value 0).HostPort}}:{{(index \$value 0).HostPort}} "
        "{{end}} {{range \$index, \$value := .Mounts}}-v {{\$value.Source}}:{{\$value.Destination}} {{end}} "
        "{{range \$network, \$details := .NetworkSettings.Networks}}--network {{\$network}} {{if and \$details.IPAddress (ne \$network \"host\") (ne \$network \"bridge\")}}--ip {{\$details.IPAddress}} {{end}} {{end}} "
        " $image' $name";

    String newCommand = await run(command);
    Logger.instance.i(newCommand);
    updateLogs(newCommand);
    update();
    return newCommand;
  }

  Future<String> run(String command) async {
    command = addProxy(command);
    final res = await client.run(". /etc/profile; $command");
    return utf8.decode(res);
  }

  Future<void> execute(String command) async {
    command = addProxy(command);
    SSHSession session = await client.execute(". /etc/profile; $command");
    // 监听 stdout
    session.stdout.listen((data) {
      final output = utf8.decode(data);
      Logger.instance.i('Output: $output');
      updateLogs(output);

      update();
    });

    // 监听 stderr
    session.stderr.listen((data) {
      final errorOutput = utf8.decode(data);
      Logger.instance.i('Error: $errorOutput');
      updateLogs(errorOutput);

      update();
    });
    update();
  }

  void clear() {
    logList.clear();
    logList = ['日志已清除，SSHClient欢迎你！'];
    update();
  }

  Future<void> getContainerList() async {
    Logger.instance.i('开始获取容器列表');
    String command =
        '. /etc/profile; docker ps -a --format "{{.ID}} {{.Image}} {{.Names}} {{.Status}}"';
    updateLogs('开始获取容器列表');
    update();
    SSHSession session = await client.execute(command);
    final output = await session.stdout.map(utf8.decode).join();
    Logger.instance.d(output);
    containerList = output
        .trim()
        .split('\n')
        .map((line) {
          var parts = line.split(' ');
          return {
            'id': parts[0],
            'image': parts[1],
            'name': parts[2],
            'status': parts.sublist(3).join(' '),
          };
        })
        .map((e) => DockerContainer.fromJson(e))
        .toList();
    await checkAllImageUpdate();
    startPeriodicTimer();

    Logger.instance.i('Output: $containerList'); // 期望输出 Docker 容器列表
    update();
  }

  void restartContainer(String? name) async {
    Logger.instance.i('正在重启容器：$name');
    updateLogs('正在重启容器：$name');
    update();
    String command = 'docker restart $name';
    await execute(command);
    await Future.delayed(const Duration(seconds: 3));
    await getContainerList();
    update();
  }

  Future<String> getLocalImageDigest(String image) async {
    // String command = "docker inspect --format='{{.Created}}' $image";
    String command =
        """docker inspect --format='{{with index .RepoDigests 0}}{{if .}}{{index (split . "@") 1}}{{end}}{{end}}' $image""";
    String digest = await run(command);
    Logger.instance.d(digest);
    return digest;
  }

  Future<String> getRemoteImageDigest(String image) async {
    String tag = 'latest';
    String name = '';
    if (image.contains(':')) {
      name = image.split(':').first;
      tag = image.split(':').last;
    } else {
      name = image;
    }
    if (!name.contains('/')) {
      name = 'library/$name';
    }
    List<String> parts = name.split('/');
    name = '${parts[parts.length - 2]}/${parts[parts.length - 1]}';
    Logger.instance.d('镜像名称：$name:$tag');
    update();

    String command = 'curl ';
    if (proxyController.text.isNotEmpty) {
      command += '-x ${proxyController.text} ';
    }
    command +=
        """-s https://hub.docker.com/v2/repositories/$name/tags/$tag/ | grep '"digest"' | sed 's/.*"digest":"\\([^"]*\\)".*/\\1/'""";

    Logger.instance.d(command);
    return await run(command);
  }

  Future<void> fetchStatsForItem(
      DockerContainer item, Map<String, ContainerStats> idToMap) async {
    try {
      item.stats = idToMap[item.id];
      containerStreamController.sink.add([item]);
      update();
    } catch (e) {
      Logger.instance.e('${item.image} 检查更新失败: $e');
    }
  }

  void startPeriodicTimer() {
    cancelPeriodicTimer();
    timerToStop();
    // 设置定时器，每隔一定时间刷新下载器数据
    periodicTimer =
        Timer.periodic(const Duration(seconds: 10), (Timer t) async {
      // 在定时器触发时获取最新的下载器数据
      await checkAllContainerStats();
    });
    isTimerActive = true;
    update();
  }

  void timerToStop() {
    fiveMinutesTimer = Timer(const Duration(minutes: 10), () {
      // 定时器触发后执行的操作，这里可以取消periodicTimer、关闭资源等
      cancelPeriodicTimer();
      // 你可以在这里添加其他需要在定时器触发后执行的逻辑
    });
  }

  // 取消定时器
  void cancelPeriodicTimer() {
    if (periodicTimer != null && periodicTimer?.isActive == true) {
      periodicTimer?.cancel();
    }
    if (fiveMinutesTimer != null && fiveMinutesTimer?.isActive == true) {
      fiveMinutesTimer?.cancel();
    }
    isTimerActive = false;
    update();
  }

  Future<void> checkAllContainerStats() async {
    List<String?> nameList = containerList.map((el) => el.name).toList();
    updateLogs('刷新容器运行状态');
    String command =
        '. /etc/profile; docker stats ${nameList.join(" ")} --no-stream --format "{{json .}}"';
    final res = await run(command);
    List<ContainerStats> statsList = res
        .trim()
        .split("\n")
        .map((el) => ContainerStats.fromJson(json.decode(el)))
        .toList();
    Map<String, ContainerStats> idToMap = {
      for (var stats in statsList) stats.id: stats
    };
    List<Future<void>> futures = [];

    for (DockerContainer item in containerList) {
      Future<void> fetchStatus = fetchStatsForItem(item, idToMap);
      futures.add(fetchStatus);
      update();
    }
    await Future.wait(futures);
  }

  Future<bool> checkNewImage(String image) async {
    updateLogs('检查更新：$image');
    update();
    String localImageDigest = await getLocalImageDigest(image);
    // results.add('当前镜像digest：$localImageDigest');

    String remoteImageDigest = await getRemoteImageDigest(image);
    // results.add('远程镜像digest：$remoteImageDigest');
    bool flag = localImageDigest.isNotEmpty &&
        remoteImageDigest.isNotEmpty &&
        localImageDigest.toLowerCase() != remoteImageDigest.toLowerCase();
    updateLogs('$image 有更新：$flag');
    update();

    return flag;
  }

  Future<void> fetchStatusForItem(DockerContainer item) async {
    try {
      item.hasNew = await checkNewImage(item.image.toString());
      containerStreamController.sink.add([item]);
      update();
    } catch (e) {
      Logger.instance.e('${item.image} 检查更新失败: $e');
    }
  }

  Future<void> checkAllImageUpdate() async {
    updateLogs('开始检查镜像是否有更新');
    List<Future<void>> futures = [];

    for (DockerContainer item in containerList) {
      if (!item.hasNew) {
        Future<void> fetchStatus = fetchStatusForItem(item);
        futures.add(fetchStatus);
        update();
      }
    }
    await Future.wait(futures);
  }

  String addProxy(String command) {
    if (proxyController.text.isNotEmpty) {
      command =
          "export HTTP_PROXY=${proxyController.text} HTTPS_PROXY=${proxyController.text} && $command";
    }
    return command;
  }

  void getNewImage(String? image) async {
    String command = 'docker pull $image';
    updateLogs('正在更新镜像：$image');
    update();
    await execute(command);
    update();
  }

  void rebuildContainer(String name, String image) async {
    Logger.instance.i('正在重建容器：$name');

    String newCommand = await generateNewContainerCommand(name, image);

    String command =
        'docker pull $image && docker stop $name && docker rm -f $name && $newCommand';
    await execute(command);
    await Future.delayed(const Duration(seconds: 3));
    await getContainerList();

    update();
  }

  Future<void> stopContainer(String name) async {
    String command = 'docker stop $name';
    await execute(command);
    update();
  }

  Future<void> startContainer(String name) async {
    String command = 'docker start $name';
    await execute(command);
    update();
  }

  @override
  void dispose() {
    disconnect();
    cancelPeriodicTimer();
    super.dispose();
  }
}
