import 'Subscribe.dart';
import 'my_site.dart';

class SubHistory {
  SubHistory({
    num? id,
    Subscribe? subscribe,
    MySite? site,
    String? magnet,
    String? message,
    bool? pushed,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _subscribe = subscribe;
    _site = site;
    _magnet = magnet;
    _message = message;
    _pushed = pushed;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  SubHistory.fromJson(dynamic json) {
    _id = json['id'];
    _subscribe = json['subscribe'] != null
        ? Subscribe.fromJson(json['subscribe'])
        : null;
    _site = json['site'] != null ? MySite.fromJson(json['site']) : null;
    _magnet = json['magnet'];
    _message = json['message'];
    _pushed = json['pushed'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  num? _id;
  Subscribe? _subscribe;
  MySite? _site;
  String? _magnet;
  String? _message;
  bool? _pushed;
  String? _createdAt;
  String? _updatedAt;

  SubHistory copyWith({
    num? id,
    Subscribe? subscribe,
    MySite? site,
    String? magnet,
    String? message,
    bool? pushed,
    String? createdAt,
    String? updatedAt,
  }) =>
      SubHistory(
        id: id ?? _id,
        subscribe: subscribe ?? _subscribe,
        site: site ?? _site,
        magnet: magnet ?? _magnet,
        message: message ?? _message,
        pushed: pushed ?? _pushed,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );

  num? get id => _id;

  Subscribe? get subscribe => _subscribe;

  MySite? get site => _site;

  String? get magnet => _magnet;

  String? get message => _message;

  bool? get pushed => _pushed;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    if (_subscribe != null) {
      map['subscribe'] = _subscribe?.toJson();
    }
    if (_site != null) {
      map['site'] = _site?.toJson();
    }
    map['magnet'] = _magnet;
    map['message'] = _message;
    map['pushed'] = _pushed;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

  @override
  String toString() {
    return '订阅历史消息：$site - $message';
  }
}
