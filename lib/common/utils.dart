import 'package:intl/intl.dart';

import '../app/home/pages/models/my_site.dart';

String formatCreatedTimeToDateString(StatusInfo item) {
  return DateFormat("yyyy-MM-dd").format(DateTime.parse(item.createdAt));
}
