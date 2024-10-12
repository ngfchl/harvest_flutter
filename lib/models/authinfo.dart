class AuthInfo {
  String? authToken;
  String? user;

  AuthInfo({this.authToken, this.user});

  AuthInfo.fromJson(Map<String, dynamic> json) {
    authToken = json['auth_token'];
    user = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['auth_token'] = authToken;
    data['user'] = user;
    return data;
  }
}

class GitLog {
  final String date;
  final String data;
  final String hex;

  GitLog({required this.date, required this.data, required this.hex});

  factory GitLog.fromJson(Map<String, dynamic> json) {
    return GitLog(
      date: json['date'],
      data: json['data'],
      hex: json['hex'],
    );
  }

  @override
  String toString() => '$date - $hex：$data';
}

class UpdateLogState {
  final GitLog localLogs;
  final List<GitLog> updateNotes;
  final bool update;

  UpdateLogState({
    required this.localLogs,
    required this.updateNotes,
    required this.update,
  });

  factory UpdateLogState.fromJson(Map<String, dynamic> json) {
    var updateNotesJson = json['update_notes'] as List;
    List<GitLog> updateNotesList =
        updateNotesJson.map((e) => GitLog.fromJson(e)).toList();

    return UpdateLogState(
      localLogs: GitLog.fromJson(json['local_logs']),
      updateNotes: updateNotesList,
      update: json['update'],
    );
  }
}
