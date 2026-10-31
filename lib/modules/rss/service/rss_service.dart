import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/hooks.dart';
import 'package:harvest/core/http/http.dart';

import '../model/rss_models.dart';

/// Harvest RSS 订阅接口 + qBittorrent RSS 管理接口。
class RssService {
  RssService._();

  static const String _feeds = API.SUB_RSS;
  static const String _tags = '/api/option/rss/tags';
  static const String _plans = '/api/option/rss/plans';
  static const String _subs = '/api/option/rss/subscriptions';
  static const String _history = '/api/option/rss/history';
  static const String _run = '/api/option/rss/run';
  static const String _qbRss = '/api/option/downloaders/rss';

  // ─────────────────── RSS 源 ───────────────────

  static Future<List<RssFeed>> fetchFeeds() =>
      fetchModelList('$_feeds/feeds', RssFeed.fromJson);

  static Future<void> createFeed(RssFeed feed) =>
      addData('$_feeds/feeds', feed.toJson());

  static Future<void> updateFeed(RssFeed feed) =>
      editData('$_feeds/feeds/${feed.id}', feed.toJson());

  static Future<void> deleteFeed(int id) => removeData('$_feeds/feeds/$id');

  static Future<List<RssPreviewItem>> previewFeed(int id) =>
      fetchModelList('$_feeds/feeds/$id/preview', RssPreviewItem.fromJson);

  static Future<RssFeedRefreshResult> refreshFeed(int id) async {
    final data = await Http.post<Map<dynamic, dynamic>>('$_feeds/feeds/$id/refresh');
    return RssFeedRefreshResult.fromJson(Map<String, dynamic>.from(data));
  }

  // ─────────────────── 订阅标签 ───────────────────

  static Future<List<RssTag>> fetchTags() =>
      fetchModelList(_tags, RssTag.fromJson);

  static Future<void> createTag(RssTag tag) => addData(_tags, tag.toJson());

  static Future<void> updateTag(RssTag tag) =>
      editData('$_tags/${tag.id}', tag.toJson());

  static Future<void> deleteTag(int id) => removeData('$_tags/$id');

  static Future<RssTagImportResult> importDefaultTags() async {
    final data = await Http.get<Map<dynamic, dynamic>>('$_tags/import');
    return RssTagImportResult.fromJson(Map<String, dynamic>.from(data));
  }

  // ─────────────────── 订阅方案 ───────────────────

  static Future<List<RssPlan>> fetchPlans() =>
      fetchModelList(_plans, RssPlan.fromJson);

  static Future<void> createPlan(RssPlan plan) =>
      addData(_plans, plan.toJson());

  static Future<void> updatePlan(RssPlan plan) =>
      editData('$_plans/${plan.id}', plan.toJson());

  static Future<void> deletePlan(int id) => removeData('$_plans/$id');

  // ─────────────────── RSS 订阅 ───────────────────

  static Future<List<RssSubscription>> fetchSubscriptions() =>
      fetchModelList(_subs, RssSubscription.fromJson);

  static Future<void> createSubscription(RssSubscription sub) =>
      addData(_subs, sub.toJson());

  static Future<void> updateSubscription(RssSubscription sub) =>
      editData('$_subs/${sub.id}', sub.toJson());

  static Future<void> deleteSubscription(int id) => removeData('$_subs/$id');

  // ─────────────────── 订阅历史 ───────────────────

  static Future<List<RssHistoryItem>> fetchHistory() =>
      fetchModelList(_history, RssHistoryItem.fromJson);

  static Future<void> pushHistory(int id) =>
      Http.put<dynamic>('$_history/$id/push');

  static Future<void> deleteHistory(int id) => removeData('$_history/$id');

  static Future<void> clearHistory() => Http.delete<dynamic>(_history);

  // ─────────────────── 执行订阅 ───────────────────

  static Future<List<RssSubscriptionPreviewItem>> previewSubscription(int id, {int limit = 20}) =>
      fetchModelList('$_subs/$id/preview', RssSubscriptionPreviewItem.fromJson,
          queryParameters: {'limit': limit});

  static Future<List<RssRunResult>> runAll() async {
    final data = await Http.post<List>(_run);
    return data
        .whereType<Map>()
        .map((e) => RssRunResult.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<RssRunResult> runOne(int subscriptionId) async {
    final data = await Http.post<Map<dynamic, dynamic>>('$_run/$subscriptionId');
    return RssRunResult.fromJson(Map<String, dynamic>.from(data));
  }

  // ─────────────────── qBittorrent RSS ───────────────────

  static Future<QbRssTree> fetchQbRssItems(int downloaderId,
      {bool withData = false}) async {
    final data = await Http.get<dynamic>('$_qbRss/$downloaderId',
        queryParameters: {'with_data': withData});
    return QbRssTree.parse(data);
  }

  static Future<void> qbCreateFolder(int downloaderId, String path) =>
      Http.post<dynamic>('$_qbRss/folders/$downloaderId',
          data: {'path': path});

  static Future<void> qbAddFeed(int downloaderId, String url, String path) =>
      Http.post<dynamic>('$_qbRss/feeds/$downloaderId',
          data: {'url': url, 'path': path});

  static Future<void> qbUpdateFeed(int downloaderId, String url, String path) =>
      Http.put<dynamic>('$_qbRss/feeds/$downloaderId',
          data: {'url': url, 'path': path});

  static Future<void> qbRemoveItem(int downloaderId, String path) =>
      Http.delete<dynamic>('$_qbRss/item/$downloaderId',
          queryParameters: {'path': path});

  static Future<void> qbMoveItem(
          int downloaderId, String itemPath, String destPath) =>
      Http.put<dynamic>('$_qbRss/item/move/$downloaderId',
          data: {'item_path': itemPath, 'dest_path': destPath});

  static Future<void> qbRefreshItem(int downloaderId, String path) =>
      Http.post<dynamic>('$_qbRss/item/refresh/$downloaderId',
          data: {'path': path});

  static Future<void> qbMarkRead(int downloaderId, String path,
          String articleId) =>
      Http.post<dynamic>('$_qbRss/item/read/$downloaderId',
          data: {'path': path, 'article_id': articleId});

  static Future<List<QbRssRule>> fetchQbRules(int downloaderId) async {
    final data = await Http.get<Map<dynamic, dynamic>>('$_qbRss/rules/$downloaderId');
    return data.entries
        .where((e) => e.value is Map)
        .map((e) => QbRssRule.fromEntry(
            e.key, Map<String, dynamic>.from(e.value as Map)))
        .toList();
  }

  static Future<void> qbSaveRule(
          int downloaderId, String ruleName, Map<String, dynamic> rule) =>
      Http.put<dynamic>('$_qbRss/rules/$downloaderId',
          data: {'rule_name': ruleName, 'rule': rule});

  static Future<void> qbRenameRule(
          int downloaderId, String ruleName, String newRuleName) =>
      Http.put<dynamic>('$_qbRss/rules/rename/$downloaderId',
          data: {'rule_name': ruleName, 'new_rule_name': newRuleName});

  static Future<void> qbDeleteRule(int downloaderId, String ruleName) =>
      Http.delete<dynamic>(
          '$_qbRss/rules/$downloaderId/${Uri.encodeComponent(ruleName)}');

  static Future<List<QbRssArticle>> qbMatchingArticles(
      int downloaderId, String ruleName) async {
    final data = await Http.get<List>(
        '$_qbRss/rules/matching/$downloaderId/${Uri.encodeComponent(ruleName)}');
    return data
        .whereType<Map>()
        .map((e) => QbRssArticle.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> qbSetAutoDownload(int downloaderId, bool enabled) =>
      Http.put<dynamic>('$_qbRss/auto-download/$downloaderId',
          data: {'enabled': enabled});

  static Future<void> qbSetProcessing(int downloaderId, bool enabled) =>
      Http.put<dynamic>('$_qbRss/processing/$downloaderId',
          data: {'enabled': enabled});
}
