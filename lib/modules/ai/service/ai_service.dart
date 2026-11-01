import 'package:dio/dio.dart';
import 'package:harvest/core/http/http.dart';

import '../model/ai_models.dart';

/// AI 管理相关接口。
class AiService {
  AiService._();

  static const String _providers = '/api/ai/providers';
  static const String _providerTest = '/api/ai/providers/test';
  static const String _chat = '/api/ai/assistant/chat';
  static const String _history = '/api/ai/assistant/history';
  static const String _historyDates = '/api/ai/assistant/history/dates';
  static const String _usage = '/api/ai/usage';
  static const String _diagnostics = '/api/ai/diagnostics/run';

  /// 关闭全局错误 Toast，由 UI 层展示更精确的 AI 错误。
  static final Options _noToast = Options(extra: {'suppressErrorToast': true});

  /// AI 推理耗时较长，单独放宽接收超时（对齐后端 timeout_seconds 上限并留余量）。
  static final Options _slowNoToast = Options(
    extra: {'suppressErrorToast': true},
    receiveTimeout: const Duration(seconds: 120),
  );

  /// 统一处理 AI 接口返回体为空的情况。
  ///
  /// 后端在 AI 调用失败时可能返回 HTTP 200 但 body 为空（老版本行为），
  /// 此时无法解析出 data，需要给出可读的错误而不是抛出类型转换异常。
  static Future<T> _guard<T>(Future<T> Function() run, String emptyHint) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw _friendly(e, emptyHint);
    } catch (e) {
      final text = e.toString();
      // 空 body 时 Dio 会把 data 解析成空字符串，进而引发 cast 异常。
      if (text.contains("type 'Null'") ||
          text.contains("type 'String'") ||
          text.contains("is not a subtype") ||
          text.contains("null")) {
        throw Exception(emptyHint);
      }
      rethrow;
    }
  }

  static Exception _friendly(DioException e, String emptyHint) {
    final data = e.response?.data;
    if (data is Map && data['msg'] is String && (data['msg'] as String).isNotEmpty) {
      return Exception(_enhance(data['msg'] as String));
    }
    if (data == null || (data is String && data.trim().isEmpty)) {
      return Exception(emptyHint);
    }
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      return Exception('AI 响应超时：模型推理较慢，请稍后重试或调大配置中的超时时间');
    }
    final msg = e.message ?? '';
    if (msg.contains('SocketException') || msg.contains('Connection')) {
      return Exception('无法连接服务器，请检查网络');
    }
    if (msg.toLowerCase().contains('timeout')) {
      return Exception('AI 响应超时：模型推理较慢，请稍后重试');
    }
    return Exception(emptyHint);
  }

  /// 对后端返回的错误做去重与可操作化提示。
  static String _enhance(String raw) {
    var msg = raw.trim();
    // 后端可能已在错误里带 "AI 请求失败：..."，去掉重复前缀。
    msg = msg.replaceFirst(RegExp(r'^AI (回答|测试|诊断)失败：(?=AI 请求失败)'), '');
    if (msg.contains('401') || msg.toLowerCase().contains('invalid api key') || msg.contains('API Key')) {
      if (!msg.contains('API Key')) return '$msg（API Key 可能无效，请在「AI 配置」中更新）';
      return '$msg\n请在「AI 配置」中确认 API Key 是否有效。';
    }
    return msg;
  }

  static Future<AiConfig> fetchConfig() => _guard(() async {
        final data = await Http.get<Map<dynamic, dynamic>>(_providers, options: _noToast);
        return AiConfig.fromJson(Map<String, dynamic>.from(data));
      }, '获取 AI 配置失败：服务端未返回数据');

  static Future<AiConfig> saveConfig(AiConfig config) => _guard(() async {
        final data = await Http.put<Map<dynamic, dynamic>>(_providers, data: config.toJson(), options: _noToast);
        return AiConfig.fromJson(Map<String, dynamic>.from(data));
      }, '保存 AI 配置失败：服务端未返回数据');

  static Future<AiTestResult> testProvider() => _guard(() async {
        final data = await Http.post<Map<dynamic, dynamic>>(_providerTest, options: _slowNoToast);
        return AiTestResult.fromJson(Map<String, dynamic>.from(data));
      }, 'AI 测试失败：服务端未返回数据。请确认已填写有效的 API Key，并检查 Base URL 与模型名称');

  static Future<AiChatResult> chat(String message, {String system = ''}) => _guard(() async {
        final data = await Http.post<Map<dynamic, dynamic>>(
          _chat,
          data: {
            'message': message,
            if (system.trim().isNotEmpty) 'system': system.trim(),
          },
          options: _slowNoToast,
        );
        return AiChatResult.fromJson(Map<String, dynamic>.from(data));
      }, 'AI 回答失败：服务端未返回数据。请检查 AI 配置是否正确、额度是否充足');

  static Future<List<String>> fetchHistoryDates({int limit = 100}) => _guard(() async {
        final data = await Http.get<Map<dynamic, dynamic>>(
          _historyDates,
          queryParameters: {'limit': limit},
          options: _noToast,
        );
        return AiChatHistoryDates.fromJson(Map<String, dynamic>.from(data)).dates;
      }, '获取聊天历史日期失败：服务端未返回数据');

  static Future<AiChatHistoryPage> fetchHistory({String? date, int cursor = 0, int limit = 20}) => _guard(() async {
        final data = await Http.get<Map<dynamic, dynamic>>(
          _history,
          queryParameters: {
            if (date != null && date.isNotEmpty) 'date': date,
            'cursor': cursor,
            'limit': limit,
          },
          options: _noToast,
        );
        return AiChatHistoryPage.fromJson(Map<String, dynamic>.from(data));
      }, '获取聊天历史失败：服务端未返回数据');

  static Future<AiUsage> fetchUsage() => _guard(() async {
        final data = await Http.get<Map<dynamic, dynamic>>(_usage, options: _noToast);
        return AiUsage.fromJson(Map<String, dynamic>.from(data));
      }, '获取 AI 用量失败：服务端未返回数据');

  static Future<AiDiagnosisReport> runDiagnostics() => _guard(() async {
        final data = await Http.post<Map<dynamic, dynamic>>(_diagnostics, options: _noToast);
        return AiDiagnosisReport.fromJson(Map<String, dynamic>.from(data));
      }, 'AI 诊断失败：服务端未返回数据');
}
