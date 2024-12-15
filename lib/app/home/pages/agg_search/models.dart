class Movie {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String mediaType;
  final String originalLanguage;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final bool adult;
  final bool video;
  final List<int> genreIds;

  Movie({
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
    required this.adult,
    required this.video,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
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
      adult: json['adult'] ?? false,
      video: json['video'] ?? false,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }
}

class TvShow {
  final int id;
  final String title;
  final String originalName;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String mediaType;
  final String originalLanguage;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final String firstAirDate;
  final List<String> originCountry;
  final List<int> genreIds;
  final bool adult;

  TvShow({
    required this.id,
    required this.title,
    required this.originalName,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.mediaType,
    required this.originalLanguage,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.firstAirDate,
    required this.originCountry,
    required this.genreIds,
    required this.adult,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'],
      title: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      mediaType: json['media_type'] ?? '',
      originalLanguage: json['original_language'] ?? '',
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      firstAirDate: json['first_air_date'] ?? '',
      originCountry: List<String>.from(json['origin_country'] ?? []),
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      adult: json['adult'] ?? false,
    );
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
          if (item['media_type'] == 'movie') {
            return Movie.fromJson(item);
          } else if (item['media_type'] == 'tv') {
            return TvShow.fromJson(item);
          } else {
            return null;
          }
        })
        .where((element) => element != null)
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
  final String? firstAirDate;
  final List<Genre> genres;
  final String? homepage;
  final int id;
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
  final String originalName;
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
    this.firstAirDate,
    required this.genres,
    this.homepage,
    required this.id,
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
    required this.originalName,
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
      firstAirDate: json['first_air_date'],
      genres: List<Genre>.from(json['genres'].map((x) => Genre.fromJson(x))),
      homepage: json['homepage'],
      id: json['id'],
      inProduction: json['in_production'],
      languages: List<dynamic>.from(json['languages']),
      lastAirDate: json['last_air_date'],
      lastEpisodeToAir: json['last_episode_to_air'] != null
          ? LastEpisodeToAir.fromJson(json['last_episode_to_air'])
          : null,
      title: json['name'],
      nextEpisodeToAir: json['next_episode_to_air'],
      networks:
          List<Network>.from(json['networks'].map((x) => Network.fromJson(x))),
      numberOfEpisodes: json['number_of_episodes'],
      numberOfSeasons: json['number_of_seasons'],
      originCountry: List<String>.from(json['origin_country']),
      originalLanguage: json['original_language'],
      originalName: json['original_name'],
      overview: json['overview'],
      popularity: json['popularity'].toDouble(),
      posterPath: json['poster_path'],
      productionCompanies: List<ProductionCompany>.from(
          json['production_companies']
              .map((x) => ProductionCompany.fromJson(x))),
      productionCountries: List<ProductionCountry>.from(
          json['production_countries']
              .map((x) => ProductionCountry.fromJson(x))),
      seasons:
          List<Season>.from(json['seasons'].map((x) => Season.fromJson(x))),
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
      episodeType: json['episode_type'],
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
      logoPath: json['logo_path'],
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
      airDate: json['air_date'],
      episodeCount: json['episode_count'],
      id: json['id'],
      name: json['name'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      seasonNumber: json['season_number'],
      voteAverage: json['vote_average'].toDouble(),
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
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      adult: json['adult'],
      backdropPath: json['backdrop_path'],
      belongsToCollection: json['belongs_to_collection'] != null
          ? BelongsToCollection.fromJson(json['belongs_to_collection'])
          : null,
      budget: json['budget'],
      genres: (json['genres'] as List).map((e) => Genre.fromJson(e)).toList(),
      homepage: json['homepage'],
      id: json['id'],
      imdbId: json['imdb_id'],
      originCountry: List<String>.from(json['origin_country']),
      originalLanguage: json['original_language'],
      originalTitle: json['original_title'],
      overview: json['overview'],
      popularity: json['popularity'].toDouble(),
      posterPath: json['poster_path'],
      productionCompanies: (json['production_companies'] as List)
          .map((e) => ProductionCompany.fromJson(e))
          .toList(),
      productionCountries: (json['production_countries'] as List)
          .map((e) => ProductionCountry.fromJson(e))
          .toList(),
      releaseDate: json['release_date'],
      revenue: json['revenue'],
      runtime: json['runtime'],
      spokenLanguages: (json['spoken_languages'] as List)
          .map((e) => SpokenLanguage.fromJson(e))
          .toList(),
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
      backdropPath: json['backdrop_path'],
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
