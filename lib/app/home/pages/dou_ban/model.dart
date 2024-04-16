class MovieInfo {
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

  MovieInfo({
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

  factory MovieInfo.fromJson(Map<String, dynamic> json) {
    return MovieInfo(
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
  String url;
  String cover;
  bool playable;
  String id;
  String rate;
  int coverX;
  int coverY;
  bool isNew;
  String episodesInfo;

  HotMediaInfo({
    required this.title,
    required this.url,
    required this.cover,
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
      url: json['url'],
      cover: json['cover'],
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
      'url': url,
      'cover': cover,
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
