import '../../../../utils/logger_helper.dart';

class MediaItem {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String mediaType;
  final String originalLanguage;
  final double popularity;
  final double? voteAverage;
  final int? voteCount;
  final String releaseDate;
  final List<int> genreIds;
  final bool adult;
  final bool? video; // Movie 特有属性
  final List<String>? originCountry; // TvShow 特有属性

  MediaItem({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.mediaType,
    required this.originalLanguage,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genreIds,
    required this.adult,
    this.video, // 可选属性
    this.originCountry, // 可选属性
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'original_title': originalTitle,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'media_type': mediaType,
      'original_language': originalLanguage,
      'popularity': popularity,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'adult': adult,
      'video': video,
      'origin_country': originCountry,
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    if (json['media_type'] == 'movie') {
      return MediaItem(
        id: json['id'],
        title: json['title'] ?? '',
        originalTitle: json['original_title'] ?? '',
        overview: json['overview'] ?? '',
        posterPath: json['poster_path'] ?? '',
        backdropPath: json['backdrop_path'] ?? '',
        mediaType: json['media_type'] ?? '',
        originalLanguage: json['original_language'] ?? '',
        popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
        voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
        voteCount: json['vote_count'] ?? 0,
        releaseDate: json['release_date'] ?? '',
        genreIds: List<int>.from(json['genre_ids'] ?? []),
        adult: json['adult'] ?? false,
        video: json['video'] ?? false,
      );
    } else if (json['media_type'] == 'tv') {
      return MediaItem(
        id: json['id'],
        title: json['name'] ?? '',
        originalTitle: json['original_name'] ?? '',
        overview: json['overview'] ?? '',
        posterPath: json['poster_path'] ?? '',
        backdropPath: json['backdrop_path'] ?? '',
        mediaType: json['media_type'] ?? '',
        originalLanguage: json['original_language'] ?? '',
        popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
        voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
        voteCount: json['vote_count'] ?? 0,
        releaseDate: json['first_air_date'] ?? '',
        genreIds: List<int>.from(json['genre_ids'] ?? []),
        adult: json['adult'] ?? false,
        originCountry: List<String>.from(json['origin_country'] ?? []),
      );
    } else {
      throw ArgumentError('Unsupported media type: ${json['media_type']}');
    }
  }
}

class SearchResults {
  final int page;
  final int totalPages;
  final int totalResults;
  final List<dynamic> results;

  SearchResults({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    final List<dynamic> resultsList = json['results'] ?? [];
    final List<dynamic> parsedResults = resultsList
        .map((item) {
          try {
            return MediaItem.fromJson(item);
          } catch (e, trace) {
            // 记录异常信息
            Logger.instance.e('Error parsing MediaItem: $e');
            Logger.instance.d('Error parsing MediaItem: $trace');
            return null;
          }
        })
        .whereType<MediaItem>()
        .toList();

    return SearchResults(
      page: json['page'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
      results: parsedResults,
    );
  }
}

class TvShowDetail {
  final bool adult;
  final String? backdropPath;
  final List<dynamic> createdBy;
  final List<dynamic> episodeRunTime;
  final String? releaseDate;
  final List<Genre> genres;
  final String? homepage;
  final int id;
  String? imdbId;
  String mediaType = 'tv';
  final bool inProduction;
  final List<dynamic> languages;
  final String? lastAirDate;
  final LastEpisodeToAir? lastEpisodeToAir;
  final String title;
  final dynamic nextEpisodeToAir;
  final List<Network> networks;
  final int numberOfEpisodes;
  final int numberOfSeasons;
  final List<String> originCountry;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String? posterPath;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final List<Season> seasons;
  final List<dynamic> spokenLanguages;
  final String status;
  final String tagline;
  final String type;
  final double voteAverage;
  final int voteCount;

  TvShowDetail({
    required this.adult,
    this.backdropPath,
    required this.createdBy,
    required this.episodeRunTime,
    required this.releaseDate,
    required this.genres,
    this.homepage,
    required this.id,
    this.imdbId,
    required this.mediaType,
    required this.inProduction,
    required this.languages,
    this.lastAirDate,
    this.lastEpisodeToAir,
    required this.title,
    this.nextEpisodeToAir,
    required this.networks,
    required this.numberOfEpisodes,
    required this.numberOfSeasons,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    this.posterPath,
    required this.productionCompanies,
    required this.productionCountries,
    required this.seasons,
    required this.spokenLanguages,
    required this.status,
    required this.tagline,
    required this.type,
    required this.voteAverage,
    required this.voteCount,
  });

  factory TvShowDetail.fromJson(Map<String, dynamic> json) {
    return TvShowDetail(
      adult: json['adult'],
      backdropPath: json['backdrop_path'],
      createdBy: List<dynamic>.from(json['created_by']),
      episodeRunTime: List<dynamic>.from(json['episode_run_time']),
      releaseDate: json['first_air_date'],
      genres: List<Genre>.from(json['genres'].map((x) => Genre.fromJson(x))),
      homepage: json['homepage'],
      id: json['id'],
      imdbId: json['imdb_id'],
      mediaType: 'tv',
      inProduction: json['in_production'],
      languages: List<dynamic>.from(json['languages']),
      lastAirDate: json['last_air_date'],
      lastEpisodeToAir:
          json['last_episode_to_air'] != null ? LastEpisodeToAir.fromJson(json['last_episode_to_air']) : null,
      title: json['name'],
      nextEpisodeToAir: json['next_episode_to_air'],
      networks: List<Network>.from(json['networks'].map((x) => Network.fromJson(x))),
      numberOfEpisodes: json['number_of_episodes'],
      numberOfSeasons: json['number_of_seasons'],
      originCountry: List<String>.from(json['origin_country']),
      originalLanguage: json['original_language'],
      originalTitle: json['original_name'],
      overview: json['overview'],
      popularity: json['popularity'].toDouble(),
      posterPath: json['poster_path'],
      productionCompanies:
          List<ProductionCompany>.from(json['production_companies'].map((x) => ProductionCompany.fromJson(x))),
      productionCountries:
          List<ProductionCountry>.from(json['production_countries'].map((x) => ProductionCountry.fromJson(x))),
      seasons: List<Season>.from(json['seasons'].map((x) => Season.fromJson(x))),
      spokenLanguages: List<dynamic>.from(json['spoken_languages']),
      status: json['status'],
      tagline: json['tagline'],
      type: json['type'],
      voteAverage: json['vote_average'].toDouble(),
      voteCount: json['vote_count'],
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
    );
  }
}

class LastEpisodeToAir {
  final int id;
  final String name;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String airDate;
  final int episodeNumber;
  final String episodeType;
  final String productionCode;
  final dynamic runtime;
  final int seasonNumber;
  final int showId;
  final dynamic stillPath;

  LastEpisodeToAir({
    required this.id,
    required this.name,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.airDate,
    required this.episodeNumber,
    required this.episodeType,
    required this.productionCode,
    this.runtime,
    required this.seasonNumber,
    required this.showId,
    this.stillPath,
  });

  factory LastEpisodeToAir.fromJson(Map<String, dynamic> json) {
    return LastEpisodeToAir(
      id: json['id'],
      name: json['name'],
      overview: json['overview'],
      voteAverage: json['vote_average'].toDouble(),
      voteCount: json['vote_count'],
      airDate: json['air_date'],
      episodeNumber: json['episode_number'],
      episodeType: json['episode_type'] ?? '',
      productionCode: json['production_code'],
      runtime: json['runtime'],
      seasonNumber: json['season_number'],
      showId: json['show_id'],
      stillPath: json['still_path'],
    );
  }
}

class Network {
  final int id;
  final String logoPath;
  final String name;
  final String originCountry;

  Network({
    required this.id,
    required this.logoPath,
    required this.name,
    required this.originCountry,
  });

  factory Network.fromJson(Map<String, dynamic> json) {
    return Network(
      id: json['id'],
      logoPath: json['logo_path'] ?? '',
      name: json['name'],
      originCountry: json['origin_country'],
    );
  }
}

class ProductionCompany {
  final int id;
  final dynamic logoPath;
  final String name;
  final String originCountry;

  ProductionCompany({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'],
      logoPath: json['logo_path'],
      name: json['name'],
      originCountry: json['origin_country'],
    );
  }
}

class ProductionCountry {
  final String iso31661;
  final String name;

  ProductionCountry({
    required this.iso31661,
    required this.name,
  });

  factory ProductionCountry.fromJson(Map<String, dynamic> json) {
    return ProductionCountry(
      iso31661: json['iso_3166_1'],
      name: json['name'],
    );
  }
}

class Season {
  final String airDate;
  final int episodeCount;
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final int seasonNumber;
  final double voteAverage;

  Season({
    required this.airDate,
    required this.episodeCount,
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.seasonNumber,
    required this.voteAverage,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      airDate: json['air_date'] ?? '',
      episodeCount: json['episode_count'],
      id: json['id'],
      name: json['name'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      seasonNumber: json['season_number'],
      voteAverage: json['vote_average'] ?? 0,
    );
  }
}

class MovieDetail {
  final bool adult;
  final String backdropPath;
  final BelongsToCollection? belongsToCollection;
  final int budget;
  final List<Genre> genres;
  final String homepage;
  final int id;
  final String imdbId;
  final String mediaType = 'movie';
  final List<String> originCountry;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String posterPath;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final String releaseDate;
  final int revenue;
  final int runtime;
  final List<SpokenLanguage> spokenLanguages;
  final String status;
  final String tagline;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;

  MovieDetail({
    required this.adult,
    required this.backdropPath,
    this.belongsToCollection,
    required this.budget,
    required this.genres,
    required this.homepage,
    required this.id,
    required this.imdbId,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.productionCompanies,
    required this.productionCountries,
    required this.releaseDate,
    required this.revenue,
    required this.runtime,
    required this.spokenLanguages,
    required this.status,
    required this.tagline,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
    required String mediaType,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      adult: json['adult'],
      backdropPath: json['backdrop_path'] ?? '',
      belongsToCollection:
          json['belongs_to_collection'] != null ? BelongsToCollection.fromJson(json['belongs_to_collection']) : null,
      budget: json['budget'],
      genres: (json['genres'] as List).map((e) => Genre.fromJson(e)).toList(),
      homepage: json['homepage'],
      id: json['id'],
      imdbId: json['imdb_id'] ?? '',
      mediaType: 'movie',
      originCountry: List<String>.from(json['origin_country'] ?? []),
      originalLanguage: json['original_language'],
      originalTitle: json['original_title'],
      overview: json['overview'],
      popularity: json['popularity'].toDouble(),
      posterPath: json['poster_path'],
      productionCompanies: (json['production_companies'] as List).map((e) => ProductionCompany.fromJson(e)).toList(),
      productionCountries: (json['production_countries'] as List).map((e) => ProductionCountry.fromJson(e)).toList(),
      releaseDate: json['release_date'],
      revenue: json['revenue'],
      runtime: json['runtime'],
      spokenLanguages: (json['spoken_languages'] as List).map((e) => SpokenLanguage.fromJson(e)).toList(),
      status: json['status'],
      tagline: json['tagline'],
      title: json['title'],
      video: json['video'],
      voteAverage: json['vote_average'].toDouble(),
      voteCount: json['vote_count'],
    );
  }
}

class BelongsToCollection {
  final int id;
  final String name;
  final String posterPath;
  final String backdropPath;

  BelongsToCollection({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.backdropPath,
  });

  factory BelongsToCollection.fromJson(Map<String, dynamic> json) {
    return BelongsToCollection(
      id: json['id'],
      name: json['name'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'] ?? '',
    );
  }
}

class SpokenLanguage {
  final String englishName;
  final String iso6391;
  final String name;

  SpokenLanguage({
    required this.englishName,
    required this.iso6391,
    required this.name,
  });

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) {
    return SpokenLanguage(
      englishName: json['english_name'],
      iso6391: json['iso_639_1'],
      name: json['name'],
    );
  }
}

class Person {
  final int id;
  final String? posterPath;
  final bool adult;
  final double popularity;
  final String? backdropPath;
  final double? voteAverage;
  final String? overview;
  final String? firstAirDate;
  final List<String>? originCountry;
  final List<int>? genreIds;
  final String? originalLanguage;
  final int? voteCount;
  final String name;
  final String originalName;
  final String mediaType;
  final String profilePath;
  final List<KnownFor> knownFor;
  final String knownForDepartment;
  final int gender;

  Person({
    required this.id,
    this.posterPath,
    required this.adult,
    required this.popularity,
    this.backdropPath,
    this.voteAverage,
    this.overview,
    this.firstAirDate,
    this.originCountry,
    this.genreIds,
    this.originalLanguage,
    this.voteCount,
    required this.name,
    required this.originalName,
    required this.mediaType,
    required this.profilePath,
    required this.knownFor,
    required this.knownForDepartment,
    required this.gender,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      posterPath: json['poster_path'],
      adult: json['adult'],
      popularity: json['popularity'].toDouble(),
      backdropPath: json['backdrop_path'],
      voteAverage: json['vote_average']?.toDouble(),
      overview: json['overview'],
      firstAirDate: json['first_air_date'],
      originCountry: json['origin_country'] != null ? List<String>.from(json['origin_country']) : null,
      genreIds: json['genre_ids'] != null ? List<int>.from(json['genre_ids']) : null,
      originalLanguage: json['original_language'],
      voteCount: json['vote_count'],
      name: json['name'],
      originalName: json['original_name'],
      mediaType: json['media_type'],
      profilePath: json['profile_path'],
      knownFor:
          json['known_for'] != null ? List<KnownFor>.from(json['known_for'].map((x) => KnownFor.fromJson(x))) : [],
      knownForDepartment: json['known_for_department'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['poster_path'] = posterPath;
    data['adult'] = adult;
    data['popularity'] = popularity;
    data['backdrop_path'] = backdropPath;
    data['vote_average'] = voteAverage;
    data['overview'] = overview;
    data['first_air_date'] = firstAirDate;
    data['origin_country'] = originCountry;
    data['genre_ids'] = genreIds;
    data['original_language'] = originalLanguage;
    data['vote_count'] = voteCount;
    data['name'] = name;
    data['original_name'] = originalName;
    data['media_type'] = mediaType;
    data['profile_path'] = profilePath;
    data['known_for'] = knownFor.map((x) => x.toJson()).toList();
    data['known_for_department'] = knownForDepartment;
    data['gender'] = gender;
    return data;
  }
}

class KnownFor {
  final int id;
  final String? posterPath;
  final bool adult;
  final double popularity;
  final String? backdropPath;
  final double voteAverage;
  final String overview;
  final String? firstAirDate;
  final List<String>? originCountry;
  final List<int> genreIds;
  final String originalLanguage;
  final int voteCount;
  final String? name;
  final String? originalName;
  final String mediaType;
  final String? releaseDate;
  final String? originalTitle;
  final String? title;
  final bool video;

  KnownFor({
    required this.id,
    this.posterPath,
    required this.adult,
    required this.popularity,
    this.backdropPath,
    required this.voteAverage,
    required this.overview,
    this.firstAirDate,
    this.originCountry,
    required this.genreIds,
    required this.originalLanguage,
    required this.voteCount,
    this.name,
    this.originalName,
    required this.mediaType,
    this.releaseDate,
    this.originalTitle,
    this.title,
    required this.video,
  });

  factory KnownFor.fromJson(Map<String, dynamic> json) {
    return KnownFor(
      id: json['id'],
      posterPath: json['poster_path'],
      adult: json['adult'],
      popularity: json['popularity'].toDouble(),
      backdropPath: json['backdrop_path'],
      voteAverage: json['vote_average']?.toDouble() ?? 0.0,
      overview: json['overview'] ?? '',
      firstAirDate: json['first_air_date'],
      originCountry: json['origin_country'] != null ? List<String>.from(json['origin_country']) : null,
      genreIds: json['genre_ids'] != null ? List<int>.from(json['genre_ids']) : [],
      originalLanguage: json['original_language'] ?? '',
      voteCount: json['vote_count'] ?? 0,
      name: json['name'],
      originalName: json['original_name'],
      mediaType: json['media_type'],
      releaseDate: json['release_date'],
      originalTitle: json['original_title'],
      title: json['title'],
      video: json['video'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['poster_path'] = posterPath;
    data['adult'] = adult;
    data['popularity'] = popularity;
    data['backdrop_path'] = backdropPath;
    data['vote_average'] = voteAverage;
    data['overview'] = overview;
    data['first_air_date'] = firstAirDate;
    data['origin_country'] = originCountry;
    data['genre_ids'] = genreIds;
    data['original_language'] = originalLanguage;
    data['vote_count'] = voteCount;
    data['name'] = name;
    data['original_name'] = originalName;
    data['media_type'] = mediaType;
    data['release_date'] = releaseDate;
    data['original_title'] = originalTitle;
    data['title'] = title;
    data['video'] = video;
    return data;
  }
}
