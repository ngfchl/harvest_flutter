import 'package:freezed_annotation/freezed_annotation.dart';

part 'rank_movie.freezed.dart';
part 'rank_movie.g.dart';

@freezed
abstract class RankMovie with _$RankMovie {
  const factory RankMovie({
    @Default(0) int rank,
    @Default('') @JsonKey(name: 'cover_url') String poster,
    @Default('') String title,
    @Default('') @JsonKey(name: 'url') String doubanUrl,
    @Default([]) List<String> rating,
    @Default(false) @JsonKey(name: 'is_playable') bool isPlayable,
    @Default('') String id,
    @Default([]) List<String> types,
    @Default([]) List<String> regions,
    @Default('') @JsonKey(name: 'release_date') String releaseDate,
    @Default(0) @JsonKey(name: 'actor_count') int actorCount,
    @Default(0) @JsonKey(name: 'vote_count') int voteCount,
    @Default('') String score,
    String? cookie,
    @Default([]) List<String> actors,
    @Default(false) @JsonKey(name: 'is_watched') bool isWatched,
  }) = _RankMovie;

  factory RankMovie.fromJson(Map<String, dynamic> json) =>
      _$RankMovieFromJson(json);
}
