class API {
  // Token
  static const String TOKEN_PAIR = "/api/token/pair";
  static const String TOKEN_REFRESH = "/api/token/refresh";
  static const String TOKEN_VERIFY = "/api/token/verify";

  // 登录接口
  static const String LOGIN_URL = "/api/auth/login";
  static const String USER_INFO = "/api/auth/userinfo";
  static const String UPDATE_LOG = "/api/auth/update/log";
  static const String UPDATE_SITES = "/api/auth/update/sites";
  static const String AUTH_INFO = "/api/auth/auth_info";
  static const String AUTH_USER = "/api/auth/user";
  static const String SERVER_STATUS = "/api/auth/server/status";
  static const String SERVICES_STATUS = "/api/auth/services/status";
  static const String ADMIN_USER = "/api/auth/admin/users";
  static const String ADMIN_SEND_TOKEN = "/api/auth/admin/send";
  static const String ADMIN_RESET_TOKEN = "/api/auth/admin/reset/token";
  static const String ADMIN_RESET_INVITE = "/api/auth/admin/reset/invite/";
  static const String QINIU_UPLOAD_FILES = "/api/source/qiniu/upload_files";

  // 我的站点列表增删改查
  static const String DASHBOARD_DATA = "/api/mysite/dashboard";

  // 获取所有站点配置文件列表的接口
  static const String WEBSITE_LIST = "/api/mysite/website";

  // 获取未添加站点名称的接口
  static const String WEBSITE_TO_ADD = "/api/mysite/website/add";

  // 我的站点信息的增删改查接口
  static const String MYSITE_LIST = "/api/mysite/mysite";

  // 清理缓存
  static const String CLEAR_CACHE = "/api/mysite/cache/clear";

  // 上传单个站点配置文件的接口
  static const String Import_Custom_Site_Toml = "/api/mysite/import/toml";

  // 执行获取站点信息
  static const String MYSITE_STATUS_OPERATE = "/api/mysite/info/";

  // 执行签到
  static const String MYSITE_SIGNIN_OPERATE = "/api/mysite/sign/";

  // 执行辅种
  static const String MYSITE_REPEAT_OPERATE = "/api/mysite/repeat/";

  // 搜索
  static const String WEBSITE_SEARCH = "/api/mysite/search";

  // 批量操作
  static const String Bulk_UPGRADE_API = "/api/mysite/bulk/upgrade";

  // PTPP
  static const String IMPORT_COOKIE_PTPP = "/api/mysite/cookie/ptpp";

  // PT-depiler
  static const String IMPORT_COOKIE_PTD = "/api/mysite/cookie/ptd";

  // CookieCloud
  static const String IMPORT_COOKIE_CLOUD = "/api/mysite/cookie/cloud";

  // 通知测试
  static const String NOTIFY_TEST = "/api/option/test";
  static const String TELEGRAM_WEBHOOK = 'option/tg/webhook';

  // 更新 Docker
  static const String DOCKER_UPDATE = "/api/option/update/";

  // 下载器列表
  static const String DOWNLOADER_LIST = "/api/option/downloaders";

  // 单个下载器辅种
  static const String DOWNLOADER_REAPEAT = "/api/option/repeat";
  static const String DOWNLOADER_PATHS = "/api/option/paths";

  // 下载器分类列表
  static const String DOWNLOADER_TORRENTS = "/api/ws/downloader";
  static const String DOWNLOADER_STATUS = "/api/ws/downloader/speed";
  static const String DOWNLOADER_TOGGLE_SPEED_LIMIT_ENABLE =
      "/api/option/downloaders/toggle_speed_limit/";
  static const String DOWNLOADER_MAIN = "/api/option/downloaders/main/";
  static const String DOWNLOADER_TEST = "/api/option/downloaders/test/";
  static const String DOWNLOADER_TAGS = "/api/option/downloaders/tags/";
  static const String DOWNLOADER_TRACKER_REPLACE =
      "/api/option/downloaders/trackers/replace/";
  static const String DOWNLOADER_SET_TAGS = "/api/option/downloaders/tags/set/";
  static const String DOWNLOADER_CATEGORY = "/api/option/downloaders/category/";
  static const String DOWNLOADER_SET_CATEGORY =
      "/api/option/downloaders/category/set/";
  static const String DOWNLOADER_CONTROL = "/api/option/downloaders/control/";
  static const String DOWNLOADER_PUSH_TORRENT = "/api/option/push_torrent";
  static const String DOWNLOADER_PREFERENCES =
      "/api/option/downloaders/preferences/";
  static const String DOWNLOADER_TORRENT_DETAIL =
      "/api/option/downloaders/torrent/detail/";

  // 推送种子到下载器
  static const String PUSH_TORRENT_URL = "/api/option/push_torrent/";
  static const String PUSH_TORRENT_MONKEY_URL = "/api/option/push_monkey/";

  // 下载器种子文件夹列表

  static const String WEBSITE_TRACKERS_LIST = "/api/website/trackers";

  static const String MYSITE_TORRENTS_RSS = "/api/mysite/torrents/rss";
  static const String MYSITE_TORRENTS_UPDATE = "/api/mysite/torrents/update";
  static const String MYSITE_IMPORT = "/api/mysite/import";
  static const String MYSITE_STATUS_CHART = "/api/mysite/status/chart";
  static const String MYSITE_STATUS_CHART_V2 = "/api/mysite/status/chart/v2";
  static const String MYSITE_SORT = "/api/mysite/sort";
  static const String MYSITE_STATUS_TODAY = "/api/mysite/status/today";

  // 种子列表
  static const String MYSITE_TORRENTS = "/api/mysite/torrents";
  static const String MYSITE_TORRENTS_GET = "/api/mysite/torrents/get";

  // Flower
  static const String FLOWER_TASKS = "/api/flower/api/tasks";
  static const String FLOWER_TASKS_INFO = "/api/flower/api/task/info";
  static const String FLOWER_TASKS_RESULT = "/api/flower/api/task/result";
  static const String FLOWER_TASKS_ABORT = "/api/flower/api/task/abort";
  static const String FLOWER_TASKS_REVOKE = "/api/flower/api/task/revoke";

  // 任务列表
  static const String OPTION_OPERATE = "/api/option/options";
  static const String NOTICE_TEST = "/api/option/test";
  static const String SPEED_TEST = "/api/option/speedtest";
  static const String TASK_LIST = "/api/option/tasks";
  static const String TASK_OPERATE = "/api/option/schedule";
  static const String CRONTAB_LIST = "/api/option/crontabs";
  static const String TASK_EXEC_URL = "/api/option/exec";

  static const String SYSTEM_CONFIG = "/api/auth/config";
  static const String SYSTEM_LOGGING = "/api/logging";

  /// 订阅相关
  static const String SUB_RSS = "/api/option/rss";
  static const String SUB_SUB = "/api/option/sub";
  static const String SUB_PLAN = "/api/option/plan";
  static const String SUB_TAG = "/api/option/tags";
  static const String IMPORT_SUB_TAG = "/api/option/import/tags";
  static const String SUB_HISTORY = "/api/option/sub_history";

  /// 消息记录
  static const String NOTICE_HISTORY = "/api/option/notice";
  static const String NOTICE_READ_ALL = "/api/option/notice/read";

  static String noticeDetail(int id) => "$NOTICE_HISTORY/$id";

  static String noticeRead(int id) => "$NOTICE_HISTORY/$id/read";

  /// 豆瓣 API
  static const String DOUBAN_TOP250 = "/api/option/douban/top250";
  static const String DOUBAN_CELEBRITY = "/api/option/douban/celebrity/";
  static const String DOUBAN_SUBJECT = "/api/option/douban/subject/";
  static const String DOUBAN_TAGS = "/api/option/douban/tags";
  static const String DOUBAN_HOT = "/api/option/douban/hot";
  static const String DOUBAN_RANK = "/api/option/douban/rank";
  static const String DOUBAN_SEARCH = "/api/option/douban/search";

  // tmdb API
  static const String TMDB_SEARCH = "/api/tmdb/search";
  static const String TMDB_PERSON = "/api/tmdb/person/";
  static const String TMDB_MOVIE_INFO = "/api/tmdb/movie/";
  static const String TMDB_TV_INFO = "/api/tmdb/tv/";
  static const String TMDB_SEASON = "/api/tmdb/season/{tv_id}/{season_id}";
  static const String TMDB_EPISODE =
      "/api/tmdb/episode/{tv_id}/{season_id}/{episode_id}";
  static const String TMDB_ON_THE_AIR = "/api/tmdb/on_the_air/tvs";
  static const String TMDB_AIRING_TODAY = "/api/tmdb/airing_today/tvs";
  static const String TMDB_UPCOMING_MOVIES = "/api/tmdb/upcoming/movies";
  static const String TMDB_PLAYING_MOVIES = "/api/tmdb//playing/movies";
  static const String TMDB_POPULAR_TVS = "/api/tmdb/popular/tvs";
  static const String TMDB_POPULAR_MOVIES = "/api/tmdb/popular/movies";
  static const String TMDB_TOP_TVS = "/api/tmdb/top_rated/tvs";
  static const String TMDB_TOP_MOVIES = "/api/tmdb/top_rated/movies";
  static const String TMDB_LATEST_MOVIES = "/api/tmdb/latest/movies";
  static const String TMDB_LATEST_TV = "/api/tmdb/latest/tv";
  static const String TMDB_MATCH_MOVIE = "/api/tmdb/match/movie";
  static const String TMDB_MATCH_TV = "/api/tmdb/match/tv";
  static const String TMDB_MATCH_SAVE = "/api/tmdb/match/save";

  // 资源管理
  static const String SOURCE_LIST = "/api/source/all";
  static const String SOURCE_HARD_LINK = "/api/source/hard_link";
  static const String SOURCE_URL = "/api/source/file/url";
  static const String SOURCE_ACCESS = "/api/source/file/access";
  static const String SOURCE_OPERATE = "/api/source/file/operate";
}
