import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../common/card_view.dart';
import '../../../../utils/storage.dart';

class DoubanItemView extends StatelessWidget {
  final List<dynamic> mediaItems;
  final void Function(dynamic) onTap;
  final void Function(dynamic) onLongPress;

  final String cacheServer = 'https://images.weserv.nl/?url=';

  const DoubanItemView({
    super.key,
    required this.mediaItems,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    double itemWidth = SPUtil.getDouble('tmdb_media_item_width', defaultValue: 120);
    double itemHeight = itemWidth * 1.5;
    return CustomCard(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 12,
            runSpacing: 12,
            children: mediaItems
                .map((e) => InkWell(
                      onTap: () => onTap(e),
                      onLongPress: () => onLongPress(e),
                      child: SizedBox(
                        width: itemWidth,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                httpHeaders: {
                                  'Referer': 'https://movie.douban.com/',
                                  'User-Agent':
                                      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0',
                                },
                                imageUrl: '${e.poster}',
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Image.asset('assets/images/douban.png'),
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
    );
  }
}
