class Api {
  // 登录接口
  static const String LOGIN_URL = "auth/login";
  static const String USER_INFO = "auth/userinfo";

  // 我的站点列表增删改查
  static const String WEBSITE_LIST = "mysite/website";
  static const String MYSITE_LIST = "mysite/mysite";
  static const String CLEAR_CACHE = "mysite/cache/clear";

  // 站点信息
  static const String MYSITE_STATUS_OPERATE = "mysite/info";

  // 签到
  static const String MYSITE_SIGNIN_OPERATE = "mysite/sign";

  // 搜索
  static const String WEBSITE_SEARCH = "mysite/search";

  // PTPP
  static const String IMPORT_COOKIE_PTPP = "mysite/cookie/ptpp";

  // CookieCloud
  static const String IMPORT_COOKIE_CLOUD = "mysite/cookie/cloud";

  // 通知测试
  static const String NOTIFY_TEST = "option/test";

  // 下载器列表
  static const String DOWNLOADER_LIST = "option/downloaders";

  // 单个下载器辅种
  static const String DOWNLOADER_REAPEAT = "option/repeat";
  static const String DOWNLOADER_PATHS = "option/paths";

  // 下载器分类列表
  static const String DOWNLOADER_CATEGORIES = "option/downloaders/categories";

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

  // 推送种子到下载器
  static const String PUSH_TORRENT_URL = "/mysite/push_torrent";

  // 任务列表
  static const String OPTION_OPERATE = "option/options";
  static const String NOTICE_TEST = "option/test";
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
  static const String SUB_HISTORY = "option/sub_history";

  /// 豆瓣 API
  static const String DOUBAN_TOP250 = "option/douban/top250";
  static const String DOUBAN_CELEBRITY = "option/douban/celebrity/";
  static const String DOUBAN_SUBJECT = "option/douban/subject/";
  static const String DOUBAN_TAGS = "option/douban/tags";
  static const String DOUBAN_HOT = "option/douban/hot";
}
