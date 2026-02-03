import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/dou_ban/tmdb_item_view.dart';
import 'package:harvest/app/home/pages/models/dou_ban_info.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:harvest/models/common_response.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/logger_helper.dart';
import '../../../../utils/storage.dart';
import '../../../routes/app_pages.dart';
import '../models/tmdb.dart';
import 'controller.dart';
import 'douban_item_view.dart';

class DouBanPage extends StatefulWidget {
  const DouBanPage({super.key});

  @override
  State<DouBanPage> createState() => _DouBanPageState();
}

class _DouBanPageState extends State<DouBanPage> with SingleTickerProviderStateMixin {
  final controller = Get.put(DouBanController());

  // String cacheServer = 'https://images.weserv.nl/?url=';

  @override
  Widget build(BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<DouBanController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(builder: (context, constraints) {
          final contentHeight = constraints.maxHeight - 64; // 减去 tabBar 高度
          return CustomCard(
            width: constraints.maxWidth,
            margin: EdgeInsets.symmetric(vertical: 3),
            child: Center(
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
                    value: 'tmdb',
                    content: buildTmdbView(controller, shadColorScheme, context),
                    child: Text(
                      'Tmdb',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  ShadTab(
                    value: 'douban',
                    content: buildDouBanView(controller, shadColorScheme, context),
                    child: Text(
                      '豆瓣影视',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  Widget buildTmdbView(controller, ShadColorScheme shadColorScheme, context) {
    const List<Tab> tabs = [
      Tab(text: '电影'),
      Tab(text: '剧集'),
      // Tab(text: '热门榜单'),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: CustomCard(
            padding: EdgeInsets.zero,
            child: TabBar(
              tabs: tabs,
              dividerHeight: 0,
              unselectedLabelColor: shadColorScheme.foreground,
              labelColor: shadColorScheme.primary,
            )),
        body: TabBarView(
          children: [
            Column(children: [
              CustomCard(
                width: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...controller.tmdbMovieTagMap
                              .map<Widget>(
                                (e) => FilterChip(
                                  labelPadding: EdgeInsets.zero,
                                  label: Text(
                                    e.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  selected: controller.selectTmdbMovieTag == e.value,
                                  onSelected: (bool value) async {
                                    if (value == true && controller.selectTmdbMovieTag != e.value) {
                                      controller.showTmdbMovieList.clear();
                                      controller.tmdbMoviePage = 1;
                                      controller.update();
                                      controller.selectTmdbMovieTag = e.value;
                                      await controller.getTmdbMovies();
                                    }
                                  },
                                ),
                              )
                              .toList(),
                        ],
                      )),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    TmdbItemView(
                      results: controller.showTmdbMovieList,
                      onRefresh: () async {
                        controller.tmdbMoviePage = 1;
                        controller.showTmdbMovieList.clear();
                        controller.update();
                        await controller.getTmdbMovies();
                      },
                      onLoad: () async {
                        Logger.instance
                            .d('加载更多，当前页码：${controller.tmdbMoviePage}，总页数：${controller.tmdbMovies.totalPages}');
                        if (controller.tmdbMoviePage < controller.tmdbMovies.totalPages) {
                          controller.tmdbMoviePage++;
                          await controller.getTmdbMovies();
                        }
                      },
                      onTap: (item) => _showTMDBDetail(item),
                      onLongPress: (item) {},
                    ),
                    if (controller.tmdbLoading == true)
                      Center(
                        child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: shadColorScheme.primary,
                            )),
                      ),
                  ],
                ),
              ),
            ]),
            Column(children: [
              CustomCard(
                width: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...controller.tmdbTvTagMap
                              .map((MetaDataItem e) => FilterChip(
                                    labelPadding: EdgeInsets.zero,
                                    label: Text(
                                      e.name,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    selected: controller.selectTmdbTvTag == e.value,
                                    onSelected: (bool value) async {
                                      if (value == true && controller.selectTmdbTvTag != e.value) {
                                        controller.showTmdbTvList.clear();
                                        controller.tmdbTvPage = 1;
                                        controller.update();
                                        controller.selectTmdbTvTag = e.value;
                                        await controller.getTmdbTvs();
                                      }
                                    },
                                  ))
                              .toList(),
                        ],
                      )),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    TmdbItemView(
                      results: controller.showTmdbTvList,
                      onRefresh: () async {
                        controller.tmdbTvPage = 1;
                        controller.showTmdbTvList.clear();
                        await controller.getTmdbTvs();
                      },
                      onLoad: () async {
                        Logger.instance.d('加载更多，当前页码：${controller.tmdbTvPage}，总页数：${controller.tmdbTvs.totalPages}');

                        if (controller.tmdbTvPage < controller.tmdbTvs.totalPages) {
                          controller.tmdbTvPage++;
                          await controller.getTmdbTvs();
                        }
                      },
                      onTap: (item) => _showTMDBDetail(item),
                      onLongPress: (item) {},
                    ),
                    if (controller.tmdbLoading == true)
                      Center(
                        child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: shadColorScheme.primary,
                            )),
                      ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showTMDBDetail(info) async {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    var res = await controller.getTMDBDetail(info);
    if (!res.succeed) {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('出错啦'),
          description: Text(res.msg),
        ),
      );
      return;
    }
    var mediaInfo = res.data;
    String urlPrefix = 'https://media.themoviedb.org/t/p/w300_and_h450_bestv2';
    String posterPath = '$urlPrefix${mediaInfo.posterPath}';
    Logger.instance.d(mediaInfo);
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height * 0.5;

    Get.bottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      backgroundColor: shadColorScheme.background,
      enableDrag: true,
      GetBuilder<DouBanController>(builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
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
                                radius: 8,
                                backgroundColor: shadColorScheme.background,
                                content: InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: CachedNetworkImage(
                                        imageUrl: posterPath.replaceFirst('w300_and_h450', 'w600_and_h900'),
                                        errorWidget: (context, url, error) =>
                                            const Image(image: AssetImage('assets/images/background.png')),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: posterPath,
                              placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                color: shadColorScheme.primary,
                              )),
                              errorWidget: (context, url, error) => Image.asset('assets/images/background.png'),
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
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${mediaInfo.title}${mediaInfo.releaseDate}',
                                style: TextStyle(
                                    color: shadColorScheme.foreground, fontSize: 20, fontWeight: FontWeight.w700),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Text(
                              //   '${mediaInfo.director.map((e) => e.name).join('/')}/${mediaInfo.genres}/${mediaInfo.releaseDate}/${mediaInfo.duration}',
                              //   overflow: TextOverflow.ellipsis,
                              //   maxLines: 2,
                              // ),
                              // Text(
                              //   mediaInfo.writer.map((e) => e.name).join(' / '),
                              //   overflow: TextOverflow.ellipsis,
                              // ),
                              if (mediaInfo.productionCountries.isNotEmpty)
                                Text(mediaInfo.productionCountries.map((e) => e.name).join(' / '),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                              if (mediaInfo.genres.isNotEmpty)
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Wrap(
                                    spacing: 4,
                                    children: [
                                      ...mediaInfo.genres.map<CustomTextTag>((Genre item) => CustomTextTag(
                                            labelText: item.name,
                                          )),
                                    ],
                                  ),
                                ),

                              // Text(mediaInfo.region.toString()),
                              // Text(mediaInfo.language.toString()),
                              // Text(mediaInfo.season.toString()),
                              // Text(mediaInfo.episode.toString()),
                              mediaInfo.voteCount > 0
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        RatingBar.readOnly(
                                          initialRating: mediaInfo.voteAverage / 2,
                                          filledIcon: Icons.star,
                                          emptyIcon: Icons.star_border,
                                          emptyColor: Colors.redAccent,
                                          filledColor: shadColorScheme.foreground,
                                          halfFilledColor: Colors.amberAccent,
                                          halfFilledIcon: Icons.star_half,
                                          maxRating: 5,
                                          size: 14,
                                        ),
                                        Text(
                                          '${mediaInfo.voteCount} 人评价',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text('暂无评分', style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                              if (mediaInfo.imdbId != null)
                                Text('iMdb: ${mediaInfo.imdbId}',
                                    style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                            ],
                          ),
                        ))
                      ],
                    ),
                    Text(mediaInfo.overview, style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ShadButton.ghost(
                    size: ShadButtonSize.sm,
                    onPressed: () async {
                      String url = 'https://www.themoviedb.org/movie/${mediaInfo.id}';
                      if (kIsWeb) {
                        Logger.instance.i('Explorer');
                        if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
                          ShadToaster.of(context).show(
                            ShadToast.destructive(
                              title: const Text('打开网页出错'),
                              description: Text('打开网页出错，不支持的客户端？'),
                            ),
                          );
                        }
                      } else {
                        Logger.instance.i('WebView');
                        Get.toNamed(Routes.WEBVIEW, arguments: {'url': url});
                      }
                    },
                    leading: Icon(
                      Icons.info_outline,
                      size: 16,
                    ),
                    child: const Text('详情'),
                  ),
                  ShadButton.destructive(
                    size: ShadButtonSize.sm,
                    onPressed: () async {
                      Get.back();
                      controller.tmdbGoSearchPage(mediaInfo);
                    },
                    leading: Icon(
                      Icons.search,
                      size: 16,
                    ),
                    child: const Text('搜索'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildDouBanView(DouBanController controller, ShadColorScheme shadColorScheme, BuildContext context) {
    const List<Tab> tabs = [
      Tab(text: '热门电影'),
      Tab(text: '热门剧集'),
      Tab(text: '热门榜单'),
    ];
    double itemWidth = SPUtil.getDouble('tmdb_media_item_width', defaultValue: 120);
    double itemHeight = itemWidth * 1.5;
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
                width: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    DoubanItemView(
                      mediaItems: controller.douBanMovieHot,
                      onTap: (item) => _buildOperateDialog(item),
                      onDoubleTap: (item) => controller.getVideoDetail(item, toSearch: true),
                      onLongPress: (item) =>
                          Get.toNamed(Routes.WEBVIEW, arguments: {'url': item.douBanUrl, 'cookie': item.cookie}),
                    ),
                    if (controller.isLoading == true)
                      Center(
                        child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: shadColorScheme.primary,
                            )),
                      ),
                  ],
                ),
              ),
            ]),
            Column(children: [
              CustomCard(
                padding: const EdgeInsets.all(8.0),
                width: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    DoubanItemView(
                      mediaItems: controller.douBanTvHot,
                      onTap: (item) => _buildOperateDialog(item),
                      onDoubleTap: (item) => controller.getVideoDetail(item, toSearch: true),
                      onLongPress: (item) =>
                          Get.toNamed(Routes.WEBVIEW, arguments: {'url': item.douBanUrl, 'cookie': item.cookie}),
                    ),
                    if (controller.isLoading == true)
                      Center(
                        child: CircularProgressIndicator(
                          color: shadColorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ]),
            Column(
              children: [
                CustomCard(
                  width: double.infinity,
                  child: Center(
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 8,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                      children:
                                          controller.douBanTop250.map((e) => buildTop250Item(e, context)).toList())
                                  : Wrap(
                                      alignment: WrapAlignment.spaceAround,
                                      children:
                                          controller.rankMovieList.map((e) => buildRankItem(e, context)).toList()),
                            ),
                          ),
                        ),
                        if (controller.isLoading == true)
                          Center(
                            child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: shadColorScheme.primary,
                                )),
                          ),
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
  }

  InkWell buildRankItem(RankMovie e, BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return InkWell(
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
                  borderRadius: BorderRadius.circular(15.0),
                  child: CachedNetworkImage(
                    httpHeaders: {
                      'Referer': 'https://movie.douban.com/',
                      'User-Agent':
                          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0',
                    },
                    imageUrl: e.poster,
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: shadColorScheme.primary,
                          )),
                    ),
                    errorWidget: (context, url, error) => Image.asset('assets/images/douban.png'),
                    width: 80,
                    height: 120,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: shadColorScheme.background,
                    width: 80,
                    child: Center(
                      child: Tooltip(
                        message: e.title.toString(),
                        triggerMode: TooltipTriggerMode.tap,
                        margin: const EdgeInsets.symmetric(horizontal: 36),
                        child: Text(
                          "${e.rank}.${e.title}",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                        ),
                      ),
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
                spacing: 3,
                children: [
                  Text(
                    e.title.toString(),
                    style: ShadTheme.of(context).textTheme.large.copyWith(fontSize: 15),
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
                  Text(
                    '上映日期：${e.releaseDate} 发行地：${e.regions}',
                    style: const TextStyle(fontSize: 13),
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
                          filledColor: shadColorScheme.primary,
                          halfFilledColor: Colors.amberAccent,
                          halfFilledIcon: Icons.star_half,
                          maxRating: 5,
                          size: 16,
                        ),
                      ),
                      Text('投票数：${e.voteCount.toString()}'),
                    ],
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  InkWell buildTop250Item(TopMovieInfo e, BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return InkWell(
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
                  borderRadius: BorderRadius.circular(15.0),
                  child: CachedNetworkImage(
                    imageUrl: e.poster,
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: shadColorScheme.primary,
                          )),
                    ),
                    errorWidget: (context, url, error) => Image.asset('assets/images/douban.png'),
                    width: 80,
                    height: 120,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: shadColorScheme.background,
                    width: 80,
                    child: Center(
                      child: Tooltip(
                        message: "${e.title}.${e.subtitle}",
                        triggerMode: TooltipTriggerMode.tap,
                        margin: const EdgeInsets.symmetric(horizontal: 36),
                        child: Text(
                          "${e.rank}.${e.title}",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                        ),
                      ),
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
                spacing: 3,
                children: [
                  Text(
                    e.subtitle.toString(),
                    style: ShadTheme.of(context).textTheme.large.copyWith(fontSize: 15),
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
                          filledColor: shadColorScheme.primary,
                          halfFilledColor: Colors.amberAccent,
                          halfFilledIcon: Icons.star_half,
                          maxRating: 5,
                          size: 16,
                        ),
                      ),
                      Text(e.evaluateNum),
                    ],
                  ),
                  Text(
                    e.quote,
                    style: ShadTheme.of(context).textTheme.blockquote.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Future<dynamic> _buildOperateDialog(dynamic mediaInfo) async {
    CommonResponse detail = await controller.getVideoDetail(mediaInfo, toSearch: false);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    if (!detail.succeed || detail.data == null) {
      Logger.instance.e(detail.msg);
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('获取资源详情失败'),
          description: Text(detail.succeed ? '触发豆瓣警报了，请稍后再试' : detail.msg),
        ),
      );
      return;
    }
    Logger.instance.e(detail.data);
    VideoDetail videoDetail = detail.data;
    Get.bottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        backgroundColor: shadColorScheme.background,
        enableDrag: true, GetBuilder<DouBanController>(builder: (controller) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
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
                                    imageUrl: '${mediaInfo.poster}',
                                    errorWidget: (context, url, error) =>
                                        const Image(image: AssetImage('assets/images/douban.png')),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: '${mediaInfo.poster}',
                            httpHeaders: {
                              'Referer': 'https://movie.douban.com/',
                              'User-Agent':
                                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
                              'cookie': mediaInfo.cookie ?? ''
                            },
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: shadColorScheme.primary,
                                  )),
                            ),
                            errorWidget: (context, url, error) => Image.asset('assets/images/douban.png'),
                            width: 100,
                            height: 150,
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
                                  color: shadColorScheme.foreground, fontSize: 20, fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${videoDetail.director.map((e) => e.name).join('/')}/${videoDetail.genres}/${videoDetail.releaseDate}/${videoDetail.duration}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                color: shadColorScheme.foreground,
                                fontSize: 12,
                              ),
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
                                style: TextStyle(
                                  color: shadColorScheme.foreground,
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              videoDetail.region.toString(),
                              style: TextStyle(
                                color: shadColorScheme.foreground,
                                fontSize: 12,
                              ),
                            ),
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
                                        filledColor: shadColorScheme.foreground,
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
                            Text(
                              'iMdb: ${videoDetail.imdb}',
                              style: TextStyle(
                                color: shadColorScheme.foreground,
                                fontSize: 12,
                              ),
                            ),
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
                                          imageUrl: imgUrl,
                                          httpHeaders: {
                                            'Referer': 'https://movie.douban.com/',
                                            'User-Agent':
                                                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
                                            'cookie': mediaInfo.cookie ?? ''
                                          },
                                          errorWidget: (context, url, error) =>
                                              const Image(image: AssetImage('assets/images/douban.png')),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl: imgUrl,
                                        placeholder: (context, url) => Center(
                                          child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                color: shadColorScheme.primary,
                                              )),
                                        ),
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
                                                    imageUrl: '${worker.imgUrl}',
                                                    errorWidget: (context, url, error) =>
                                                        const Image(image: AssetImage('assets/images/douban.png')),
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              ));
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: CachedNetworkImage(
                                            imageUrl: '${worker.imgUrl}',
                                            httpHeaders: {
                                              'Referer': 'https://movie.douban.com/',
                                              'User-Agent':
                                                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
                                              'cookie': mediaInfo.cookie ?? ''
                                            },
                                            placeholder: (context, url) => Center(
                                              child: SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(
                                                    color: shadColorScheme.primary,
                                                  )),
                                            ),
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
                                      style: TextStyle(
                                        color: shadColorScheme.foreground,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      worker.role!,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: shadColorScheme.foreground,
                                        fontSize: 13,
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
                        style: TextStyle(
                          color: shadColorScheme.destructive,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        videoDetail.wantLook,
                        style: TextStyle(
                          color: shadColorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...videoDetail.summary.map((e) => Text(
                        e,
                        style: TextStyle(
                          color: shadColorScheme.foreground,
                          fontSize: 13,
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: () async {
                    await _openMediaInfoDetail(mediaInfo);
                  },
                  leading: Icon(
                    Icons.info_outline,
                    size: 16,
                  ),
                  child: const Text('详情'),
                ),
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  onPressed: () => controller.goSearchPage(videoDetail),
                  leading: Icon(
                    Icons.search,
                    size: 16,
                  ),
                  child: const Text('搜索'),
                ),
              ],
            ),
          ],
        ),
      );
    }));
  }

  Future<void> _openMediaInfoDetail(dynamic mediaInfo) async {
    Get.back();
    if (kIsWeb) {
      Logger.instance.i('Explorer');
      if (!await launchUrl(Uri.parse(mediaInfo.douBanUrl), mode: LaunchMode.externalApplication)) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('打开网页出错'),
            description: Text('打开网页出错，不支持的客户端？'),
          ),
        );
      }
    } else {
      Logger.instance.i('WebView');
      Get.toNamed(Routes.WEBVIEW, arguments: {'url': mediaInfo.douBanUrl, 'cookie': mediaInfo.cookie ?? ''});
    }
  }
}
