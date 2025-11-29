import 'package:get/get.dart';
import 'package:harvest/models/common_response.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../api/api.dart';
import '../../../../api/hooks.dart';
import '../../../../utils/logger_helper.dart';
import '../models/AuthPeriod.dart';
import 'model.dart';

class AppPublishController extends GetxController {
  AuthPeriod? authInfo;
  bool uploading = false;
  bool loading = false;
  ShadTabsController<String> tabsController = ShadTabsController<String>(value: 'userManageMent');
  List<AdminUser> users = [];
  List<AdminUser> showUsers = [];

  String searchKey = '';

  @override
  void onInit() async {
    loading = true;
    update();
    await getAdminUserList();
    loading = false;
    super.onInit();
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

  void filterUser() {
    showUsers = users
        .where((element) =>
            element.email.toLowerCase().contains(searchKey.toLowerCase()) ||
            (element.username?.toLowerCase().contains(searchKey.toLowerCase()) == true))
        .toList();
    update();
  }

  Future<void> getAdminUserList() async {
    Logger.instance.i('开始获取AdminUser列表');

    var response = await fetchDataList(Api.ADMIN_USER, (p0) => AdminUser.fromJson(p0));
    Logger.instance.i('获取到AdminUser列表, 数量为：${response.data!.length}');
    if (response.succeed) {
      users = response.data!;
      filterUser();
    }
    Logger.instance.i('AdminUser列表获取成功！');
  }

  Future<CommonResponse> sendAdminUserToken(int id) async {
    return await fetchData(Api.ADMIN_SEND_TOKEN, queryParameters: {'user_id': id});
  }

  Future<CommonResponse> resetAdminUserToken(int id, Map<String, dynamic> data) async {
    return await addData(Api.ADMIN_RESET_TOKEN, data, queryParameters: {'user_id': id});
  }

  Future<CommonResponse> resetAdminUserInvite(int count) async {
    return await fetchData(Api.ADMIN_RESET_INVITE, queryParameters: {'count': count});
  }

  Future<AdminUser?> getAdminUser(int id) async {
    var response = await fetchData('${Api.ADMIN_USER}/$id', queryParameters: {'id': id});
    if (response.succeed) {
      return AdminUser.fromJson(response.data);
    }
    return null;
  }

  Future<CommonResponse> editAdminUser(AdminUser user) async {
    Map<String, dynamic> map = user.toJson();
    map = Map.fromEntries(
      map.entries.where((entry) {
        final value = entry.value;
        // 保留：非 null 且（不是字符串 或 字符串非空）
        return value != null && (value is! String || value.isNotEmpty);
      }),
    );
    return await editData(Api.ADMIN_USER, map);
  }

  Future<CommonResponse> createAdminUser(String email) async {
    return await addData(Api.ADMIN_USER, null, queryParameters: {'invite_email': email, 'notify': false});
  }

  deleteAdminUser(int id) async {
    return await removeData('${Api.ADMIN_USER}/$id', queryParameters: {'id': id});
  }
}
