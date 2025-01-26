

class TaskItem {
  String uuid;
  String name;
  String state;
  double received;
  double? sent;
  double started;
  double? rejected;
  double succeeded;
  double? failed;
  double? retried;
  double? revoked;
  String args;
  String kwargs;
  double? eta;
  double? expires;
  int retries;
  String result;
  String? exception;
  double timestamp;
  double runtime;
  String? traceback;
  String? exchange;
  String? routingKey;
  int clock;
  String? client;
  String root;
  String rootId;
  String? parent;
  String? parentId;
  List<dynamic>? children;
  String worker;

  TaskItem({
    required this.uuid,
    required this.name,
    required this.state,
    required this.received,
    this.sent,
    required this.started,
    this.rejected,
    required this.succeeded,
    this.failed,
    this.retried,
    this.revoked,
    required this.args,
    required this.kwargs,
    this.eta,
    this.expires,
    required this.retries,
    required this.result,
    this.exception,
    required this.timestamp,
    required this.runtime,
    this.traceback,
    this.exchange,
    this.routingKey,
    required this.clock,
    this.client,
    required this.root,
    required this.rootId,
    this.parent,
    this.parentId,
    required this.children,
    required this.worker,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      uuid: json['uuid'],
      name: json['name'],
      state: json['state'],
      received: json['received'].toDouble(),
      sent: json['sent']?.toDouble(),
      started: json['started'].toDouble(),
      rejected: json['rejected']?.toDouble(),
      succeeded: json['succeeded'].toDouble(),
      failed: json['failed']?.toDouble(),
      retried: json['retried']?.toDouble(),
      revoked: json['revoked']?.toDouble(),
      args: json['args'],
      kwargs: json['kwargs'],
      eta: json['eta']?.toDouble(),
      expires: json['expires']?.toDouble(),
      retries: json['retries'],
      result: json['result'],
      exception: json['exception'],
      timestamp: json['timestamp'].toDouble(),
      runtime: json['runtime'].toDouble(),
      traceback: json['traceback'],
      exchange: json['exchange'],
      routingKey: json['routing_key'],
      clock: json['clock'],
      client: json['client'],
      root: json['root'],
      rootId: json['root_id'],
      parent: json['parent'],
      parentId: json['parent_id'],
      children: json['children'] ?? [],
      worker: json['worker'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'state': state,
      'received': received,
      'sent': sent,
      'started': started,
      'rejected': rejected,
      'succeeded': succeeded,
      'failed': failed,
      'retried': retried,
      'revoked': revoked,
      'args': args,
      'kwargs': kwargs,
      'eta': eta,
      'expires': expires,
      'retries': retries,
      'result': result,
      'exception': exception,
      'timestamp': timestamp,
      'runtime': runtime,
      'traceback': traceback,
      'exchange': exchange,
      'routing_key': routingKey,
      'clock': clock,
      'client': client,
      'root': root,
      'root_id': rootId,
      'parent': parent,
      'parent_id': parentId,
      'children': children,
      'worker': worker,
    };
  }
}
