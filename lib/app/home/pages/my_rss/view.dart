import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../models/my_rss.dart';
import '../models/my_site.dart';
import '../models/website.dart';
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
      return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: IconButton(
          icon: Icon(
            Icons.add,
            size: 28,
            color: ShadTheme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            _openEditDialog(null);
          },
        ),
        body: GetBuilder<MyRssController>(builder: (controller) {
          return EasyRefresh(
            onRefresh: () => controller.getMyRssFromServer(),
            child: SingleChildScrollView(
              child: Wrap(
                children: controller.rssList.map((MyRss rss) => _buildMyRss(rss)).toList(),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildMyRss(MyRss rss) {
    MySite mySite = controller.mySiteMap[rss.siteId]!;
    WebSite webSite = controller.mySiteController.webSiteList[rss.siteId]!;
    var colorScheme = ShadTheme.of(context).colorScheme;
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
                radius: 5,
                titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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
                        Get.snackbar('删除通知', res.msg.toString(), colorText: colorScheme.foreground);
                      } else {
                        Get.snackbar('删除通知', res.msg.toString(), colorText: colorScheme.destructive);
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
        title: Text(rss.name!, style: TextStyle(fontSize: 14, color: colorScheme.foreground)),
        subtitle: Text(
          rss.siteId!,
          style: const TextStyle(fontSize: 10),
        ),
        leading: CircleAvatar(
          backgroundImage: NetworkImage('${mySite.mirror}${webSite.logo}'),
          backgroundColor: Colors.transparent,
        ),
        trailing: IconButton(
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
      ),
    ));
  }

  void _openEditDialog(MyRss? rss) {
    '''
    String? name,
    String? category,
    bool? available,
    ''';
    final TextEditingController nameController = TextEditingController(text: rss != null ? rss.name : '');
    final TextEditingController rssController = TextEditingController(text: rss != null ? rss.rss : '');
    final TextEditingController siteController =
        TextEditingController(text: rss != null ? rss.siteId : controller.mySiteController.mySiteList[0].site);
    final TextEditingController sortController = TextEditingController(text: rss != null ? rss.sort.toString() : '0');

    RxBool available = true.obs;
    final isLoading = false.obs;

    available.value = rss != null ? rss.available! : true;
    String title = rss != null ? '编辑RSS：${rss.name!}' : '添加RSS';
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.bottomSheet(
        backgroundColor: shadColorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
        ),
        isScrollControlled: true,
        Container(
          height: 410,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16, color: shadColorScheme.foreground),
                  )),
              Expanded(
                child: ListView(
                  children: [
                    CustomTextField(
                      controller: nameController,
                      labelText: '名称',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownSearch<MySite>(
                        items: (String? filter, _) async => controller.mySiteController.mySiteList,
                        selectedItem: controller.mySiteMap[siteController.text],
                        filterFn: (MySite item, String filter) =>
                            item.site.toLowerCase().contains(filter.toLowerCase()) ||
                            item.nickname.toLowerCase().contains(filter.toLowerCase()),
                        itemAsString: (MySite? item) => item!.site,
                        compareFn: (MySite item, MySite selectedItem) => item.site == selectedItem.site,
                        onChanged: (MySite? item) {
                          siteController.text = item!.site;
                          Logger.instance.i(siteController);
                        },
                        decoratorProps: DropDownDecoratorProps(
                          baseStyle: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                          decoration: InputDecoration(
                            labelText: '站点选择',
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                        popupProps: PopupPropsMultiSelection.menu(
                          searchDelay: const Duration(milliseconds: 50),
                          // isFilterOnline: false,
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
                          itemBuilder: (BuildContext context, MySite item, bool isSelected, _) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: EdgeInsets.zero,
                              decoration: !isSelected
                                  ? null
                                  : BoxDecoration(
                                      border: Border.all(color: shadColorScheme.foreground),
                                      borderRadius: BorderRadius.circular(5),
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
                    ),
                    CustomTextField(
                      controller: rssController,
                      labelText: '链接',
                    ),
                    CustomTextField(
                      controller: sortController,
                      labelText: '优先级',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Obx(() {
                        return SwitchListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text('可用', style: TextStyle(fontSize: 14, color: shadColorScheme.foreground)),
                            value: available.value,
                            onChanged: (bool val) {
                              available.value = val;
                            });
                      }),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShadButton.destructive(
                    size: ShadButtonSize.sm,
                    onPressed: () {
                      // 清空表单数据
                      nameController.clear();
                      rssController.clear();
                      siteController.clear();
                      sortController.clear();
                      available.value = true;
                      Get.back();
                    },
                    leading: Icon(
                      Icons.cancel,
                      size: 18,
                      color: shadColorScheme.destructiveForeground,
                    ),
                    child: Text('取消', style: TextStyle(color: shadColorScheme.destructiveForeground)),
                  ),
                  Obx(() {
                    return ShadButton(
                      size: ShadButtonSize.sm,
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
                      leading: isLoading.value
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: shadColorScheme.primary,
                              )))
                          : const Icon(Icons.save),
                      child: Text(
                        '保存',
                        style: TextStyle(color: shadColorScheme.primaryForeground),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ));
  }

  void submitForm(MyRss rss) async {
    try {
      CommonResponse res = await controller.saveMyRss(rss);

      Logger.instance.i(res.msg);
      if (res.code == 0) {
        Get.back();
        Get.snackbar('标签保存成功！', res.msg, colorText: ShadTheme.of(context).colorScheme.foreground);
      } else {
        Get.snackbar('标签保存失败！', res.msg, colorText: ShadTheme.of(context).colorScheme.destructive);
      }
    } finally {}
  }

  @override
  void dispose() {
    Get.delete<MyRssController>();
    super.dispose();
  }
}
