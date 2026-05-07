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
  all,
  hasDelta,
  keepAccount,
  graduated,
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
  sortId,
}

class SiteFilterState extends ChangeNotifier {
  FilterCondition _condition = FilterCondition.all;
  SortField _sortField = SortField.sortId;
  bool _sortAscending = true;
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

  /// 全部 + 排序 ID 正序 是默认值，不算"额外"筛选
  bool get hasActiveFilters =>
      _condition != FilterCondition.all ||
      _selectedTags.isNotEmpty ||
      _sortField != SortField.sortId ||
      _sortAscending != _defaultSortAscending(_sortField) ||
      _siteNameQuery.isNotEmpty;

  void _loadFromStorage() {
    final ci = HiveManager.get<int>(StorageKeys.siteFilterCondition);
    if (ci != null && ci >= 0 && ci < FilterCondition.values.length) {
      _condition = FilterCondition.values[ci];
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
      _sortAscending = _defaultSortAscending(f);
      HiveManager.set(StorageKeys.siteFilterSortField, f.index);
      HiveManager.set(StorageKeys.siteFilterSortAscending, _sortAscending);
    }
    notifyListeners();
  }

  void toggleTag(String tag) {
    _selectedTags.contains(tag)
        ? _selectedTags.remove(tag)
        : _selectedTags.add(tag);
    notifyListeners();
  }

  void clearTags() {
    if (_selectedTags.isEmpty) return;
    _selectedTags.clear();
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
    _condition = FilterCondition.all;
    _sortField = SortField.sortId;
    _sortAscending = _defaultSortAscending(_sortField);
    _selectedTags.clear();
    _siteNameQuery = '';
    HiveManager.delete(StorageKeys.siteFilterCondition);
    HiveManager.delete(StorageKeys.siteFilterSortField);
    HiveManager.delete(StorageKeys.siteFilterSortAscending);
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  static bool _defaultSortAscending(SortField field) {
    return field == SortField.sortId;
  }
}
