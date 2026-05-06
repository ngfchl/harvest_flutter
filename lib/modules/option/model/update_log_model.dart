enum UpdateTarget { backend, sites }

extension UpdateTargetLabel on UpdateTarget {
  String get title {
    switch (this) {
      case UpdateTarget.backend:
        return '后端代码';
      case UpdateTarget.sites:
        return '站点配置';
    }
  }

  UpgradeAction get upgradeAction {
    switch (this) {
      case UpdateTarget.backend:
        return UpgradeAction.django;
      case UpdateTarget.sites:
        return UpgradeAction.sites;
    }
  }
}

enum UpgradeAction {
  django('upgrade_django', '更新后端代码'),
  sites('upgrade_sites', '更新站点配置'),
  all('upgrade_all', '更新所有'),
  webui('upgrade_webui', '更新WEBUI');

  final String tag;
  final String label;

  const UpgradeAction(this.tag, this.label);
}

class UpdateCommit {
  final String? hash;
  final String message;
  final String? author;
  final String? date;
  final String raw;

  const UpdateCommit({
    required this.message,
    required this.raw,
    this.hash,
    this.author,
    this.date,
  });

  factory UpdateCommit.fromJson(Map<String, dynamic> json) {
    final hash = _firstString(json, const [
      'hash',
      'hex',
      'commit',
      'commit_id',
      'sha',
      'id',
      'revision',
    ]);
    final message =
        _firstString(json, const [
          'message',
          'msg',
          'subject',
          'title',
          'summary',
          'name',
          'data',
        ]) ??
        '';
    final author = _firstString(json, const [
      'author',
      'committer',
      'user',
      'username',
    ]);
    final date = _firstString(json, const [
      'date',
      'time',
      'datetime',
      'created_at',
      'commit_time',
      'timestamp',
    ]);
    final raw =
        _firstString(json, const ['raw', 'text', 'line', 'data']) ??
        json.toString();

    return UpdateCommit(
      hash: hash,
      message: message.isEmpty ? raw : message,
      author: author,
      date: date,
      raw: raw,
    );
  }

  factory UpdateCommit.fromText(String text) {
    final trimmed = text.trim();
    final hash = RegExp(
      r'\b[0-9a-f]{7,40}\b',
      caseSensitive: false,
    ).firstMatch(trimmed)?.group(0);
    var message = trimmed;
    if (hash != null) {
      message = trimmed.replaceFirst(hash, '').trimLeft();
      if (message.startsWith('-')) message = message.substring(1).trimLeft();
    }
    return UpdateCommit(
      hash: hash,
      message: message.isEmpty ? trimmed : message,
      raw: trimmed,
    );
  }

  String get shortHash =>
      hash == null || hash!.length <= 8 ? (hash ?? '') : hash!.substring(0, 8);
}

class UpdateLogInfo {
  final UpdateTarget target;
  final bool? hasUpdate;
  final int? behindCount;
  final String? branch;
  final String? localVersion;
  final String? remoteVersion;
  final String? message;
  final String? rawText;
  final UpdateCommit? localLog;
  final List<UpdateCommit> commits;
  final DateTime checkedAt;

  const UpdateLogInfo({
    required this.target,
    required this.checkedAt,
    this.hasUpdate,
    this.behindCount,
    this.branch,
    this.localVersion,
    this.remoteVersion,
    this.message,
    this.rawText,
    this.localLog,
    this.commits = const [],
  });

  factory UpdateLogInfo.empty(UpdateTarget target) {
    return UpdateLogInfo(
      target: target,
      checkedAt: DateTime.now(),
      hasUpdate: false,
    );
  }

  factory UpdateLogInfo.fromResponse(UpdateTarget target, dynamic data) {
    final now = DateTime.now();
    if (data == null) {
      return UpdateLogInfo(
        target: target,
        checkedAt: now,
        hasUpdate: null,
        message: '暂无返回数据',
      );
    }

    if (data is List) {
      final commits = _parseCommitList(data);
      return UpdateLogInfo(
        target: target,
        checkedAt: now,
        hasUpdate: commits.isNotEmpty,
        commits: commits,
      );
    }

    if (data is String) {
      final commits = _parseCommitsFromText(data);
      return UpdateLogInfo(
        target: target,
        checkedAt: now,
        hasUpdate: _inferHasUpdate(data, commits: commits),
        rawText: data,
        commits: commits,
      );
    }

    if (data is Map) {
      final json = Map<String, dynamic>.from(data);
      final localLog = _parseSingleCommit(
        _firstValue(json, const ['local_logs', 'localLog', 'local_log']),
      );
      final rawText = _firstString(json, const [
        'raw',
        'text',
        'log_text',
        'output',
        'stdout',
        'result',
      ]);
      final listValue = _firstValue(json, const [
        'update_notes',
        'updateNotes',
        'logs',
        'log',
        'commits',
        'commit_logs',
        'updates',
        'changes',
        'items',
        'results',
      ]);
      var commits = _parseCommitValue(listValue);
      if (commits.isEmpty && rawText != null) {
        commits = _parseCommitsFromText(rawText);
      }

      final explicitHasUpdate = _firstBool(json, const [
        'has_update',
        'hasUpdate',
        'need_update',
        'needUpdate',
        'can_update',
        'canUpdate',
        'update',
        'updated',
      ]);
      final behind = _firstInt(json, const [
        'behind',
        'behind_count',
        'behindCount',
        'count',
        'total',
      ]);
      final message = _firstString(json, const [
        'message',
        'msg',
        'detail',
        'summary',
        'status',
      ]);
      final inferredText = rawText ?? message;

      return UpdateLogInfo(
        target: target,
        checkedAt: now,
        hasUpdate:
            explicitHasUpdate ??
            (behind == null
                ? _inferHasUpdate(inferredText, commits: commits)
                : behind > 0),
        behindCount: behind ?? (commits.isEmpty ? null : commits.length),
        branch: _firstString(json, const ['branch', 'current_branch']),
        localVersion:
            _firstString(json, const [
              'local',
              'local_version',
              'localVersion',
              'current',
              'current_version',
            ]) ??
            localLog?.hash,
        remoteVersion: _firstString(json, const [
          'remote',
          'remote_version',
          'remoteVersion',
          'latest',
          'latest_version',
        ]),
        message: message,
        rawText: rawText,
        localLog: localLog,
        commits: commits,
      );
    }

    final text = data.toString();
    final commits = _parseCommitsFromText(text);
    return UpdateLogInfo(
      target: target,
      checkedAt: now,
      hasUpdate: _inferHasUpdate(text, commits: commits),
      rawText: text,
      commits: commits,
    );
  }

  int get currentCommitIndex {
    final hash = localLog?.hash;
    if (hash == null || hash.isEmpty) return -1;
    return commits.indexWhere((commit) => _sameCommitHash(commit.hash, hash));
  }

  int get pendingUpdateCount {
    final index = currentCommitIndex;
    if (index >= 0) return index;
    if (behindCount != null) return behindCount!;
    if (hasUpdate == false) return 0;
    return commits.length;
  }

  bool get needsUpdate {
    if (pendingUpdateCount > 0) return true;
    return hasUpdate == true && commits.isEmpty && behindCount == null;
  }

  String get statusText {
    final count = pendingUpdateCount;
    if (needsUpdate) {
      if (count > 0) return '发现 $count 个更新';
      return '发现更新';
    }
    if (hasUpdate == false || currentCommitIndex >= 0) return '已是最新';
    return '状态未知';
  }

  String get detailText {
    final parts = <String>[];
    if (branch != null && branch!.isNotEmpty) parts.add(branch!);
    if (localLog != null && localLog!.shortHash.isNotEmpty) {
      parts.add('本地 ${localLog!.shortHash}');
    } else if (localVersion != null && localVersion!.isNotEmpty) {
      parts.add('本地 ${_shortVersion(localVersion!)}');
    }
    if (remoteVersion != null && remoteVersion!.isNotEmpty) {
      parts.add('远端 ${_shortVersion(remoteVersion!)}');
    }
    if (parts.isNotEmpty) return parts.join(' · ');
    if (message != null && message!.isNotEmpty) return message!;
    if (rawText != null && rawText!.trim().isNotEmpty && commits.isEmpty) {
      return rawText!.trim();
    }
    return '最近检查 ${_formatClock(checkedAt)}';
  }
}

String parseUpdateCommandMessage(dynamic data) {
  if (data == null) return '升级命令已执行';
  if (data is String) return data.trim().isEmpty ? '升级命令已执行' : data.trim();
  if (data is Map) {
    final json = Map<String, dynamic>.from(data);
    return _firstString(json, const [
          'message',
          'msg',
          'detail',
          'summary',
          'output',
          'stdout',
          'result',
        ]) ??
        '升级命令已执行';
  }
  return data.toString();
}

List<UpdateCommit> _parseCommitValue(dynamic value) {
  if (value == null) return const [];
  if (value is List) return _parseCommitList(value);
  if (value is String) return _parseCommitsFromText(value);
  if (value is Map) {
    final json = Map<String, dynamic>.from(value);
    if (_isCommitMap(json)) {
      final commit = _parseSingleCommit(json);
      return commit == null ? const [] : [commit];
    }
    return _parseCommitList(value.values.toList());
  }
  return [UpdateCommit.fromText(value.toString())];
}

UpdateCommit? _parseSingleCommit(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    return UpdateCommit.fromJson(Map<String, dynamic>.from(value));
  }
  if (value is String && value.trim().isNotEmpty) {
    return UpdateCommit.fromText(value);
  }
  return null;
}

bool _isCommitMap(Map<String, dynamic> json) {
  return json.containsKey('hex') ||
      json.containsKey('hash') ||
      json.containsKey('commit') ||
      json.containsKey('sha') ||
      json.containsKey('data') ||
      json.containsKey('message');
}

List<UpdateCommit> _parseCommitList(List list) {
  return list
      .map((item) {
        if (item is Map) {
          return UpdateCommit.fromJson(Map<String, dynamic>.from(item));
        }
        return UpdateCommit.fromText(item.toString());
      })
      .where(
        (commit) =>
            commit.message.trim().isNotEmpty &&
            !_looksLikeNoUpdateText(commit.message),
      )
      .toList();
}

List<UpdateCommit> _parseCommitsFromText(String text) {
  final commitBlocks = RegExp(
    r'^commit\s+([0-9a-f]{7,40})([\s\S]*?)(?=^commit\s+[0-9a-f]{7,40}|\z)',
    caseSensitive: false,
    multiLine: true,
  ).allMatches(text);

  final parsedBlocks = commitBlocks.map((match) {
    final block = match.group(0) ?? '';
    final body = match.group(2) ?? '';
    final author = RegExp(
      r'^Author:\s*(.+)$',
      multiLine: true,
    ).firstMatch(body)?.group(1)?.trim();
    final date = RegExp(
      r'^Date:\s*(.+)$',
      multiLine: true,
    ).firstMatch(body)?.group(1)?.trim();
    final messageLines = body
        .split('\n')
        .map((line) => line.trim())
        .where(
          (line) =>
              line.isNotEmpty &&
              !line.startsWith('Author:') &&
              !line.startsWith('Date:'),
        )
        .toList();
    final message = messageLines.isEmpty
        ? block.split('\n').first.trim()
        : messageLines.first;
    return UpdateCommit(
      hash: match.group(1),
      message: message,
      author: author,
      date: date,
      raw: block.trim(),
    );
  }).toList();

  if (parsedBlocks.isNotEmpty) return parsedBlocks;

  return text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !_looksLikeNoUpdateText(line))
      .map(UpdateCommit.fromText)
      .toList();
}

bool? _inferHasUpdate(String? text, {required List<UpdateCommit> commits}) {
  if (commits.isNotEmpty) return true;
  if (text == null || text.trim().isEmpty) return false;
  if (_looksLikeNoUpdateText(text)) return false;
  if (RegExp(r'\b[0-9a-f]{7,40}\b', caseSensitive: false).hasMatch(text)) {
    return true;
  }
  return null;
}

bool _looksLikeNoUpdateText(String text) {
  final lower = text.toLowerCase();
  return lower.contains('already up to date') ||
      lower.contains('already up-to-date') ||
      lower.contains('up to date') ||
      lower.contains('no update') ||
      lower.contains('no updates') ||
      text.contains('暂无更新') ||
      text.contains('无更新') ||
      text.contains('已是最新') ||
      text.contains('已经是最新');
}

bool _sameCommitHash(String? a, String b) {
  if (a == null || a.isEmpty) return false;
  return a == b || a.startsWith(b) || b.startsWith(a);
}

String? _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

dynamic _firstValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) return json[key];
  }
  return null;
}

bool? _firstBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (['true', '1', 'yes', 'y'].contains(normalized)) return true;
      if (['false', '0', 'no', 'n'].contains(normalized)) return false;
    }
  }
  return null;
}

int? _firstInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

String _shortVersion(String value) {
  final trimmed = value.trim();
  return trimmed.length <= 10 ? trimmed : trimmed.substring(0, 10);
}

String _formatClock(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
