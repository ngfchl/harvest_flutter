import 'dart:convert';

import 'package:get/get.dart';
import 'package:harvest/app/login/models/server.dart';
import 'package:harvest/models/common_response.dart';

import '../../../utils/logger_helper.dart';
import '../../../utils/storage.dart';

class ServerRepository {
  List<Server> serverList = [];

  Future<void> init() async {
    await SPUtil.getInstance();
    getServers();
  }

  // 获取所有服务器信息
  void getServers() {
    if (SPUtil.containsKey('servers')) {
      List<Object?> storageData = SPUtil.getLocalStorage('servers');
      serverList = storageData
          .map((data) => Server.fromJson(
              json.decode(data as String) as Map<String, dynamic>))
          .toList();
    }
  }

// 插入新的服务器信息
  Future<CommonResponse> insertServer(Server server) async {
    bool exists = serverList.any((existingServer) =>
        existingServer.protocol == server.protocol &&
        existingServer.domain == server.domain &&
        existingServer.port == server.port);
    if (exists) {
      return CommonResponse.error(msg: '服务器已存在');
    }
    if (server.selected) {
      serverList = serverList.map((e) => e.copyWith(selected: false)).toList();
    }

    server = server.copyWith(id: serverList.length + 1);
    serverList.add(server);

    bool res = await SPUtil.setStringList(
        'servers', serverList.map((e) => json.encode(e.toJson())).toList());
    if (res) {
      getServers();
      return CommonResponse.success(msg: '服务器 ${server.name} 添加成功');
    }
    return CommonResponse.error(msg: '服务器 ${server.name} 添加失败!');
  }

  // 更新服务器信息
  Future<CommonResponse> updateServer(Server server) async {
    try {
      if (server.selected) {
        serverList =
            serverList.map((e) => e.copyWith(selected: false)).toList();
      }
      int index = serverList.indexWhere((element) => element.id == server.id);
      if (index >= 0) {
        serverList[index] = server;
        bool res = await SPUtil.setStringList(
            'servers', serverList.map((e) => json.encode(e.toJson())).toList());
        if (res) {
          getServers();
          return CommonResponse.success(msg: '服务器 ${server.name} 更新成功');
        }
        return CommonResponse.error(msg: '服务器 ${server.name} 更新失败!');
      }
      return CommonResponse.error(msg: '服务器 ${server.name} 更新失败！错误信息：未找到此服务器');
    } catch (e) {
      return CommonResponse.error(msg: '服务器 ${server.name} 更新失败! $e');
    }
  }

  // 删除服务器信息
  Future<CommonResponse> deleteServer(int key) async {
    try {
      Logger.instance.i('删除服务器: $key');
      serverList.removeWhere((element) => element.id == key);
      var res = await SPUtil.setLocalStorage(
          'servers', serverList.map((e) => json.encode(e.toJson())).toList());
      Logger.instance.i('删除服务器结果: $res');
      if (res == null) {
        getServers();
        return CommonResponse.success(msg: '服务器删除成功');
      }
      return CommonResponse.error(msg: '服务器删除失败!');
    } catch (e) {
      return CommonResponse.error(msg: '服务器删除失败! $e');
    }
  }

  // 根据 ID 获取单个服务器信息
  Server? getServerById(int key) {
    return serverList.firstWhereOrNull((element) => element.id == key);
  }
}
