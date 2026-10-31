import 'dart:convert';

// ─────────────────────────────────────────────────────────────
// 通用解析工具
// ─────────────────────────────────────────────────────────────

List<String> _stringList(dynamic value) {
  if (value is List) return value.map((e) => e.toString()).toList();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const [];
    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return trimmed
        .split(RegExp(r'[,，]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return const [];
}

bool _bool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == 'true' || value == '1';
  return fallback;
}

int _int(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

String _str(dynamic value) => value?.toString() ?? '';

// ─────────────────────────────────────────────────────────────
// RSS 源
// ─────────────────────────────────────────────────────────────

class RssFeed {
  final int id;
  final String name;
  final String rss;
  final int sort;
  final bool available;
  final int siteId;
  final String createdAt;
  final String updatedAt;

  const RssFeed({
    this.id = 0,
    this.name = '',
    this.rss = '',
    this.sort = 1,
    this.available = true,
    this.siteId = 0,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory RssFeed.fromJson(Map<String, dynamic> json) => RssFeed(
        id: _int(json['id']),
        name: _str(json['name']),
        rss: _str(json['rss'] ?? json['url']),
        sort: _int(json['sort'] ?? json['priority'], 1),
        available: _bool(json['available'] ?? json['enabled'], true),
        siteId: _int(json['site_id']),
        createdAt: _str(json['created_at']),
        updatedAt: _str(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'rss': rss,
        'sort': sort,
        'available': available,
        'site_id': siteId,
      };
}

/// RSS 源刷新结果
class RssFeedRefreshResult {
  final int feedId;
  final int itemCount;
  final String lastBuild;

  const RssFeedRefreshResult({this.feedId = 0, this.itemCount = 0, this.lastBuild = ''});

  factory RssFeedRefreshResult.fromJson(Map<String, dynamic> json) => RssFeedRefreshResult(
        feedId: _int(json['feed_id']),
        itemCount: _int(json['item_count']),
        lastBuild: _str(json['last_build']),
      );
}

/// 订阅预览匹配候选
class RssSubscriptionPreviewItem {
  final int feedId;
  final String feedName;
  final String title;
  final String torrentUrl;
  final int size;
  final String publishedAt;

  const RssSubscriptionPreviewItem({
    this.feedId = 0,
    this.feedName = '',
    this.title = '',
    this.torrentUrl = '',
    this.size = 0,
    this.publishedAt = '',
  });

  factory RssSubscriptionPreviewItem.fromJson(Map<String, dynamic> json) =>
      RssSubscriptionPreviewItem(
        feedId: _int(json['feed_id']),
        feedName: _str(json['feed_name']),
        title: _str(json['title']),
        torrentUrl: _str(json['torrent_url']),
        size: _int(json['size']),
        publishedAt: _str(json['published_at']),
      );
}

// ─────────────────────────────────────────────────────────────
// 订阅标签
// ─────────────────────────────────────────────────────────────

class RssTag {
  final int id;
  final String name;
  final String category;
  final bool enabled;

  const RssTag({this.id = 0, this.name = '', this.category = '', this.enabled = true});

  factory RssTag.fromJson(Map<String, dynamic> json) => RssTag(
        id: _int(json['id']),
        name: _str(json['name']),
        category: _str(json['category']),
        enabled: _bool(json['enabled'] ?? json['available'], true),
      );

  Map<String, dynamic> toJson() => {'name': name, 'category': category, 'enabled': enabled};
}

/// 默认标签导入结果
class RssTagImportResult {
  final int total;
  final int created;
  final int updated;

  const RssTagImportResult({this.total = 0, this.created = 0, this.updated = 0});

  factory RssTagImportResult.fromJson(Map<String, dynamic> json) => RssTagImportResult(
        total: _int(json['total']),
        created: _int(json['created']),
        updated: _int(json['updated']),
      );
}


/// 订阅标签分类：英文 key -> 中文显示名
const Map<String, String> kRssTagCategoryLabels = {
  'season': '季数',
  'category': '分类',
  'publish_year': '发布年份',
  'source': '来源媒介',
  'tags': '其他标签',
  'publisher': '制作组',
  'audio_codec': '音频编码',
  'video_codec': '视频编码',
  'resolution': '分辨率',
  'video_quality': '画质',
  'discount': '优惠',
};

/// 订阅标签分类有序列表（Select 选项用）
const List<String> kRssTagCategoryKeys = [
  'resolution',
  'video_quality',
  'video_codec',
  'audio_codec',
  'source',
  'publisher',
  'season',
  'publish_year',
  'category',
  'discount',
  'tags',
];

/// 分类 key 转中文显示名；未知 key 原样返回
String rssTagCategoryLabel(String key) {
  final trimmed = key.trim();
  if (trimmed.isEmpty) return '未分类';
  return kRssTagCategoryLabels[trimmed] ?? trimmed;
}

// ─────────────────────────────────────────────────────────────
// 订阅方案
// ─────────────────────────────────────────────────────────────

class RssPlan {
  final int id;
  final String name;
  final bool enabled;
  final bool startDownload;
  final int minSizeMb;
  final int maxSizeMb;
  final String category;
  final List<String> discount;
  final List<String> excludes;
  final List<String> resolution;
  final List<String> videoCodec;
  final List<String> audioCodec;
  final List<String> source;
  final List<String> publisher;
  final List<String> tags;
  final int downloaderId;
  final String downloaderCategory;
  final String downloaderSavePath;
  final List<int> rssFeedIds;

  const RssPlan({
    this.id = 0,
    this.name = '',
    this.enabled = true,
    this.startDownload = true,
    this.minSizeMb = 1024,
    this.maxSizeMb = 20480,
    this.category = '',
    this.discount = const [],
    this.excludes = const [],
    this.resolution = const [],
    this.videoCodec = const [],
    this.audioCodec = const [],
    this.source = const [],
    this.publisher = const [],
    this.tags = const [],
    this.downloaderId = 0,
    this.downloaderCategory = '',
    this.downloaderSavePath = '',
    this.rssFeedIds = const [],
  });

  factory RssPlan.fromJson(Map<String, dynamic> json) => RssPlan(
        id: _int(json['id']),
        name: _str(json['name']),
        enabled: _bool(json['enabled'] ?? json['available'], true),
        startDownload: _bool(json['start_download'] ?? json['start'], true),
        minSizeMb: _int(json['min_size_mb'], 1024),
        maxSizeMb: _int(json['max_size_mb'], 20480),
        category: _str(json['category']),
        discount: _stringList(json['discount']),
        excludes: _stringList(json['excludes']),
        resolution: _stringList(json['resolution']),
        videoCodec: _stringList(json['video_codec']),
        audioCodec: _stringList(json['audio_codec']),
        source: _stringList(json['source']),
        publisher: _stringList(json['publisher']),
        tags: _stringList(json['tags']),
        downloaderId: _int(json['downloader_id']),
        downloaderCategory: _str(json['downloader_category']),
        downloaderSavePath: _str(json['downloader_save_path']),
        rssFeedIds: _stringList(json['rss_feed_ids'] ?? json['rss_list'])
            .map((e) => int.tryParse(e) ?? 0)
            .where((e) => e > 0)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'enabled': enabled,
        'start_download': startDownload,
        'min_size_mb': minSizeMb,
        'max_size_mb': maxSizeMb,
        'category': category,
        'discount': discount,
        'excludes': excludes,
        'resolution': resolution,
        'video_codec': videoCodec,
        'audio_codec': audioCodec,
        'source': source,
        'publisher': publisher,
        'tags': tags,
        'downloader_id': downloaderId,
        'downloader_category': downloaderCategory,
        'downloader_save_path': downloaderSavePath,
        'rss_feed_ids': rssFeedIds,
      };
}

// ─────────────────────────────────────────────────────────────
// RSS 订阅
// ─────────────────────────────────────────────────────────────

class RssSubscription {
  final int id;
  final String name;
  final bool enabled;
  final String keyword;
  final List<String> excludes;
  final String season;
  final List<String> publishYear;
  final String doubanId;
  final String imdbId;
  final String tmdbId;
  final int planId;

  const RssSubscription({
    this.id = 0,
    this.name = '',
    this.enabled = true,
    this.keyword = '',
    this.excludes = const [],
    this.season = '',
    this.publishYear = const [],
    this.doubanId = '',
    this.imdbId = '',
    this.tmdbId = '',
    this.planId = 0,
  });

  factory RssSubscription.fromJson(Map<String, dynamic> json) => RssSubscription(
        id: _int(json['id']),
        name: _str(json['name']),
        enabled: _bool(json['enabled'] ?? json['available'], true),
        keyword: _str(json['keyword']),
        excludes: _stringList(json['excludes'] ?? json['exclude']),
        season: _str(json['season']),
        publishYear: _stringList(json['publish_year']),
        doubanId: _str(json['douban_id'] ?? json['douban']),
        imdbId: _str(json['imdb_id'] ?? json['imdb']),
        tmdbId: _str(json['tmdb_id'] ?? json['tmdb']),
        planId: _int(json['plan_id']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'enabled': enabled,
        'keyword': keyword,
        'excludes': excludes,
        'season': season,
        'publish_year': publishYear,
        'douban_id': doubanId,
        'imdb_id': imdbId,
        'tmdb_id': tmdbId,
        'plan_id': planId,
      };
}

// ─────────────────────────────────────────────────────────────
// 订阅历史
// ─────────────────────────────────────────────────────────────

class RssHistoryItem {
  final int id;
  final int subscriptionId;
  final String subscriptionName;
  final int feedId;
  final String feedName;
  final String title;
  final String torrentUrl;
  final String message;
  final bool pushed;
  final String createdAt;

  const RssHistoryItem({
    this.id = 0,
    this.subscriptionId = 0,
    this.subscriptionName = '',
    this.feedId = 0,
    this.feedName = '',
    this.title = '',
    this.torrentUrl = '',
    this.message = '',
    this.pushed = false,
    this.createdAt = '',
  });

  factory RssHistoryItem.fromJson(Map<String, dynamic> json) => RssHistoryItem(
        id: _int(json['id']),
        subscriptionId: _int(json['subscription_id']),
        subscriptionName: _str(json['subscription_name']),
        feedId: _int(json['feed_id']),
        feedName: _str(json['feed_name']),
        title: _str(json['title']),
        torrentUrl: _str(json['torrent_url']),
        message: _str(json['message']),
        pushed: _bool(json['pushed']),
        createdAt: _str(json['created_at']),
      );
}

// ─────────────────────────────────────────────────────────────
// RSS 源解析预览条目
// ─────────────────────────────────────────────────────────────

class RssPreviewItem {
  final String id;
  final String title;
  final String link;
  final String torrentUrl;
  final String category;
  final String summary;
  final int size;
  final String publishedAt;

  const RssPreviewItem({
    this.id = '',
    this.title = '',
    this.link = '',
    this.torrentUrl = '',
    this.category = '',
    this.summary = '',
    this.size = 0,
    this.publishedAt = '',
  });

  factory RssPreviewItem.fromJson(Map<String, dynamic> json) => RssPreviewItem(
        id: _str(json['id']),
        title: _str(json['title']),
        link: _str(json['link']),
        torrentUrl: _str(json['torrent_url']),
        category: _str(json['category']),
        summary: _str(json['summary']),
        size: _int(json['size']),
        publishedAt: _str(json['published_at']),
      );
}

// ─────────────────────────────────────────────────────────────
// 订阅执行结果
// ─────────────────────────────────────────────────────────────

class RssRunResult {
  final int subscriptionId;
  final String name;
  final bool pushed;
  final String message;
  final String title;

  const RssRunResult({
    this.subscriptionId = 0,
    this.name = '',
    this.pushed = false,
    this.message = '',
    this.title = '',
  });

  factory RssRunResult.fromJson(Map<String, dynamic> json) => RssRunResult(
        subscriptionId: _int(json['subscription_id']),
        name: _str(json['name']),
        pushed: _bool(json['pushed']),
        message: _str(json['message']),
        title: _str(json['title']),
      );
}

// ─────────────────────────────────────────────────────────────
// qBittorrent RSS 数据
// ─────────────────────────────────────────────────────────────

class QbRssArticle {
  final String id;
  final String date;
  final String title;
  final String author;
  final String description;
  final String torrentUrl;
  final String link;
  final bool isRead;

  const QbRssArticle({
    this.id = '',
    this.date = '',
    this.title = '',
    this.author = '',
    this.description = '',
    this.torrentUrl = '',
    this.link = '',
    this.isRead = false,
  });

  factory QbRssArticle.fromJson(Map<String, dynamic> json) => QbRssArticle(
        id: _str(json['id']),
        date: _str(json['date']),
        title: _str(json['title']),
        author: _str(json['author']),
        description: _str(json['description']),
        torrentUrl: _str(json['torrentURL'] ?? json['torrent_url']),
        link: _str(json['link']),
        isRead: _bool(json['isRead']),
      );
}

class QbRssFeed {
  final String uid;
  final String url;
  final String title;
  final String lastBuildDate;
  final bool isLoading;
  final bool hasError;
  final List<QbRssArticle> articles;

  const QbRssFeed({
    this.uid = '',
    this.url = '',
    this.title = '',
    this.lastBuildDate = '',
    this.isLoading = false,
    this.hasError = false,
    this.articles = const [],
  });

  factory QbRssFeed.fromJson(Map<String, dynamic> json) => QbRssFeed(
        uid: _str(json['uid']),
        url: _str(json['url']),
        title: _str(json['title']),
        lastBuildDate: _str(json['lastBuildDate']),
        isLoading: _bool(json['isLoading']),
        hasError: _bool(json['hasError']),
        articles: json['articles'] is List
            ? (json['articles'] as List)
                .whereType<Map>()
                .map((e) => QbRssArticle.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : const [],
      );
}

class QbRssNode {
  final String name;
  final bool isFolder;
  final QbRssFeed? feed;
  final List<QbRssNode> children;

  const QbRssNode.folder(this.name, this.children)
      : isFolder = true,
        feed = null;

  const QbRssNode.feedItem(this.name, this.feed)
      : isFolder = false,
        children = const [];
}

class QbRssTree {
  final List<QbRssNode> roots;

  const QbRssTree(this.roots);

  factory QbRssTree.parse(dynamic data) {
    if (data is! Map) return const QbRssTree([]);
    return QbRssTree(_parseMap(data));
  }

  static List<QbRssNode> _parseMap(Map data) {
    final nodes = <QbRssNode>[];
    data.forEach((key, value) {
      final name = key.toString();
      if (value is Map) {
        if (value.containsKey('uid') || value.containsKey('url')) {
          nodes.add(QbRssNode.feedItem(name, QbRssFeed.fromJson(Map<String, dynamic>.from(value))));
        } else {
          nodes.add(QbRssNode.folder(name, _parseMap(value)));
        }
      } else {
        nodes.add(QbRssNode.folder(name, const []));
      }
    });
    return nodes;
  }
}

class QbRssRule {
  final String name;
  final bool enabled;
  final int priority;
  final bool useRegex;
  final String mustContain;
  final String mustNotContain;
  final String episodeFilter;
  final List<String> affectedFeeds;
  final String lastMatch;
  final int ignoreDays;
  final bool smartFilter;
  final Map<String, dynamic> torrentParams;

  const QbRssRule({
    this.name = '',
    this.enabled = true,
    this.priority = 0,
    this.useRegex = false,
    this.mustContain = '',
    this.mustNotContain = '',
    this.episodeFilter = '',
    this.affectedFeeds = const [],
    this.lastMatch = '',
    this.ignoreDays = 0,
    this.smartFilter = false,
    this.torrentParams = const {},
  });

  factory QbRssRule.fromEntry(String name, Map<String, dynamic> json) => QbRssRule(
        name: name,
        enabled: _bool(json['enabled'], true),
        priority: _int(json['priority']),
        useRegex: _bool(json['useRegex']),
        mustContain: _str(json['mustContain']),
        mustNotContain: _str(json['mustNotContain']),
        episodeFilter: _str(json['episodeFilter']),
        affectedFeeds: _stringList(json['affectedFeeds']),
        lastMatch: _str(json['lastMatch']),
        ignoreDays: _int(json['ignoreDays']),
        smartFilter: _bool(json['smartFilter']),
        torrentParams: json['torrentParams'] is Map
            ? Map<String, dynamic>.from(json['torrentParams'] as Map)
            : const {},
      );

  Map<String, dynamic> toRuleJson() => {
        'enabled': enabled,
        'priority': priority,
        'useRegex': useRegex,
        'mustContain': mustContain,
        'mustNotContain': mustNotContain,
        'episodeFilter': episodeFilter,
        'affectedFeeds': affectedFeeds,
        'ignoreDays': ignoreDays,
        'smartFilter': smartFilter,
        if (torrentParams.isNotEmpty) 'torrentParams': torrentParams,
      };
}
