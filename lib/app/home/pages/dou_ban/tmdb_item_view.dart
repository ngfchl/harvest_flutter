import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:harvest/utils/storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common/card_view.dart';
import '../models/tmdb.dart';

class TmdbItemView extends StatelessWidget {
  final List<MediaItem> results;
  final FutureOr<void> Function()? onRefresh;
  final FutureOr<void> Function()? onLoad;
  final void Function(MediaItem item)? onTap;
  final void Function(MediaItem item)? onLongPress;
  final String urlPrefix = 'https://images.weserv.nl/?url=https://media.themoviedb.org/t/p/w300_and_h450_bestv2';

  const TmdbItemView({
    super.key,
    required this.results,
    this.onRefresh,
    this.onLoad,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    double itemWidth = SPUtil.getDouble('tmdb_media_item_width', defaultValue: 120);
    double itemHeight = itemWidth * 1.5;
    return CustomCard(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(8),
      child: EasyRefresh(
        onRefresh: onRefresh, // 注意：直接传函数，不要包 () =>
        onLoad: onLoad,
        child: SingleChildScrollView(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 8,
              runSpacing: 12,
              children: [
                for (final e in results)
                  InkWell(
                    onTap: () => onTap?.call(e),
                    onLongPress: () => onLongPress?.call(e),
                    child: SizedBox(
                      width: itemWidth,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  imageUrl: '$urlPrefix${e.posterPath}',
                                  placeholder: (context, url) => Center(
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: shadColorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Image.asset('assets/images/tmdb.png'),
                                  width: itemWidth,
                                  height: itemHeight,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                child: Container(
                                  color: Colors.black38,
                                  width: itemWidth,
                                  child: Text(
                                    e.releaseDate.trim(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            color: Colors.black38,
                            width: itemWidth,
                            child: Text(
                              e.title.trim(),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
