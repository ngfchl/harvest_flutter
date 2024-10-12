import 'dart:convert';

import 'package:dartssh2_plus/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../../../utils/storage.dart';
import 'models.dart';

Logger logger = Logger();

class SshController extends GetxController {
  bool connected = false;
  late SSHClient client;
  TextEditingController usernameController =
      TextEditingController(text: 'root');
  TextEditingController passwordController = TextEditingController();
  TextEditingController hostController =
      TextEditingController(text: '192.168.1.1');
  TextEditingController portController = TextEditingController(text: '22');
  List<String> results = ['SSHClient欢迎你！'];
  List<DockerContainer> containerList = [];

  @override
  void onInit() {
    String? serverDomain =
        SPUtil.getString('serverDomain', defaultValue: '192.168.1.1');

    hostController.text = serverDomain!;

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

      logger.i(await run('whoami'));
      String msg;
      if (client.isClosed) {
        msg = 'SSH 连接到 ${hostController.text} 失败！';
      } else {
        connected = !client.isClosed;
        msg = 'SSH 连接到 ${hostController.text}';
        await getContainerList();
      }
      logger.i(msg);
      results.add(msg);
    } catch (e, trace) {
      logger.e(e);
      logger.e(trace);
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
        "--network {{.HostConfig.NetworkMode}} "
        "{{range \$key, \$value := .Config.Labels}}--label {{\$key}}=\"{{\$value}}\" {{end}} "
        "{{range \$index, \$value := .Config.Env}}--env {{\$value}} {{end}} "
        "{{range \$index, \$value := .HostConfig.PortBindings}}-p {{(index \$value 0).HostPort}}:{{(index \$value 0).HostPort}} "
        "{{end}} {{range \$index, \$value := .Mounts}}-v {{\$value.Source}}:{{\$value.Destination}} {{end}} "
        "{{.Config.Image}}'  $name";
    String newCommand = await run(command);
    logger.i(newCommand);
    results.add(newCommand);
    update();
    return newCommand;
  }

  Future<String> run(String command) async {
    final res = await client.run(command);
    return utf8.decode(res);
  }

  execute(String command) async {
    clear();
    update();
    SSHSession session = await client.execute(command);
    // 监听 stdout
    session.stdout.listen((data) {
      final output = utf8.decode(data);
      logger.i('Output: $output');
      results.add(output);

      update();
    });

    // 监听 stderr
    session.stderr.listen((data) {
      final errorOutput = utf8.decode(data);
      logger.i('Error: $errorOutput');
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
    String command =
        'docker ps -a --format "{{.ID}} {{.Image}} {{.Names}} {{.Status}}"';
    SSHSession session = await client.execute(command);
    final output = await session.stdout.map(utf8.decode).join();
    print(output);
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
    logger.i('Output: $containerList'); // 期望输出 Docker 容器列表
    update();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void restartContainer(String? name) async {
    String command = 'docker restart $name';
    await execute(command);
    await getContainerList();
    update();
  }

  void getNewImage(String? image) async {
    String command = 'docker pull $image';
    await execute(command);
    update();
  }

  void rebuildContainer(String name, String image) async {
    String command = 'docker stop $name';
    await execute(command);
    command = 'docker commit $name $image';
    await execute(command);
    command = 'docker commit $name $image';
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
