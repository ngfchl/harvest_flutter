class Api {
  // 登录接口
  static const String LOGIN_URL = "auth/login";
  static const String USER_INFO = "auth/userinfo";
  static const String UPDATE_LOG = "auth/update/log";
  static const String AUTH_INFO = "auth/auth_info";
  static const String AUTH_USER = "auth/user";
  static const String INVITE_USER = "auth/try";

  // 我的站点列表增删改查
  static const String WEBSITE_LIST = "mysite/website";
  static const String MYSITE_LIST = "mysite/mysite";
  static const String CLEAR_CACHE = "mysite/cache/clear";

  // 站点信息
  static const String MYSITE_STATUS_OPERATE = "mysite/info";

  // 签到
  static const String MYSITE_SIGNIN_OPERATE = "mysite/sign";

  // 辅种
  static const String MYSITE_REPEAT_OPERATE = "mysite/repeat";

  // 搜索
  static const String WEBSITE_SEARCH = "mysite/search";

  // 批量操作
  static const String Bulk_UPGRADE_API = "mysite/bulk/upgrade";

  // PTPP
  static const String IMPORT_COOKIE_PTPP = "mysite/cookie/ptpp";

  // CookieCloud
  static const String IMPORT_COOKIE_CLOUD = "mysite/cookie/cloud";

  // 通知测试
  static const String NOTIFY_TEST = "option/test";

  // 更新 Docker
  static const String DOCKER_UPDATE = "option/update/";

  // 下载器列表
  static const String DOWNLOADER_LIST = "option/downloaders";

  // 单个下载器辅种
  static const String DOWNLOADER_REAPEAT = "option/repeat";
  static const String DOWNLOADER_PATHS = "option/paths";

  // 下载器分类列表
  static const String DOWNLOADER_TORRENTS = "ws/downloader";
  static const String DOWNLOADER_STATUS = "ws/downloader/speed";
  static const String DOWNLOADER_TOGGLE_SPEED_LIMIT_ENABLE =
      "/option/downloaders/toggle_speed_limit/";
  static const String DOWNLOADER_MAIN = "option/downloaders/main/";
  static const String DOWNLOADER_TEST = "option/downloaders/test/";
  static const String DOWNLOADER_TAGS = "option/downloaders/tags/";
  static const String DOWNLOADER_TRACKER_REPLACE =
      "option/downloaders/trackers/replace/";
  static const String DOWNLOADER_SET_TAGS = "option/downloaders/tags/set/";
  static const String DOWNLOADER_CATEGORY = "option/downloaders/categories/";
  static const String DOWNLOADER_SET_CATEGORY =
      "option/downloaders/category/set/";
  static const String DOWNLOADER_CONTROL = "option/downloaders/control/";
  static const String DOWNLOADER_PUSH_TORRENT = "option/push_torrent";
  static const String DOWNLOADER_PREFERENCES =
      "option/downloaders/preferences/";
  static const String DOWNLOADER_TORRENT_DETAIL =
      "option/downloaders/torrent/detail/";

  // 推送种子到下载器
  static const String PUSH_TORRENT_URL = "option/push_torrent/";

  // 下载器种子文件夹列表

  static const String WEBSITE_TRACKERS_LIST = "website/trackers";

  static const String MYSITE_TORRENTS_RSS = "mysite/torrents/rss";
  static const String MYSITE_TORRENTS_UPDATE = "mysite/torrents/update";
  static const String MYSITE_IMPORT = "mysite/import";
  static const String MYSITE_STATUS_CHART = "mysite/status/chart";
  static const String MYSITE_STATUS_CHART_V2 = "mysite/status/chart/v2";
  static const String MYSITE_SORT = "mysite/sort";
  static const String MYSITE_STATUS_TODAY = "mysite/status/today";

  // 种子列表
  static const String MYSITE_TORRENTS = "mysite/torrents";
  static const String MYSITE_TORRENTS_GET = "mysite/torrents/get";

  // Flower
  static const String FLOWER_TASKS = "/flower/api/tasks";
  static const String FLOWER_TASKS_INFO = "/flower/api/task/info";
  static const String FLOWER_TASKS_RESULT = "/flower/api/task/result";
  static const String FLOWER_TASKS_ABORT = "/flower/api/task/abort";
  static const String FLOWER_TASKS_REVOKE = "/flower/api/task/revoke";

  // 任务列表
  static const String OPTION_OPERATE = "option/options";
  static const String NOTICE_TEST = "option/test";
  static const String SPEED_TEST = "option/speedtest";
  static const String TASK_RESULTS = "option/tasks";
  static const String TASK_OPERATE = "/option/schedule";
  static const String CRONTAB_LIST = "option/crontabs";
  static const String TASK_EXEC_URL = "option/exec";

  static const String SYSTEM_CONFIG = "auth/config";
  static const String SYSTEM_LOGGING = "logging";

  /// 订阅相关
  static const String SUB_RSS = "option/rss";
  static const String SUB_SUB = "option/sub";
  static const String SUB_TAG = "option/tags";
  static const String IMPORT_SUB_TAG = "option/import/tags";
  static const String SUB_HISTORY = "option/sub_history";

  /// 豆瓣 API
  static const String DOUBAN_TOP250 = "option/douban/top250";
  static const String DOUBAN_CELEBRITY = "option/douban/celebrity/";
  static const String DOUBAN_SUBJECT = "option/douban/subject/";
  static const String DOUBAN_TAGS = "option/douban/tags";
  static const String DOUBAN_HOT = "option/douban/hot";
  static const String DOUBAN_RANK = "option/douban/rank";

  // tmdb API
  static const String TMDB_SEARCH = "/tmdb/search";
  static const String TMDB_PERSON = "/tmdb/person/";
  static const String TMDB_MOVIE_INFO = "/tmdb/movie/";
  static const String TMDB_TV_INFO = "/tmdb/tv/";
  static const String TMDB_SEASON = "/tmdb/season/{tv_id}/{season_id}";
  static const String TMDB_EPISODE =
      "/tmdb/episode/{tv_id}/{season_id}/{episode_id}";
  static const String TMDB_ON_THE_AIR = "/tmdb/on_the_air/tvs";
  static const String TMDB_AIRING_TODAY = "/tmdb/airing_today/tvs";
  static const String TMDB_UPCOMING = "/tmdb/upcoming/movies";
  static const String TMDB_POPULAR_TVS = "/tmdb/popular/tvs";
  static const String TMDB_POPULAR_MOVIES = "/tmdb/popular/movies";
  static const String TMDB_TOP_TVS = "/tmdb/top_rated/tvs";
  static const String TMDB_TOP_MOVIES = "/tmdb/top_rated/movies";
  static const String TMDB_LATEST_MOVIES = "/tmdb/latest/movies";
  static const String TMDB_LATEST_TV = "/tmdb/latest/tv";
}
