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
  static const String SERVER_RESTART = "/api/auth/server/restart";
  static const String ADMIN_USER = "/api/auth/admin/users";
  static const String ADMIN_SEND_TOKEN = "/api/auth/admin/send";
  static const String ADMIN_RESET_TOKEN = "/api/auth/admin/reset/token";
  static const String ADMIN_RESET_INVITE = "/api/auth/admin/reset/invite/";
  static const String APP_VERSION_CACHE_CLEAR = "/api/auth/admin/cache/clear";
  static const String QINIU_UPLOAD_FILES = "/api/source/qiniu/upload_files";
  static const String APP_VERSION_LATEST = "/api/app/version/latest";
  static const String APP_VERSION_LIST = "/api/app/version/list";

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
  static const String TELEGRAM_WEBHOOK = '/api/option/tg/webhook';

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
  static const String DOWNLOADER_TOGGLE_SPEED_LIMIT_ENABLE = "/api/option/downloaders/toggle_speed_limit/";
  static const String DOWNLOADER_MAIN = "/api/option/downloaders/main/";
  static const String DOWNLOADER_TEST = "/api/option/downloaders/test/";
  static const String DOWNLOADER_TAGS = "/api/option/downloaders/tags/";
  static const String DOWNLOADER_TRACKER_REPLACE = "/api/option/downloaders/trackers/replace/";
  static const String DOWNLOADER_SET_TAGS = "/api/option/downloaders/tags/set/";
  static const String DOWNLOADER_CATEGORY = "/api/option/downloaders/category/";
  static const String DOWNLOADER_SET_CATEGORY = "/api/option/downloaders/category/set/";
  static const String DOWNLOADER_CONTROL = "/api/option/downloaders/control/";
  static const String DOWNLOADER_PUSH_TORRENT = "/api/option/push_torrent";
  static const String DOWNLOADER_PREFERENCES = "/api/option/downloaders/preferences/";
  static const String DOWNLOADER_TORRENT_DETAIL = "/api/option/downloaders/torrent/detail/";

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
  static const String TASK_RESULTS = "/api/option/task-results/";

  static const String SYSTEM_CONFIG = "/api/auth/config";
  static const String SYSTEM_LOGGING = "/api/logging";
  static const String setupStatus = "/api/setup/status";
  static const String setupDatabase = "/api/setup/database";
  static const String setupInit = "/api/setup/init";
  static const String setupImport = "/api/setup/import";
  static const String setupSqlite = "/api/setup/sqlite";
  static const String setupBackup = "/api/setup/backup";

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
  static const String DOUBAN_NOW_PLAYING = "/api/option/douban/now_playing";
  static const String DOUBAN_RANK = "/api/option/douban/rank";
  static const String DOUBAN_SEARCH = "/api/option/douban/search";

  // tmdb API
  static const String TMDB_SEARCH = "/api/tmdb/search";
  static const String TMDB_PERSON = "/api/tmdb/person/";
  static const String TMDB_MOVIE_INFO = "/api/tmdb/movie/";
  static const String TMDB_TV_INFO = "/api/tmdb/tv/";
  static const String TMDB_SEASON = "/api/tmdb/season/{tv_id}/{season_id}";
  static const String TMDB_EPISODE = "/api/tmdb/episode/{tv_id}/{season_id}/{episode_id}";
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

  static String describePath(String rawPath) => _describeApiPath(rawPath);
}

String _describeApiPath(String rawPath) {
  final path = _normalizeApiPath(rawPath);
  final exact = _apiEndpointNames[path];
  if (exact != null) return exact;

  for (final entry in _apiEndpointPrefixNames) {
    if (path.startsWith(entry.key)) return entry.value;
  }

  if (path.startsWith('/api/mysite/')) return '站点数据接口';
  if (path.startsWith('/api/option/downloaders/')) return '下载器接口';
  if (path.startsWith('/api/option/douban/')) return '豆瓣接口';
  if (path.startsWith('/api/option/')) return '选项设置接口';
  if (path.startsWith('/api/auth/admin/')) return '管理员接口';
  if (path.startsWith('/api/auth/')) return '认证接口';
  if (path.startsWith('/api/tmdb/')) return 'TMDB 接口';
  if (path.startsWith('/api/source/')) return '资源管理接口';
  if (path.startsWith('/api/flower/')) return '任务监控接口';
  if (path.startsWith('/api/ws/')) return '实时数据接口';
  if (path.startsWith('/api/setup/')) return '系统初始化接口';
  return '接口请求';
}

String _normalizeApiPath(String rawPath) {
  final uri = Uri.tryParse(rawPath);
  final path = uri?.path.isNotEmpty == true ? uri!.path : rawPath;
  if (path.startsWith('/')) return path;
  return '/$path';
}

const _apiEndpointNames = <String, String>{
  API.TOKEN_PAIR: '登录令牌接口',
  API.TOKEN_REFRESH: '令牌刷新接口',
  API.TOKEN_VERIFY: '令牌校验接口',
  API.LOGIN_URL: '登录接口',
  API.USER_INFO: '用户信息接口',
  API.UPDATE_LOG: '后端更新日志接口',
  API.UPDATE_SITES: '站点配置更新日志接口',
  API.AUTH_INFO: '认证信息接口',
  API.AUTH_USER: '认证用户接口',
  API.SERVER_STATUS: '服务器状态接口',
  API.SERVER_RESTART: '服务器重启接口',
  API.ADMIN_USER: '管理员用户接口',
  API.ADMIN_SEND_TOKEN: '授权邮件接口',
  API.ADMIN_RESET_TOKEN: '重置令牌接口',
  API.QINIU_UPLOAD_FILES: '七牛上传接口',
  API.APP_VERSION_LATEST: 'APP 最新版本接口',
  API.APP_VERSION_LIST: 'APP 版本列表接口',
  API.APP_VERSION_CACHE_CLEAR: 'APP 版本缓存清理接口',
  API.DASHBOARD_DATA: '仪表盘数据接口',
  API.WEBSITE_LIST: '站点配置列表接口',
  API.WEBSITE_TO_ADD: '待添加站点接口',
  API.MYSITE_LIST: '我的站点接口',
  API.CLEAR_CACHE: '缓存清理接口',
  API.Import_Custom_Site_Toml: '站点配置上传接口',
  API.WEBSITE_SEARCH: '站点搜索接口',
  API.Bulk_UPGRADE_API: '站点批量更新接口',
  API.IMPORT_COOKIE_PTPP: 'PTPP 站点导入接口',
  API.IMPORT_COOKIE_PTD: 'PT-depiler 站点导入接口',
  API.IMPORT_COOKIE_CLOUD: 'CookieCloud 同步接口',
  API.NOTIFY_TEST: '通知测试接口',
  API.TELEGRAM_WEBHOOK: 'Telegram Webhook 接口',
  API.DOWNLOADER_LIST: '下载器列表接口',
  API.DOWNLOADER_REAPEAT: '下载器辅种接口',
  API.DOWNLOADER_PATHS: '下载路径接口',
  API.DOWNLOADER_TORRENTS: '下载器实时数据接口',
  API.DOWNLOADER_STATUS: '下载器速度接口',
  API.DOWNLOADER_PUSH_TORRENT: '种子推送接口',
  API.PUSH_TORRENT_URL: '种子推送接口',
  API.PUSH_TORRENT_MONKEY_URL: '脚本种子推送接口',
  API.WEBSITE_TRACKERS_LIST: 'Tracker 列表接口',
  API.MYSITE_TORRENTS_RSS: '站点种子 RSS 接口',
  API.MYSITE_TORRENTS_UPDATE: '站点种子刷新接口',
  API.MYSITE_IMPORT: '站点导入接口',
  API.MYSITE_STATUS_CHART: '站点状态图表接口',
  API.MYSITE_STATUS_CHART_V2: '站点状态图表接口',
  API.MYSITE_SORT: '站点排序接口',
  API.MYSITE_STATUS_TODAY: '今日站点状态接口',
  API.MYSITE_TORRENTS: '站点种子列表接口',
  API.MYSITE_TORRENTS_GET: '站点种子获取接口',
  API.FLOWER_TASKS: '任务列表接口',
  API.FLOWER_TASKS_INFO: '任务详情接口',
  API.FLOWER_TASKS_RESULT: '任务结果接口',
  API.FLOWER_TASKS_ABORT: '任务中止接口',
  API.FLOWER_TASKS_REVOKE: '任务撤销接口',
  API.OPTION_OPERATE: '选项配置接口',
  API.SPEED_TEST: '网络测速接口',
  API.TASK_LIST: '计划任务列表接口',
  API.TASK_OPERATE: '计划任务配置接口',
  API.CRONTAB_LIST: '定时任务接口',
  API.TASK_EXEC_URL: '任务执行接口',
  API.TASK_RESULTS: '任务执行记录接口',
  API.SYSTEM_CONFIG: '系统配置接口',
  API.SYSTEM_LOGGING: '系统日志接口',
  API.setupStatus: '初始化状态接口',
  API.setupDatabase: '初始化数据库接口',
  API.setupInit: '初始化配置接口',
  API.setupImport: '旧数据导入接口',
  API.setupSqlite: '旧数据库导入接口',
  API.setupBackup: '数据备份接口',
  API.SUB_RSS: 'RSS 订阅接口',
  API.SUB_SUB: '订阅配置接口',
  API.SUB_PLAN: '订阅计划接口',
  API.SUB_TAG: '订阅标签接口',
  API.IMPORT_SUB_TAG: '订阅标签导入接口',
  API.SUB_HISTORY: '订阅历史接口',
  API.NOTICE_HISTORY: '消息记录接口',
  API.NOTICE_READ_ALL: '消息全部已读接口',
  API.DOUBAN_TOP250: '豆瓣 Top250 接口',
  API.DOUBAN_TAGS: '豆瓣标签接口',
  API.DOUBAN_HOT: '豆瓣热门接口',
  API.DOUBAN_NOW_PLAYING: '豆瓣正在热映接口',
  API.DOUBAN_RANK: '豆瓣榜单接口',
  API.DOUBAN_SEARCH: '豆瓣搜索接口',
  API.TMDB_SEARCH: 'TMDB 搜索接口',
  API.TMDB_ON_THE_AIR: 'TMDB 在播剧集接口',
  API.TMDB_AIRING_TODAY: 'TMDB 今日播出接口',
  API.TMDB_UPCOMING_MOVIES: 'TMDB 即将上映接口',
  API.TMDB_PLAYING_MOVIES: 'TMDB 正在上映接口',
  API.TMDB_POPULAR_TVS: 'TMDB 热门剧集接口',
  API.TMDB_POPULAR_MOVIES: 'TMDB 热门电影接口',
  API.TMDB_TOP_TVS: 'TMDB 高分剧集接口',
  API.TMDB_TOP_MOVIES: 'TMDB 高分电影接口',
  API.TMDB_LATEST_MOVIES: 'TMDB 最新电影接口',
  API.TMDB_LATEST_TV: 'TMDB 最新剧集接口',
  API.TMDB_MATCH_MOVIE: 'TMDB 电影匹配接口',
  API.TMDB_MATCH_TV: 'TMDB 剧集匹配接口',
  API.TMDB_MATCH_SAVE: 'TMDB 匹配保存接口',
  API.SOURCE_LIST: '资源列表接口',
  API.SOURCE_HARD_LINK: '硬链接接口',
  API.SOURCE_URL: '资源链接接口',
  API.SOURCE_ACCESS: '资源访问接口',
  API.SOURCE_OPERATE: '资源操作接口',
};

const _apiEndpointPrefixNames = <MapEntry<String, String>>[
  MapEntry(API.ADMIN_RESET_INVITE, '重置邀请码接口'),
  MapEntry(API.MYSITE_STATUS_OPERATE, '站点数据刷新接口'),
  MapEntry(API.MYSITE_SIGNIN_OPERATE, '站点签到接口'),
  MapEntry(API.MYSITE_REPEAT_OPERATE, '站点辅种接口'),
  MapEntry(API.DOUBAN_CELEBRITY, '豆瓣人物接口'),
  MapEntry(API.DOUBAN_SUBJECT, '豆瓣条目接口'),
  MapEntry(API.TMDB_PERSON, 'TMDB 人物接口'),
  MapEntry(API.TMDB_MOVIE_INFO, 'TMDB 电影详情接口'),
  MapEntry(API.TMDB_TV_INFO, 'TMDB 剧集详情接口'),
  MapEntry(API.DOWNLOADER_TOGGLE_SPEED_LIMIT_ENABLE, '下载器限速开关接口'),
  MapEntry(API.DOWNLOADER_MAIN, '主下载器设置接口'),
  MapEntry(API.DOWNLOADER_TEST, '下载器测试接口'),
  MapEntry(API.DOWNLOADER_TAGS, '下载器标签接口'),
  MapEntry(API.DOWNLOADER_TRACKER_REPLACE, 'Tracker 替换接口'),
  MapEntry(API.DOWNLOADER_SET_TAGS, '下载器标签设置接口'),
  MapEntry(API.DOWNLOADER_CATEGORY, '下载器分类接口'),
  MapEntry(API.DOWNLOADER_SET_CATEGORY, '下载器分类设置接口'),
  MapEntry(API.DOWNLOADER_CONTROL, '下载器控制接口'),
  MapEntry(API.DOWNLOADER_PREFERENCES, '下载器偏好设置接口'),
  MapEntry(API.DOWNLOADER_TORRENT_DETAIL, '下载器种子详情接口'),
  MapEntry(API.DOCKER_UPDATE, '程序更新接口'),
  MapEntry(API.NOTICE_HISTORY, '消息记录接口'),
];
