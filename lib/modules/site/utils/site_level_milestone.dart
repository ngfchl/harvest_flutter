import '../model/site_config.dart';
import '../model/site_info.dart';

enum SiteLevelMilestoneType {
  keepAccount('保号', '已达到保号等级'),
  graduation('毕业', '已达到毕业等级');

  final String label;
  final String tooltip;

  const SiteLevelMilestoneType(this.label, this.tooltip);
}

SiteLevelMilestoneType? siteLevelMilestone(
  WebSite? config,
  SiteDailyStatus? status,
) {
  final currentName = status?.myLevel.trim() ?? '';
  final levelMap = config?.level ?? const <String, SiteLevel>{};
  if (currentName.isEmpty || levelMap.isEmpty) return null;

  MapEntry<String, SiteLevel>? currentEntry;
  for (final entry in levelMap.entries) {
    if (entry.key == currentName || entry.value.level == currentName) {
      currentEntry = entry;
      break;
    }
  }
  if (currentEntry == null) return null;

  final currentId = currentEntry.value.levelId;
  final achievedLevels = levelMap.entries
      .where((entry) {
        final levelId = entry.value.levelId;
        if (currentId > 0 && levelId > 0) return levelId <= currentId;
        return entry.key == currentEntry?.key;
      })
      .map((entry) => entry.value)
      .toList();

  if (achievedLevels.any((level) => level.graduation)) {
    return SiteLevelMilestoneType.graduation;
  }
  if (achievedLevels.any((level) => level.keepAccount)) {
    return SiteLevelMilestoneType.keepAccount;
  }
  return null;
}
