import '../models/common_response.dart';
import '../utils/http.dart';
import '../utils/logger_helper.dart';
import 'api.dart';

Future<CommonResponse> getSystemConfig() async {
  final response = await DioClient()
      .get(Api.SYSTEM_CONFIG, queryParameters: {"name": "ptools.toml"});
  if (response.statusCode == 200) {
    try {
      final dataList = response.data['data'];
      String msg = '共有${dataList.length}条项目';
      return CommonResponse(data: dataList, code: 0, msg: msg);
    } catch (e, trace) {
      Logger.instance.w(trace);
      String msg = '解析出错啦！';
      return CommonResponse(data: null, code: -1, msg: msg);
    }
  } else {
    String msg = '获取系统设置失败: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}
