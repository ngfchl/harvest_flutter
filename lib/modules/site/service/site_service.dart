import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/dio_client.dart';
import 'package:harvest/core/http/http.dart';
import 'package:harvest/core/http/hooks.dart';
import 'package:harvest/core/http/interceptors/response_interceptor.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/site_config.dart';
import '../model/site_info.dart';

class SiteService {
  SiteService._();

  static const String _websiteList = API.WEBSITE_LIST;
  static const String _websiteToAdd = API.WEBSITE_TO_ADD;
  static const String _mysiteList = API.MYSITE_LIST;
  static const String _clearCache = API.CLEAR_CACHE;
  static const String _mysiteStatus = API.MYSITE_STATUS_OPERATE;
  static const String _mysiteSignin = API.MYSITE_SIGNIN_OPERATE;
  static const String _mysiteRepeat = API.MYSITE_REPEAT_OPERATE;
  static const String _importCustomSiteToml = API.Import_Custom_Site_Toml;

  static Future<List<WebSite>> fetchWebsiteList() {
    return fetchModelList(_websiteList, WebSite.fromJson);
  }

  static Future<Map<String, dynamic>> fetchWebsiteConfig(String site) async {
    final data = await Http.get<dynamic>(
      '$_websiteList/${Uri.encodeComponent(site)}',
    );
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) return {'content': data};
    return const <String, dynamic>{};
  }

  static Future<List<String>> fetchUnadded() async {
    return List<String>.from(await fetchBasicList(_websiteToAdd));
  }

  static Future<List<SiteInfo>> fetchMySiteList() {
    return fetchModelList(_mysiteList, SiteInfo.fromJson);
  }

  static Future<void> createSite(SiteInfo site) {
    return addData(_mysiteList, site.toJson());
  }

  static Future<void> importCustomSiteToml(
    List<PlatformFile> files, {
    bool overwrite = false,
  }) async {
    AppLogger.info(
      '开始上传自定义站点配置: files=${files.map((file) => file.name).join(', ')}, overwrite=$overwrite',
    );
    final formData = FormData();
    formData.fields.add(MapEntry('overwrite', overwrite.toString()));

    for (final file in files) {
      if (file.path == null && file.bytes == null) {
        throw StateError('无法读取文件: ${file.name}');
      }
      final multipart = file.bytes != null
          ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
          : await MultipartFile.fromFile(file.path!, filename: file.name);
      formData.files.add(MapEntry('files', multipart));
    }

    try {
      final response = await DioClient.dio.post(
        _importCustomSiteToml,
        data: formData,
        options: Options(extra: const {'allowAnySucceed': true}),
      );
      AppLogger.info('自定义站点配置上传完成: ${response.data}');
    } on DioException catch (e, st) {
      AppLogger.error('自定义站点配置上传接口异常: response=${e.response?.data}', e, st);
      rethrow;
    }
  }

  static Future<void> updateSite(SiteInfo site) {
    return editData('$_mysiteList/${site.id}', site.toJson());
  }

  static Future<void> deleteSite(int id) {
    return removeData('$_mysiteList/$id');
  }

  static Future<String> refreshSiteStatus(int siteId) {
    return _operateSite('$_mysiteStatus$siteId', fallback: '刷新成功');
  }

  static Future<String> signInSite(int siteId) {
    return _operateSite('$_mysiteSignin$siteId', fallback: '签到成功');
  }

  static Future<String> repeatTorrents(int siteId) {
    return _operateSite('$_mysiteRepeat$siteId', fallback: '辅种任务已提交');
  }

  static Future<void> clearCache() {
    return fetchBasic(_clearCache);
  }

  static Future<String> _operateSite(
    String apiEndpoint, {
    required String fallback,
  }) async {
    final response = await DioClient.dio.get<dynamic>(apiEndpoint);
    final message =
        response.extra[ResponseInterceptor.responseMessageKey]?.toString() ??
        response.requestOptions.extra[ResponseInterceptor.responseMessageKey]
            ?.toString() ??
        fallback;
    return message.trim().isEmpty ? fallback : message.trim();
  }
}
