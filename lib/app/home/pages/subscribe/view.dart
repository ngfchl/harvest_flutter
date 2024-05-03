import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../models/common_response.dart';
import '../../../../models/download.dart';
import '../../../../utils/logger_helper.dart';
import '../models/MyRss.dart';
import '../models/Subscribe.dart';
import 'controller.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  final controller = Get.put(SubscribeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscribeController>(builder: (controller) {
      return Column(children: [
        Expanded(
          child: GetBuilder<SubscribeController>(builder: (controller) {
            return ListView(
              children: controller.subList
                  .map((Subscribe sub) => _buildSub(sub))
                  .toList(),
            );
          }),
        ),
        CustomCard(
          child: ListTile(
            dense: true,
            title: const Text(
              '订阅管理',
              style: TextStyle(fontSize: 16),
            ),
            leading: IconButton(
                onPressed: () => controller.getSubscribeFromServer(),
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.green,
                )),
            trailing: IconButton(
              icon: const Icon(
                Icons.add,
                size: 20,
              ),
              onPressed: () async {
                // await _openEditDialog(null);
                await _openEditDialogX(null);
              },
            ),
          ),
        ),
      ]);
    });
  }

  Widget _buildSub(Subscribe sub) {
    return CustomCard(
        child: Slidable(
            key: ValueKey('${sub.id}_${sub.name}'),
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  onPressed: (context) async {
                    // await _openEditDialog(sub);
                    await _openEditDialogX(sub);
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
                      titleStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900),
                      middleText: '确定要删除吗？',
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
                            CommonResponse res =
                                await controller.removeSubscribe(sub);
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
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  title: Text(sub.name),
                  subtitle: Text(
                    sub.keyword,
                    style: const TextStyle(fontSize: 10),
                  ),
                  onTap: () {
                    _openEditDialogX(sub);
                  },
                  trailing: IconButton(
                    icon: sub.available == true
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
                      Subscribe newSub =
                          sub.copyWith(available: !sub.available);
                      submitForm(newSub);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildSubTags(sub),
                  ),
                )
              ],
            )));
  }

  _buildSubTags(Subscribe sub) {
    List<Widget> tags = [];
    tags.add(CustomTextTag(
      labelText: '${sub.size} GB',
      backgroundColor: Colors.brown,
    ));
    tags.addAll(sub.publishYear.map((e) => CustomTextTag(
          labelText: e,
          backgroundColor: Colors.black54,
        )));
    tags.addAll(sub.discount.map((e) => CustomTextTag(
          labelText: e,
          backgroundColor: Colors.green,
        )));
    tags.addAll(sub.resolution.map((e) => CustomTextTag(
          labelText: e,
          backgroundColor: Colors.purple,
        )));
    tags.addAll(sub.videoCodec.map((e) => CustomTextTag(
          labelText: e,
          backgroundColor: Colors.amber,
        )));
    tags.addAll(sub.audioCodec.map((e) => CustomTextTag(
          labelText: e,
          backgroundColor: Colors.teal,
        )));
    tags.addAll(sub.source.map((e) => CustomTextTag(
          labelText: e,
          backgroundColor: Colors.indigo,
        )));
    tags.addAll(sub.publisher.map((e) => CustomTextTag(
          labelText: e,
          backgroundColor: Colors.cyan,
        )));
    tags.addAll(sub.tags.map((e) => CustomTextTag(
          labelText: e,
          backgroundColor: Colors.blue,
        )));
    return tags;
  }

  @override
  void dispose() {
    Get.delete<SubscribeController>();
    super.dispose();
  }

  Future<void> _openEditDialogX(Subscribe? sub) async {
    final dialogController = Get.put(EditDialogController());
    await dialogController.init(sub);
    Get.bottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
      ),
      GetBuilder<EditDialogController>(
        builder: (controller) => Stack(
          children: [
            CustomCard(
              padding: const EdgeInsets.all(12),
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                children: [
                  GFTypography(
                    text: controller.title,
                    textColor: Theme.of(context).colorScheme.onBackground,
                    dividerColor: Theme.of(context).colorScheme.onBackground,
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        CustomTextField(
                          controller: controller.nameController,
                          labelText: '名称',
                        ),
                        CustomTextField(
                          controller: controller.keywordController,
                          labelText: '关键字',
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: DropdownSearch<Downloader>(
                            items: controller.subController.downloaderList,
                            selectedItem: controller
                                .subController.downloaderList
                                .firstWhereOrNull((element) =>
                                    element.id ==
                                    int.parse(
                                        controller.downloaderController.text)),
                            compareFn: (item, sItem) => item.id == sItem.id,
                            itemAsString: (Downloader? item) => item!.name,
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: '下载器',
                                filled: true,
                                fillColor: Theme.of(context)
                                    .inputDecorationTheme
                                    .fillColor,
                              ),
                            ),
                            onChanged: (Downloader? item) async {
                              controller.downloaderCategoryController.clear();
                              controller.subController.isDownloaderLoading =
                                  true;
                              controller.update();
                              controller.downloaderController.text =
                                  item!.id.toString();
                              controller.categories.value = await controller
                                  .subController
                                  .getDownloaderCategories(item);
                              controller.subController.isDownloaderLoading =
                                  false;
                              controller.update();
                              if (controller.categories.isNotEmpty) {
                                controller.downloaderCategoryController.text =
                                    controller.categories.keys.toList()[0];
                              }
                              Logger.instance.i(controller.categories);
                              controller.update();
                            },
                          ),
                        ),
                        controller.categories.isNotEmpty
                            ? CustomPickerField(
                                controller:
                                    controller.downloaderCategoryController,
                                labelText: '下载到分类',
                                data: controller.categories.keys.toList(),
                                onChanged: (value, index) {
                                  controller.downloaderCategoryController.text =
                                      value;
                                  controller.update();
                                },
                              )
                            : CustomTextField(
                                controller:
                                    controller.downloaderCategoryController,
                                labelText: '分类',
                              ),
                        Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: controller.size.value.toDouble(),
                                  min: 1,
                                  max: 100,
                                  divisions: 100,
                                  onChanged: (double value) {
                                    controller.size.value = value.toInt();
                                    controller.update();
                                  },
                                ),
                              ),
                              Text('${controller.size.value} GB'),
                            ],
                          ),
                        ),
                        SwitchListTile(
                            dense: true,
                            title: const Text('可用',
                                style: TextStyle(fontSize: 14)),
                            value: controller.available.value,
                            onChanged: (bool val) {
                              controller.available.value = val;
                              controller.update();
                            }),
                        SwitchListTile(
                            dense: true,
                            title: const Text('直接下载',
                                style: TextStyle(fontSize: 14)),
                            value: controller.start.value,
                            onChanged: (bool val) {
                              controller.start.value = val;
                              controller.update();
                            }),
                        ExpansionTile(
                          title: const Text('RSS选择'),
                          dense: true,
                          children: controller
                              .subController.rssController.rssList
                              .map((MyRss item) => CheckboxListTile(
                                    title: Text(item.name.toString()),
                                    dense: true,
                                    value: controller.rssList
                                        .map((element) => element.id)
                                        .contains(item.id),
                                    onChanged: (bool? value) {
                                      Logger.instance.i(controller.rssList);
                                      if (value == true) {
                                        controller.rssList.add(item);
                                      } else {
                                        controller.rssList.removeWhere(
                                            (element) => element.id == item.id);
                                      }
                                      Logger.instance.i(controller.rssList);
                                      controller.update();
                                    },
                                  ))
                              .toList(),
                        ),
                        Column(
                            children: controller.subController.tagCategoryList
                                .where((element) =>
                                    controller.prop[element.value] != null)
                                .map((e) => ExpansionTile(
                                      title: Text(e.name),
                                      dense: true,
                                      children: controller.subController.tags
                                          .where((item) =>
                                              item.category == e.value)
                                          .map((item) => CheckboxListTile(
                                                title:
                                                    Text(item.name.toString()),
                                                dense: true,
                                                value: controller
                                                        .prop[e.value]!.value ==
                                                    item.name,
                                                selected: controller
                                                        .prop[e.value]!.value ==
                                                    item.name,
                                                onChanged: (bool? value) {
                                                  Logger.instance.i(
                                                      controller.prop[e.value]);
                                                  if (value == true) {
                                                    controller.prop[e.value]
                                                        ?.value = item.name!;
                                                  } else {
                                                    controller.prop[e.value]
                                                        ?.value = '';
                                                  }
                                                  Logger.instance.i(
                                                      controller.prop[e.value]);
                                                  controller.update();
                                                },
                                              ))
                                          .toList(),
                                    ))
                                .toList()),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: GFTypography(
                            text: '标签选择',
                            type: GFTypographyType.typo6,
                            icon: const Icon(Icons.sort_by_alpha),
                            dividerWidth: 108,
                            textColor:
                                Theme.of(context).colorScheme.onBackground,
                            dividerColor:
                                Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        SizedBox(
                          height: 360,
                          child: SingleChildScrollView(
                            child: Column(
                              children: controller.subController.tagCategoryList
                                  .where((element) =>
                                      controller.props[element.value] != null)
                                  .map((e) => ExpansionTile(
                                        title: Text(e.name),
                                        dense: true,
                                        initiallyExpanded: true,
                                        children: controller.subController.tags
                                            .where((item) =>
                                                item.category == e.value)
                                            .map((item) => CheckboxListTile(
                                                  dense: true,
                                                  title: Text(
                                                      item.name.toString()),
                                                  value: controller
                                                      .props[e.value]!
                                                      .contains(item.name),
                                                  onChanged: (bool? value) {
                                                    Logger.instance.i(controller
                                                        .props[e.value]);
                                                    if (value == true) {
                                                      controller.props[e.value]!
                                                          .add(item.name!);
                                                    } else {
                                                      controller.props[e.value]!
                                                          .removeWhere(
                                                              (element) =>
                                                                  element ==
                                                                  item.name);
                                                    }
                                                    Logger.instance.i(controller
                                                        .props[e.value]);
                                                    controller.update();
                                                  },
                                                ))
                                            .toList(),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Colors.redAccent.withAlpha(150)),
                        ),
                        icon: const Icon(Icons.cancel_outlined,
                            color: Colors.white),
                        label: const Text(
                          '取消',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.saveSub(sub);
                        },
                        icon: controller.isLoading.value
                            ? const GFLoader(size: 18)
                            : const Icon(Icons.save),
                        label: const Text('保存'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (controller.subController.isDownloaderLoading) const GFLoader()
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void submitForm(Subscribe sub) async {
    try {
      CommonResponse res = await controller.saveSubscribe(sub);

      Logger.instance.i(res.msg);
      if (res.code == 0) {
        Get.back();
        Get.snackbar('保存成功！', res.msg!);
      } else {
        Get.snackbar('保存失败！', res.msg!);
      }
    } finally {}
  }
}

class EditDialogController extends GetxController {
  final subController = Get.put(SubscribeController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController keywordController = TextEditingController();
  final TextEditingController downloaderCategoryController =
      TextEditingController();
  final TextEditingController doubanController = TextEditingController();
  final TextEditingController imdbController = TextEditingController();
  final TextEditingController tmdbController = TextEditingController();
  final TextEditingController downloaderController = TextEditingController();
  RxList<MyRss> rssList = <MyRss>[].obs;
  Map<String, RxList<String>> props = {};
  Map<String, RxString> prop = {};
  RxMap<String, String> categories = <String, String>{}.obs;
  RxBool available = true.obs;
  RxBool start = true.obs;
  RxBool isLoading = false.obs;
  RxInt size = 15.obs;
  String title = '';

  Future<void> init(Subscribe? sub) async {
    nameController.text = sub?.name ?? '';
    keywordController.text = sub?.keyword ?? '';
    downloaderCategoryController.text = sub?.downloaderCategory ?? '';
    doubanController.text = sub?.douban ?? '';
    imdbController.text = sub?.imdb ?? '';
    tmdbController.text = sub?.tmdb ?? '';
    downloaderController.text = sub?.downloaderId?.toString() ??
        subController.downloaderList[0].id.toString();
    rssList.value = sub?.rssList ?? [];
    props = {
      'exclude': (sub?.exclude ?? <String>[]).obs,
      'publish_year': (sub?.publishYear ?? <String>[]).obs,
      'discount': (sub?.discount ?? <String>[]).obs,
      'resolution': (sub?.resolution ?? <String>[]).obs,
      'video_codec': (sub?.videoCodec ?? <String>[]).obs,
      'audio_codec': (sub?.audioCodec ?? <String>[]).obs,
      'source': (sub?.source ?? <String>[]).obs,
      'publisher': (sub?.publisher ?? <String>[]).obs,
      'tags': (sub?.tags ?? <String>[]).obs,
    };
    prop = {
      'category': (sub?.category ?? '').obs,
      'season': (sub?.season ?? '').obs,
    };
    categories.value = await subController
        .getDownloaderCategories(subController.downloaderList[0]);
    available.value = sub?.available ?? true;
    start.value = sub?.start ?? true;
    size.value = sub?.size ?? 15;
    title = sub != null ? '编辑标签：${sub.name}' : '添加订阅';
  }

  Future<void> saveSub(Subscribe? sub) async {
    isLoading.value = true;
    Subscribe newTag;
    if (sub != null) {
      newTag = sub.copyWith(
        name: nameController.text,
        keyword: keywordController.text,
        publishYear: props['publish_year']!,
        exclude: props['exclude']!,
        discount: props['discount']!,
        resolution: props['resolution']!,
        videoCodec: props['video_codec']!,
        audioCodec: props['audio_codec']!,
        source: props['source']!,
        publisher: props['publisher']!,
        tags: props['tags']!,
        season: prop['season']?.value,
        category: prop['category']?.value,
        downloaderId: int.parse(downloaderController.text),
        downloaderCategory: downloaderCategoryController.text,
        available: available.value,
        start: start.value,
        size: size.value,
        douban: doubanController.text,
        imdb: imdbController.text,
        tmdb: tmdbController.text,
        rssList: rssList,
      );
    } else {
      newTag = Subscribe(
        id: 0,
        name: nameController.text,
        keyword: keywordController.text,
        publishYear: props['publish_year']!,
        exclude: props['exclude']!,
        discount: props['discount']!,
        resolution: props['resolution']!,
        videoCodec: props['video_codec']!,
        audioCodec: props['audio_codec']!,
        source: props['source']!,
        publisher: props['publisher']!,
        tags: props['tags']!,
        season: prop['season']?.value,
        category: prop['category']?.value,
        downloaderId: int.parse(downloaderController.text),
        downloaderCategory: downloaderCategoryController.text,
        available: available.value,
        start: start.value,
        size: size.value,
        douban: doubanController.text,
        imdb: imdbController.text,
        tmdb: tmdbController.text,
        rssList: rssList,
      );
    }
    submitForm(newTag);
    isLoading.value = false;
  }

  void submitForm(Subscribe sub) async {
    try {
      CommonResponse res = await subController.saveSubscribe(sub);

      Logger.instance.i(res.msg);
      if (res.code == 0) {
        Get.back();
        Get.snackbar('保存成功！', res.msg!,
            backgroundColor: Colors.green.shade300, colorText: Colors.white);
      } else {
        Get.snackbar('保存失败！', res.msg!,
            backgroundColor: Colors.red.shade300, colorText: Colors.white);
      }
    } finally {}
  }
}
