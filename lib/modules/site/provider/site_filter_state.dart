import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';

enum FilterCondition {
  alive,
  dead,
  notSignedIn,
  hasNewMessage,
  hasNewAnnouncement,
  hasNewNotification,
  noTodayData,
  hasUploadDelta,
  hasDownloadDelta,
  noProxy,
  noUid,
  noUsername,
  noEmail,
  noSignInRecord,
  noCookie,
  noPasskey,
  noAuthKey,
  noSiteData,
  abnormalRegTime,
  hasInvitation,
  noSeeding,
  hasDownloading,
  abnormalShareRatio,
}

enum SortField {
  updatedAt,
  siteName,
  nickname,
  regTime,
  lastVisit,
  seedingSize,
  magic,
  credits,
  upload,
  uploadDelta,
  download,
  downloadDelta,
  seedCount,
  hourlyMagic,
  invitation,
  downloading,
  seeding,
  shareRatio,
}

class SiteFilterState extends ChangeNotifier {
  FilterCondition _condition = FilterCondition.alive; // 默认 alive
  SortField _sortField = SortField.updatedAt;
  bool _sortAscending = false;
  final Set<String> _selectedTags = {};
  String _siteNameQuery = '';
  Timer? _debounce;

  SiteFilterState() {
    _loadFromStorage();
  }

  FilterCondition get condition => _condition;

  SortField get sortField => _sortField;

  bool get sortAscending => _sortAscending;

  Set<String> get selectedTags => _selectedTags;

  String get siteNameQuery => _siteNameQuery;

  /// alive 是默认值，不算"额外"筛选
  bool get hasActiveFilters =>
      _condition != FilterCondition.alive ||
      _selectedTags.isNotEmpty ||
      _sortField != SortField.updatedAt ||
      _sortAscending ||
      _siteNameQuery.isNotEmpty;

  void _loadFromStorage() {
    final ci = HiveManager.get<int>(StorageKeys.siteFilterCondition);
    if (ci != null && ci >= 0 && ci < FilterCondition.values.length) {
      _condition = FilterCondition.values[ci];
    }
    // 没有存储过 → 保持默认 alive，并写入
    if (ci == null) {
      HiveManager.set(StorageKeys.siteFilterCondition, FilterCondition.alive.index);
    }

    final si = HiveManager.get<int>(StorageKeys.siteFilterSortField);
    if (si != null && si >= 0 && si < SortField.values.length) {
      _sortField = SortField.values[si];
    }
    final asc = HiveManager.get<bool>(StorageKeys.siteFilterSortAscending);
    if (asc != null) _sortAscending = asc;
  }

  void setCondition(FilterCondition c) {
    if (_condition == c) return; // 已选中，不切换
    _condition = c;
    HiveManager.set(StorageKeys.siteFilterCondition, c.index);
    notifyListeners();
  }

  void setSortField(SortField f) {
    if (_sortField == f) {
      _sortAscending = !_sortAscending;
      HiveManager.set(StorageKeys.siteFilterSortAscending, _sortAscending);
    } else {
      _sortField = f;
      _sortAscending = false;
      HiveManager.set(StorageKeys.siteFilterSortField, f.index);
      HiveManager.set(StorageKeys.siteFilterSortAscending, false);
    }
    notifyListeners();
  }

  void toggleTag(String tag) {
    _selectedTags.contains(tag) ? _selectedTags.remove(tag) : _selectedTags.add(tag);
    notifyListeners();
  }

  void setSiteNameQuery(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _siteNameQuery = q.trim();
      notifyListeners();
    });
  }

  void commitSiteNameQuery(String q) {
    _debounce?.cancel();
    _siteNameQuery = q;
    notifyListeners();
  }

  void clearAll() {
    _debounce?.cancel();
    _condition = FilterCondition.alive; // 重置为默认值
    _sortField = SortField.updatedAt;
    _sortAscending = false;
    _selectedTags.clear();
    _siteNameQuery = '';
    HiveManager.set(StorageKeys.siteFilterCondition, FilterCondition.alive.index);
    HiveManager.delete(StorageKeys.siteFilterSortField);
    HiveManager.delete(StorageKeys.siteFilterSortAscending);
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
