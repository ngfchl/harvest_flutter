import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/common/card_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/logger_helper.dart';
import '../../../routes/app_pages.dart';
import 'controller.dart';
import 'model.dart';

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
    const List<Tab> tabs = [
      Tab(text: '热门电影'),
      Tab(text: '热门剧集'),
      Tab(text: '热门榜单'),
    ];
    return GetBuilder<DouBanController>(builder: (controller) {
      return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          // floatingActionButton: _buildBottomButtonBar(),
          bottomNavigationBar: const TabBar(tabs: tabs),
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
                Expanded(
                  child: Stack(
                    children: [
                      CustomCard(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        child: SingleChildScrollView(
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
                                        await controller
                                            .getVideoDetail(e.douBanUrl);
                                      },
                                      child: SizedBox(
                                        width: 100,
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    '$cacheServer${e.poster}',
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Image.asset(
                                                        'assets/images/logo.png'),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                      if (controller.isLoading == true)
                        const Center(child: CircularProgressIndicator())
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
                Expanded(
                  child: Stack(
                    children: [
                      CustomCard(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        child: SingleChildScrollView(
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
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    '$cacheServer${e.poster}',
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Image.asset(
                                                        'assets/images/logo.png'),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                      if (controller.isLoading == true)
                        const Center(child: CircularProgressIndicator())
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
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              spacing: 8,
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
                                ...controller.typeMap.entries
                                    .map((e) => FilterChip(
                                          labelPadding: EdgeInsets.zero,
                                          label: Text(
                                            e.key,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          selected:
                                              controller.selectTypeTag == e.key,
                                          onSelected: (bool value) {
                                            if (value == true) {
                                              controller.selectTypeTag = e.key;
                                              controller.getRankListByType(
                                                  controller.selectTypeTag);
                                            }
                                          },
                                        ))
                              ],
                            )),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: Stack(
                        children: [
                          EasyRefresh(
                            onRefresh: () async {
                              controller.initPage = 0;
                              await controller
                                  .getRankListByType(controller.selectTypeTag);
                            },
                            onLoad: () async {
                              if (controller.selectTypeTag == "TOP250") {
                                await controller.getRankListByType(
                                    controller.selectTypeTag);
                              }
                            },
                            child: SingleChildScrollView(
                              child: controller.selectTypeTag == "TOP250"
                                  ? Wrap(
                                      children: controller.douBanTop250
                                          .map((e) => InkWell(
                                                onTap: () async {
                                                  _buildOperateDialog(e);
                                                },
                                                onLongPress: () {
                                                  Logger.instance.i('WebView');
                                                  Get.toNamed(Routes.WEBVIEW,
                                                      arguments: {
                                                        'url': e.douBanUrl,
                                                      });
                                                },
                                                child: CustomCard(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Row(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  '$cacheServer${e.poster}',
                                                              placeholder: (context,
                                                                      url) =>
                                                                  const Center(
                                                                      child:
                                                                          CircularProgressIndicator()),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Image.asset(
                                                                      'assets/images/logo.png'),
                                                              width: 100,
                                                              height: 150,
                                                              fit: BoxFit
                                                                  .fitWidth,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Center(
                                                              child: Container(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .surface,
                                                                width: 30,
                                                                child: Text(
                                                                  e.rank,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onSurface,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            bottom: 0,
                                                            child: Container(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surface,
                                                              width: 100,
                                                              child: Text(
                                                                e.title,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurface,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Expanded(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 12),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            GFTypography(
                                                              text: e.subtitle
                                                                  .toString(),
                                                              type:
                                                                  GFTypographyType
                                                                      .typo5,
                                                              dividerHeight: 0,
                                                              textColor: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                            Tooltip(
                                                              message: e.cast
                                                                  .toString(),
                                                              triggerMode:
                                                                  TooltipTriggerMode
                                                                      .tap,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          36),
                                                              child: Text(
                                                                e.cast,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            13),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            Tooltip(
                                                              message: e.desc
                                                                  .toString(),
                                                              triggerMode:
                                                                  TooltipTriggerMode
                                                                      .tap,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          36),
                                                              child: Text(
                                                                '${e.desc}',
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            13),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Tooltip(
                                                                  message:
                                                                      '评分：${e.ratingNum}',
                                                                  child: RatingBar
                                                                      .readOnly(
                                                                    initialRating:
                                                                        double.parse(e.ratingNum) /
                                                                            2,
                                                                    filledIcon:
                                                                        Icons
                                                                            .star,
                                                                    emptyIcon: Icons
                                                                        .star_border,
                                                                    emptyColor:
                                                                        Colors
                                                                            .redAccent,
                                                                    filledColor: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .primary,
                                                                    halfFilledColor:
                                                                        Colors
                                                                            .amberAccent,
                                                                    halfFilledIcon:
                                                                        Icons
                                                                            .star_half,
                                                                    maxRating:
                                                                        5,
                                                                    size: 18,
                                                                  ),
                                                                ),
                                                                Text(e
                                                                    .evaluateNum),
                                                              ],
                                                            ),
                                                            GFTypography(
                                                              text: e.quote,
                                                              type:
                                                                  GFTypographyType
                                                                      .typo5,
                                                              dividerHeight: 0,
                                                              textColor: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary,
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
                                      children: controller.rankMovieList
                                          .map((e) => InkWell(
                                                onTap: () async {
                                                  _buildOperateDialog(e);
                                                },
                                                onLongPress: () {
                                                  Logger.instance.i('WebView');
                                                  Get.toNamed(Routes.WEBVIEW,
                                                      arguments: {
                                                        'url': e.douBanUrl,
                                                      });
                                                },
                                                child: CustomCard(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Row(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  '$cacheServer${e.poster}',
                                                              placeholder: (context,
                                                                      url) =>
                                                                  const Center(
                                                                      child:
                                                                          CircularProgressIndicator()),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Image.asset(
                                                                      'assets/images/logo.png'),
                                                              width: 100,
                                                              height: 150,
                                                              fit: BoxFit
                                                                  .fitWidth,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Container(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surface,
                                                              width: 20,
                                                              child: Text(
                                                                e.rank
                                                                    .toString(),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurface,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            bottom: 0,
                                                            child: Container(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surface,
                                                              width: 100,
                                                              child: Text(
                                                                e.title,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurface,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Expanded(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 12),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            GFTypography(
                                                              text: e.title
                                                                  .toString(),
                                                              type:
                                                                  GFTypographyType
                                                                      .typo5,
                                                              dividerHeight: 0,
                                                              textColor: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                            Tooltip(
                                                              message: e.actors
                                                                  .toString(),
                                                              triggerMode:
                                                                  TooltipTriggerMode
                                                                      .tap,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          36),
                                                              child: Text(
                                                                e.actors
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            13),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Tooltip(
                                                                  message:
                                                                      '评分：${e.rating.first}',
                                                                  child: RatingBar
                                                                      .readOnly(
                                                                    initialRating:
                                                                        double.parse(e.rating.first) /
                                                                            2,
                                                                    filledIcon:
                                                                        Icons
                                                                            .star,
                                                                    emptyIcon: Icons
                                                                        .star_border,
                                                                    emptyColor:
                                                                        Colors
                                                                            .redAccent,
                                                                    filledColor: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .primary,
                                                                    halfFilledColor:
                                                                        Colors
                                                                            .amberAccent,
                                                                    halfFilledIcon:
                                                                        Icons
                                                                            .star_half,
                                                                    maxRating:
                                                                        5,
                                                                    size: 18,
                                                                  ),
                                                                ),
                                                                Text(e.voteCount
                                                                    .toString()),
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
                          if (controller.isLoading == true)
                            const Center(child: CircularProgressIndicator())
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
    VideoDetail videoDetail =
        await controller.getVideoDetail(mediaInfo.douBanUrl);
    Get.bottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
        ),
        isScrollControlled: true,
        enableDrag: true, GetBuilder<DouBanController>(builder: (controller) {
      return CustomCard(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                                child: CachedNetworkImage(
                                  imageUrl: '$cacheServer${mediaInfo.poster}',
                                  errorWidget: (context, url, error) =>
                                      const Image(
                                          image: AssetImage(
                                              'assets/images/logo.png')),
                                  fit: BoxFit.fitWidth,
                                ),
                              ));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: '$cacheServer${mediaInfo.poster}',
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Image.asset('assets/images/logo.png'),
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
                                  color: Theme.of(context).colorScheme.primary,
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
                            videoDetail.rate != null &&
                                    videoDetail.rate!.isNotEmpty
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      RatingBar.readOnly(
                                        initialRating:
                                            double.parse(videoDetail.rate!) / 2,
                                        filledIcon: Icons.star,
                                        emptyIcon: Icons.star_border,
                                        emptyColor: Colors.redAccent,
                                        filledColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                                            const Image(
                                                image: AssetImage(
                                                    'assets/images/logo.png')),
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: '$cacheServer$imgUrl',
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
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
                                                onTap: () =>
                                                    Navigator.of(context).pop(),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      '$cacheServer${worker.imgUrl}',
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Image(
                                                          image: AssetImage(
                                                              'assets/images/logo.png')),
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ));
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '$cacheServer${worker.imgUrl}',
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator()),
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
                ElevatedButton.icon(
                  onPressed: () => controller.goSearchPage(mediaInfo),
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  label: const Text('搜索'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _openMediaInfoDetail(mediaInfo);
                  },
                  icon: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  label: const Text('详情'),
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
    if (!Platform.isIOS && !Platform.isAndroid) {
      Logger.instance.i('Explorer');
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？',
            colorText: Theme.of(context).colorScheme.primary);
      }
    } else {
      Logger.instance.i('WebView');
      Get.toNamed(Routes.WEBVIEW, arguments: {'url': url});
    }
  }
}
