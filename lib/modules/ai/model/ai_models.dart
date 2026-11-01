// ─────────────────────────────────────────────────────────────
// AI 配置
// ─────────────────────────────────────────────────────────────

class AiConfig {
  final bool enabled;
  final String provider;
  final String baseUrl;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;
  final int timeoutSeconds;
  final int dailyTokenLimit;
  final int concurrency;
  final bool allowWriteActions;

  const AiConfig({
    this.enabled = false,
    this.provider = 'openai',
    this.baseUrl = '',
    this.apiKey = '',
    this.model = '',
    this.temperature = 0.2,
    this.maxTokens = 2048,
    this.timeoutSeconds = 60,
    this.dailyTokenLimit = 100000,
    this.concurrency = 3,
    this.allowWriteActions = false,
  });

  factory AiConfig.fromJson(Map<String, dynamic> json) => AiConfig(
        enabled: _bool(json['enabled']),
        provider: _str(json['provider'], 'openai'),
        baseUrl: _str(json['base_url']),
        apiKey: _str(json['api_key']),
        model: _str(json['model']),
        temperature: _num(json['temperature'], 0.2).toDouble(),
        maxTokens: _int(json['max_tokens'], 2048),
        timeoutSeconds: _int(json['timeout_seconds'], 60),
        dailyTokenLimit: _int(json['daily_token_limit'], 100000),
        concurrency: _int(json['concurrency'], 3),
        allowWriteActions: _bool(json['allow_write_actions']),
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'provider': provider,
        'base_url': baseUrl,
        if (apiKey.isNotEmpty) 'api_key': apiKey,
        'model': model,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'timeout_seconds': timeoutSeconds,
        'daily_token_limit': dailyTokenLimit,
        'concurrency': concurrency,
        'allow_write_actions': allowWriteActions,
      };
}

// ─────────────────────────────────────────────────────────────
// AI 测试结果
// ─────────────────────────────────────────────────────────────

class AiTestResult {
  final String text;
  final String model;
  final int promptTokens;
  final int completionTokens;

  const AiTestResult({
    this.text = '',
    this.model = '',
    this.promptTokens = 0,
    this.completionTokens = 0,
  });

  factory AiTestResult.fromJson(Map<String, dynamic> json) => AiTestResult(
        text: _str(json['text']),
        model: _str(json['model']),
        promptTokens: _int(json['prompt_tokens']),
        completionTokens: _int(json['completion_tokens']),
      );
}

// ─────────────────────────────────────────────────────────────
// 项目状态快照
// ─────────────────────────────────────────────────────────────

class AiContextSnapshot {
  final int sitesTotal;
  final int sitesEnabled;
  final int downloadersTotal;
  final int downloadersActive;
  final int scheduleTasks;
  final int rssFeeds;
  final int rssSubscriptions;
  final int recentResults;

  const AiContextSnapshot({
    this.sitesTotal = 0,
    this.sitesEnabled = 0,
    this.downloadersTotal = 0,
    this.downloadersActive = 0,
    this.scheduleTasks = 0,
    this.rssFeeds = 0,
    this.rssSubscriptions = 0,
    this.recentResults = 0,
  });

  factory AiContextSnapshot.fromJson(Map<String, dynamic> json) => AiContextSnapshot(
        sitesTotal: _int(json['sites_total']),
        sitesEnabled: _int(json['sites_enabled']),
        downloadersTotal: _int(json['downloaders_total']),
        downloadersActive: _int(json['downloaders_active']),
        scheduleTasks: _int(json['schedule_tasks']),
        rssFeeds: _int(json['rss_feeds']),
        rssSubscriptions: _int(json['rss_subscriptions']),
        recentResults: _int(json['recent_results']),
      );
}

// ─────────────────────────────────────────────────────────────
// AI 助手回答
// ─────────────────────────────────────────────────────────────

class AiChatResult {
  final String text;
  final String model;
  final int promptTokens;
  final int completionTokens;
  final AiContextSnapshot context;

  const AiChatResult({
    this.text = '',
    this.model = '',
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.context = const AiContextSnapshot(),
  });

  factory AiChatResult.fromJson(Map<String, dynamic> json) => AiChatResult(
        text: _str(json['text']),
        model: _str(json['model']),
        promptTokens: _int(json['prompt_tokens']),
        completionTokens: _int(json['completion_tokens']),
        context: json['context'] is Map
            ? AiContextSnapshot.fromJson(Map<String, dynamic>.from(json['context'] as Map))
            : const AiContextSnapshot(),
      );
}

// ─────────────────────────────────────────────────────────────
// 调用用量
// ─────────────────────────────────────────────────────────────

class AiUsage {
  final String day;
  final int promptTokens;
  final int completionTokens;
  final int dailyLimit;

  const AiUsage({
    this.day = '',
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.dailyLimit = 100000,
  });

  int get totalTokens => promptTokens + completionTokens;

  double get ratio => dailyLimit <= 0 ? 0 : totalTokens / dailyLimit;

  factory AiUsage.fromJson(Map<String, dynamic> json) => AiUsage(
        day: _str(json['day']),
        promptTokens: _int(json['prompt_tokens']),
        completionTokens: _int(json['completion_tokens']),
        dailyLimit: _int(json['daily_limit'], 100000),
      );
}

// ─────────────────────────────────────────────────────────────
// 状态诊断
// ─────────────────────────────────────────────────────────────

class AiFinding {
  final String level;
  final String code;
  final String message;

  const AiFinding({this.level = '', this.code = '', this.message = ''});

  bool get isError => level == 'error';
  bool get isWarning => level == 'warning';

  factory AiFinding.fromJson(Map<String, dynamic> json) => AiFinding(
        level: _str(json['level']),
        code: _str(json['code']),
        message: _str(json['message']),
      );
}

class AiDiagnosisReport {
  final AiContextSnapshot context;
  final List<AiFinding> findings;

  const AiDiagnosisReport({this.context = const AiContextSnapshot(), this.findings = const []});

  factory AiDiagnosisReport.fromJson(Map<String, dynamic> json) => AiDiagnosisReport(
        context: json['context'] is Map
            ? AiContextSnapshot.fromJson(Map<String, dynamic>.from(json['context'] as Map))
            : const AiContextSnapshot(),
        findings: json['findings'] is List
            ? (json['findings'] as List)
                .whereType<Map>()
                .map((e) => AiFinding.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : const [],
      );
}

// ─────────────────────────────────────────────────────────────
// 解析工具
// ─────────────────────────────────────────────────────────────

String _str(dynamic v, [String fallback = '']) => v?.toString() ?? fallback;

bool _bool(dynamic v) => v == true || v == 1 || v == '1' || v == 'true';

int _int(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

num _num(dynamic v, [num fallback = 0]) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? fallback;
  return fallback;
}

// ─────────────────────────────────────────────────────────────
// 聊天历史
// ─────────────────────────────────────────────────────────────

class AiChatHistoryItem {
  final int id;
  final String role;
  final String content;
  final String status;
  final String createdAt;
  final AiContextSnapshot context;

  const AiChatHistoryItem({
    this.id = 0,
    this.role = '',
    this.content = '',
    this.status = '',
    this.createdAt = '',
    this.context = const AiContextSnapshot(),
  });

  bool get isUser => role == 'user';

  factory AiChatHistoryItem.fromJson(Map<String, dynamic> json) => AiChatHistoryItem(
        id: _int(json['id']),
        role: _str(json['role']),
        content: _str(json['content']),
        status: _str(json['status']),
        createdAt: _str(json['created_at']),
        context: json['context'] is Map
            ? AiContextSnapshot.fromJson(Map<String, dynamic>.from(json['context'] as Map))
            : const AiContextSnapshot(),
      );
}

class AiChatHistoryPage {
  final String date;
  final List<AiChatHistoryItem> items;
  final int nextCursor;
  final bool hasMore;

  const AiChatHistoryPage({
    this.date = '',
    this.items = const [],
    this.nextCursor = 0,
    this.hasMore = false,
  });

  factory AiChatHistoryPage.fromJson(Map<String, dynamic> json) => AiChatHistoryPage(
        date: _str(json['date']),
        items: json['items'] is List
            ? (json['items'] as List)
                .whereType<Map>()
                .map((e) => AiChatHistoryItem.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : const [],
        nextCursor: _int(json['next_cursor']),
        hasMore: _bool(json['has_more']),
      );
}

class AiChatHistoryDates {
  final List<String> dates;

  const AiChatHistoryDates({this.dates = const []});

  factory AiChatHistoryDates.fromJson(Map<String, dynamic> json) => AiChatHistoryDates(
        dates: json['dates'] is List
            ? (json['dates'] as List).map((e) => e.toString()).toList()
            : const [],
      );
}
