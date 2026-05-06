import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/modules/dashboard/provider/dashboard_provider.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart';
import 'package:harvest/modules/download/provider/downloader_speed_provider.dart';
import 'package:harvest/modules/news/douban/provider/douban_provider.dart';
import 'package:harvest/modules/news/tmdb/provider/tmdb_provider.dart';
import 'package:harvest/modules/notice/provider/notice_provider.dart';
import 'package:harvest/modules/option/provider/update_provider.dart';
import 'package:harvest/modules/site/provider/site_filtered_provider.dart';
import 'package:harvest/modules/site/provider/site_provider.dart';
import 'package:harvest/modules/task/provider/crontab_provider.dart';
import 'package:harvest/modules/task/provider/schedule_provider.dart';
import 'package:harvest/modules/user/provider/user_management_provider.dart';

void invalidateSessionState(Ref ref) {
  ref
    ..invalidate(dashboardNotifierProvider)
    ..invalidate(dashboardCacheInfoProvider)
    ..invalidate(siteInfoListProvider)
    ..invalidate(siteInfoCacheInfoProvider)
    ..invalidate(websiteListProvider)
    ..invalidate(unaddedSitesProvider)
    ..invalidate(siteFilterStateProvider)
    ..invalidate(filteredSiteListProvider)
    ..invalidate(availableTagsProvider)
    ..invalidate(downloaderListProvider)
    ..invalidate(downloaderListCacheInfoProvider)
    ..invalidate(downloaderPathsProvider)
    ..invalidate(downloaderSpeedProvider)
    ..invalidate(speedPausedProvider)
    ..invalidate(speedRemainingProvider)
    ..invalidate(scheduleProvider)
    ..invalidate(scheduleCacheInfoProvider)
    ..invalidate(crontabListProvider)
    ..invalidate(taskTypeListProvider)
    ..invalidate(noticeHistoryProvider)
    ..invalidate(updateProvider)
    ..invalidate(authInfoProvider)
    ..invalidate(managedUserListProvider)
    ..invalidate(tmdbCacheInfoProvider)
    ..invalidate(tmdbForceRefreshProvider)
    ..invalidate(playingMoviesProvider)
    ..invalidate(popularMoviesProvider)
    ..invalidate(upcomingMoviesProvider)
    ..invalidate(topRatedMoviesProvider)
    ..invalidate(airingTodayTvsProvider)
    ..invalidate(onTheAirTvsProvider)
    ..invalidate(popularTvsProvider)
    ..invalidate(topRatedTvsProvider)
    ..invalidate(doubanCacheInfoProvider)
    ..invalidate(doubanForceRefreshProvider)
    ..invalidate(doubanHotMoviesProvider)
    ..invalidate(doubanHotTvsProvider)
    ..invalidate(doubanTop250Provider)
    ..invalidate(doubanRankMoviesProvider)
    ..invalidate(doubanRankTvsProvider);
}
