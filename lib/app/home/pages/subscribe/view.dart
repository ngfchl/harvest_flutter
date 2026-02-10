import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/utils/storage.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../models/Subscribe.dart';
import '../models/download.dart';
import '../models/my_rss.dart';
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
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<SubscribeController>(builder: (controller) {
      return LayoutBuilder(builder: (context, constraints) {
        final contentHeight = constraints.maxHeight - 64;
        return CustomCard(
          width: constraints.maxWidth,
          margin: EdgeInsets.symmetric(vertical: 3),
          child: ShadTabs(
              onChanged: (String value) => controller.tabsController.select(value),
              controller: controller.tabsController,
              tabBarConstraints: const BoxConstraints(maxHeight: 50),
              contentConstraints: BoxConstraints(maxHeight: contentHeight),
              decoration: ShadDecoration(
                color: Colors.transparent,
              ),
              tabs: [
                ShadTab(
                  value: 'subscribe',
                  content: Scaffold(
                    backgroundColor: Colors.transparent,
                    floatingActionButton: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadIconButton.ghost(
                          icon: Icon(
                            Icons.refresh_outlined,
                            size: 24,
                            color: shadColorScheme.primary,
                          ),
                          onPressed: () => controller.getSubscribeFromServer(),
                        ),
                        ShadIconButton.ghost(
                          icon: Icon(
                            Icons.add,
                            size: 24,
                            color: shadColorScheme.primary,
                          ),
                          onPressed: () async {
                            // await _openEditDialog(null);
                            await _openEditDialogX(null);
                          },
                        ),
                      ],
                    ),
                    body: GetBuilder<SubscribeController>(builder: (controller) {
                      return Stack(
                        children: [
                          EasyRefresh(
                            header: ClassicHeader(
                              dragText: '下拉刷新...',
                              readyText: '松开刷新',
                              processingText: '正在刷新...',
                              processedText: '刷新完成',
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: shadColorScheme.foreground,
                                fontWeight: FontWeight.bold,
                              ),
                              messageStyle: TextStyle(
                                fontSize: 12,
                                color: shadColorScheme.foreground,
                              ),
                            ),
                            onRefresh: () => controller.getSubscribeFromServer(),
                            child: ListView(
                              children: controller.subList.map((Subscribe sub) => _buildSub(sub)).toList(),
                            ),
                          ),
                          if (controller.loading)
                            Center(
                              child: CircularProgressIndicator(
                                color: shadColorScheme.foreground,
                              ),
                            )
                        ],
                      );
                    }),
                  ),
                  child: Text(
                    '订阅管理',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                ShadTab(
                  value: 'sub_plan',
                  content: Scaffold(
                    backgroundColor: Colors.transparent,
                    floatingActionButton: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadIconButton.ghost(
                          icon: Icon(
                            Icons.refresh_outlined,
                            size: 24,
                            color: shadColorScheme.primary,
                          ),
                          onPressed: () => controller.getSubPlanFromServer(),
                        ),
                        ShadIconButton.ghost(
                          icon: Icon(
                            Icons.add,
                            size: 24,
                            color: shadColorScheme.primary,
                          ),
                          onPressed: () async {
                            // await _openEditDialog(null);
                            await _openEditSubPLan(null);
                          },
                        ),
                      ],
                    ),
                    body: GetBuilder<SubscribeController>(builder: (controller) {
                      return Stack(
                        children: [
                          EasyRefresh(
                            header: ClassicHeader(
                              dragText: '下拉刷新...',
                              readyText: '松开刷新',
                              processingText: '正在刷新...',
                              processedText: '刷新完成',
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: shadColorScheme.foreground,
                                fontWeight: FontWeight.bold,
                              ),
                              messageStyle: TextStyle(
                                fontSize: 12,
                                color: shadColorScheme.foreground,
                              ),
                            ),
                            onRefresh: () => controller.getSubPlanFromServer(),
                            child: ListView.builder(
                              itemCount: controller.planList.length,
                              itemBuilder: (context, index) {
                                return _buildSubPlanItem(controller.planList[index], context);
                              },
                            ),
                          ),
                          if (controller.loading)
                            Center(
                              child: CircularProgressIndicator(
                                color: shadColorScheme.foreground,
                              ),
                            )
                        ],
                      );
                    }),
                  ),
                  child: Text(
                    '订阅方案',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ]),
        );
      });
    });
  }

  Widget _buildSubPlanItem(SubPlan plan, BuildContext context) {
    double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Logger.instance.d(plan.name);
    return CustomCard(
      child: ShadContextMenuRegion(
        decoration: ShadDecoration(
          labelStyle: TextStyle(),
          descriptionStyle: TextStyle(),
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 100),
        items: [
          ShadContextMenuItem(
            leading: Icon(
              size: 14,
              Icons.edit_outlined,
              color: shadColorScheme.foreground,
            ),
            child: Text(style: TextStyle(fontSize: 12), '编辑'),
            onPressed: () => _openEditSubPLan(plan),
          ),
          ShadContextMenuItem(
            leading: Icon(
              size: 14,
              Icons.delete_outline,
              color: shadColorScheme.foreground,
            ),
            child: Text(style: TextStyle(fontSize: 12), '删除'),
            onPressed: () => removeSubPlan(plan),
          ),
          ShadContextMenuItem(
            leading: Icon(
              size: 14,
              plan.available == true ? Icons.close_outlined : Icons.play_arrow_outlined,
              color: shadColorScheme.foreground,
            ),
            child: Text(style: TextStyle(fontSize: 12), plan.available == true ? '关闭' : '开启'),
            onPressed: () => switchSubPlan(plan),
          ),
        ],
        child: Slidable(
          key: ValueKey('${plan.id}_${plan.name}'),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.2,
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                onPressed: (context) => _openEditSubPLan(plan),
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
            extentRatio: 0.2,
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                onPressed: (context) => removeSubPlan(plan),
                flex: 1,
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: '删除',
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                dense: true,
                title: Text(plan.name, style: TextStyle(fontSize: 14, color: shadColorScheme.foreground)),
                subtitle: Text(
                  "下载器：${controller.downloadController.dataList.firstWhereOrNull((item) => item.id == plan.downloaderId)?.name ?? '未知下载器'}  【分类/路径】：${plan.downloaderCategory ?? plan.downloaderSavePath}",
                  style: TextStyle(fontSize: 10, color: shadColorScheme.foreground.withValues(alpha: opacity * 255)),
                ),
                onTap: () async {
                  await _openEditSubPLan(plan);
                },
                trailing: IconButton(
                  icon: plan.available == true
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
                  onPressed: () => switchSubPlan(plan),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  alignment: WrapAlignment.spaceEvenly,
                  children: plan.rssList
                      .map((item) => CustomTextTag(
                            labelText: item.siteId!,
                            backgroundColor: shadColorScheme.primary,
                          ))
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  alignment: WrapAlignment.spaceEvenly,
                  children: _buildSubTags(plan),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> switchSubPlan(SubPlan plan) async {
    SubPlan newPlan = plan.copyWith(available: !plan.available);
    CommonResponse response = await controller.saveSubPlan(newPlan);
    ShadToaster.of(context).show(
      response.succeed
          ? ShadToast(title: const Text('成功啦'), description: Text(response.msg))
          : ShadToast.destructive(title: const Text('出错啦'), description: Text(response.msg)),
    );
  }

  void removeSubPlan(SubPlan plan) {
    Get.defaultDialog(
      title: '确认',
      radius: 5,
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      middleText: '确定要删除吗？',
      actions: [
        ShadButton.ghost(
          size: ShadButtonSize.sm,
          onPressed: () {
            Get.back(result: false);
          },
          child: const Text('取消'),
        ),
        ShadButton.destructive(
          size: ShadButtonSize.sm,
          onPressed: () async {
            Get.back(result: true);
            CommonResponse res = await controller.removeSubPlan(plan);
            ShadToaster.of(context).show(
              res.succeed
                  ? ShadToast(title: const Text('成功啦'), description: Text(res.msg))
                  : ShadToast.destructive(title: const Text('出错啦'), description: Text(res.msg)),
            );
          },
          child: const Text('确认'),
        ),
      ],
    );
  }

  Widget _buildSub(Subscribe sub) {
    double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return CustomCard(
        child: ShadContextMenuRegion(
      decoration: ShadDecoration(
        labelStyle: TextStyle(),
        descriptionStyle: TextStyle(),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 100),
      items: [
        ShadContextMenuItem(
          leading: Icon(
            size: 14,
            Icons.edit_outlined,
            color: shadColorScheme.foreground,
          ),
          child: Text(style: TextStyle(fontSize: 12), '编辑'),
          onPressed: () => _openEditDialogX(sub),
        ),
        ShadContextMenuItem(
          leading: Icon(
            size: 14,
            Icons.delete_outline,
            color: shadColorScheme.foreground,
          ),
          child: Text(style: TextStyle(fontSize: 12), '删除'),
          onPressed: () => removeSubscribe(sub),
        ),
        ShadContextMenuItem(
          leading: Icon(
            size: 14,
            sub.available == true ? Icons.close_outlined : Icons.play_arrow_outlined,
            color: shadColorScheme.foreground,
          ),
          child: Text(style: TextStyle(fontSize: 12), sub.available == true ? '关闭' : '开启'),
          onPressed: () => switchSubAvailable(sub),
        ),
      ],
      child: Slidable(
          key: ValueKey('${sub.id}_${sub.name}'),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.2,
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                onPressed: (context) => _openEditDialogX(sub),
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
            extentRatio: 0.2,
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                onPressed: (context) => removeSubscribe(sub),
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
                title:
                    Text(sub.name, style: TextStyle(fontSize: 14, color: ShadTheme.of(context).colorScheme.foreground)),
                subtitle: Text(
                  sub.keyword,
                  style: TextStyle(
                      fontSize: 10,
                      color: ShadTheme.of(context).colorScheme.foreground.withValues(alpha: opacity * 255)),
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
                  onPressed: () => switchSubAvailable(sub),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: _buildSubTags(sub),
              //   ),
              // )
            ],
          )),
    ));
  }

  Future<void> switchSubAvailable(Subscribe sub) async {
    Subscribe newSub = sub.copyWith(available: !sub.available);
    var res = await controller.saveSubscribe(newSub);
    ShadToaster.of(context).show(
      res.succeed
          ? ShadToast(title: const Text('成功啦'), description: Text(res.msg))
          : ShadToast.destructive(title: const Text('出错啦'), description: Text(res.msg)),
    );
  }

  void removeSubscribe(Subscribe sub) {
    Get.defaultDialog(
      title: '确认',
      radius: 5,
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      middleText: '确定要删除吗？',
      actions: [
        ShadButton.ghost(
          size: ShadButtonSize.sm,
          onPressed: () {
            Get.back(result: false);
          },
          child: const Text('取消'),
        ),
        ShadButton.destructive(
          size: ShadButtonSize.sm,
          onPressed: () async {
            Get.back(result: true);
            CommonResponse res = await controller.removeSubscribe(sub);
            ShadToaster.of(context).show(
              res.succeed
                  ? ShadToast(title: const Text('成功啦'), description: Text(res.msg))
                  : ShadToast.destructive(title: const Text('出错啦'), description: Text(res.msg)),
            );
          },
          child: const Text('确认'),
        ),
      ],
    );
  }

  List<Widget> _buildSubTags(SubPlan sub) {
    List<Widget> tags = [];
    if (sub.exclude?.isNotEmpty == true) {
      tags.addAll(sub.exclude!.map((e) => CustomTextTag(
            labelText: e,
            backgroundColor: ShadTheme.of(context).colorScheme.destructive,
          )));
    }
    tags.add(CustomTextTag(
      labelText: '${sub.minSize} GB -> ${sub.maxSize} GB',
      backgroundColor: Colors.brown,
    ));

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
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final TextEditingController nameController = TextEditingController(text: sub?.name ?? '');
    final TextEditingController keywordController = TextEditingController(text: sub?.keyword ?? '');
    final TextEditingController doubanController = TextEditingController(text: sub?.douban ?? '');
    final TextEditingController imdbController = TextEditingController(text: sub?.imdb ?? '');
    final TextEditingController tmdbController = TextEditingController(text: sub?.tmdb ?? '');
    Map<String, RxList<String>> props = {};
    RxBool available = true.obs;
    RxBool isLoading = true.obs;
    Rx<int?> planId = (sub?.planId ?? null).obs;
    props = {
      'publish_year': (sub?.publishYear ?? <String>[]).obs,
      'season': (sub?.season ?? []).obs,
    };

    Get.bottomSheet(
        backgroundColor: shadColorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "订阅管理",
                style: ShadTheme.of(context).textTheme.h4,
              ),
              CustomTextField(
                controller: nameController,
                labelText: '订阅名称',
              ),
              Expanded(
                child: ListView(
                  children: [
                    CustomTextField(
                      controller: keywordController,
                      labelText: '订阅关键字',
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: ShadSelect<SubPlan>(
                            placeholder: const Text('选择订阅方案'),
                            initialValue: controller.planList.firstWhereOrNull((plan) => plan.id == planId.value),
                            decoration: ShadDecoration(
                              border: ShadBorder(
                                merge: false,
                                bottom: ShadBorderSide(color: shadColorScheme.foreground.withOpacity(0.2), width: 1),
                              ),
                            ),
                            options: controller.planList
                                .map((key) => ShadOption(value: key, child: Text(key.name)))
                                .toList(),
                            selectedOptionBuilder: (context, value) {
                              return Text(value.name);
                            },
                            onChanged: (SubPlan? item) async {
                              planId.value = item?.id ?? 0;
                            })),
                    CustomTextField(
                      controller: doubanController,
                      labelText: '豆瓣ID',
                    ),
                    CustomTextField(
                      controller: imdbController,
                      labelText: 'IMDB',
                    ),
                    CustomTextField(
                      controller: tmdbController,
                      labelText: 'TMDB',
                    ),
                    Obx(() {
                      return SwitchTile(
                          title: '可用',
                          value: available.value,
                          onChanged: (bool val) {
                            available.value = val;
                          });
                    }),
                    SingleChildScrollView(
                      child: Container(
                        height: 400,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GetBuilder<SubscribeController>(builder: (controller) {
                          return ShadAccordion<String>.multiple(
                            initialValue: [...props.keys],
                            maintainState: true,
                            children: controller.subTagController.tagCategoryList
                                .where((element) => props[element.value] != null)
                                .map(
                                  (e) => ShadAccordionItem(
                                    value: e.value,
                                    title: Center(child: Text(e.name)),
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Wrap(
                                      runSpacing: 8,
                                      spacing: 8,
                                      alignment: WrapAlignment.spaceEvenly,
                                      children: controller.subTagController.tags
                                          .where((item) => item.category == e.value)
                                          .sorted((a, b) => a.name.compareTo(b.name))
                                          .map(
                                            (item) => FilterChip(
                                              label: Text(item.name.toString(),
                                                  style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                                              selected: props[e.value]!.contains(item.name),
                                              backgroundColor: shadColorScheme.background,
                                              selectedColor: shadColorScheme.background,
                                              checkmarkColor: shadColorScheme.foreground,
                                              selectedShadowColor: shadColorScheme.primary,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                              showCheckmark: true,
                                              elevation: 2,
                                              onSelected: (bool value) {
                                                Logger.instance.i(props[e.value]);
                                                if (value == true) {
                                                  props[e.value]!.add(item.name!);
                                                } else {
                                                  props[e.value]!.removeWhere((element) => element == item.name);
                                                }
                                                Logger.instance.i(props[e.value]);
                                                controller.update();
                                              },
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              OverflowBar(
                alignment: MainAxisAlignment.spaceAround,
                children: [
                  ShadButton.ghost(
                    size: ShadButtonSize.sm,
                    onPressed: () {
                      Get.back();
                    },
                    leading: Icon(
                      Icons.cancel_outlined,
                      size: 16,
                    ),
                    child: Text('取消'),
                  ),
                  ShadButton.destructive(
                    size: ShadButtonSize.sm,
                    onPressed: () async {
                      isLoading.value = true;
                      Subscribe newSub;
                      if (sub != null) {
                        newSub = sub.copyWith(
                          name: nameController.text,
                          keyword: keywordController.text,
                          publishYear: props['publish_year'] ?? [],
                          exclude: props['exclude'] ?? [],
                          season: props['season'] ?? [],
                          available: available.value,
                          douban: doubanController.text,
                          imdb: imdbController.text,
                          tmdb: tmdbController.text,
                          planId: planId.value,
                        );
                      } else {
                        newSub = Subscribe(
                          id: 0,
                          planId: planId.value,
                          name: nameController.text,
                          keyword: keywordController.text,
                          publishYear: props['publish_year'] ?? [],
                          exclude: props['exclude'] ?? [],
                          season: props['season'] ?? [],
                          available: available.value,
                          douban: doubanController.text,
                          imdb: imdbController.text,
                          tmdb: tmdbController.text,
                        );
                      }
                      CommonResponse res = await controller.saveSubscribe(newSub);
                      if (res.succeed) {
                        Get.back();
                      }
                      Logger.instance.i(res.msg);
                      ShadToaster.of(context).show(
                        res.succeed
                            ? ShadToast(title: const Text('成功啦'), description: Text(res.msg))
                            : ShadToast.destructive(title: const Text('出错啦'), description: Text(res.msg)),
                      );
                    },
                    leading: Icon(
                      Icons.cancel_outlined,
                      size: 16,
                    ),
                    child: Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Future<void> _openEditSubPLan(SubPlan? plan) async {
    controller.isAddFormLoading = true;
    controller.update();
    final dialogController = Get.put(EditDialogController());
    if (controller.downloadController.dataList.isEmpty) {
      await controller.getDownloaderListFromServer();
      if (controller.downloadController.dataList.isEmpty) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('出错啦'),
            description: Text('请先到下载管理添加下载器后重试！'),
          ),
        );
        return;
      }
    }
    await dialogController.init(plan);
    EditDialogController editDialogController = Get.find();
    Downloader? selectedDownloader =
        controller.downloadController.dataList.firstWhereOrNull((d) => d.id == plan?.downloaderId);
    if (selectedDownloader != null) {
      CommonResponse res = await editDialogController.subController.getDownloaderCategoryList(selectedDownloader);
      if (!res.succeed) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('出错啦'),
            description: Text(res.msg),
          ),
        );
      } else {
        editDialogController.categories.value = res.data;
      }
      // if (plan != null || editDialogController.categories.isEmpty) {
      //   ShadToaster.of(context).show(
      //     ShadToast.destructive(
      //       title: const Text('出错啦'),
      //       description: Text('请先给QB下载器添加分类！'),
      //     ),
      //   );
      //   return;
      // }
    }

    Rx<String> category = ''.obs;
    controller.isAddFormLoading = false;
    controller.update();
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.bottomSheet(
      backgroundColor: shadColorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
      ),
      GetBuilder<EditDialogController>(
        builder: (controller) => CustomCard(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Column(
                children: [
                  Text(
                    controller.title,
                    style: ShadTheme.of(context).textTheme.h4,
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        CustomTextField(
                          controller: controller.nameController,
                          labelText: '订阅方案名称',
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: ShadSelect<Downloader>(
                                placeholder: const Text('选择下载器'),
                                initialValue: selectedDownloader,
                                decoration: ShadDecoration(
                                  border: ShadBorder(
                                    merge: false,
                                    bottom:
                                        ShadBorderSide(color: shadColorScheme.foreground.withOpacity(0.2), width: 1),
                                  ),
                                ),
                                options: controller.subController.downloadController.dataList
                                    .map((key) => ShadOption(value: key, child: Text(key.name)))
                                    .toList(),
                                selectedOptionBuilder: (context, value) {
                                  return Text(value.name);
                                },
                                onChanged: (Downloader? item) async {
                                  controller.downloaderCategoryController.clear();
                                  controller.categories.clear();
                                  controller.subController.isDownloaderLoading = true;
                                  controller.update();
                                  controller.downloaderController.text = item!.id.toString();
                                  CommonResponse res = await controller.subController.getDownloaderCategoryList(item);
                                  controller.subController.isDownloaderLoading = false;
                                  controller.update();
                                  if (!res.succeed) {
                                    ShadToaster.of(context).show(
                                      ShadToast.destructive(title: const Text('出错啦'), description: Text(res.msg)),
                                    );
                                    return;
                                  }
                                  if (res.data.isEmpty) {
                                    ShadToaster.of(context).show(
                                      ShadToast.destructive(
                                          title: const Text('出错啦'), description: Text('请先给QB下载器添加分类！')),
                                    );
                                    return;
                                  }
                                  controller.categories.value = res.data;
                                  if (controller.categories.isNotEmpty) {
                                    controller.downloaderCategoryController.text =
                                        controller.categories.keys.toList()[0];
                                  }
                                  Logger.instance.i(controller.categories);
                                  controller.update();
                                })),
                        controller.categories.isNotEmpty
                            ? Obx(() {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Wrap(
                                    runSpacing: 8,
                                    spacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      ...controller.categories.values.sorted((a, b) => a.name!.compareTo(b.name!)).map(
                                            (item) => FilterChip(
                                              label: Text(item.name.toString(),
                                                  style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                                              selected: category.value == item.name,
                                              backgroundColor: shadColorScheme.background,
                                              selectedColor: shadColorScheme.background,
                                              checkmarkColor: shadColorScheme.foreground,
                                              selectedShadowColor: shadColorScheme.primary,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                              showCheckmark: true,
                                              elevation: 2,
                                              onSelected: (bool value) {
                                                Logger.instance.i('选中分类：$value');
                                                if (value) {
                                                  category.value = item.name.toString();
                                                  controller.downloaderCategoryController.text = item.name.toString();
                                                  controller.downloaderSavePathController.text =
                                                      item.savePath.toString();
                                                  controller.update();
                                                }
                                              },
                                            ),
                                          ),
                                    ],
                                  ),
                                );
                              })
                            : CustomTextField(
                                controller: controller.downloaderCategoryController,
                                labelText: '分类',
                                onTap: () async {
                                  if (controller.categories.isEmpty) {
                                    controller.subController.isDownloaderLoading = true;
                                    controller.update();
                                    CommonResponse res = await controller.subController.getDownloaderCategoryList(
                                        controller.subController.downloadController.dataList.firstWhere((element) =>
                                            element.id == int.parse(controller.downloaderController.text)));
                                    if (!res.succeed) {
                                      ShadToaster.of(context).show(
                                        ShadToast.destructive(
                                          title: const Text('出错啦'),
                                          description: Text(res.msg),
                                        ),
                                      );
                                      return;
                                    }
                                    controller.categories.value = res.data;
                                    if (controller.categories.isNotEmpty) {
                                      Category c = controller.categories.values.toList().first;
                                      controller.downloaderCategoryController.text = c.name ?? '';
                                      controller.downloaderSavePathController.text = c.savePath ?? '';
                                    }
                                    controller.subController.isDownloaderLoading = true;
                                    controller.update();
                                  }
                                },
                              ),
                        CustomTextField(
                          controller: controller.downloaderSavePathController,
                          labelText: '下载文件夹',
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: controller.minSize.value.toDouble(),
                                  min: 0,
                                  max: 100,
                                  // divisions: 100,
                                  onChanged: (double value) {
                                    controller.minSize.value = value.toInt();
                                    controller.update();
                                  },
                                ),
                              ),
                              Text('最小：${controller.minSize.value} GB',
                                  style: TextStyle(fontSize: 14, color: shadColorScheme.foreground)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: controller.maxSize.value.toDouble(),
                                  min: 1,
                                  max: 200,
                                  // divisions: 100,
                                  onChanged: (double value) {
                                    controller.maxSize.value = value.toInt();
                                    controller.update();
                                  },
                                ),
                              ),
                              Text('最大：${controller.maxSize.value} GB',
                                  style: TextStyle(fontSize: 14, color: shadColorScheme.foreground)),
                            ],
                          ),
                        ),
                        SwitchTile(
                            title: '可用',
                            value: controller.available.value,
                            onChanged: (bool val) {
                              controller.available.value = val;
                              controller.update();
                            }),
                        SwitchTile(
                            title: '直接下载',
                            value: controller.start.value,
                            onChanged: (bool val) {
                              controller.start.value = val;
                              controller.update();
                            }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ShadAccordion<String>.multiple(
                            initialValue: [
                              'RSS_Select',
                              ...controller.props.keys,
                              ...controller.prop.keys,
                            ],
                            maintainState: true,
                            children: [
                              ShadAccordionItem(
                                value: 'RSS_Select',
                                title: Text('RSS选择', style: TextStyle(fontSize: 14, color: shadColorScheme.foreground)),
                                child: Wrap(
                                  runSpacing: 8,
                                  spacing: 8,
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: controller.subController.rssController.rssList
                                      .map((MyRss item) => CheckboxListTile(
                                            title: Text(item.name.toString(),
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground)),
                                            dense: true,
                                            value: controller.rssList.map((element) => element.id).contains(item.id),
                                            activeColor: shadColorScheme.primary,
                                            onChanged: (bool? value) {
                                              Logger.instance.i(controller.rssList);
                                              if (value == true) {
                                                controller.rssList.add(item);
                                              } else {
                                                controller.rssList.removeWhere((element) => element.id == item.id);
                                              }
                                              Logger.instance.i(controller.rssList);
                                              controller.update();
                                            },
                                          ))
                                      .toList(),
                                ),
                              ),
                              ...controller.subController.tagCategoryList
                                  .where((element) => controller.prop[element.value] != null)
                                  .map(
                                    (e) => ShadAccordionItem(
                                      value: e.value,
                                      title: Text(e.name,
                                          style: TextStyle(fontSize: 14, color: shadColorScheme.foreground)),
                                      child: Wrap(
                                        runSpacing: 8,
                                        spacing: 8,
                                        alignment: WrapAlignment.spaceEvenly,
                                        children: controller.subController.tags
                                            .where((item) => item.category == e.value)
                                            .map(
                                              (item) => FilterChip(
                                                label: Text(item.name.toString(),
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground)),
                                                selected: controller.prop[e.value]!.value == item.name,
                                                backgroundColor: shadColorScheme.background,
                                                selectedColor: shadColorScheme.background,
                                                checkmarkColor: shadColorScheme.foreground,
                                                selectedShadowColor: shadColorScheme.primary,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                showCheckmark: true,
                                                elevation: 2,
                                                onSelected: (bool? value) {
                                                  Logger.instance.i(controller.prop[e.value]);
                                                  if (value == true) {
                                                    controller.prop[e.value]?.value = item.name!;
                                                  } else {
                                                    controller.prop[e.value]?.value = '';
                                                  }
                                                  Logger.instance.i(controller.prop[e.value]);
                                                  controller.update();
                                                },
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                              ...controller.subController.tagCategoryList
                                  .where((element) => controller.props[element.value] != null)
                                  .map(
                                    (e) => ShadAccordionItem(
                                      value: e.value,
                                      title: Center(child: Text(e.name)),
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Wrap(
                                        runSpacing: 8,
                                        spacing: 8,
                                        alignment: WrapAlignment.spaceEvenly,
                                        children: controller.subController.tags
                                            .where((item) => item.category == e.value)
                                            .map(
                                              (item) => FilterChip(
                                                label: Text(item.name.toString(),
                                                    style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                                                selected: controller.props[e.value]!.contains(item.name),
                                                backgroundColor: shadColorScheme.background,
                                                selectedColor: shadColorScheme.background,
                                                checkmarkColor: shadColorScheme.foreground,
                                                selectedShadowColor: shadColorScheme.primary,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                showCheckmark: true,
                                                elevation: 2,
                                                onSelected: (bool value) {
                                                  Logger.instance.i(controller.props[e.value]);
                                                  if (value == true) {
                                                    controller.props[e.value]!.add(item.name);
                                                  } else {
                                                    controller.props[e.value]!
                                                        .removeWhere((element) => element == item.name);
                                                  }
                                                  Logger.instance.i(controller.props[e.value]);
                                                  controller.update();
                                                },
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        onPressed: () {
                          Get.back();
                          controller.categories.clear();
                        },
                        leading: Icon(
                          Icons.cancel,
                          size: 18,
                        ),
                        child: Text('取消'),
                      ),
                      ShadButton.destructive(
                        size: ShadButtonSize.sm,
                        onPressed: () async {
                          await controller.savePlan(plan, context);
                          controller.categories.clear();
                        },
                        leading: Icon(
                          Icons.save,
                          size: 18,
                          color: shadColorScheme.primaryForeground,
                        ),
                        child: Text(
                          '保存',
                          style: TextStyle(color: shadColorScheme.primaryForeground),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (controller.subController.isDownloaderLoading)
                Center(
                    child: CircularProgressIndicator(
                  color: shadColorScheme.foreground,
                ))
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    ).whenComplete(() {
      controller.isAddFormLoading = false;
      editDialogController.categories.clear();
    });
  }
}

class EditDialogController extends GetxController {
  final subController = Get.put(SubscribeController());

  final TextEditingController nameController = TextEditingController();

  final TextEditingController downloaderCategoryController = TextEditingController();
  final TextEditingController downloaderSavePathController = TextEditingController();

  final TextEditingController downloaderController = TextEditingController();
  RxList<MyRss> rssList = <MyRss>[].obs;
  Map<String, RxList<String>> props = {};
  Map<String, RxString> prop = {};
  RxMap<String, Category> categories = <String, Category>{}.obs;
  RxBool available = true.obs;
  RxBool start = true.obs;
  RxBool isLoading = false.obs;
  RxInt minSize = 0.obs;
  RxInt maxSize = 15.obs;
  String title = '';

  Future<void> init(SubPlan? plan) async {
    nameController.text = plan?.name ?? '';
    downloaderCategoryController.text = plan?.downloaderCategory ?? '';
    downloaderSavePathController.text = plan?.downloaderSavePath ?? '';
    downloaderController.text =
        plan?.downloaderId?.toString() ?? subController.downloadController.dataList[0].id.toString();
    rssList.value = plan?.rssList ?? [];
    props = {
      'exclude': (plan?.exclude ?? <String>[]).obs,
      'discount': (plan?.discount ?? <String>[]).obs,
      'resolution': (plan?.resolution ?? <String>[]).obs,
      'video_codec': (plan?.videoCodec ?? <String>[]).obs,
      'audio_codec': (plan?.audioCodec ?? <String>[]).obs,
      'source': (plan?.source ?? <String>[]).obs,
      'publisher': (plan?.publisher ?? <String>[]).obs,
      'tags': (plan?.tags ?? <String>[]).obs,
    };
    prop = {
      'category': (plan?.category ?? '').obs,
    };
    // categories.value = await subController
    //     .getDownloaderCategories(subController.downloaderList[0]);
    available.value = plan?.available ?? true;
    start.value = plan?.start ?? true;
    minSize.value = plan?.minSize ?? 1;
    maxSize.value = plan?.maxSize ?? 15;
    title = plan != null ? '编辑方案：${plan.name}' : '添加方案';
  }

  Future<void> savePlan(SubPlan? plan, context) async {
    isLoading.value = true;
    SubPlan newPlan;
    if (plan != null) {
      newPlan = plan.copyWith(
        name: nameController.text,
        exclude: props['exclude']!,
        discount: props['discount']!,
        resolution: props['resolution']!,
        videoCodec: props['video_codec']!,
        audioCodec: props['audio_codec']!,
        source: props['source']!,
        publisher: props['publisher']!,
        tags: props['tags']!,
        category: prop['category']?.value,
        downloaderId: int.parse(downloaderController.text),
        downloaderCategory: downloaderCategoryController.text,
        downloaderSavePath: downloaderSavePathController.text,
        available: available.value,
        start: start.value,
        minSize: minSize.value,
        maxSize: maxSize.value,
        rssList: rssList,
      );
    } else {
      newPlan = SubPlan(
        id: 0,
        name: nameController.text,
        exclude: props['exclude']!,
        discount: props['discount']!,
        resolution: props['resolution']!,
        videoCodec: props['video_codec']!,
        audioCodec: props['audio_codec']!,
        source: props['source']!,
        publisher: props['publisher']!,
        tags: props['tags']!,
        category: prop['category']?.value,
        downloaderId: int.parse(downloaderController.text),
        downloaderCategory: downloaderCategoryController.text,
        downloaderSavePath: downloaderSavePathController.text,
        available: available.value,
        start: start.value,
        minSize: minSize.value,
        maxSize: maxSize.value,
        rssList: rssList,
      );
    }
    submitForm(newPlan, context);
    isLoading.value = false;
  }

  void submitForm(SubPlan plan, context) async {
    try {
      CommonResponse res = await subController.saveSubPlan(plan);

      Logger.instance.i(res.msg);
      if (res.succeed) {
        Get.back();
        ShadToaster.of(context).show(
          ShadToast(title: const Text('成功啦'), description: Text(res.msg)),
        );
      } else {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('出错啦'),
            description: Text(res.msg),
          ),
        );
      }
    } finally {}
  }
}
