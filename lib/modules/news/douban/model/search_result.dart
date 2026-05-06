import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result.freezed.dart';
part 'search_result.g.dart';

@freezed
abstract class DoubanRating with _$DoubanRating {
  const factory DoubanRating({
    @Default(0) int count,
    @Default(0) int max,
    @Default(0.0) @JsonKey(name: 'star_count') double starCount,
    @Default(0.0) double value,
  }) = _DoubanRating;

  factory DoubanRating.fromJson(Map<String, dynamic> json) => _$DoubanRatingFromJson(json);
}

@freezed
abstract class SearchTarget with _$SearchTarget {
  const factory SearchTarget({
    @Default('') String abstract,
    @Default('') @JsonKey(name: 'card_subtitle') String cardSubtitle,
    @Default('') @JsonKey(name: 'controversy_reason') String controversyReason,
    @Default('') @JsonKey(name: 'cover_url') String coverUrl,
    @Default(false) @JsonKey(name: 'has_linewatch') bool hasLinewatch,
    @Default('') String id,
    @Default('') @JsonKey(name: 'null_rating_reason') String nullRatingReason,
    @Default(DoubanRating()) DoubanRating rating,
    @Default('') String title,
    @Default('') String uri,
    @Default('') String year,
  }) = _SearchTarget;

  factory SearchTarget.fromJson(Map<String, dynamic> json) => _$SearchTargetFromJson(json);
}

@freezed
abstract class DoubanSearchResult with _$DoubanSearchResult {
  const factory DoubanSearchResult({
    @Default('') String layout,
    @Default(SearchTarget()) SearchTarget target,
    @Default('') @JsonKey(name: 'target_id') String targetId,
    @Default('') @JsonKey(name: 'target_type') String targetType,
    @Default('') @JsonKey(name: 'type_name') String typeName,
  }) = _DoubanSearchResult;

  factory DoubanSearchResult.fromJson(Map<String, dynamic> json) => _$DoubanSearchResultFromJson(json);
}
