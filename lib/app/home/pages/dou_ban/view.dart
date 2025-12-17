import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/models/dou_ban_info.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/models/common_response.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/logger_helper.dart';
import '../../../routes/app_pages.dart';
import 'controller.dart';

class DouBanPage extends StatefulWidget {
  const DouBanPage({super.key});

  @override
  State<DouBanPage> createState() => _DouBanPageState();
}

class _DouBanPageState extends State<DouBanPage> with SingleTickerProviderStateMixin {
  final controller = Get.put(DouBanController());
  String cacheServer = 'https://images.weserv.nl/?url=';

  @override
  Widget build(BuildContext context) {
    const List<Tab> tabs = [
      Tab(text: '热门电影'),
      Tab(text: '热门剧集'),
      Tab(text: '热门榜单'),
    ];
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<DouBanController>(builder: (controller) {
      return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: CustomCard(
              padding: EdgeInsets.zero,
              child: TabBar(
                tabs: tabs,
                dividerHeight: 0,
                unselectedLabelColor: ShadTheme.of(context).colorScheme.foreground,
                labelColor: ShadTheme.of(context).colorScheme.primary,
              )),
          body: TabBarView(
            children: [
              Column(children: [
                CustomCard(
                  child: Column(
                    children: [
                      ListTile(
                        dense: true,
                        title: Text(
                          '豆瓣热门电影 ${controller.douBanMovieHot.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: ShadTheme.of(context).colorScheme.foreground),
                        ),
                      ),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 8,
                            alignment: WrapAlignment.spaceAround,
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
                                          controller.getDouBanMovieHot(controller.selectMovieTag);
                                        }
                                      },
                                    ))
                                .toList(),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      CustomCard(
                        width: double.infinity,
                        height: double.infinity,
                        padding: const EdgeInsets.all(8),
                        child: SingleChildScrollView(
                          child: Center(
                            child: Wrap(
                              alignment: WrapAlignment.spaceAround,
                              spacing: 12,
                              runSpacing: 12,
                              children: controller.douBanMovieHot
                                  .map((e) => InkWell(
                                        onTap: () async {
                                          _buildOperateDialog(e);
                                        },
                                        onLongPress: () async {
                                          // Logger.instance.i('WebView');
                                          // Get.toNamed(Routes.WEBVIEW, arguments: {
                                          //   'url': e.url,
                                          // });
                                          await controller.getVideoDetail(e.douBanUrl);
                                        },
                                        child: SizedBox(
                                          width: 100,
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: '$cacheServer${e.poster}',
                                                  placeholder: (context, url) =>
                                                      const Center(child: CircularProgressIndicator()),
                                                  errorWidget: (context, url, error) =>
                                                      Image.asset('assets/images/avatar.png'),
                                                  width: 100,
                                                  height: 150,
                                                  fit: BoxFit.fitWidth,
                                                ),
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
                                                    style: const TextStyle(color: Colors.white, fontSize: 12),
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
                      ),
                      if (controller.isLoading == true) const Center(child: CircularProgressIndicator())
                    ],
                  ),
                ),
              ]),
              Column(children: [
                CustomCard(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        dense: true,
                        title: Text(
                          '豆瓣热门电视剧 ${controller.douBanTvHot.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: ShadTheme.of(context).colorScheme.foreground),
                        ),
                      ),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 8,
                            alignment: WrapAlignment.spaceAround,
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
                                          controller.getDouBanTvHot(controller.selectTvTag);
                                        }
                                      },
                                    ))
                                .toList(),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      CustomCard(
                        width: double.infinity,
                        height: double.infinity,
                        padding: const EdgeInsets.all(8),
                        child: SingleChildScrollView(
                          child: Center(
                            child: Wrap(
                              alignment: WrapAlignment.spaceAround,
                              spacing: 12,
                              runSpacing: 12,
                              children: controller.douBanTvHot
                                  .map((e) => InkWell(
                                        onTap: () async {
                                          _buildOperateDialog(e);
                                        },
                                        onLongPress: () {
                                          Logger.instance.i('WebView');
                                          Get.toNamed(Routes.WEBVIEW, arguments: {
                                            'url': e.douBanUrl,
                                          });
                                        },
                                        child: SizedBox(
                                          width: 100,
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: '$cacheServer${e.poster}',
                                                  placeholder: (context, url) =>
                                                      const Center(child: CircularProgressIndicator()),
                                                  errorWidget: (context, url, error) =>
                                                      Image.asset('assets/images/avatar.png'),
                                                  width: 100,
                                                  height: 150,
                                                  fit: BoxFit.fitWidth,
                                                ),
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
                                                    style: const TextStyle(color: Colors.white, fontSize: 12),
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
                      ),
                      if (controller.isLoading == true) const Center(child: CircularProgressIndicator())
                    ],
                  ),
                ),
              ]),
              Column(
                children: [
                  CustomCard(
                    width: double.infinity,
                    child: Column(
                      children: [
                        // Tooltip(
                        //   message: '点击刷新TOP250',
                        //   child: ListTile(
                        //     dense: true,
                        //     title: const Text(
                        //       '豆瓣TOP250',
                        //       textAlign: TextAlign.center,
                        //     ),
                        //     onTap: () => controller.getDouBanTop250(),
                        //   ),
                        // ),
                        ListTile(
                          dense: true,
                          title: Text(
                            '豆瓣 Top250 ${controller.rankMovieList.length}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: ShadTheme.of(context).colorScheme.foreground),
                          ),
                        ),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              spacing: 8,
                              alignment: WrapAlignment.spaceAround,
                              children: [
                                // FilterChip(
                                //   labelPadding: EdgeInsets.zero,
                                //   label: const Text(
                                //     'TOP250',
                                //     style: TextStyle(fontSize: 12),
                                //   ),
                                //   selected:
                                //       controller.selectTypeTag == 'TOP250',
                                //   onSelected: (bool value) {
                                //     if (value == true) {
                                //       controller.selectTypeTag = 'TOP250';
                                //       controller.getRankListByType(
                                //           controller.selectTypeTag);
                                //     }
                                //   },
                                // ),
                                ...controller.typeMap.entries.map((e) => FilterChip(
                                      labelPadding: EdgeInsets.zero,
                                      label: Text(
                                        e.key,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      selected: controller.selectTypeTag == e.key,
                                      onSelected: (bool value) {
                                        if (value == true) {
                                          controller.selectTypeTag = e.key;
                                          controller.getRankListByType(controller.selectTypeTag);
                                        }
                                      },
                                    ))
                              ],
                            )),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
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
                            onRefresh: () async {
                              controller.initPage = 0;
                              await controller.getRankListByType(controller.selectTypeTag);
                            },
                            onLoad: () async {
                              if (controller.selectTypeTag == "TOP250") {
                                await controller.getRankListByType(controller.selectTypeTag);
                              }
                            },
                            child: SingleChildScrollView(
                              child: Center(
                                child: controller.selectTypeTag == "TOP250"
                                    ? Wrap(
                                        alignment: WrapAlignment.spaceAround,
                                        children: controller.douBanTop250
                                            .map((e) => InkWell(
                                                  onTap: () async {
                                                    _buildOperateDialog(e);
                                                  },
                                                  onLongPress: () {
                                                    Logger.instance.i('WebView');
                                                    Get.toNamed(Routes.WEBVIEW, arguments: {
                                                      'url': e.douBanUrl,
                                                    });
                                                  },
                                                  child: CustomCard(
                                                    color: Colors.transparent,
                                                    padding: const EdgeInsets.all(8),
                                                    child: Row(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius: BorderRadius.circular(5.0),
                                                              child: CachedNetworkImage(
                                                                imageUrl: '$cacheServer${e.poster}',
                                                                placeholder: (context, url) =>
                                                                    const Center(child: CircularProgressIndicator()),
                                                                errorWidget: (context, url, error) =>
                                                                    Image.asset('assets/images/avatar.png'),
                                                                width: 100,
                                                                height: 150,
                                                                fit: BoxFit.fitWidth,
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              right: 0,
                                                              child: Center(
                                                                child: Container(
                                                                  color: ShadTheme.of(context).colorScheme.background,
                                                                  width: 30,
                                                                  child: Text(
                                                                    e.rank,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                        color: ShadTheme.of(context)
                                                                            .colorScheme
                                                                            .foreground,
                                                                        fontSize: 12),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              bottom: 0,
                                                              child: Container(
                                                                color: ShadTheme.of(context).colorScheme.background,
                                                                width: 100,
                                                                child: Text(
                                                                  e.title,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      color:
                                                                          ShadTheme.of(context).colorScheme.foreground,
                                                                      fontSize: 12),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Expanded(
                                                            child: Padding(
                                                          padding: const EdgeInsets.only(left: 12),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                e.subtitle.toString(),
                                                                style: ShadTheme.of(context).textTheme.h4,
                                                              ),
                                                              Tooltip(
                                                                message: e.cast.toString(),
                                                                triggerMode: TooltipTriggerMode.tap,
                                                                margin: const EdgeInsets.symmetric(horizontal: 36),
                                                                child: Text(
                                                                  e.cast,
                                                                  style: const TextStyle(fontSize: 13),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              Tooltip(
                                                                message: e.desc.toString(),
                                                                triggerMode: TooltipTriggerMode.tap,
                                                                margin: const EdgeInsets.symmetric(horizontal: 36),
                                                                child: Text(
                                                                  '${e.desc}',
                                                                  style: const TextStyle(fontSize: 13),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Tooltip(
                                                                    message: '评分：${e.ratingNum}',
                                                                    child: RatingBar.readOnly(
                                                                      initialRating: double.parse(e.ratingNum) / 2,
                                                                      filledIcon: Icons.star,
                                                                      emptyIcon: Icons.star_border,
                                                                      emptyColor: Colors.redAccent,
                                                                      filledColor:
                                                                          ShadTheme.of(context).colorScheme.foreground,
                                                                      halfFilledColor: Colors.amberAccent,
                                                                      halfFilledIcon: Icons.star_half,
                                                                      maxRating: 5,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                                  Text(e.evaluateNum),
                                                                ],
                                                              ),
                                                              Text(
                                                                e.quote,
                                                                style: ShadTheme.of(context).textTheme.h4,
                                                              ),
                                                            ],
                                                          ),
                                                        ))
                                                      ],
                                                    ),
                                                  ),
                                                ))
                                            .toList())
                                    : Wrap(
                                        alignment: WrapAlignment.spaceAround,
                                        children: controller.rankMovieList
                                            .map((e) => InkWell(
                                                  onTap: () async {
                                                    _buildOperateDialog(e);
                                                  },
                                                  onLongPress: () {
                                                    Logger.instance.i('WebView');
                                                    Get.toNamed(Routes.WEBVIEW, arguments: {
                                                      'url': e.douBanUrl,
                                                    });
                                                  },
                                                  child: CustomCard(
                                                    padding: const EdgeInsets.all(8),
                                                    child: Row(
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius: BorderRadius.circular(5.0),
                                                              child: CachedNetworkImage(
                                                                imageUrl: '$cacheServer${e.poster}',
                                                                placeholder: (context, url) =>
                                                                    const Center(child: CircularProgressIndicator()),
                                                                errorWidget: (context, url, error) =>
                                                                    Image.asset('assets/images/avatar.png'),
                                                                width: 100,
                                                                height: 150,
                                                                fit: BoxFit.fitWidth,
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              right: 0,
                                                              child: Container(
                                                                color: ShadTheme.of(context).colorScheme.background,
                                                                width: 20,
                                                                child: Text(
                                                                  e.rank.toString(),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      color:
                                                                          ShadTheme.of(context).colorScheme.foreground,
                                                                      fontSize: 12),
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              bottom: 0,
                                                              child: Container(
                                                                color: ShadTheme.of(context).colorScheme.background,
                                                                width: 100,
                                                                child: Text(
                                                                  e.title,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                      color:
                                                                          ShadTheme.of(context).colorScheme.foreground,
                                                                      fontSize: 12),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Expanded(
                                                            child: Padding(
                                                          padding: const EdgeInsets.only(left: 12),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                e.title.toString(),
                                                                style: ShadTheme.of(context).textTheme.h4,
                                                              ),
                                                              Tooltip(
                                                                message: e.actors.toString(),
                                                                triggerMode: TooltipTriggerMode.tap,
                                                                margin: const EdgeInsets.symmetric(horizontal: 36),
                                                                child: Text(
                                                                  e.actors.toString(),
                                                                  style: const TextStyle(fontSize: 13),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Tooltip(
                                                                    message: '评分：${e.rating.first}',
                                                                    child: RatingBar.readOnly(
                                                                      initialRating: double.parse(e.rating.first) / 2,
                                                                      filledIcon: Icons.star,
                                                                      emptyIcon: Icons.star_border,
                                                                      emptyColor: Colors.redAccent,
                                                                      filledColor:
                                                                          ShadTheme.of(context).colorScheme.foreground,
                                                                      halfFilledColor: Colors.amberAccent,
                                                                      halfFilledIcon: Icons.star_half,
                                                                      maxRating: 5,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                                  Text(e.voteCount.toString()),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ))
                                                      ],
                                                    ),
                                                  ),
                                                ))
                                            .toList()),
                              ),
                            ),
                          ),
                          if (controller.isLoading == true) const Center(child: CircularProgressIndicator())
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<dynamic> _buildOperateDialog(mediaInfo) async {
    CommonResponse detail = await controller.getVideoDetail(mediaInfo.douBanUrl);
    if (!detail.succeed) {
      Logger.instance.e(detail.msg);
      return;
    }
    Logger.instance.e(detail.data);
    VideoDetail videoDetail = VideoDetail.fromJson(detail.data);
    Get.bottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
        ),
        backgroundColor: ShadTheme.of(context).colorScheme.background,
        enableDrag: true, GetBuilder<DouBanController>(builder: (controller) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.defaultDialog(
                              title: '海报预览',
                              content: InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: '$cacheServer${mediaInfo.poster}',
                                    errorWidget: (context, url, error) =>
                                        const Image(image: AssetImage('assets/images/avatar.png')),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: '$cacheServer${mediaInfo.poster}',
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Image.asset('assets/images/avatar.png'),
                            width: 120,
                            height: 180,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${videoDetail.title}${videoDetail.year}',
                              style: TextStyle(
                                  color: ShadTheme.of(context).colorScheme.foreground,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${videoDetail.director.map((e) => e.name).join('/')}/${videoDetail.genres}/${videoDetail.releaseDate}/${videoDetail.duration}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            // Text(
                            //   videoDetail.writer.map((e) => e.name).join(' / '),
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                            // Text(
                            //   videoDetail.actors.map((e) => e.name).join(' / '),
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                            if (videoDetail.alias != null)
                              Text(
                                videoDetail.alias!.join(' / '),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            Text(videoDetail.region.toString()),
                            // Text(videoDetail.language.toString()),
                            // Text(videoDetail.season.toString()),
                            // Text(videoDetail.episode.toString()),
                            videoDetail.rate != null && videoDetail.rate!.isNotEmpty
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RatingBar.readOnly(
                                        initialRating: double.parse(videoDetail.rate!) / 2,
                                        filledIcon: Icons.star,
                                        emptyIcon: Icons.star_border,
                                        emptyColor: Colors.redAccent,
                                        filledColor: ShadTheme.of(context).colorScheme.foreground,
                                        halfFilledColor: Colors.amberAccent,
                                        halfFilledIcon: Icons.star_half,
                                        maxRating: 5,
                                        size: 18,
                                      ),
                                      Text(
                                        '${videoDetail.evaluate} 人评价',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    '暂无评分',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                            Text('iMdb: ${videoDetail.imdb}'),
                          ],
                        ),
                      ))
                    ],
                  ),
                  if (videoDetail.pictures != null && videoDetail.pictures!.isNotEmpty)
                    SizedBox(
                      height: 178,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            ...videoDetail.pictures!.map((imgUrl) => CustomCard(
                                  child: InkWell(
                                    onTap: () {
                                      Get.defaultDialog(
                                          content: InkWell(
                                        onTap: () => Navigator.of(context).pop(),
                                        child: CachedNetworkImage(
                                          imageUrl: '$cacheServer$imgUrl',
                                          errorWidget: (context, url, error) =>
                                              const Image(image: AssetImage('assets/images/avatar.png')),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl: '$cacheServer$imgUrl',
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        height: 160,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 160,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...videoDetail.celebrities.map((worker) => CustomCard(
                                width: 100,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          Get.defaultDialog(
                                              title: '海报预览',
                                              content: InkWell(
                                                onTap: () => Navigator.of(context).pop(),
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                                                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl: '$cacheServer${worker.imgUrl}',
                                                    errorWidget: (context, url, error) =>
                                                        const Image(image: AssetImage('assets/images/avatar.png')),
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              ));
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: CachedNetworkImage(
                                            imageUrl: '$cacheServer${worker.imgUrl}',
                                            placeholder: (context, url) =>
                                                const Center(child: CircularProgressIndicator()),
                                            width: 100,
                                            height: 150,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      worker.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      worker.role!,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        videoDetail.hadSeen,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        videoDetail.wantLook,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...videoDetail.summary.map((e) => Text(e)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ShadButton(
                  onPressed: () => controller.goSearchPage(videoDetail),
                  leading: Icon(
                    Icons.search,
                    size: 18,
                  ),
                  child: const Text('搜索'),
                ),
                ShadButton(
                  onPressed: () async {
                    await _openMediaInfoDetail(mediaInfo);
                  },
                  leading: Icon(
                    Icons.info_outline,
                    size: 18,
                  ),
                  child: const Text('详情'),
                ),
              ],
            ),
          ],
        ),
      );
    }));
  }

  Future<void> _openMediaInfoDetail(mediaInfo) async {
    Get.back();
    String url;
    try {
      url = mediaInfo.douBanUrl;
    } catch (err) {
      url = mediaInfo.douBanUrl;
    }
    await controller.getVideoDetail(url);
    if (kIsWeb) {
      Logger.instance.i('Explorer');
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？', colorText: ShadTheme.of(context).colorScheme.foreground);
      }
    } else {
      Logger.instance.i('WebView');
      Get.toNamed(Routes.WEBVIEW, arguments: {'url': url});
    }
  }
}
