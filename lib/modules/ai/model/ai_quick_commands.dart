/// AI 助手快速指令。
///
/// 输入 `/` 触发自动补全；点击指令或建议后把 [prompt] 填入输入框。
class AiQuickCommand {
  /// 触发指令，如 `/站点状态`。
  final String command;

  /// 展示名称。
  final String label;

  /// 说明文字。
  final String description;

  /// 选中后填入输入框的完整提问。
  final String prompt;

  const AiQuickCommand({
    required this.command,
    required this.label,
    required this.description,
    required this.prompt,
  });

  /// 去掉前导 `/` 的指令关键词。
  String get keyword => command.startsWith('/') ? command.substring(1) : command;
}

const List<AiQuickCommand> kAiQuickCommands = [
  AiQuickCommand(
    command: '/站点状态',
    label: '站点状态',
    description: '分析站点整体状态与异常',
    prompt: '请分析当前站点的整体状态，列出异常站点及可能原因。',
  ),
  AiQuickCommand(
    command: '/签到检查',
    label: '签到检查',
    description: '今日签到失败站点与原因',
    prompt: '今天有哪些站点签到失败？失败原因分别是什么？',
  ),
  AiQuickCommand(
    command: '/下载器',
    label: '下载器',
    description: '下载器运行状态与异常',
    prompt: '下载器当前运行状态如何？有哪些异常或离线的下载器？',
  ),
  AiQuickCommand(
    command: '/任务',
    label: '任务',
    description: '计划任务执行与失败记录',
    prompt: '最近的计划任务执行情况如何？有哪些失败记录？',
  ),
  AiQuickCommand(
    command: '/RSS',
    label: 'RSS',
    description: 'RSS 源与订阅状态',
    prompt: 'RSS 订阅当前状态如何？有哪些 RSS 源或订阅存在异常？',
  ),
  AiQuickCommand(
    command: '/总结',
    label: '总结',
    description: '生成运行总结',
    prompt: '请根据当前项目状态生成一份简要的运行总结。',
  ),
  AiQuickCommand(
    command: '/优化',
    label: '优化',
    description: '给出运维优化建议',
    prompt: '根据当前项目状态给出运维优化建议。',
  ),
  AiQuickCommand(
    command: '/安全',
    label: '安全',
    description: '检查配置安全风险',
    prompt: '检查当前配置是否存在安全风险或薄弱项。',
  ),
];

/// 根据输入文本计算需要展示的快速指令建议。
///
/// 仅当文本以 `/` 开头时返回匹配项；`/关键字` 后可继续输入空格与补充描述。
List<AiQuickCommand> matchQuickCommands(String input) {
  final text = input.trimLeft();
  if (!text.startsWith('/')) return const [];
  final body = text.substring(1);
  final query = body.split(RegExp(r'\s')).first.toLowerCase();
  if (query.isEmpty) return kAiQuickCommands;
  return kAiQuickCommands
      .where((c) => c.keyword.toLowerCase().contains(query) || c.label.toLowerCase().contains(query))
      .toList();
}
