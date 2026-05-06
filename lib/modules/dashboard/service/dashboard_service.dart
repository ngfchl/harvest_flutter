import 'package:dio/dio.dart';

import '../../../core/http/api.dart';
import '../../../core/http/hooks.dart';
import '../model/dashboard_data.dart';

Future<DashboardData?> getDashboard({CancelToken? cancelToken}) {
  return fetchModel(API.DASHBOARD_DATA, (json) => DashboardData.fromJson(json), cancelToken: cancelToken);
}
