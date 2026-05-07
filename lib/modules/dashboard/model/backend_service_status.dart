class BackendServiceSnapshot {
  final DateTime? timestamp;
  final String source;
  final BackendServiceSummary summary;
  final List<BackendServiceInfo> services;
  final List<String> errors;
  final String connectionId;
  final bool changed;

  const BackendServiceSnapshot({
    required this.timestamp,
    required this.source,
    required this.summary,
    required this.services,
    required this.errors,
    required this.connectionId,
    required this.changed,
  });

  bool get healthy =>
      summary.total > 0 &&
      summary.running == summary.total &&
      summary.failed == 0 &&
      errors.isEmpty;

  bool get hasIssue =>
      errors.isNotEmpty || summary.failed > 0 || summary.stopped > 0;

  factory BackendServiceSnapshot.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    final services = <BackendServiceInfo>[];
    if (rawServices is List) {
      for (final item in rawServices) {
        if (item is Map) {
          services.add(
            BackendServiceInfo.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return BackendServiceSnapshot(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? ''),
      source: json['source']?.toString() ?? '',
      summary: BackendServiceSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] as Map? ?? const {}),
      ),
      services: services,
      errors: (json['errors'] as List? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      connectionId: json['connectionId']?.toString() ?? '',
      changed: json['changed'] == true,
    );
  }
}

class BackendServiceSummary {
  final int total;
  final int running;
  final int stopped;
  final int failed;

  const BackendServiceSummary({
    required this.total,
    required this.running,
    required this.stopped,
    required this.failed,
  });

  static const empty = BackendServiceSummary(
    total: 0,
    running: 0,
    stopped: 0,
    failed: 0,
  );

  factory BackendServiceSummary.fromJson(Map<String, dynamic> json) {
    return BackendServiceSummary(
      total: (json['total'] as num?)?.toInt() ?? 0,
      running: (json['running'] as num?)?.toInt() ?? 0,
      stopped: (json['stopped'] as num?)?.toInt() ?? 0,
      failed: (json['failed'] as num?)?.toInt() ?? 0,
    );
  }
}

class BackendServiceInfo {
  final String name;
  final String group;
  final String displayName;
  final String state;
  final int stateCode;
  final int pid;
  final String description;
  final int start;
  final int stop;
  final int now;
  final int uptime;
  final String spawnerr;
  final int exitStatus;
  final String logfile;
  final String stdoutLogfile;
  final String stderrLogfile;

  const BackendServiceInfo({
    required this.name,
    required this.group,
    required this.displayName,
    required this.state,
    required this.stateCode,
    required this.pid,
    required this.description,
    required this.start,
    required this.stop,
    required this.now,
    required this.uptime,
    required this.spawnerr,
    required this.exitStatus,
    required this.logfile,
    required this.stdoutLogfile,
    required this.stderrLogfile,
  });

  String get title => displayName.isNotEmpty ? displayName : name;

  bool get running => state.toUpperCase() == 'RUNNING';

  factory BackendServiceInfo.fromJson(Map<String, dynamic> json) {
    return BackendServiceInfo(
      name: json['name']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      stateCode: (json['stateCode'] as num?)?.toInt() ?? 0,
      pid: (json['pid'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString() ?? '',
      start: (json['start'] as num?)?.toInt() ?? 0,
      stop: (json['stop'] as num?)?.toInt() ?? 0,
      now: (json['now'] as num?)?.toInt() ?? 0,
      uptime: (json['uptime'] as num?)?.toInt() ?? 0,
      spawnerr: json['spawnerr']?.toString() ?? '',
      exitStatus: (json['exitStatus'] as num?)?.toInt() ?? 0,
      logfile: json['logfile']?.toString() ?? '',
      stdoutLogfile: json['stdoutLogfile']?.toString() ?? '',
      stderrLogfile: json['stderrLogfile']?.toString() ?? '',
    );
  }
}
