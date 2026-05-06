import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/search_torrent_info.dart';
import '../service/resource_search_service.dart';

class SearchMessage {
  final String text;
  final bool isError;
  final DateTime time;

  SearchMessage(this.text, {this.isError = false}) : time = DateTime.now();
}

class ResourceSearchState {
  final bool searching;
  final List<SearchTorrentInfo> results;
  final List<SearchMessage> messages;
  final String query;

  const ResourceSearchState({
    this.searching = false,
    this.results = const [],
    this.messages = const [],
    this.query = '',
  });

  ResourceSearchState copyWith({
    bool? searching,
    List<SearchTorrentInfo>? results,
    List<SearchMessage>? messages,
    String? query,
  }) {
    return ResourceSearchState(
      searching: searching ?? this.searching,
      results: results ?? this.results,
      messages: messages ?? this.messages,
      query: query ?? this.query,
    );
  }
}

class ResourceSearchNotifier extends StateNotifier<ResourceSearchState> {
  StreamSubscription? _subscription;

  ResourceSearchNotifier() : super(const ResourceSearchState());

  void search(String query, {int maxCount = 5, List<String> sites = const []}) {
    _subscription?.cancel();
    state = ResourceSearchState(
      searching: true,
      query: query,
      messages: [SearchMessage('开始搜索「$query」...')],
    );

    _subscription =
        ResourceSearchService.search(
          query,
          maxCount: maxCount,
          sites: sites,
        ).listen(
          (event) {
            if (!mounted) return;

            if (event.code == -1) {
              state = state.copyWith(
                messages: [
                  ...state.messages,
                  SearchMessage(event.msg, isError: true),
                ],
              );
              return;
            }

            // Completion signal
            if (event.data == false || event.data == null) {
              state = state.copyWith(
                searching: false,
                messages: [...state.messages, SearchMessage(event.msg)],
              );
              return;
            }

            // Results
            if (event.data is List) {
              final newItems = (event.data as List)
                  .map(
                    (e) =>
                        SearchTorrentInfo.fromJson(e as Map<String, dynamic>),
                  )
                  .toList();

              state = state.copyWith(
                results: [...state.results, ...newItems],
                messages: [...state.messages, SearchMessage(event.msg)],
              );
            }
          },
          onError: (e) {
            if (!mounted) return;
            state = state.copyWith(
              searching: false,
              messages: [
                ...state.messages,
                SearchMessage('搜索出错: $e', isError: true),
              ],
            );
          },
          onDone: () {
            if (!mounted) return;
            if (state.searching) {
              state = state.copyWith(searching: false);
            }
          },
        );
  }

  void clear() {
    _subscription?.cancel();
    state = const ResourceSearchState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final resourceSearchProvider =
    StateNotifierProvider.autoDispose<
      ResourceSearchNotifier,
      ResourceSearchState
    >((ref) {
      return ResourceSearchNotifier();
    });
