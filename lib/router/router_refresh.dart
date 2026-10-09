import 'package:shadcn_flutter/shadcn_flutter.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}
