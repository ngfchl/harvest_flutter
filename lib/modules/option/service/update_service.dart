import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/hooks.dart';

import '../model/update_log_model.dart';

class UpdateService {
  const UpdateService();

  Future<UpdateLogInfo> fetchLog(UpdateTarget target) async {
    final endpoint = switch (target) {
      UpdateTarget.backend => API.UPDATE_LOG,
      UpdateTarget.sites => API.UPDATE_SITES,
    };

    final info = await fetchModel<UpdateLogInfo>(
      endpoint,
      (json) => UpdateLogInfo.fromResponse(target, json),
    );
    return info ?? UpdateLogInfo.fromResponse(target, null);
  }

  Future<String> runUpdate(UpgradeAction action) async {
    final data = await fetchBasic(
      API.DOCKER_UPDATE,
      queryParameters: {'upgrade_tag': action.tag},
    );
    return parseUpdateCommandMessage(data);
  }
}
