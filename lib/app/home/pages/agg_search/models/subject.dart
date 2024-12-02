class Subject {
  Subject({
    this.rating,
    this.lineticketUrl,
    this.controversyReason,
    this.pubdate,
    this.lastEpisodeNumber,
    this.interestControlInfo,
    this.pic,
    this.year,
    this.vendorCount,
    this.bodyBgColor,
    this.isTv,
    this.cardSubtitle,
    this.albumNoInteract,
    this.ticketPriceInfo,
    this.prePlayableDate,
    this.canRate,
    this.headInfo,
    this.forumInfo,
    this.shareActivities,
    this.webisode,
    this.id,
    this.galleryTopicCount,
    this.languages,
    this.genres,
    this.reviewCount,
    this.variableModules,
    this.title,
    this.intro,
    this.interestCmtEarlierTipTitle,
    this.hasLinewatch,
    this.commentCount,
    this.forumTopicCount,
    this.ticketPromoText,
    this.webviewInfo,
    this.isReleased,
    this.vendors,
    this.actors,
    this.interest,
    this.subtype,
    this.episodesCount,
    this.colorScheme,
    this.type,
    this.linewatches,
    this.infoUrl,
    this.tags,
    this.vendorDesc,
    this.durations,
    this.cover,
    this.coverUrl,
    this.trailers,
    this.headerBgColor,
    this.isDoubanIntro,
    this.ticketVendorIcons,
    this.honorInfos,
    this.sharingUrl,
    this.subjectCollections,
    this.wechatTimelineShare,
    this.uri,
    this.restrictiveIconUrl,
    this.rateInfo,
    this.releaseDate,
    this.countries,
    this.originalTitle,
    this.isRestrictive,
    this.webisodeCount,
    this.episodesInfo,
    this.url,
    this.directors,
    this.isShow,
    this.vendorIcons,
    this.preReleaseDesc,
    this.video,
    this.aka,
    this.realtimeHotHonorInfos,
    this.nullRatingReason,
    this.interestCmtEarlierTipDesc,
  });

  Subject.fromJson(dynamic json) {
    rating = json['rating'] != null ? Rating.fromJson(json['rating']) : null;
    lineticketUrl = json['lineticket_url'];
    controversyReason = json['controversy_reason'];
    pubdate = json['pubdate'] != null ? json['pubdate'].cast<String>() : [];
    lastEpisodeNumber = json['last_episode_number'];
    interestControlInfo = json['interest_control_info'];
    pic = json['pic'] != null ? Pic.fromJson(json['pic']) : null;
    year = json['year'];
    vendorCount = json['vendor_count'];
    bodyBgColor = json['body_bg_color'];
    isTv = json['is_tv'];
    cardSubtitle = json['card_subtitle'];
    albumNoInteract = json['album_no_interact'];
    ticketPriceInfo = json['ticket_price_info'];
    prePlayableDate = json['pre_playable_date'];
    canRate = json['can_rate'];
    headInfo = json['head_info'];
    forumInfo = json['forum_info'];
    if (json['share_activities'] != null) {
      shareActivities = [];
      json['share_activities'].forEach((v) {
        shareActivities?.add(v);
      });
    }
    webisode = json['webisode'];
    id = json['id'];
    galleryTopicCount = json['gallery_topic_count'];
    languages =
        json['languages'] != null ? json['languages'].cast<String>() : [];
    genres = json['genres'] != null ? json['genres'].cast<String>() : [];
    reviewCount = json['review_count'];
    if (json['variable_modules'] != null) {
      variableModules = [];
      json['variable_modules'].forEach((v) {
        variableModules?.add(VariableModules.fromJson(v));
      });
    }
    title = json['title'];
    intro = json['intro'];
    interestCmtEarlierTipTitle = json['interest_cmt_earlier_tip_title'];
    hasLinewatch = json['has_linewatch'];
    commentCount = json['comment_count'];
    forumTopicCount = json['forum_topic_count'];
    ticketPromoText = json['ticket_promo_text'];
    webviewInfo = json['webview_info'];
    isReleased = json['is_released'];
    if (json['vendors'] != null) {
      vendors = [];
      json['vendors'].forEach((v) {
        vendors?.add(v);
      });
    }
    if (json['actors'] != null) {
      actors = [];
      json['actors'].forEach((v) {
        actors?.add(Actors.fromJson(v));
      });
    }
    interest = json['interest'];
    subtype = json['subtype'];
    episodesCount = json['episodes_count'];
    colorScheme = json['color_scheme'] != null
        ? ColorScheme.fromJson(json['color_scheme'])
        : null;
    type = json['type'];
    if (json['linewatches'] != null) {
      linewatches = [];
      json['linewatches'].forEach((v) {
        linewatches?.add(v);
      });
    }
    infoUrl = json['info_url'];
    if (json['tags'] != null) {
      tags = [];
      json['tags'].forEach((v) {
        tags?.add(v);
      });
    }
    vendorDesc = json['vendor_desc'];
    durations =
        json['durations'] != null ? json['durations'].cast<String>() : [];
    cover = json['cover'] != null ? Cover.fromJson(json['cover']) : null;
    coverUrl = json['cover_url'];
    if (json['trailers'] != null) {
      trailers = [];
      json['trailers'].forEach((v) {
        trailers?.add(Trailers.fromJson(v));
      });
    }
    headerBgColor = json['header_bg_color'];
    isDoubanIntro = json['is_douban_intro'];
    ticketVendorIcons = json['ticket_vendor_icons'] != null
        ? json['ticket_vendor_icons'].cast<String>()
        : [];
    if (json['honor_infos'] != null) {
      honorInfos = [];
      json['honor_infos'].forEach((v) {
        honorInfos?.add(v);
      });
    }
    sharingUrl = json['sharing_url'];
    if (json['subject_collections'] != null) {
      subjectCollections = [];
      json['subject_collections'].forEach((v) {
        subjectCollections?.add(v);
      });
    }
    wechatTimelineShare = json['wechat_timeline_share'];
    uri = json['uri'];
    restrictiveIconUrl = json['restrictive_icon_url'];
    rateInfo = json['rate_info'];
    releaseDate = json['release_date'];
    countries =
        json['countries'] != null ? json['countries'].cast<String>() : [];
    originalTitle = json['original_title'];
    isRestrictive = json['is_restrictive'];
    webisodeCount = json['webisode_count'];
    episodesInfo = json['episodes_info'];
    url = json['url'];
    if (json['directors'] != null) {
      directors = [];
      json['directors'].forEach((v) {
        directors?.add(Directors.fromJson(v));
      });
    }
    isShow = json['is_show'];
    if (json['vendor_icons'] != null) {
      vendorIcons = [];
      json['vendor_icons'].forEach((v) {
        vendorIcons?.add(v);
      });
    }
    preReleaseDesc = json['pre_release_desc'];
    video = json['video'];
    aka = json['aka'] != null ? json['aka'].cast<String>() : [];
    if (json['realtime_hot_honor_infos'] != null) {
      realtimeHotHonorInfos = [];
      json['realtime_hot_honor_infos'].forEach((v) {
        realtimeHotHonorInfos?.add(v);
      });
    }
    nullRatingReason = json['null_rating_reason'];
    interestCmtEarlierTipDesc = json['interest_cmt_earlier_tip_desc'];
  }

  Rating? rating;
  String? lineticketUrl;
  String? controversyReason;
  List<String>? pubdate;
  dynamic lastEpisodeNumber;
  dynamic interestControlInfo;
  Pic? pic;
  String? year;
  int? vendorCount;
  String? bodyBgColor;
  bool? isTv;
  String? cardSubtitle;
  bool? albumNoInteract;
  String? ticketPriceInfo;
  dynamic prePlayableDate;
  bool? canRate;
  dynamic headInfo;
  dynamic forumInfo;
  List<dynamic>? shareActivities;
  dynamic webisode;
  String? id;
  int? galleryTopicCount;
  List<String>? languages;
  List<String>? genres;
  int? reviewCount;
  List<VariableModules>? variableModules;
  String? title;
  String? intro;
  String? interestCmtEarlierTipTitle;
  bool? hasLinewatch;
  int? commentCount;
  int? forumTopicCount;
  String? ticketPromoText;
  dynamic webviewInfo;
  bool? isReleased;
  List<dynamic>? vendors;
  List<Actors>? actors;
  dynamic interest;
  String? subtype;
  int? episodesCount;
  ColorScheme? colorScheme;
  String? type;
  List<dynamic>? linewatches;
  String? infoUrl;
  List<dynamic>? tags;
  String? vendorDesc;
  List<String>? durations;
  Cover? cover;
  String? coverUrl;
  List<Trailers>? trailers;
  String? headerBgColor;
  bool? isDoubanIntro;
  List<String>? ticketVendorIcons;
  List<dynamic>? honorInfos;
  String? sharingUrl;
  List<dynamic>? subjectCollections;
  String? wechatTimelineShare;
  String? uri;
  String? restrictiveIconUrl;
  String? rateInfo;
  dynamic releaseDate;
  List<String>? countries;
  String? originalTitle;
  bool? isRestrictive;
  int? webisodeCount;
  String? episodesInfo;
  String? url;
  List<Directors>? directors;
  bool? isShow;
  List<dynamic>? vendorIcons;
  String? preReleaseDesc;
  dynamic video;
  List<String>? aka;
  List<dynamic>? realtimeHotHonorInfos;
  String? nullRatingReason;
  String? interestCmtEarlierTipDesc;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (rating != null) {
      map['rating'] = rating?.toJson();
    }
    map['lineticket_url'] = lineticketUrl;
    map['controversy_reason'] = controversyReason;
    map['pubdate'] = pubdate;
    map['last_episode_number'] = lastEpisodeNumber;
    map['interest_control_info'] = interestControlInfo;
    if (pic != null) {
      map['pic'] = pic?.toJson();
    }
    map['year'] = year;
    map['vendor_count'] = vendorCount;
    map['body_bg_color'] = bodyBgColor;
    map['is_tv'] = isTv;
    map['card_subtitle'] = cardSubtitle;
    map['album_no_interact'] = albumNoInteract;
    map['ticket_price_info'] = ticketPriceInfo;
    map['pre_playable_date'] = prePlayableDate;
    map['can_rate'] = canRate;
    map['head_info'] = headInfo;
    map['forum_info'] = forumInfo;
    if (shareActivities != null) {
      map['share_activities'] =
          shareActivities?.map((v) => v.toJson()).toList();
    }
    map['webisode'] = webisode;
    map['id'] = id;
    map['gallery_topic_count'] = galleryTopicCount;
    map['languages'] = languages;
    map['genres'] = genres;
    map['review_count'] = reviewCount;
    if (variableModules != null) {
      map['variable_modules'] =
          variableModules?.map((v) => v.toJson()).toList();
    }
    map['title'] = title;
    map['intro'] = intro;
    map['interest_cmt_earlier_tip_title'] = interestCmtEarlierTipTitle;
    map['has_linewatch'] = hasLinewatch;
    map['comment_count'] = commentCount;
    map['forum_topic_count'] = forumTopicCount;
    map['ticket_promo_text'] = ticketPromoText;
    map['webview_info'] = webviewInfo;
    map['is_released'] = isReleased;
    if (vendors != null) {
      map['vendors'] = vendors?.map((v) => v.toJson()).toList();
    }
    if (actors != null) {
      map['actors'] = actors?.map((v) => v.toJson()).toList();
    }
    map['interest'] = interest;
    map['subtype'] = subtype;
    map['episodes_count'] = episodesCount;
    if (colorScheme != null) {
      map['color_scheme'] = colorScheme?.toJson();
    }
    map['type'] = type;
    if (linewatches != null) {
      map['linewatches'] = linewatches?.map((v) => v.toJson()).toList();
    }
    map['info_url'] = infoUrl;
    if (tags != null) {
      map['tags'] = tags?.map((v) => v.toJson()).toList();
    }
    map['vendor_desc'] = vendorDesc;
    map['durations'] = durations;
    if (cover != null) {
      map['cover'] = cover?.toJson();
    }
    map['cover_url'] = coverUrl;
    if (trailers != null) {
      map['trailers'] = trailers?.map((v) => v.toJson()).toList();
    }
    map['header_bg_color'] = headerBgColor;
    map['is_douban_intro'] = isDoubanIntro;
    map['ticket_vendor_icons'] = ticketVendorIcons;
    if (honorInfos != null) {
      map['honor_infos'] = honorInfos?.map((v) => v.toJson()).toList();
    }
    map['sharing_url'] = sharingUrl;
    if (subjectCollections != null) {
      map['subject_collections'] =
          subjectCollections?.map((v) => v.toJson()).toList();
    }
    map['wechat_timeline_share'] = wechatTimelineShare;
    map['uri'] = uri;
    map['restrictive_icon_url'] = restrictiveIconUrl;
    map['rate_info'] = rateInfo;
    map['release_date'] = releaseDate;
    map['countries'] = countries;
    map['original_title'] = originalTitle;
    map['is_restrictive'] = isRestrictive;
    map['webisode_count'] = webisodeCount;
    map['episodes_info'] = episodesInfo;
    map['url'] = url;
    if (directors != null) {
      map['directors'] = directors?.map((v) => v.toJson()).toList();
    }
    map['is_show'] = isShow;
    if (vendorIcons != null) {
      map['vendor_icons'] = vendorIcons?.map((v) => v.toJson()).toList();
    }
    map['pre_release_desc'] = preReleaseDesc;
    map['video'] = video;
    map['aka'] = aka;
    if (realtimeHotHonorInfos != null) {
      map['realtime_hot_honor_infos'] =
          realtimeHotHonorInfos?.map((v) => v.toJson()).toList();
    }
    map['null_rating_reason'] = nullRatingReason;
    map['interest_cmt_earlier_tip_desc'] = interestCmtEarlierTipDesc;
    return map;
  }
}

class Directors {
  Directors({
    this.name,
  });

  Directors.fromJson(dynamic json) {
    name = json['name'];
  }

  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    return map;
  }
}

class Trailers {
  Trailers({
    this.sharingUrl,
    this.videoUrl,
    this.title,
    this.typeName,
    this.uri,
    this.coverUrl,
    this.termNum,
    this.nComments,
    this.createTime,
    this.fileSize,
    this.runtime,
    this.type,
    this.id,
    this.desc,
  });

  Trailers.fromJson(dynamic json) {
    sharingUrl = json['sharing_url'];
    videoUrl = json['video_url'];
    title = json['title'];
    typeName = json['type_name'];
    uri = json['uri'];
    coverUrl = json['cover_url'];
    termNum = json['term_num'];
    nComments = json['n_comments'];
    createTime = json['create_time'];
    fileSize = json['file_size'];
    runtime = json['runtime'];
    type = json['type'];
    id = json['id'];
    desc = json['desc'];
  }

  String? sharingUrl;
  String? videoUrl;
  String? title;
  String? typeName;
  String? uri;
  String? coverUrl;
  int? termNum;
  int? nComments;
  String? createTime;
  int? fileSize;
  String? runtime;
  String? type;
  String? id;
  String? desc;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sharing_url'] = sharingUrl;
    map['video_url'] = videoUrl;
    map['title'] = title;
    map['type_name'] = typeName;
    map['uri'] = uri;
    map['cover_url'] = coverUrl;
    map['term_num'] = termNum;
    map['n_comments'] = nComments;
    map['create_time'] = createTime;
    map['file_size'] = fileSize;
    map['runtime'] = runtime;
    map['type'] = type;
    map['id'] = id;
    map['desc'] = desc;
    return map;
  }
}

class Cover {
  Cover({
    this.description,
    this.author,
    this.url,
    this.image,
    this.uri,
    this.createTime,
    this.position,
    this.ownerUri,
    this.type,
    this.id,
    this.sharingUrl,
  });

  Cover.fromJson(dynamic json) {
    description = json['description'];
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
    url = json['url'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
    uri = json['uri'];
    createTime = json['create_time'];
    position = json['position'];
    ownerUri = json['owner_uri'];
    type = json['type'];
    id = json['id'];
    sharingUrl = json['sharing_url'];
  }

  String? description;
  Author? author;
  String? url;
  Image? image;
  String? uri;
  String? createTime;
  int? position;
  String? ownerUri;
  String? type;
  String? id;
  String? sharingUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['description'] = description;
    if (author != null) {
      map['author'] = author?.toJson();
    }
    map['url'] = url;
    if (image != null) {
      map['image'] = image?.toJson();
    }
    map['uri'] = uri;
    map['create_time'] = createTime;
    map['position'] = position;
    map['owner_uri'] = ownerUri;
    map['type'] = type;
    map['id'] = id;
    map['sharing_url'] = sharingUrl;
    return map;
  }
}

class Image {
  Image({
    this.normal,
    this.large,
    this.raw,
    this.small,
    this.primaryColor,
    this.isAnimated,
  });

  Image.fromJson(dynamic json) {
    normal = json['normal'] != null ? Normal.fromJson(json['normal']) : null;
    large = json['large'] != null ? Large.fromJson(json['large']) : null;
    raw = json['raw'];
    small = json['small'] != null ? Small.fromJson(json['small']) : null;
    primaryColor = json['primary_color'];
    isAnimated = json['is_animated'];
  }

  Normal? normal;
  Large? large;
  dynamic raw;
  Small? small;
  String? primaryColor;
  bool? isAnimated;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (normal != null) {
      map['normal'] = normal?.toJson();
    }
    if (large != null) {
      map['large'] = large?.toJson();
    }
    map['raw'] = raw;
    if (small != null) {
      map['small'] = small?.toJson();
    }
    map['primary_color'] = primaryColor;
    map['is_animated'] = isAnimated;
    return map;
  }
}

class Small {
  Small({
    this.url,
    this.width,
    this.height,
    this.size,
  });

  Small.fromJson(dynamic json) {
    url = json['url'];
    width = json['width'];
    height = json['height'];
    size = json['size'];
  }

  String? url;
  int? width;
  int? height;
  int? size;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['width'] = width;
    map['height'] = height;
    map['size'] = size;
    return map;
  }
}

class Large {
  Large({
    this.url,
    this.width,
    this.height,
    this.size,
  });

  Large.fromJson(dynamic json) {
    url = json['url'];
    width = json['width'];
    height = json['height'];
    size = json['size'];
  }

  String? url;
  int? width;
  int? height;
  int? size;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['width'] = width;
    map['height'] = height;
    map['size'] = size;
    return map;
  }
}

class Normal {
  Normal({
    this.url,
    this.width,
    this.height,
    this.size,
  });

  Normal.fromJson(dynamic json) {
    url = json['url'];
    width = json['width'];
    height = json['height'];
    size = json['size'];
  }

  String? url;
  int? width;
  int? height;
  int? size;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['width'] = width;
    map['height'] = height;
    map['size'] = size;
    return map;
  }
}

class Author {
  Author({
    this.loc,
    this.kind,
    this.name,
    this.regTime,
    this.url,
    this.uri,
    this.avatar,
    this.isClub,
    this.type,
    this.id,
    this.uid,
  });

  Author.fromJson(dynamic json) {
    loc = json['loc'] != null ? Loc.fromJson(json['loc']) : null;
    kind = json['kind'];
    name = json['name'];
    regTime = json['reg_time'];
    url = json['url'];
    uri = json['uri'];
    avatar = json['avatar'];
    isClub = json['is_club'];
    type = json['type'];
    id = json['id'];
    uid = json['uid'];
  }

  Loc? loc;
  String? kind;
  String? name;
  String? regTime;
  String? url;
  String? uri;
  String? avatar;
  bool? isClub;
  String? type;
  String? id;
  String? uid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (loc != null) {
      map['loc'] = loc?.toJson();
    }
    map['kind'] = kind;
    map['name'] = name;
    map['reg_time'] = regTime;
    map['url'] = url;
    map['uri'] = uri;
    map['avatar'] = avatar;
    map['is_club'] = isClub;
    map['type'] = type;
    map['id'] = id;
    map['uid'] = uid;
    return map;
  }
}

class Loc {
  Loc({
    this.id,
    this.name,
    this.uid,
  });

  Loc.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    uid = json['uid'];
  }

  String? id;
  String? name;
  String? uid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['uid'] = uid;
    return map;
  }
}

class ColorScheme {
  ColorScheme({
    this.isDark,
    this.primaryColorLight,
    this.baseColor,
    this.secondaryColor,
    this.avgColor,
    this.primaryColorDark,
  });

  ColorScheme.fromJson(dynamic json) {
    isDark = json['is_dark'];
    primaryColorLight = json['primary_color_light'];
    baseColor =
        json['_base_color'] != null ? json['_base_color'].cast<double>() : [];
    secondaryColor = json['secondary_color'];
    avgColor =
        json['_avg_color'] != null ? json['_avg_color'].cast<double>() : [];
    primaryColorDark = json['primary_color_dark'];
  }

  bool? isDark;
  String? primaryColorLight;
  List<double>? baseColor;
  String? secondaryColor;
  List<double>? avgColor;
  String? primaryColorDark;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['is_dark'] = isDark;
    map['primary_color_light'] = primaryColorLight;
    map['_base_color'] = baseColor;
    map['secondary_color'] = secondaryColor;
    map['_avg_color'] = avgColor;
    map['primary_color_dark'] = primaryColorDark;
    return map;
  }
}

class Actors {
  Actors({
    this.name,
  });

  Actors.fromJson(dynamic json) {
    name = json['name'];
  }

  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    return map;
  }
}

class VariableModules {
  VariableModules({
    this.subModules,
    this.id,
  });

  VariableModules.fromJson(dynamic json) {
    if (json['sub_modules'] != null) {
      subModules = [];
      json['sub_modules'].forEach((v) {
        subModules?.add(v);
      });
    }
    id = json['id'];
  }

  List<dynamic>? subModules;
  String? id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (subModules != null) {
      map['sub_modules'] = subModules?.map((v) => v.toJson()).toList();
    }
    map['id'] = id;
    return map;
  }
}

class Pic {
  Pic({
    this.large,
    this.normal,
  });

  Pic.fromJson(dynamic json) {
    large = json['large'];
    normal = json['normal'];
  }

  String? large;
  String? normal;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['large'] = large;
    map['normal'] = normal;
    return map;
  }
}

class Rating {
  Rating({
    this.count,
    this.max,
    this.starCount,
    this.value,
  });

  Rating.fromJson(dynamic json) {
    count = json['count'];
    max = json['max'];
    starCount = json['star_count'];
    value = json['value'];
  }

  int? count;
  int? max;
  double? starCount;
  double? value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['count'] = count;
    map['max'] = max;
    map['star_count'] = starCount;
    map['value'] = value;
    return map;
  }
}
