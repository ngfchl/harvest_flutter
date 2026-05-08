import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_item.freezed.dart';
part 'media_item.g.dart';

@freezed
abstract class MediaItem with _$MediaItem {
  const factory MediaItem({
    @Default(0) int id,
    @Default('') String title,
    @Default('') @JsonKey(name: 'original_title') String originalTitle,
    @Default('') String overview,
    @Default('') @JsonKey(name: 'poster_path') String posterPath,
    @Default('') @JsonKey(name: 'backdrop_path') String backdropPath,
    @Default('') @JsonKey(name: 'media_type') String mediaType,
    @Default('') @JsonKey(name: 'original_language') String originalLanguage,
    @Default(0.0) double popularity,
    @Default(0.0) @JsonKey(name: 'vote_average') double? voteAverage,
    @Default(0) @JsonKey(name: 'vote_count') int? voteCount,
    @Default('') @JsonKey(name: 'release_date') String releaseDate,
    @Default([]) @JsonKey(name: 'genre_ids') List<int> genreIds,
    @Default(false) bool adult,
    bool? video,
    @Default([]) @JsonKey(name: 'origin_country') List<String>? originCountry,
  }) = _MediaItem;

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);

  /// movie → title/original_title/release_date/video
  /// tv    → name/original_name/first_air_date/origin_country
  /// 归一化后再调 fromJson
  static MediaItem fromTmdbJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    m['title'] ??= m['name'];
    m['original_title'] ??= m['original_name'];
    m['release_date'] ??= m['first_air_date'];
    return MediaItem.fromJson(m);
  }
}
