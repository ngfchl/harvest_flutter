import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:harvest/core/utils/utils.dart';

import 'media_item.dart';

part 'search_results.freezed.dart';

@freezed
abstract class SearchResults with _$SearchResults {
  const factory SearchResults({
    @Default(0) int page,
    @Default(0) @JsonKey(name: 'total_pages') int totalPages,
    @Default(0) @JsonKey(name: 'total_results') int totalResults,
    @Default([]) List<MediaItem> results,
    int? id,
    Map<String, dynamic>? dates,
  }) = _SearchResults;

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    final resultsList =
        (json['results'] as List<dynamic>? ?? [])
            .map((item) {
              try {
                return MediaItem.fromTmdbJson(item as Map<String, dynamic>);
              } catch (e, trace) {
                AppLogger.error('Error parsing MediaItem: $e');
                AppLogger.error('Error parsing MediaItem: $trace');
                return null;
              }
            })
            .whereType<MediaItem>()
            .toList()
          ..sort((a, b) => a.releaseDate.compareTo(b.releaseDate));

    return SearchResults(
      page: json['page'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      totalResults: json['total_results'] as int? ?? 0,
      results: resultsList,
      id: json['id'] as int?,
      dates: json['dates'] != null
          ? Map<String, dynamic>.from(json['dates'] as Map)
          : null,
    );
  }
}
