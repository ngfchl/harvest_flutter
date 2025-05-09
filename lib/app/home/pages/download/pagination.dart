import 'package:get/get.dart';

import '../../../../utils/logger_helper.dart';

class LocalPaginationController<T> extends GetxController {
  final int pageSize;
  final RxList<T> displayedItems = <T>[].obs;

  final RxList<T> sourceItems = <T>[].obs; // 源数据
  int currentPage = 0;

  LocalPaginationController({this.pageSize = 10}); // 👈 默认值为10，可外部传入

  @override
  void onInit() {
    ever<List<T>>(sourceItems, (newList) => _handleSourceChange(newList));
    super.onInit();
  }

  void bindSource(List<T> list, {bool reset = false}) {
    Logger.instance.d("重新绑定数据列表，新列表元素${list.length}个");
    sourceItems.assignAll(list);
    if (reset) _resetPagination();
  }

  void _handleSourceChange(List<T> newList) {
    // 判断是否是第一次加载或显示数据为空（首次或重置）
    if (displayedItems.isEmpty) {
      _resetPagination();
      return;
    }

    // 如果有新增数据，就尝试继续加载下一页
    if (newList.length > displayedItems.length) {
      final start = displayedItems.length;
      final end = (start + pageSize).clamp(0, newList.length);
      displayedItems.addAll(newList.sublist(start, end));
      currentPage = (displayedItems.length / pageSize).ceil();
    }
  }

  void _resetPagination() {
    Logger.instance.d("重置分页信息");
    currentPage = 0;
    displayedItems.clear();
    loadNextPage();
  }

  void loadNextPage() {
    final start = currentPage * pageSize;
    print("当前页码：$currentPage");
    final end = (start + pageSize).clamp(0, sourceItems.length);
    if (start >= sourceItems.length) return;
    displayedItems.addAll(sourceItems.sublist(start, end));
    currentPage++;
  }

  bool get hasMore => displayedItems.length < sourceItems.length;
}
