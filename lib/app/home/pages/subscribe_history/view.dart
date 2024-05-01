import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/models/SubHistory.dart';

import '../../../../common/card_view.dart';
import '../../../../models/common_response.dart';
import 'controller.dart';

class SubscribeHistoryPage extends StatefulWidget {
  const SubscribeHistoryPage({super.key});

  @override
  State<SubscribeHistoryPage> createState() => _SubscribeHistoryPageState();
}

class _SubscribeHistoryPageState extends State<SubscribeHistoryPage> {
  final controller = Get.put(SubscribeHistoryController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscribeHistoryController>(builder: (controller) {
      return Column(
        children: [
          Expanded(
            child: ListView(
              children: controller.subHistory
                  .map((SubHistory history) => _buildSubHistory(history))
                  .toList(),
            ),
          ),
          CustomCard(
            child: ListTile(
                dense: true,
                title: const Text(
                  '订阅历史',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                leading: IconButton(
                    onPressed: () => controller.getSubHistoryFromServer(),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.green,
                    )),
                trailing: Text(
                  '${controller.subHistory.length} 条',
                  style: const TextStyle(fontSize: 16),
                )),
          ),
        ],
      );
    });
  }

  Widget _buildSubHistory(SubHistory history) {
    return CustomCard(
        child: Slidable(
      key: ValueKey('${history.id}_${history.subscribe?.id}'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            onPressed: (context) async {
              Get.defaultDialog(
                title: '确认',
                radius: 5,
                titleStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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
                          await controller.removeHistory(history);
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
            title: Text('${history.subscribe?.name}'),
            subtitle: Text(
              history.site!.site.toString(),
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
            leading: history.pushed == true
                ? const Icon(
                    Icons.check_box,
                    size: 28,
                    color: Colors.green,
                  )
                : const Icon(
                    Icons.disabled_by_default,
                    size: 28,
                    color: Colors.red,
                  ),
            trailing: IconButton(
              icon: const Icon(
                Icons.upload,
                size: 28,
              ),
              onPressed: () {},
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
              child: Text(
                history.message.toString(),
                style: const TextStyle(
                  fontSize: 12,
                ),
              )),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    Get.delete<SubscribeHistoryController>();
    super.dispose();
  }
}
