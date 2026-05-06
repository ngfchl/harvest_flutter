import 'package:freezed_annotation/freezed_annotation.dart';

part 'top_movie.freezed.dart';
part 'top_movie.g.dart';

@freezed
abstract class TopMovie with _$TopMovie {
  const factory TopMovie({
    @Default('') String rank,
    @Default('') @JsonKey(name: 'douban_url') String doubanUrl,
    @Default('') String poster,
    @Default('') String title,
    @Default([]) List<String> subtitle,
    @Default('') String cast,
    @Default([]) List<String> desc,
    @Default('') @JsonKey(name: 'rating_num') String ratingNum,
    @Default('') @JsonKey(name: 'evaluate_num') String evaluateNum,
    @Default('') String quote,
    @Default('') String cookie,
  }) = _TopMovie;

  factory TopMovie.fromJson(Map<String, dynamic> json) => _$TopMovieFromJson(json);
}
