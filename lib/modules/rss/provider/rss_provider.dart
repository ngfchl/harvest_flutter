import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';

import '../model/rss_models.dart';
import '../service/rss_service.dart';

// ─────────────────── RSS 源 ───────────────────

final rssFeedsProvider =
    AsyncNotifierProvider<RssFeedsNotifier, List<RssFeed>>(
        RssFeedsNotifier.new);

class RssFeedsNotifier extends AsyncNotifier<List<RssFeed>> {
  @override
  Future<List<RssFeed>> build() async {
    if (!HiveManager.hasAccessToken) return const <RssFeed>[];
    return RssService.fetchFeeds();
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = AsyncValue.data(state.value ?? const <RssFeed>[]);
      return;
    }
    state = await AsyncValue.guard(RssService.fetchFeeds);
  }

  Future<void> save(RssFeed feed) async {
    if (feed.id == 0) {
      await RssService.createFeed(feed);
    } else {
      await RssService.updateFeed(feed);
    }
    await refresh();
  }

  Future<void> delete(int id) async {
    await RssService.deleteFeed(id);
    await refresh();
  }

  Future<RssFeedRefreshResult> refreshFeed(int id) async {
    final result = await RssService.refreshFeed(id);
    await refresh();
    return result;
  }
}

// ─────────────────── 订阅标签 ───────────────────

final rssTagsProvider = AsyncNotifierProvider<RssTagsNotifier, List<RssTag>>(
    RssTagsNotifier.new);

class RssTagsNotifier extends AsyncNotifier<List<RssTag>> {
  @override
  Future<List<RssTag>> build() async {
    if (!HiveManager.hasAccessToken) return const <RssTag>[];
    return RssService.fetchTags();
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = AsyncValue.data(state.value ?? const <RssTag>[]);
      return;
    }
    state = await AsyncValue.guard(RssService.fetchTags);
  }

  Future<void> save(RssTag tag) async {
    if (tag.id == 0) {
      await RssService.createTag(tag);
    } else {
      await RssService.updateTag(tag);
    }
    await refresh();
  }

  Future<void> delete(int id) async {
    await RssService.deleteTag(id);
    await refresh();
  }

  Future<RssTagImportResult> importDefaults() async {
    final result = await RssService.importDefaultTags();
    await refresh();
    return result;
  }
}

// ─────────────────── 订阅方案 ───────────────────

final rssPlansProvider = AsyncNotifierProvider<RssPlansNotifier, List<RssPlan>>(
    RssPlansNotifier.new);

class RssPlansNotifier extends AsyncNotifier<List<RssPlan>> {
  @override
  Future<List<RssPlan>> build() async {
    if (!HiveManager.hasAccessToken) return const <RssPlan>[];
    return RssService.fetchPlans();
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = AsyncValue.data(state.value ?? const <RssPlan>[]);
      return;
    }
    state = await AsyncValue.guard(RssService.fetchPlans);
  }

  Future<void> save(RssPlan plan) async {
    if (plan.id == 0) {
      await RssService.createPlan(plan);
    } else {
      await RssService.updatePlan(plan);
    }
    await refresh();
  }

  Future<void> delete(int id) async {
    await RssService.deletePlan(id);
    await refresh();
  }
}

// ─────────────────── RSS 订阅 ───────────────────

final rssSubscriptionsProvider =
    AsyncNotifierProvider<RssSubscriptionsNotifier, List<RssSubscription>>(
        RssSubscriptionsNotifier.new);

class RssSubscriptionsNotifier extends AsyncNotifier<List<RssSubscription>> {
  @override
  Future<List<RssSubscription>> build() async {
    if (!HiveManager.hasAccessToken) return const <RssSubscription>[];
    return RssService.fetchSubscriptions();
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = AsyncValue.data(state.value ?? const <RssSubscription>[]);
      return;
    }
    state = await AsyncValue.guard(RssService.fetchSubscriptions);
  }

  Future<void> save(RssSubscription sub) async {
    if (sub.id == 0) {
      await RssService.createSubscription(sub);
    } else {
      await RssService.updateSubscription(sub);
    }
    await refresh();
  }

  Future<void> delete(int id) async {
    await RssService.deleteSubscription(id);
    await refresh();
  }

  Future<RssRunResult> runOne(int id) async {
    final result = await RssService.runOne(id);
    await ref.read(rssHistoryProvider.notifier).refresh();
    return result;
  }

  Future<List<RssRunResult>> runAll() async {
    final results = await RssService.runAll();
    await ref.read(rssHistoryProvider.notifier).refresh();
    return results;
  }

  Future<List<RssSubscriptionPreviewItem>> preview(int id, {int limit = 20}) {
    return RssService.previewSubscription(id, limit: limit);
  }
}

// ─────────────────── 订阅历史 ───────────────────

final rssHistoryProvider =
    AsyncNotifierProvider<RssHistoryNotifier, List<RssHistoryItem>>(
        RssHistoryNotifier.new);

class RssHistoryNotifier extends AsyncNotifier<List<RssHistoryItem>> {
  @override
  Future<List<RssHistoryItem>> build() async {
    if (!HiveManager.hasAccessToken) return const <RssHistoryItem>[];
    return RssService.fetchHistory();
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = AsyncValue.data(state.value ?? const <RssHistoryItem>[]);
      return;
    }
    state = await AsyncValue.guard(RssService.fetchHistory);
  }

  Future<void> push(int id) async {
    await RssService.pushHistory(id);
    await refresh();
  }

  Future<void> delete(int id) async {
    await RssService.deleteHistory(id);
    await refresh();
  }

  Future<void> clear() async {
    await RssService.clearHistory();
    await refresh();
  }
}

// ─────────────────── qBittorrent RSS ───────────────────

final qbRssItemsProvider =
    FutureProvider.family<QbRssTree, ({int downloaderId, bool withData})>((
  ref,
  params,
) {
  if (!HiveManager.hasAccessToken) return Future.value(const QbRssTree([]));
  return RssService.fetchQbRssItems(params.downloaderId,
      withData: params.withData);
});

final qbRssRulesProvider =
    FutureProvider.family<List<QbRssRule>, int>((ref, downloaderId) {
  if (!HiveManager.hasAccessToken) return Future.value(const <QbRssRule>[]);
  return RssService.fetchQbRules(downloaderId);
});
