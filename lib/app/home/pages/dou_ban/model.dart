class TopMovieInfo {
  String rank;
  String douBanUrl;
  String poster;
  String title;
  List<String> subtitle;
  String cast;
  List<String> desc;
  String ratingNum;
  String evaluateNum;
  String quote;

  TopMovieInfo({
    required this.rank,
    required this.douBanUrl,
    required this.poster,
    required this.title,
    required this.subtitle,
    required this.cast,
    required this.desc,
    required this.ratingNum,
    required this.evaluateNum,
    required this.quote,
  });

  factory TopMovieInfo.fromJson(Map<String, dynamic> json) {
    return TopMovieInfo(
      rank: json['rank'],
      douBanUrl: json['douban_url'],
      poster: json['poster'],
      title: json['title'],
      subtitle: List<String>.from(json['subtitle']),
      cast: json['cast'],
      desc: List<String>.from(json['desc']),
      ratingNum: json['rating_num'],
      evaluateNum: json['evaluate_num'],
      quote: json['quote'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'douban_url': douBanUrl,
      'poster': poster,
      'title': title,
      'subtitle': subtitle,
      'cast': cast,
      'desc': desc,
      'rating_num': ratingNum,
      'evaluate_num': evaluateNum,
      'quote': quote,
    };
  }
}

class HotMediaInfo {
  String title;
  String douBanUrl;
  String poster;
  bool playable;
  String id;
  String rate;
  int coverX;
  int coverY;
  bool isNew;
  String episodesInfo;

  HotMediaInfo({
    required this.title,
    required this.douBanUrl,
    required this.poster,
    required this.playable,
    required this.id,
    required this.rate,
    required this.coverX,
    required this.coverY,
    required this.isNew,
    required this.episodesInfo,
  });

  factory HotMediaInfo.fromJson(Map<String, dynamic> json) {
    return HotMediaInfo(
      title: json['title'],
      douBanUrl: json['url'],
      poster: json['cover'],
      playable: json['playable'],
      id: json['id'],
      rate: json['rate'],
      coverX: json['cover_x'],
      coverY: json['cover_y'],
      isNew: json['is_new'],
      episodesInfo: json['episodes_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': douBanUrl,
      'cover': poster,
      'playable': playable,
      'id': id,
      'rate': rate,
      'cover_x': coverX,
      'cover_y': coverY,
      'is_new': isNew,
      'episodes_info': episodesInfo,
    };
  }
}

class Worker {
  String name;
  String url;
  String? imgUrl;
  String? role;

  Worker({
    required this.name,
    required this.url,
    this.imgUrl,
    this.role,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      name: json['name'],
      url: json['url'],
      imgUrl: json['imgUrl'],
      role: json['role'],
    );
  }
}

class VideoDetail {
  String title;
  String year;
  List<Worker> director;
  List<Worker> writer;
  List<Worker> actors;
  List<Worker> celebrities;
  List<String> genres;
  String? officialSite;
  List<String> region;
  List<String> language;
  String duration;
  List<String> releaseDate;
  List<String>? alias;
  List<String>? pictures;
  String imdb;
  String? rate;
  String evaluate;
  List<String> summary;
  String hadSeen;
  String wantLook;
  String? season;
  String? episode;

  VideoDetail({
    required this.title,
    required this.year,
    required this.director,
    required this.writer,
    required this.actors,
    required this.genres,
    required this.celebrities,
    this.officialSite,
    required this.region,
    required this.language,
    required this.duration,
    required this.releaseDate,
    this.alias,
    this.pictures,
    required this.imdb,
    this.rate,
    required this.evaluate,
    required this.summary,
    required this.hadSeen,
    required this.wantLook,
    this.season,
    this.episode,
  });

  factory VideoDetail.fromJson(Map<String, dynamic> json) {
    return VideoDetail(
      title: json['title'],
      year: json['year'],
      director:
          (json['director'] as List).map((e) => Worker.fromJson(e)).toList(),
      writer: (json['writer'] as List).map((e) => Worker.fromJson(e)).toList(),
      actors: (json['actors'] as List).map((e) => Worker.fromJson(e)).toList(),
      celebrities:
          (json['celebrities'] as List).map((e) => Worker.fromJson(e)).toList(),
      genres: List<String>.from(json['genres']),
      officialSite: json['official_site'],
      region: List<String>.from(json['region']),
      language: List<String>.from(json['language']),
      duration: json['duration'],
      releaseDate: List<String>.from(json['release_date']),
      alias: List<String>.from(json['alias']),
      imdb: json['imdb'],
      rate: json['rate'],
      evaluate: json['evaluate'],
      summary: List<String>.from(json['summary'] ?? []),
      pictures: List<String>.from(json['pictures'] ?? []),
      hadSeen: json['had_seen'],
      wantLook: json['want_look'],
      season: json['season'],
      episode: json['episode'],
    );
  }
}

class RankMovie {
  final int rank;
  final String douBanUrl;
  final String poster;
  final String title;
  final List<String> actors;
  final List<String> rating;
  final bool isPlayable;
  final String id;
  final List<String> types;
  final List<String> regions;
  final String releaseDate;
  final int actorCount;
  final int voteCount;
  final String score;
  final bool isWatched;

  RankMovie({
    required this.rating,
    required this.rank,
    required this.poster,
    required this.isPlayable,
    required this.id,
    required this.types,
    required this.regions,
    required this.title,
    required this.douBanUrl,
    required this.releaseDate,
    required this.actorCount,
    required this.voteCount,
    required this.score,
    required this.actors,
    required this.isWatched,
  });

  // From JSON constructor
  factory RankMovie.fromJson(Map<String, dynamic> json) {
    return RankMovie(
      rating: List<String>.from(json['rating']),
      rank: json['rank'],
      poster: json['cover_url'],
      isPlayable: json['is_playable'],
      id: json['id'],
      types: List<String>.from(json['types'] ?? []),
      regions: List<String>.from(json['regions'] ?? []),
      title: json['title'],
      douBanUrl: json['url'],
      releaseDate: json['release_date'],
      actorCount: json['actor_count'],
      voteCount: json['vote_count'],
      score: json['score'],
      actors: List<String>.from(json['actors'] ?? []),
      isWatched: json['is_watched'],
    );
  }

  // To JSON method (optional)
  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'rank': rank,
      'cover_url': poster,
      'is_playable': isPlayable,
      'id': id,
      'types': types,
      'regions': regions,
      'title': title,
      'url': douBanUrl,
      'release_date': releaseDate,
      'actor_count': actorCount,
      'vote_count': voteCount,
      'score': score,
      'actors': actors,
      'is_watched': isWatched,
    };
  }

  @override
  String toString() => "$title - $id";
}
