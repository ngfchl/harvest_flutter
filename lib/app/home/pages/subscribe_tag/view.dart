import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/models/common_response.dart';

import '../../../../common/form_widgets.dart';
import '../../../../common/meta_item.dart';
import '../../../../utils/logger_helper.dart';
import '../models/SubTag.dart';
import 'controller.dart';

class SubscribeTagPage extends StatefulWidget {
  const SubscribeTagPage({super.key});

  @override
  State<SubscribeTagPage> createState() => _SubscribeTagPageState();
}

class _SubscribeTagPageState extends State<SubscribeTagPage> {
  final controller = Get.put(SubscribeTagController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscribeTagController>(builder: (controller) {
      return Column(
        children: [
          Expanded(
            child: GetBuilder<SubscribeTagController>(builder: (controller) {
              return SingleChildScrollView(
                child: Wrap(
                  children: controller.tags
                      .map((SubTag tag) => _buildTag(tag))
                      .toList(),
                ),
              );
            }),
          ),
          CustomCard(
            child: ListTile(
              dense: true,
              title: const Text(
                '订阅标签',
                style: TextStyle(fontSize: 16),
              ),
              leading: IconButton(
                  onPressed: () => controller.getTagsFromServer(),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.green,
                  )),
              trailing: IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 20,
                ),
                onPressed: () {
                  _openEditDialog(null);
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    Get.delete<SubscribeTagController>();
    super.dispose();
  }

  CustomCard _buildTag(SubTag tag) {
    return CustomCard(
      child: Slidable(
        key: ValueKey('${tag.id}_${tag.name}'),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) async {
                _openEditDialog(tag);
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
                        CommonResponse res = await controller.removeSubTag(tag);
                        if (res.code == 0) {
                          Get.snackbar('删除通知', res.msg.toString());
                        } else {
                          Get.snackbar('删除通知', res.msg.toString());
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
          title: Text(tag.name!),
          subtitle: Text(
            tag.category!,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
          onTap: () => _openEditDialog(tag),
          trailing: IconButton(
            icon: tag.available == true
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
            onPressed: () async {
              SubTag newTag = tag.copyWith(available: !tag.available!);
              submitForm(newTag);
            },
          ),
        ),
      ),
    );
  }

  _openEditDialog(SubTag? tag) {
    '''
    String? name,
    String? category,
    bool? available,
    ''';
    final TextEditingController nameController =
        TextEditingController(text: tag != null ? tag.name : '');
    final TextEditingController categoryController = TextEditingController(
        text: tag != null ? tag.category : controller.tagCategoryList[0].value);

    RxBool available = true.obs;
    final isLoading = false.obs;

    available.value = tag != null ? tag.available! : true;
    String title = tag != null ? '编辑标签：${tag.name!}' : '添加标签';
    Get.bottomSheet(CustomCard(
      child: Column(
        children: [
          GFTypography(
            text: title,
            textColor: Theme.of(context).colorScheme.onBackground,
            dividerColor: Theme.of(context).colorScheme.onBackground,
          ),
          CustomTextField(
            controller: nameController,
            labelText: '名称',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              isDense: true,
              value: categoryController.text,
              onChanged: (String? newValue) {
                categoryController.text = newValue!;
              },
              items: controller.tagCategoryList
                  .map<DropdownMenuItem<String>>(
                      (MetaDataItem item) => DropdownMenuItem<String>(
                            value: item.value,
                            child: Text(
                              item.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              return SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('标签可用'),
                  value: available.value,
                  onChanged: (bool val) {
                    available.value = val;
                  });
            }),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // 清空表单数据
                  nameController.clear();
                  categoryController.clear();
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
                    SubTag newTag;
                    if (tag != null) {
                      newTag = tag.copyWith(
                        name: nameController.text,
                        category: categoryController.text,
                        available: available.value,
                      );
                    } else {
                      newTag = SubTag.fromJson({
                        'id': 0,
                        'name': nameController.text,
                        'category': categoryController.text,
                        'available': available.value,
                      });
                    }
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
      ),
    ));
  }

  void submitForm(SubTag tag) async {
    try {
      CommonResponse res = await controller.saveSubTag(tag);

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
}
