import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../common/glass_widget.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  GFListTile _buildLogo() {
    return const GFListTile(
      avatar: GFAvatar(
        backgroundImage: AssetImage('assets/images/logo.png'),
        size: 40,
        shape: GFAvatarShape.square,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Harvest',
            style: TextStyle(
                color: Colors.teal, fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subTitle: Row(
        children: [
          Text(
            '祝你每一天都收获满满',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 打开服务器列表弹窗
  Widget openSelectServerSheet() {
    return controller.serverList.isNotEmpty
        ? SingleChildScrollView(
            child: ListView.builder(
                itemCount: controller.serverList.length,
                shrinkWrap: true,
                itemBuilder: (
                  BuildContext context,
                  int index,
                ) {
                  String server = controller.serverList[index];
                  return GFRadioListTile(
                    // size: GFSize.SMALL,
                    title: Text(
                      server,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    size: 18,
                    icon: const Icon(
                      Icons.computer,
                      color: Colors.white,
                    ),
                    color: Colors.transparent,
                    activeBorderColor: Colors.green,
                    focusColor: Colors.green,
                    selected: controller.serverController.text == server,
                    value: server,
                    toggleable: true,
                    groupValue: controller.serverController.text,
                    onChanged: (value) {
                      controller.serverController.text = value.toString();
                      controller.saveServer();
                      Get.back();
                    },
                    onLongPress: () {
                      print('object');
                      Get.defaultDialog(
                          title: '确认？',
                          content: const Text('确认删除当前内容？'),
                          textCancel: '取消',
                          textConfirm: '确认',
                          onConfirm: () => {});
                    },
                    inactiveIcon: null,
                  );
                }),
          )
        : const SizedBox.shrink();
  }

  List<Widget> _buildUserForm() {
    return [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        child: TextField(
          controller: controller.usernameController,
          decoration: const InputDecoration(
            hintText: '请输入用户名',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          textAlign: TextAlign.center,
          autofocus: false,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade400,
            ),
          ),
        ),
        child: TextField(
          controller: controller.passwordController,
          decoration: const InputDecoration(
            hintText: '请输入密码',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          obscureText: true,
          autofocus: false,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.orangeAccent,
      body: GlassWidget(
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          width: double.infinity,
          decoration:const  BoxDecoration(
            // gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            //   Colors.white38,
            //   Colors.white30,
            //   Colors.white24
            // ]),
            color: Colors.white24,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: GFCard(
                height: 420,
                boxFit: BoxFit.cover,
                color: Colors.white38,
                // image: Image.asset('images/ptools.jpg'),
                title: _buildLogo(),
                content: Column(
                  children: [
                    // _buildServerWidget(),
                    ..._buildUserForm(),
                  ],
                ),
                buttonBar: GFButtonBar(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GFCheckbox(
                              size: 22,
                              activeBgColor: GFColors.PRIMARY,
                              onChanged: (value) {
                                controller.isChecked = value;
                              },
                              value: controller.isChecked,
                            ),
                            const Text(
                              '记住密码',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        GFButton(
                          text: '设置服务器',
                          textStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                          onPressed: () =>
                              Get.bottomSheet(SingleChildScrollView(
                            child: Container(
                              height: 300,
                              color: Colors.white60,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              controller.serverController,
                                          decoration: const InputDecoration(
                                            hintText: '请输入服务器地址',
                                            hintStyle: TextStyle(
                                                color: Colors.white70),
                                            // border: InputBorder.none
                                          ),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.cyan,
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp("[A-Z,a-z,0-9,/,:,.,-]"))
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 75,
                                        child: GFButton(
                                          text: "清除",
                                          onPressed: controller.clearServerList,
                                          type: GFButtonType.solid,
                                          color: GFColors.DANGER,
                                          size: 24,
                                          icon: const Icon(
                                            Icons.clear_all,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 75,
                                        child: GFButton(
                                          text: "添加",
                                          onPressed: controller.saveServerList,
                                          type: GFButtonType.solid,
                                          color: GFColors.PRIMARY,
                                          size: 22,
                                          icon: const Icon(
                                            Icons.add_box,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(child: openSelectServerSheet()),
                                ],
                              ),
                            ),
                          )),
                          type: GFButtonType.transparent,
                          color: Colors.white,
                          size: 22,
                          icon: const Icon(
                            Icons.select_all_outlined,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GFButton(
                          onPressed: controller.doLogin,
                          text: "登录",
                          size: GFSize.LARGE,
                          shape: GFButtonShape.square,
                          type: GFButtonType.outline2x,
                          color: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GFButton(
                          onPressed: () => controller.box.remove('userinfo'),
                          text: "重置",
                          size: GFSize.LARGE,
                          shape: GFButtonShape.square,
                          type: GFButtonType.outline2x,
                          color: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
