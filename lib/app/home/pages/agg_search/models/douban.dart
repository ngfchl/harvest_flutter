class DouBanSearchResult {
  final String layout;
  final String typeName;
  final SearchTarget target;
  final String targetType;

  DouBanSearchResult({
    required this.layout,
    required this.typeName,
    required this.target,
    required this.targetType,
  });

  @override
  String toString() => target.toString();

  factory DouBanSearchResult.fromJson(Map<String, dynamic> json) {
    return DouBanSearchResult(
      layout: json['layout'],
      typeName: json['type_name'],
      target: SearchTarget.fromJson(json['target']),
      targetType: json['target_type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'layout': layout,
        'type_name': typeName,
        'target': target.toJson(),
        'target_type': targetType,
      };
}

class SearchTarget {
  final Rating rating;
  final String title;
  final String uri;
  final String coverUrl;
  final String? year;
  final String cardSubtitle;
  final String id;

  SearchTarget({
    required this.rating,
    required this.title,
    required this.uri,
    required this.coverUrl,
    required this.year,
    required this.cardSubtitle,
    required this.id,
  });

  @override
  String toString() => "$title [$year] - $id - ${rating.toString()}";

  factory SearchTarget.fromJson(Map<String, dynamic> json) {
    return SearchTarget(
      rating: json['rating'] != null
          ? Rating.fromJson(json['rating'])
          : Rating(count: 0, max: 0, starCount: 0, value: 0),
      title: json['title'],
      uri: json['uri'],
      coverUrl: json['cover_url'] ?? "",
      year: json['year'],
      cardSubtitle: json['card_subtitle'] ?? "",
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'rating': rating.toJson(),
        'title': title,
        'uri': uri,
        'cover_url': coverUrl,
        'year': year,
        'card_subtitle': cardSubtitle,
        'id': id,
      };
}

class Rating {
  final int count;
  final int max;
  final double starCount;
  final double value;

  Rating({
    required this.count,
    required this.max,
    required this.starCount,
    required this.value,
  });

  @override
  String toString() => "评分：$value";

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      count: json['count'],
      max: json['max'],
      starCount: json['star_count']?.toDouble() ?? 0.0,
      value: json['value']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'max': max,
        'star_count': starCount,
        'value': value,
      };
}
