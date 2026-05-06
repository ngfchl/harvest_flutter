import 'package:freezed_annotation/freezed_annotation.dart';

import 'search_torrent_info.dart';

part 'search_state.freezed.dart';

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default([]) List<SearchTorrentInfo> results,
    @Default(false) bool isLoading,
    @Default([]) List<String> messages,
    String? error,
  }) = _SearchState;
}
