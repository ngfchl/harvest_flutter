import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../models/MyRss.dart';
import '../models/my_site.dart';
import 'controller.dart';

class MyRssPage extends StatefulWidget {
  const MyRssPage({super.key});

  @override
  State<MyRssPage> createState() => _MyRssPageState();
}

class _MyRssPageState extends State<MyRssPage> {
  final controller = Get.put(MyRssController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyRssController>(builder: (controller) {
      return Column(
        children: [
          CustomCard(
            child: ListTile(
              dense: true,
              title: const Text(
                '站点RSS',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              leading: IconButton(
                  onPressed: () => controller.getMyRssFromServer(),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.green,
                  )),
              trailing: IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 28,
                  color: Colors.blue,
                ),
                onPressed: () {
                  _openEditDialog(null);
                },
              ),
            ),
          ),
          Expanded(
            child: GetBuilder<MyRssController>(builder: (controller) {
              return SingleChildScrollView(
                child: Wrap(
                  children: controller.rssList
                      .map((MyRss rss) => _buildMyRss(rss))
                      .toList(),
                ),
              );
            }),
          ),
          const SizedBox(height: 60),
        ],
      );
    });
  }

  Widget _buildMyRss(MyRss rss) {
    return CustomCard(
        child: Slidable(
      key: ValueKey('${rss.id}_${rss.name}'),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            onPressed: (context) async {
              _openEditDialog(rss);
            },
            flex: 1,
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: '编辑',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            onPressed: (context) async {
              Get.defaultDialog(
                title: '确认',
                backgroundColor: Colors.white,
                radius: 5,
                titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.deepPurple),
                middleText: '确定要删除标签吗？',
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back(result: false);
                    },
                    child: const Text('取消'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Get.back(result: true);
                      CommonResponse res = await controller.removeMyRss(rss);
                      if (res.code == 0) {
                        Get.snackbar('删除通知', res.msg.toString(),
                            backgroundColor: Colors.green.shade500,
                            colorText: Colors.white70);
                      } else {
                        Get.snackbar('删除通知', res.msg.toString(),
                            backgroundColor: Colors.red.shade500,
                            colorText: Colors.white70);
                      }
                    },
                    child: const Text('确认'),
                  ),
                ],
              );
            },
            flex: 1,
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),

      // The end action pane is the one at the right or the bottom side.
      child: ListTile(
        dense: true,
        title: Text(rss.name!),
        subtitle: Text(
          rss.siteId!,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
        trailing: SizedBox(
          width: 80,
          child: Row(
            children: [
              IconButton(
                icon: rss.available == true
                    ? const Icon(
                        Icons.check_box,
                        size: 18,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.disabled_by_default,
                        size: 18,
                        color: Colors.red,
                      ),
                onPressed: () {
                  MyRss newRss = rss.copyWith(available: !rss.available!);
                  submitForm(newRss);
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }

  _openEditDialog(MyRss? rss) {
    '''
    String? name,
    String? category,
    bool? available,
    ''';
    final TextEditingController nameController =
        TextEditingController(text: rss != null ? rss.name : '');
    final TextEditingController rssController =
        TextEditingController(text: rss != null ? rss.rss : '');
    final TextEditingController siteController = TextEditingController(
        text: rss != null
            ? rss.siteId
            : controller.mySiteController.mySiteList[0].site);
    final TextEditingController sortController =
        TextEditingController(text: rss != null ? rss.sort.toString() : '0');

    RxBool available = true.obs;
    final isLoading = false.obs;

    available.value = rss != null ? rss.available! : true;
    String title = rss != null ? '编辑RSS：${rss.name!}' : '添加RSS';
    Get.defaultDialog(
        title: title,
        content: Column(
          children: [
            CustomTextField(
              controller: nameController,
              labelText: '名称',
            ),
            DropdownSearch<MySite>(
              items: controller.mySiteController.mySiteList,
              selectedItem: controller.mySiteMap[siteController.text],
              filterFn: (MySite item, String filter) =>
                  item.site.toLowerCase().contains(filter.toLowerCase()) ||
                  item.nickname.toLowerCase().contains(filter.toLowerCase()),
              itemAsString: (MySite? item) => item!.site,
              compareFn: (MySite item, MySite selectedItem) =>
                  item.site == selectedItem.site,
              onChanged: (MySite? item) {
                siteController.text = item!.site;
                Logger.instance.i(siteController);
              },
              popupProps: PopupPropsMultiSelection.menu(
                searchDelay: const Duration(milliseconds: 50),
                isFilterOnline: false,
                showSelectedItems: true,
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  // padding: EdgeInsets.zero,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // 设置搜索框的边框圆角
                    ),
                  ),
                ),
                itemBuilder:
                    (BuildContext context, MySite item, bool isSelected) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: EdgeInsets.zero,
                    decoration: !isSelected
                        ? null
                        : BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                    child: ListTile(
                      dense: true,
                      selected: isSelected,
                      title: Text(item.site),
                      subtitle: Text(item.nickname.toString()),
                    ),
                  );
                },
              ),
            ),
            CustomTextField(
              controller: rssController,
              labelText: '链接',
            ),
            CustomTextField(
              controller: sortController,
              labelText: '优先级',
            ),
            Obx(() {
              return SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    '可用',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  value: available.value,
                  onChanged: (bool val) {
                    available.value = val;
                  });
            }),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // 清空表单数据
                    nameController.clear();
                    rssController.clear();
                    siteController.clear();
                    sortController.clear();
                    available.value = true;
                    Get.back();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Colors.redAccent.withAlpha(150)),
                  ),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                  label: const Text(
                    '取消',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Obx(() {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      isLoading.value = true;
                      MyRss newTag;
                      if (rss != null) {
                        newTag = rss.copyWith(
                          name: nameController.text,
                          siteId: siteController.text,
                          sort: int.parse(sortController.text),
                          rss: rssController.text,
                          available: available.value,
                        );
                      } else {
                        newTag = MyRss.fromJson({
                          'id': 0,
                          'name': nameController.text,
                          'sort': int.parse(sortController.text),
                          'site_id': siteController.text,
                          'rss': rssController.text,
                          'available': available.value,
                        });
                      }
                      Logger.instance.i(siteController.text);
                      Logger.instance.i(newTag.toJson());
                      submitForm(newTag);
                      isLoading.value = false;
                    },
                    icon: isLoading.value
                        ? const GFLoader(size: 18)
                        : const Icon(Icons.save),
                    label: const Text('保存'),
                  );
                }),
              ],
            ),
          ],
        ));
  }

  void submitForm(MyRss rss) async {
    try {
      CommonResponse res = await controller.saveMyRss(rss);

      Logger.instance.i(res.msg);
      if (res.code == 0) {
        Get.back();
        Get.snackbar('标签保存成功！', res.msg!,
            backgroundColor: Colors.green.shade300, colorText: Colors.white);
      } else {
        Get.snackbar('标签保存失败！', res.msg!,
            backgroundColor: Colors.red.shade300, colorText: Colors.white);
      }
    } finally {}
  }

  @override
  void dispose() {
    Get.delete<MyRssController>();
    super.dispose();
  }
}
