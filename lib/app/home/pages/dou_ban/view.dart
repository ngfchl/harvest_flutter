import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';

import '../../../../utils/logger_helper.dart';
import '../../../routes/app_pages.dart';
import 'controller.dart';

class DouBanPage extends StatefulWidget {
  const DouBanPage({super.key});

  @override
  State<DouBanPage> createState() => _DouBanPageState();
}

class _DouBanPageState extends State<DouBanPage>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(DouBanController());
  String cacheServer = 'https://images.weserv.nl/?url=';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DouBanController>(builder: (controller) {
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildBottomButtonBar(),
        body: EasyRefresh(
          onRefresh: () async {
            await controller.initData();
          },
          child: ListView(
            children: [
              CustomCard(
                child: Tooltip(
                  message: '点击刷新TOP250',
                  child: ListTile(
                    dense: true,
                    title: Text(
                      '豆瓣TOP${controller.douBanTop250.length}',
                      textAlign: TextAlign.center,
                    ),
                    onTap: () => controller.getDouBanTop250(),
                  ),
                ),
              ),
              if (controller.douBanTop250.isNotEmpty)
                CustomCard(
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: controller.douBanTop250
                          .map((e) => InkWell(
                                onTap: () {
                                  _buildOperateDialog(e, context);
                                },
                                onLongPress: () {
                                  Logger.instance.i('WebView');
                                  Get.toNamed(Routes.WEBVIEW, arguments: {
                                    'url': e.douBanUrl,
                                  });
                                },
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: '$cacheServer${e.poster}',
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          Image.asset('assets/images/logo.png'),
                                      width: 100,
                                      height: 150,
                                      fit: BoxFit.fitWidth,
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Container(
                                        color: Colors.black38,
                                        width: 100,
                                        child: Text(
                                          e.rank,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 2,
                                      child: Container(
                                        color: Colors.black38,
                                        width: 100,
                                        child: Text(
                                          e.title,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              CustomCard(
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      title: Text(
                        '豆瓣热门电影 ${controller.douBanMovieHot.length}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8,
                          children: controller.douBanMovieTags
                              .map((e) => FilterChip(
                                    labelPadding: EdgeInsets.zero,
                                    label: Text(
                                      e,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    selected: controller.selectMovieTag == e,
                                    onSelected: (bool value) {
                                      if (value == true) {
                                        controller.selectMovieTag = e;
                                        controller.getDouBanMovieHot(
                                            controller.selectMovieTag);
                                      }
                                    },
                                  ))
                              .toList(),
                        )),
                  ],
                ),
              ),
              if (controller.douBanMovieHot.isNotEmpty)
                CustomCard(
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: controller.douBanMovieHot
                          .map((e) => InkWell(
                                onTap: () {
                                  _buildOperateDialog(e, context);
                                },
                                onLongPress: () {
                                  Logger.instance.i('WebView');
                                  Get.toNamed(Routes.WEBVIEW, arguments: {
                                    'url': e.url,
                                  });
                                },
                                child: SizedBox(
                                  width: 100,
                                  child: Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: '$cacheServer${e.cover}',
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                                'assets/images/logo.png'),
                                        width: 100,
                                        height: 150,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      Positioned(
                                        bottom: 2,
                                        child: Container(
                                          color: Colors.black38,
                                          width: 100,
                                          child: Text(
                                            e.title.trim(),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              CustomCard(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      title: Text(
                        '豆瓣热门电视剧 ${controller.douBanTvHot.length}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8,
                          children: controller.douBanTvTags
                              .map((e) => FilterChip(
                                    labelPadding: EdgeInsets.zero,
                                    label: Text(
                                      e,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    selected: controller.selectTvTag == e,
                                    onSelected: (bool value) {
                                      if (value == true) {
                                        controller.selectTvTag = e;
                                        controller.getDouBanTvHot(
                                            controller.selectTvTag);
                                      }
                                    },
                                  ))
                              .toList(),
                        )),
                  ],
                ),
              ),
              if (controller.douBanTvHot.isNotEmpty)
                CustomCard(
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: controller.douBanTvHot
                          .map((e) => InkWell(
                                onTap: () {
                                  _buildOperateDialog(e, context);
                                },
                                onLongPress: () {
                                  Logger.instance.i('WebView');
                                  Get.toNamed(Routes.WEBVIEW, arguments: {
                                    'url': e.url,
                                  });
                                },
                                child: SizedBox(
                                  width: 100,
                                  child: Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: '$cacheServer${e.cover}',
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                                'assets/images/logo.png'),
                                        width: 100,
                                        height: 150,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      Positioned(
                                        bottom: 2,
                                        child: Container(
                                          color: Colors.black38,
                                          width: 100,
                                          child: Text(
                                            e.title.trim(),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    });
  }

  Future<dynamic> _buildOperateDialog(e, BuildContext context) {
    return Get.defaultDialog(
        title: '选中的资源名称',
        content: GetBuilder<DouBanController>(builder: (controller) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  try {
                    Get.toNamed(Routes.WEBVIEW, arguments: {
                      'url': e.douBanUrl,
                    });
                  } catch (err) {
                    Get.toNamed(Routes.WEBVIEW, arguments: {
                      'url': e.url,
                    });
                  }
                },
                child: Tooltip(
                  message: '点击查看影视详情',
                  child: Text(
                    e.title,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => controller.goSearchPage(e),
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    label: const Text('搜索'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.subscriptions_outlined,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    label: const Text('订阅'),
                  ),
                ],
              ),
            ],
          );
        }));
  }

  _buildBottomButtonBar() {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Tooltip(
            message: '刷新TOP250',
            child: IconButton(
              icon: const Icon(Icons.topic_outlined, size: 20),
              onPressed: () async {
                await controller.getDouBanTop250();
              },
            ),
          ),
          Tooltip(
            message: '刷新热门电影',
            child: IconButton(
              icon: const Icon(Icons.movie_creation_outlined, size: 20),
              onPressed: () async {
                await controller.getDouBanMovieHot(controller.selectMovieTag);
              },
            ),
          ),
          Tooltip(
            message: '刷新热门电视剧',
            child: IconButton(
              icon: const Icon(Icons.live_tv, size: 20),
              onPressed: () async {
                await controller.getDouBanTvHot(controller.selectTvTag);
              },
            ),
          ),
        ],
      ),
    );
  }
}
