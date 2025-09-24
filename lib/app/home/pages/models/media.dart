import 'package:intl/intl.dart';

class Media {
  bool adult;
  String backdropPath;
  List<int> genreIds;
  int id;
  List<String>? originCountry;
  String originalLanguage;
  late String originalName;
  late String title;
  String overview;
  double popularity;
  String posterPath;
  late DateTime? firstAirDate;
  late DateTime? releaseDate;
  double voteAverage;
  int voteCount;

  Media({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
    required this.id,
    this.originCountry,
    required this.originalLanguage,
    required this.originalName,
    this.title = '',
    required this.overview,
    required this.popularity,
    required this.posterPath,
    this.firstAirDate,
    this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    final formatter = DateFormat('yyyy-MM-dd');
    DateTime? airOrReleaseDate;

    if (json.containsKey('first_air_date')) {
      airOrReleaseDate = formatter.parse(json['first_air_date']);
    } else if (json.containsKey('release_date')) {
      airOrReleaseDate = formatter.parse(json['release_date']);
    }

    return Media(
      adult: json['adult'],
      backdropPath: json['backdrop_path'],
      genreIds: List.castFrom<dynamic, int>(json['genre_ids']),
      id: json['id'],
      originCountry: json['origin_country'] != null
          ? List.castFrom<dynamic, String>(json['origin_country'])
          : null,
      originalLanguage: json['original_language'],
      originalName: json.containsKey('original_name')
          ? json['original_name']
          : json['original_title'],
      title: json.containsKey('name') ? json['name'] : json['title'],
      overview: json['overview'],
      popularity: json['popularity'].toDouble(),
      posterPath: json['poster_path'],
      firstAirDate:
          json.containsKey('first_air_date') ? airOrReleaseDate : null,
      releaseDate: json.containsKey('release_date') ? airOrReleaseDate : null,
      voteAverage: json['vote_average'].toDouble(),
      voteCount: json['vote_count'],
    );
  }
}
