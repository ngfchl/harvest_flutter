// 独立组件
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../app/home/pages/models/tmdb.dart';
import 'card_view.dart';

class MediaItemCard extends StatelessWidget {
  final MediaItem media;
  final void Function(MediaItem media) onDetail;
  final Future<void> Function(MediaItem media) onSearch;
  final void Function()? onTap;

  const MediaItemCard({
    super.key,
    this.onTap,
    required this.media,
    required this.onDetail,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    const String urlPrefix = 'https://media.themoviedb.org/t/p/w300_and_h450_bestv2';
    final String posterPath = '$urlPrefix${media.posterPath}';
    final bool isMovie = media.mediaType == 'movie';

    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Slidable(
        key: ValueKey('${media.title}_${media.id}'),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) async => onDetail(media),
              backgroundColor: const Color(0xFF0392CF),
              foregroundColor: Colors.white,
              label: '详情',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) async => await onSearch(media),
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              label: '搜索',
            ),
          ],
        ),
        child: Row(
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
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Image(image: AssetImage('assets/images/avatar.png')),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: SizedBox(
                width: 55,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(
                        imageUrl: posterPath,
                        errorWidget: (context, url, error) => const SizedBox.shrink(),
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: CustomTextTag(
                        labelText: isMovie ? '电影' : '电视剧',
                        backgroundColor: shadColorScheme.primary,
                        labelColor: shadColorScheme.primaryForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: EllipsisText(
                      text: media.title,
                      ellipsis: "...",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        color: shadColorScheme.foreground,
                      ),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${media.releaseDate} 【${media.originalLanguage}】",
                          style: TextStyle(
                            fontSize: 13,
                            color: shadColorScheme.foreground,
                          ),
                        ),
                        media.voteCount == 0 || media.voteAverage == null
                            ? const Text(
                                '暂无评分',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              )
                            : Row(
                                children: [
                                  Tooltip(
                                    message: '评分：${media.voteAverage}',
                                    child: RatingBar.readOnly(
                                      initialRating: media.voteAverage! / 2,
                                      filledIcon: Icons.star,
                                      emptyIcon: Icons.star_border,
                                      emptyColor: Colors.redAccent,
                                      filledColor: shadColorScheme.foreground,
                                      halfFilledColor: Colors.amberAccent,
                                      halfFilledIcon: Icons.star_half,
                                      maxRating: 5,
                                      size: 18,
                                    ),
                                  ),
                                  Text(
                                    media.voteAverage.toString(),
                                    style: TextStyle(
                                      color: shadColorScheme.secondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "(${media.voteCount}评分)",
                                    style: TextStyle(
                                      color: shadColorScheme.secondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                    onTap: onTap != null ? () async => onTap!() : null,
                    onLongPress: () async => await onSearch(media),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: EllipsisText(
                      text: media.overview.trim(),
                      maxLines: 2,
                      ellipsis: '...',
                      style: TextStyle(
                        fontSize: 11,
                        color: shadColorScheme.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
