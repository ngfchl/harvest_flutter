import '../../../site/model/site_config.dart' as site_config;
import 'torrent_model.dart';

class TorrentSiteMatch {
  final String key;
  final String name;
  final String displayName;
  final String trackerHost;
  final site_config.WebSite site;

  const TorrentSiteMatch({
    required this.key,
    required this.name,
    required this.displayName,
    required this.trackerHost,
    required this.site,
  });
}

class TorrentSiteMatcher {
  final List<_TrackerSiteCandidate> _candidates;

  TorrentSiteMatcher(List<site_config.WebSite> sites)
    : _candidates = _buildCandidates(sites);

  TorrentSiteMatch? match(Torrent torrent) {
    final hosts = _torrentHosts(torrent);
    if (hosts.isEmpty || _candidates.isEmpty) return null;

    for (final host in hosts) {
      for (final candidate in _candidates) {
        if (_hostMatches(host, candidate.host)) {
          return TorrentSiteMatch(
            key: candidate.site.name,
            name: candidate.site.name,
            displayName: candidate.displayName,
            trackerHost: candidate.host,
            site: candidate.site,
          );
        }
      }
    }
    return null;
  }

  static List<_TrackerSiteCandidate> _buildCandidates(
    List<site_config.WebSite> sites,
  ) {
    final candidates = <_TrackerSiteCandidate>[];
    final seen = <String>{};

    for (final site in sites) {
      final hosts = <String>{
        ..._hostsFromText(site.tracker),
        if (site.tracker.trim().isEmpty)
          ...site.url.expand((url) => _hostsFromText(url)),
      };

      for (final host in hosts) {
        final key = '${site.name}::$host';
        if (seen.add(key)) {
          candidates.add(_TrackerSiteCandidate(site: site, host: host));
        }
      }
    }

    candidates.sort((a, b) => b.host.length.compareTo(a.host.length));
    return candidates;
  }

  static Set<String> _torrentHosts(Torrent torrent) {
    final hosts = <String>{};
    for (final tracker in torrent.visibleTrackerStats) {
      hosts.addAll(_hostsFromText(tracker.host));
      hosts.addAll(_hostsFromText(tracker.announce));
    }
    hosts.addAll(_hostsFromText(torrent.trackerUrl));
    return hosts;
  }

  static Set<String> _hostsFromText(String text) {
    final hosts = <String>{};
    for (final token in text.split(RegExp(r'[\s,;|]+'))) {
      final host = _normalizeHost(token);
      if (host.isNotEmpty) hosts.add(host);
    }
    return hosts;
  }

  static String _normalizeHost(String raw) {
    var value = raw.trim().toLowerCase();
    if (value.isEmpty) return '';
    value = value.replaceAll(RegExp(r'^\*+\.'), '');

    try {
      final uri = Uri.parse(value.contains('://') ? value : 'https://$value');
      value = uri.host.isNotEmpty ? uri.host : value;
    } catch (_) {
      final slash = value.indexOf('/');
      if (slash >= 0) value = value.substring(0, slash);
    }

    if (value.startsWith('www.')) value = value.substring(4);
    return value.replaceAll(RegExp(r'^\.+|\.+$'), '');
  }

  static bool _hostMatches(String torrentHost, String trackerHost) {
    if (torrentHost == trackerHost) return true;
    return torrentHost.endsWith('.$trackerHost') ||
        trackerHost.endsWith('.$torrentHost');
  }
}

class _TrackerSiteCandidate {
  final site_config.WebSite site;
  final String host;

  const _TrackerSiteCandidate({required this.site, required this.host});

  String get displayName =>
      site.nickname.isNotEmpty ? site.nickname : site.name;
}
