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
  late SSHClient client;
  TextEditingController usernameController =
      TextEditingController(text: 'root');
  TextEditingController passwordController = TextEditingController();
  TextEditingController hostController =
      TextEditingController(text: '192.168.1.1');
  TextEditingController portController = TextEditingController(text: '22');
  TextEditingController proxyController = TextEditingController(text: '');
  List<String> results = ['SSHClient欢迎你！'];
  List<DockerContainer> containerList = [];

  // 使用StreamController来管理下载状态的流
  final StreamController<List<DockerContainer>> containerStreamController =
      StreamController<List<DockerContainer>>.broadcast();

  Stream<List<DockerContainer>> get containerStream =>
      containerStreamController.stream;

  @override
  void onInit() {
    String? serverDomain =
        SPUtil.getString('serverDomain', defaultValue: '192.168.1.1');
    String? password =
        SPUtil.getString('SSH_CLIENT_PASSWORD', defaultValue: '');
    String? proxy = SPUtil.getString('SSH_CLIENT_PROXY', defaultValue: '');
    hostController.text = serverDomain!;
    passwordController.text = password!;
    proxyController.text = proxy!;
    remember = SPUtil.getBool('SSH_CLIENT_REMEMBER', defaultValue: false)!;
    super.onInit();
  }

  connect() async {
    try {
      client = SSHClient(
        await SSHSocket.connect(
            hostController.text, int.parse(portController.text)),
        username: usernameController.text,
        onPasswordRequest: () => passwordController.text,
      );
      if (remember) {
        SPUtil.setLocalStorage('SSH_CLIENT_PASSWORD', passwordController.text);
        SPUtil.setLocalStorage('SSH_CLIENT_PROXY', proxyController.text);
        SPUtil.setBool('SSH_CLIENT_REMEMBER', remember);
      }
      Logger.instance.i(await run('whoami'));
      String msg;
      if (client.isClosed) {
        msg = 'SSH 连接到 ${hostController.text} 失败！';
      } else {
        connected = !client.isClosed;
        msg = 'SSH 连接到 ${hostController.text}';
        await getContainerList();
      }
      Logger.instance.i(msg);
      results.add(msg);
    } catch (e, trace) {
      Logger.instance.e(e);
      Logger.instance.e(trace);
    }
    update();
  }

  disconnect() {
    client.close();
    connected = false;
    update();
  }

  generateNewContainerCommand(String name) async {
    String command = "docker inspect --format='docker run -d "
        "--name {{(slice .Name 1)}} {{if .HostConfig.Privileged}}--privileged {{end}}"
        "{{range \$key, \$value := .Config.Labels}}--label {{\$key}}=\"{{\$value}}\" {{end}} "
        "{{range \$index, \$value := .Config.Env}}--env {{\$value}} {{end}} "
        "{{range \$index, \$value := .HostConfig.PortBindings}}-p {{(index \$value 0).HostPort}}:{{(index \$value 0).HostPort}} "
        "{{end}} {{range \$index, \$value := .Mounts}}-v {{\$value.Source}}:{{\$value.Destination}} {{end}} "
        "{{range \$network, \$details := .NetworkSettings.Networks}}--network {{\$network}} {{if \$details.IPAddress}}--ip {{\$details.IPAddress}} {{end}} {{end}} "
        "{{.Config.Image}}' $name";

    String newCommand = await run(command);
    Logger.instance.i(newCommand);
    results.add(newCommand);
    update();
    return newCommand;
  }

  Future<String> run(String command) async {
    final res = await client.run(command);
    return utf8.decode(res);
  }

  execute(String command) async {
    SSHSession session = await client.execute(command);
    // 监听 stdout
    session.stdout.listen((data) {
      final output = utf8.decode(data);
      Logger.instance.i('Output: $output');
      results.add(output);

      update();
    });

    // 监听 stderr
    session.stderr.listen((data) {
      final errorOutput = utf8.decode(data);
      Logger.instance.i('Error: $errorOutput');
      results.add(errorOutput);

      update();
    });
    update();
  }

  clear() {
    results.clear();
    results = ['日志已清除，SSHClient欢迎你！'];
    update();
  }

  getContainerList() async {
    Logger.instance.i('开始获取容器列表');
    String command =
        'docker ps -a --format "{{.ID}} {{.Image}} {{.Names}} {{.Status}}"';
    clear();
    results.add('开始获取容器列表');
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
    Logger.instance.i('Output: $containerList'); // 期望输出 Docker 容器列表
    update();
  }

  void restartContainer(String? name) async {
    Logger.instance.i('正在重启容器：$name');
    clear();
    results.add('正在重启容器：$name');
    update();
    String command = 'docker restart $name';
    await execute(command);
    await getContainerList();
    update();
  }

  getLocalImageDigest(String image) async {
    // String command = "docker inspect --format='{{.Created}}' $image";
    String command =
        """docker inspect --format='{{with index .RepoDigests 0}}{{if .}}{{index (split . "@") 1}}{{end}}{{end}}' $image""";
    String createdTime = await run(command);
    return createdTime;
  }

  getRemoteImageDigest(String image) async {
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
    results.add('镜像名称：$name:$tag');
    update();

    String command = 'curl ';
    if (proxyController.text.isNotEmpty) {
      command += '-x ${proxyController.text} ';
    }
    command +=
        """-s https://hub.docker.com/v2/repositories/$name/tags/$tag/ | grep '"digest"' | sed 's/.*"digest":"\\([^"]*\\)".*/\\1/'""";

    results.add(command);
    return await run(command);
  }

  Future<bool> checkNewImage(String image) async {
    clear();
    results.add('检查更新：$image');
    update();
    String localImageDigest = await getLocalImageDigest(image);
    results.add('当前镜像digest：$localImageDigest');

    String remoteImageDigest = await getRemoteImageDigest(image);
    results.add('远程镜像digest：$remoteImageDigest');
    results.add(
        '$image 当前镜像digest：$localImageDigest - $remoteImageDigest 远程镜像digest');
    return localImageDigest.toLowerCase() == remoteImageDigest.toLowerCase();
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

  checkAllImageUpdate() async {
    results.add('开始检查镜像是否有更新');
    List<Future<void>> futures = [];
    for (DockerContainer item in containerList) {
      if (!item.hasNew) {
        Future<void> fetchStatus = fetchStatusForItem(item);
        futures.add(fetchStatus);
      }
    }
    await Future.wait(futures);
  }

  void getNewImage(String? image) async {
    String command = 'docker pull $image';
    if (proxyController.text.isNotEmpty) {
      command =
          "export HTTP_PROXY=${proxyController.text} HTTPS_PROXY=${proxyController.text} && $command";
    }
    clear();
    results.add('正在更新镜像：$image');
    update();
    await execute(command);
    update();
  }

  void rebuildContainer(String name, String image) async {
    Logger.instance.i('正在重建容器：$name');

    String newCommand = await generateNewContainerCommand(name);

    String command =
        'docker pull $image && docker stop $name && docker rm -f $name && $newCommand';
    await execute(command);
    await getContainerList();
    update();
  }

  stopContainer(String name) async {
    String command = 'docker stop $name';
    await execute(command);
    update();
  }
}
