import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/http/http.dart';

import 'package:harvest/core/utils/utils.dart';
import '../model/search_state.dart';
import '../model/search_torrent_info.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  CancelToken? _cancelToken;

  SearchNotifier() : super(const SearchState());

  Future<void> search(String keyword, {int maxCount = 5, List<String> sites = const []}) async {
    if (keyword.trim().isEmpty) return;

    // 取消上一次搜索
    cancel();
    state = const SearchState(isLoading: true);
    _cancelToken = CancelToken();
    AppLogger.info("开始搜索「$keyword」... 最大允许搜索 $maxCount 个站点  站点: ${sites.join(', ')}");
    try {
      final response = await Http.post(
        '/api/mysite/search',
        data: {'key': keyword.trim(), 'max_count': maxCount, 'sites': sites},
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream', 'Cache-Control': 'no-cache'},
        ),
        cancelToken: _cancelToken,
      );

      final responseBody = response.data as ResponseBody;
      String buffer = '';

      await for (final chunk in responseBody.stream) {
        if (_cancelToken?.isCancelled == true) break;

        buffer += utf8.decode(chunk);

        // SSE 事件以 \n\n 分隔
        while (buffer.contains('\n\n')) {
          final index = buffer.indexOf('\n\n');
          final event = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 2);

          if (event.isEmpty) continue;
          _processEvent(event);
        }
      }

      // 处理缓冲区剩余内容
      final remaining = buffer.trim();
      if (remaining.isNotEmpty) {
        _processEvent(remaining);
      }

      if (_cancelToken?.isCancelled != true) {
        state = state.copyWith(isLoading: false);
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel) {
        state = state.copyWith(isLoading: false, error: '搜索请求失败: ${e.message}');
      }
    } catch (e, trace) {
      AppLogger.error(e);
      AppLogger.error(trace);
      state = state.copyWith(isLoading: false, error: '搜索出错: $e');
    }
  }

  void _processEvent(String event) {
    try {
      String jsonData = event;
      if (jsonData.startsWith('data: ')) {
        jsonData = jsonData.substring(6);
      } else if (jsonData.startsWith('data:')) {
        jsonData = jsonData.substring(5);
      }

      if (jsonData.isEmpty) return;

      final parsed = jsonDecode(jsonData) as Map<String, dynamic>;
      final code = parsed['code'] as int;
      final msg = parsed['msg'] as String? ?? '';
      final data = parsed['data'];

      // 追加消息
      state = state.copyWith(messages: [...state.messages, msg]);

      if (code == 0 && data is List) {
        // 正常搜索结果
        final torrents = data.map((e) => SearchTorrentInfo.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(results: [...state.results, ...torrents]);
      } else if (code == -1) {
        // 某站点搜索失败，记录日志
        AppLogger.error('站点搜索失败: $msg');
      }
      // data == false 表示搜索完成，由外层 isLoading = false 处理
    } catch (e, trace) {
      AppLogger.error('解析SSE事件失败: $e');
      AppLogger.error(trace);
    }
  }

  void cancel() {
    _cancelToken?.cancel('用户取消搜索');
    _cancelToken = null;
    if (state.isLoading) {
      state = state.copyWith(isLoading: false);
    }
  }

  void clear() {
    cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  final notifier = SearchNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
