import 'package:get/get.dart';

class LocalPaginationController<T> extends GetxController {
  final int pageSize;
  final RxList<T> displayedItems = <T>[].obs;

  final RxList<T> sourceItems = <T>[].obs; // 源数据
  int currentPage = 0;

  LocalPaginationController({this.pageSize = 10}); // 👈 默认值为10，可外部传入

  @override
  void onInit() {
    ever(sourceItems, (_) => _resetPagination());
    super.onInit();
  }

  void bindSource(RxList<T> list) {
    sourceItems.assignAll(list); // 初始绑定
  }

  void _resetPagination() {
    currentPage = 0;
    displayedItems.clear();
    loadNextPage();
  }

  void loadNextPage() {
    final start = currentPage * pageSize;
    final end = (start + pageSize).clamp(0, sourceItems.length);
    if (start >= sourceItems.length) return;
    displayedItems.addAll(sourceItems.sublist(start, end));
    currentPage++;
  }

  bool get hasMore => displayedItems.length < sourceItems.length;
}
