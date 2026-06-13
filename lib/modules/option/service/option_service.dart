import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/dio_client.dart';
import 'package:harvest/core/http/hooks.dart';
import 'package:harvest/core/http/http.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/option_model.dart';

enum CookieBackupSource { ptpp, ptd }

class BackupDownload {
  final Uint8List bytes;
  final String fileName;

  const BackupDownload({required this.bytes, required this.fileName});
}

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
  Future<void> testNotice(
    String title,
    String content, {
    String pushType = '',
  }) async {
    await Http.get(
      API.NOTICE_TEST,
      queryParameters: {
        'title': title,
        'content': content,
        'push_type': pushType,
      },
    );
  }

  /// 设置 Telegram Webhook
  Future<void> setTelegramWebhook(String host) async {
    await Http.post(API.TELEGRAM_WEBHOOK, data: {'host': host});
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

  /// 导出完整数据备份
  Future<BackupDownload> exportBackup() async {
    try {
      final response = await DioClient.dio.get<List<int>>(
        API.setupBackup,
        options: Options(
          responseType: ResponseType.bytes,
          extra: const {'allowAnySucceed': true},
        ),
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw StateError('备份文件为空');
      }

      final fileName = _normalizeBackupFileName(
        _backupFileNameFromHeaders(response.headers) ??
            _defaultBackupFileName(),
      );
      AppLogger.info('数据备份导出完成: fileName=$fileName, size=${data.length}');
      return BackupDownload(
        bytes: Uint8List.fromList(data),
        fileName: fileName,
      );
    } on DioException catch (e, st) {
      AppLogger.error('数据备份导出失败: response=${e.response?.data}', e, st);
      rethrow;
    }
  }

  /// 导入完整数据备份
  Future<String> importBackup({required PlatformFile file}) async {
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
        API.setupBackup,
        data: formData,
        options: Options(extra: const {'allowAnySucceed': true}),
      );
      AppLogger.info('数据备份导入已提交: ${response.data}');

      final data = response.data;
      if (data is Map && data['msg'] != null) {
        return data['msg'].toString();
      }
      return '数据备份导入任务已提交';
    } on DioException catch (e, st) {
      AppLogger.error('数据备份导入失败: response=${e.response?.data}', e, st);
      rethrow;
    }
  }

  String? _backupFileNameFromHeaders(Headers headers) {
    final value = headers.value('content-disposition');
    if (value == null || value.trim().isEmpty) return null;

    final encodedMatch = RegExp(
      r'''filename\*=UTF-8''([^;]+)''',
      caseSensitive: false,
    ).firstMatch(value);
    if (encodedMatch != null) {
      final encoded = encodedMatch.group(1)?.trim();
      if (encoded != null && encoded.isNotEmpty) {
        return Uri.decodeFull(encoded);
      }
    }

    final quotedMatch = RegExp(
      r'''filename="?([^";]+)"?''',
      caseSensitive: false,
    ).firstMatch(value);
    return quotedMatch?.group(1)?.trim();
  }

  String _defaultBackupFileName() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    final stamp =
        '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}';
    return 'harvest_backup_$stamp.zip';
  }

  String _normalizeBackupFileName(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.toLowerCase().endsWith('.zip')) return trimmed;
    if (trimmed.toLowerCase().endsWith('.gz')) {
      return '${trimmed.substring(0, trimmed.length - 3)}.zip';
    }
    return '$trimmed.zip';
  }

  /// CookieCloud 同步
  Future<void> syncCookieCloud() async {
    await fetchBasic(API.IMPORT_COOKIE_CLOUD);
    AppLogger.info('CookieCloud 同步任务已提交');
  }

  /// 从旧收割机服务器导入数据
  Future<void> importLegacyHarvestData({
    required String baseUrl,
    required String legacyToken,
  }) async {
    await Http.post<dynamic>(
      API.setupImport,
      data: {'base_url': baseUrl, 'legacy_token': legacyToken},
    );
    AppLogger.info('[Option] 收割机数据导入已提交 baseUrl=$baseUrl');
  }

  /// 从旧版 sqlite3 数据库文件导入数据
  Future<String> importLegacySqlite({required PlatformFile file}) async {
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
        API.setupSqlite,
        data: formData,
        options: Options(extra: const {'allowAnySucceed': true}),
      );
      AppLogger.info('旧版 sqlite3 数据库导入已提交: ${response.data}');

      final data = response.data;
      if (data is Map && data['msg'] != null) {
        return data['msg'].toString();
      }
      return '旧版数据库导入任务已提交';
    } on DioException catch (e, st) {
      AppLogger.error(
        '旧版 sqlite3 数据库导入失败: response=${e.response?.data}',
        e,
        st,
      );
      rethrow;
    }
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
