class Api {
  // 登录接口
  static const String LOGIN_URL = "auth/login";
  static const String USER_INFO = "auth/userinfo";

  // 我的站点列表增删改查
  static const String WEBSITE_LIST = "mysite/website";
  static const String MYSITE_LIST = "mysite/mysite";

  // 站点信息
  static const String MYSITE_STATUS_OPERATE = "mysite/info";

  // 签到
  static const String MYSITE_SIGNIN_OPERATE = "mysite/sign";

  // 搜索
  static const String WEBSITE_SEARCH = "mysite/search";

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
}
