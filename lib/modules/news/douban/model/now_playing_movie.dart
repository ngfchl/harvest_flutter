import 'package:freezed_annotation/freezed_annotation.dart';

part 'now_playing_movie.freezed.dart';
part 'now_playing_movie.g.dart';

@freezed
abstract class DoubanCover with _$DoubanCover {
  const factory DoubanCover({
    @Default('') String url,
    @Default(0) int width,
    @Default(0) int height,
  }) = _DoubanCover;

  factory DoubanCover.fromJson(Map<String, dynamic> json) =>
      _$DoubanCoverFromJson(json);
}

@freezed
abstract class DoubanRating with _$DoubanRating {
  const factory DoubanRating({
    @Default(0) int count,
    @Default(0) num value,
    @Default(0) num starCount,
  }) = _DoubanRating;

  factory DoubanRating.fromJson(Map<String, dynamic> json) =>
      _$DoubanRatingFromJson(json);
}

@freezed
abstract class NowPlayingMovie with _$NowPlayingMovie {
  const factory NowPlayingMovie({
    @Default('') String id,
    @Default('') String title,
    @JsonKey(name: 'original_title') @Default('') String originalTitle,
    @Default('') String year,
    @Default(DoubanCover()) DoubanCover cover,
    DoubanRating? rating,
    @JsonKey(name: 'card_subtitle') @Default('') String cardSubtitle,
    @Default([]) List<String> directors,
    @Default([]) List<String> actors,
    @JsonKey(name: 'release_date') @Default('') String releaseDate,
    @JsonKey(name: 'has_linewatch') @Default(false) bool hasLinewatch,
    @Default('') String uri,
    @Default('') String url,
  }) = _NowPlayingMovie;

  factory NowPlayingMovie.fromJson(Map<String, dynamic> json) =>
      _$NowPlayingMovieFromJson(json);
}
