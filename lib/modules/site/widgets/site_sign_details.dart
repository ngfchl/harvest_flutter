import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/http/http.dart';
import 'package:harvest/core/utils/utils.dart';

class SignInHistorySheet extends StatefulWidget {
  final int siteId;

  const SignInHistorySheet({super.key, required this.siteId});

  @override
  State<SignInHistorySheet> createState() => _SignInHistorySheetState();
}

class _SignInHistorySheetState extends State<SignInHistorySheet> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _signInfo = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final resp = await Http.get('/api/mysite/mysite/${widget.siteId}');
      if (!mounted) return;

      final data = resp is Map<String, dynamic> ? resp : (resp.data ?? {});
      final signInfo = data['sign_info'] as Map<String, dynamic>? ?? {};

      setState(() {
        _signInfo = signInfo;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '加载失败: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final mobile = MediaQuery.of(context).size.width < 600;

    final content = Container(
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: mobile ? const BorderRadius.vertical(top: Radius.circular(16)) : BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          _buildHeader(context, cs, mobile),
          // 内容
          Expanded(child: _buildBody(context, cs)),
        ],
      ),
    );

    if (mobile) {
      return SafeArea(child: content);
    }
    return content;
  }

  Widget _buildHeader(BuildContext context, FColors cs, bool mobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, mobile ? 12 : 16, 12, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [

          if (!mobile) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(FIcons.arrowLeft, size: 18, color: cs.foreground),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '签到历史',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.foreground),
                ),
                if (!_loading && !_loading)
                  Text(
                    '共 ${_signInfo.length} 条记录',
                    style: TextStyle(fontSize: 11, color: cs.foreground.withOpacity(0.4)),
                  ),
              ],
            ),
          ),
          if (!_loading)
            GestureDetector(
              onTap: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _fetchData();
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(FIcons.refreshCw, size: 16, color: cs.mutedForeground),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, FColors cs) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FProgress.circularIcon(),
            const SizedBox(height: 12),
            Text('加载中...', style: TextStyle(color: cs.mutedForeground, fontSize: 12)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FIcons.circleAlert, size: 32, color: const Color(0xFFF85149)),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: cs.mutedForeground, fontSize: 12)),
            const SizedBox(height: 12),
            FButton(
              style: FButtonStyle.outline(),
              onPress: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _fetchData();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_signInfo.isEmpty) {
      return Center(
        child: Text('暂无签到记录', style: TextStyle(color: cs.mutedForeground, fontSize: 13)),
      );
    }

    // 按日期倒序排列
    final sorted = _signInfo.entries.toList()..sort((a, b) => b.key.compareTo(a.key));

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 16),
      itemCount: sorted.length,
      itemBuilder: (_, i) => _buildItem(context, cs, sorted[i].key, sorted[i].value),
    );
  }

  Widget _buildItem(BuildContext context, FColors cs, String date, dynamic value) {
    final info = value as Map<String, dynamic>;
    final text = info['info']?.toString() ?? '';
    final updatedAt = info['updated_at']?.toString() ?? '';

    // 提取签到内容（去掉前缀 "XXX 签到返回信息："）
    String displayText = text;
    final colonIndex = text.indexOf('签到返回信息：');
    if (colonIndex >= 0) {
      displayText = text.substring(colonIndex + 6).trim();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期 + 状态
          Row(
            children: [
              Text(
                date,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.foreground),
              ),
              const SizedBox(width: 8),
              const Spacer(),
              if (updatedAt.isNotEmpty)
                Text(formatTime(updatedAt), style: TextStyle(fontSize: 10, color: cs.foreground.withOpacity(0.35))),
            ],
          ),
          const SizedBox(height: 4),
          Text(displayText, style: TextStyle(fontSize: 11, color: cs.foreground.withOpacity(0.6), height: 1.4)),
        ],
      ),
    );
  }


}
