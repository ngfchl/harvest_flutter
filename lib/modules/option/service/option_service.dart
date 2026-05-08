import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/dio_client.dart';
import 'package:harvest/core/http/hooks.dart';
import 'package:harvest/core/http/http.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/option_model.dart';

enum CookieBackupSource { ptpp, ptd }

extension CookieBackupSourceX on CookieBackupSource {
  String get endpoint {
    return switch (this) {
      CookieBackupSource.ptpp => API.IMPORT_COOKIE_PTPP,
      CookieBackupSource.ptd => API.IMPORT_COOKIE_PTD,
    };
  }

  String get label {
    return switch (this) {
      CookieBackupSource.ptpp => 'PTPP',
      CookieBackupSource.ptd => 'PT-depiler',
    };
  }
}

class OptionService {
  /// 获取所有配置项
  Future<List<Option>> fetchOptions() async {
    final res = await Http.get(API.OPTION_OPERATE);
    if (res is List) {
      return res
          .map((e) => Option.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// 保存配置项
  Future<void> saveOption(Option option) async {
    if (option.id == null) {
      await addData(API.OPTION_OPERATE, option.toJson());
    } else {
      await editData('${API.OPTION_OPERATE}/${option.id}', option.toJson());
    }
  }

  /// 删除配置项
  Future<void> removeOption(int id) async {
    await Http.delete('${API.OPTION_OPERATE}/$id');
  }

  /// 通知测试
  Future<void> testNotice(Map<String, String> body) async {
    await Http.get(API.NOTICE_TEST, data: body);
  }

  /// 设置 Telegram Webhook
  Future<void> setTelegramWebhook(String host) async {
    await Http.post(API.TELEGRAM_WEBHOOK, queryParameters: {'host': host});
  }

  /// 导入站点备份文件
  Future<String> importCookieBackup({
    required PlatformFile file,
    required CookieBackupSource source,
  }) async {
    if (file.path == null && file.bytes == null) {
      throw StateError('无法读取文件: ${file.name}');
    }

    final formData = FormData();
    final multipart = file.bytes != null
        ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
        : await MultipartFile.fromFile(file.path!, filename: file.name);
    formData.files.add(MapEntry('file', multipart));

    try {
      final response = await DioClient.dio.post(
        source.endpoint,
        data: formData,
        options: Options(extra: const {'allowAnySucceed': true}),
      );
      AppLogger.info('${source.label} 备份导入已提交: ${response.data}');

      final data = response.data;
      if (data is Map && data['msg'] != null) {
        return data['msg'].toString();
      }
      return '${source.label} 导入任务已提交';
    } on DioException catch (e, st) {
      AppLogger.error(
        '${source.label} 备份导入失败: response=${e.response?.data}',
        e,
        st,
      );
      rethrow;
    }
  }

  /// CookieCloud 同步
  Future<void> syncCookieCloud() async {
    await fetchBasic(API.IMPORT_COOKIE_CLOUD);
    AppLogger.info('CookieCloud 同步任务已提交');
  }

  /// 生成测速任务
  Future<void> speedTest() async {
    await fetchBasic(API.SPEED_TEST);
    AppLogger.info('测速任务已提交');
  }

  /// 批量更新站点配置字段
  Future<void> bulkUpgrade({
    required String key,
    required dynamic value,
  }) async {
    await Http.post<dynamic>(
      API.Bulk_UPGRADE_API,
      data: {'key': key, 'value': value},
    );
    AppLogger.info('[Option] 批量更新已提交 key=$key valueType=${value.runtimeType}');
  }
}
