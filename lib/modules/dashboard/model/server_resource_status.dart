class ServerResourceStatus {
  final DateTime? timestamp;
  final bool isDocker;
  final int interval;
  final ServerCpuStatus cpu;
  final ServerMemoryStatus memory;
  final ServerNetworkStatus network;

  const ServerResourceStatus({
    required this.timestamp,
    required this.isDocker,
    required this.interval,
    required this.cpu,
    required this.memory,
    required this.network,
  });

  factory ServerResourceStatus.fromJson(Map<String, dynamic> json) {
    return ServerResourceStatus(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? ''),
      isDocker: json['isDocker'] == true,
      interval: (json['interval'] as num?)?.toInt() ?? 0,
      cpu: ServerCpuStatus.fromJson(Map<String, dynamic>.from(json['cpu'] as Map? ?? const {})),
      memory: ServerMemoryStatus.fromJson(Map<String, dynamic>.from(json['memory'] as Map? ?? const {})),
      network: ServerNetworkStatus.fromJson(Map<String, dynamic>.from(json['network'] as Map? ?? const {})),
    );
  }
}

class ServerCpuStatus {
  final double percent;
  final double usageSeconds;
  final double limitCores;

  const ServerCpuStatus({
    required this.percent,
    required this.usageSeconds,
    required this.limitCores,
  });

  factory ServerCpuStatus.fromJson(Map<String, dynamic> json) {
    return ServerCpuStatus(
      percent: (json['percent'] as num?)?.toDouble() ?? 0,
      usageSeconds: (json['usageSeconds'] as num?)?.toDouble() ?? 0,
      limitCores: (json['limitCores'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ServerMemoryStatus {
  final num usage;
  final num workingSet;
  final num limit;
  final double percent;

  const ServerMemoryStatus({
    required this.usage,
    required this.workingSet,
    required this.limit,
    required this.percent,
  });

  factory ServerMemoryStatus.fromJson(Map<String, dynamic> json) {
    return ServerMemoryStatus(
      usage: json['usage'] as num? ?? 0,
      workingSet: json['workingSet'] as num? ?? 0,
      limit: json['limit'] as num? ?? 0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ServerNetworkStatus {
  final num bytesSent;
  final num bytesRecv;
  final num uploadSpeed;
  final num downloadSpeed;

  const ServerNetworkStatus({
    required this.bytesSent,
    required this.bytesRecv,
    required this.uploadSpeed,
    required this.downloadSpeed,
  });

  factory ServerNetworkStatus.fromJson(Map<String, dynamic> json) {
    return ServerNetworkStatus(
      bytesSent: json['bytesSent'] as num? ?? 0,
      bytesRecv: json['bytesRecv'] as num? ?? 0,
      uploadSpeed: json['uploadSpeed'] as num? ?? 0,
      downloadSpeed: json['downloadSpeed'] as num? ?? 0,
    );
  }
}
