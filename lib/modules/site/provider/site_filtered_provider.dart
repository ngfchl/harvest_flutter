import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/site_info.dart';
import 'site_filter_state.dart';
import 'site_provider.dart';

part 'site_filtered_provider.g.dart';

final siteFilterStateProvider = ChangeNotifierProvider((_) => SiteFilterState());

@riverpod
List<String> availableTags(Ref ref) {
  final sites = ref.watch(siteInfoListProvider).valueOrNull ?? [];
  return sites.expand((s) => s.tags).where((t) => t.isNotEmpty).toSet().toList()..sort();
}

@riverpod
List<SiteInfo> filteredSiteList(Ref ref) {
  final sites = ref.watch(siteInfoListProvider).valueOrNull ?? [];
  final filter = ref.watch(siteFilterStateProvider);
  return _applyFilter(sites, filter);
}

List<SiteInfo> _applyFilter(List<SiteInfo> sites, SiteFilterState filter) {
  final condition = filter.condition;
  final query = filter.siteNameQuery.toLowerCase();

  List<SiteInfo> result;
  if (condition == null && filter.selectedTags.isEmpty && query.isEmpty) {
    result = List.of(sites);
  } else {
    result = sites.where((s) {
      if (query.isNotEmpty) {
        if (!s.site.toLowerCase().contains(query) && !s.nickname.toLowerCase().contains(query)) return false;
      }
      if (condition != null && !_matchCondition(s, condition)) return false;
      if (filter.selectedTags.isNotEmpty && !filter.selectedTags.any(s.tags.contains)) return false;
      return true;
    }).toList();
  }

  result.sort((a, b) {
    final va = _sortKey(a, filter.sortField);
    final vb = _sortKey(b, filter.sortField);
    int cmp;
    if (va is String && vb is String) {
      cmp = va.compareTo(vb);
    } else {
      cmp = (va as num).toDouble().compareTo((vb as num).toDouble());
    }
    return filter.sortAscending ? cmp : -cmp;
  });

  return result;
}

bool _matchCondition(SiteInfo s, FilterCondition c) {
  final status = s.latestStatus;
  switch (c) {
    case FilterCondition.alive:
      return s.available;
    case FilterCondition.dead:
      return !s.available;
    case FilterCondition.notSignedIn:
      return s.signIn && (s.signInfo == null || s.signInfo!.isEmpty);
    case FilterCondition.hasNewMessage:
      return s.mail > 0;
    case FilterCondition.hasNewAnnouncement:
      return s.notice > 0;
    case FilterCondition.hasNewNotification:
      return s.mail > 0 || s.notice > 0;
    case FilterCondition.noTodayData:
      if (s.status == null || s.status!.isEmpty) return true;
      final latest = s.latestStatus;
      if (latest == null) return true;
      return !latest.updated_at.startsWith(_todayStr());
    case FilterCondition.hasUploadDelta:
      return _uploadDelta(s) > 0;
    case FilterCondition.hasDownloadDelta:
      return _downloadDelta(s) > 0;
    case FilterCondition.noProxy:
      return (s.proxy ?? '').isEmpty;
    case FilterCondition.noUid:
      return (s.userId ?? '').isEmpty;
    case FilterCondition.noUsername:
      return (s.username ?? '').isEmpty;
    case FilterCondition.noEmail:
      return (s.email ?? '').isEmpty;
    case FilterCondition.noSignInRecord:
      return s.signIn && (s.signInfo == null || s.signInfo!.isEmpty);
    case FilterCondition.noCookie:
      return (s.cookie ?? '').isEmpty;
    case FilterCondition.noPasskey:
      return (s.passkey ?? '').isEmpty;
    case FilterCondition.noAuthKey:
      return (s.authkey ?? '').isEmpty;
    case FilterCondition.noSiteData:
      return s.status == null || s.status!.isEmpty;
    case FilterCondition.abnormalRegTime:
      return s.timeJoin == null || s.timeJoin!.startsWith('0001');
    case FilterCondition.hasInvitation:
      return status != null && status.invitation > 0;
    case FilterCondition.noSeeding:
      return status == null || status.seed <= 0;
    case FilterCondition.hasDownloading:
      return status != null && status.leech > 0;
    case FilterCondition.abnormalShareRatio:
      return status != null && status.ratio < 1.0;
  }
}

String _todayStr() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String _dateStr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

int _uploadDelta(SiteInfo s) {
  if (s.status == null || s.status!.isEmpty) return 0;
  final now = DateTime.now();
  final today = s.status![_dateStr(now)];
  final yesterday = s.status![_dateStr(now.subtract(const Duration(days: 1)))];
  if (today == null || yesterday == null) return 0;
  return today.uploaded - yesterday.uploaded;
}

int _downloadDelta(SiteInfo s) {
  if (s.status == null || s.status!.isEmpty) return 0;
  final now = DateTime.now();
  final today = s.status![_dateStr(now)];
  final yesterday = s.status![_dateStr(now.subtract(const Duration(days: 1)))];
  if (today == null || yesterday == null) return 0;
  return today.downloaded - yesterday.downloaded;
}

Object _sortKey(SiteInfo s, SortField field) {
  final status = s.latestStatus;
  switch (field) {
    case SortField.updatedAt:
      return s.latestStatusUpdatedAt ?? '';
    case SortField.siteName:
      return s.site;
    case SortField.nickname:
      return s.nickname;
    case SortField.regTime:
      return s.timeJoin ?? '';
    case SortField.lastVisit:
      return s.latestActive ?? '';
    case SortField.seedingSize:
      return status?.seedVolume ?? 0;
    case SortField.magic:
      return status?.myBonus ?? 0.0;
    case SortField.credits:
      return status?.myScore ?? 0.0;
    case SortField.upload:
      return status?.uploaded ?? 0;
    case SortField.uploadDelta:
      return _uploadDelta(s);
    case SortField.download:
      return status?.downloaded ?? 0;
    case SortField.downloadDelta:
      return _downloadDelta(s);
    case SortField.seedCount:
      return status?.publish ?? 0;
    case SortField.hourlyMagic:
      return status?.bonusHour ?? 0.0;
    case SortField.invitation:
      return status?.invitation ?? 0;
    case SortField.downloading:
      return status?.leech ?? 0;
    case SortField.seeding:
      return status?.seed ?? 0;
    case SortField.shareRatio:
      return status?.ratio ?? 0.0;
  }
}
