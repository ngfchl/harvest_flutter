import 'package:dio/dio.dart';

import '../../../../utils/logger_helper.dart';
import '../../../../utils/storage.dart';
import 'models/douban.dart';

class DouBanSearchHelper {
  late Dio _dio;

  DouBanSearchHelper() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://frodo.douban.com/',
      headers: {
        'Referer':
            'https://servicewechat.com/wx2f9b06c1de1ccfca/91/page-frame.html',
        'User-Agent': 'MicroMessenger/'
      },
    ));
    _dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseHeader: false,
    ));
  }

  Future<List<DouBanSearchResult>> doSearch({required String q}) async {
    String key = "DouBanSearchResult-$q";
    Map<String, dynamic> data = await SPUtil.getCache(key);
    if (data.isEmpty) {
      var params = {
        "q": q,
        "count": 100,
        "apikey": "0ac44ae016490db2204ce0a042db2916",
      };
      var response = await _dio.get("api/v2/search", queryParameters: params);
      if (response.statusCode != 200) {
        // return CommonResponse.error(msg: "搜索出错啦！${response.statusCode}");
        return [];
      }
      var subjects = response.data['subjects']['items'];
      data = {key: subjects};
      Logger.instance.d(data);
      await SPUtil.setCache(key, data, 60 * 60 * 12);
    }
    Logger.instance.d(data[key]);
    return data[key]
        .where((el) => el['layout'] != 'person' && el['layout'] != 'book')
        .map((el) => DouBanSearchResult.fromJson(el))
        .toList()
        .cast<DouBanSearchResult>();
    """
     {
                "layout": "subject",
                "type_name": "电影",
                "target_id": "26100958",
                "target": {
                    "rating": {
                        "count": 1110877,
                        "max": 10,
                        "star_count": 4.5,
                        "value": 8.5
                    },
                    "controversy_reason": "",
                    "title": "复仇者联盟4：终局之战",
                    "abstract": "",
                    "has_linewatch": true,
                    "uri": "douban://douban.com/movie/26100958",
                    "cover_url": "https://qnmob3.doubanio.com/view/photo/s_ratio_poster/public/p2550755859.jpg?imageView2/0/q/80/w/9999/h/120/format/jpg",
                    "year": "2019",
                    "card_subtitle": "美国 / 剧情 动作 科幻 奇幻 冒险 / 安东尼·罗素 乔·罗素 / 小罗伯特·唐尼 克里斯·埃文斯",
                    "id": "26100958",
                    "null_rating_reason": ""
                },
                "target_type": "movie"
            } 
             {
                "layout": "person",
                "type_name": "人物",
                "target_id": "27260298",
                "target": {
                    "is_followed": false,
                    "sharing_url": "https://www.douban.com/doubanapp/dispatch?fallback=https%3A%2F%2Fwww.douban.com%2Fpersonage%2F27260298&uri=%2Fsubject%2F27260298",
                    "followed_count": 32673,
                    "extra": {
                        "info": [
                            [
                                "性别",
                                "男"
                            ],
                            [
                                "出生日期",
                                "1954年4月7日"
                            ],
                            [
                                "出生地",
                                "中国,香港,太平山"
                            ],
                            [
                                "更多中文名",
                                "房仕龙(本名) / 陈港生(原名) / 元楼(前艺名)"
                            ],
                            [
                                "更多外文名",
                                "Kong-sang Chan(本名) / Pao Pao(昵称) / Sing Lung(昵称) / Y'uen Lo(昵称)"
                            ],
                            [
                                "家庭成员",
                                "林凤娇(妻) / 房祖名(子) / 吴卓林(女)"
                            ],
                            [
                                "IMDb编号",
                                "nm0000329"
                            ],
                            [
                                "厂牌",
                                "滚石唱片 / 乐林文化"
                            ],
                            [
                                "流派",
                                "中国流行 / 流行"
                            ],
                            [
                                "擅长乐器",
                                ""
                            ],
                            [
                                "语言",
                                "普通话 / 粤语 / 英语"
                            ],
                            [
                                "所属乐队",
                                ""
                            ]
                        ],
                        "short_info": "演员 制片人 编剧 作者 音乐人 / 喜剧之王 功夫熊猫 宝贝计划",
                        "header_img": null
                    },
                    "cover_img": {
                        "url": "https://img1.doubanio.com/view/celebrity/l/public/p1542339950.68.jpg",
                        "width": 0,
                        "id": "",
                        "height": 0
                    },
                    "created_at": "2017-11-24 17:05:44",
                    "title": "成龙",
                    "cover": {
                        "large": {
                            "url": "https://img1.doubanio.com/view/celebrity/l/public/p1542339950.68.jpg",
                            "width": 0,
                            "height": 0
                        },
                        "normal": {
                            "url": "https://img1.doubanio.com/view/celebrity/m/public/p1542339950.68.jpg",
                            "width": 0,
                            "height": 0
                        }
                    },
                    "uri": "douban://douban.com/subject/27260298?subtype=person",
                    "latin_title": "Jackie Chan",
                    "subtype": "person",
                    "url": "https://www.douban.com/personage/27260298",
                    "header_bg_color": "#3ba94d",
                    "color_scheme": {
                        "is_dark": true,
                        "primary_color_light": "a56237",
                        "_base_color": [
                            0.065,
                            0.666,
                            0.541
                        ],
                        "secondary_color": "f9f3ef",
                        "_avg_color": [
                            0.065,
                            0.666,
                            0.541
                        ],
                        "primary_color_dark": "7f4b2a"
                    },
                    "type": "subject",
                    "id": "27260298"
                },
                "target_type": "person"
            },
    """;
  }
}
