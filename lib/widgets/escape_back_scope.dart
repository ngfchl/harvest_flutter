import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class EscapeBackScope extends StatefulWidget {
  final Widget child;
  final VoidCallback onBack;

  const EscapeBackScope({super.key, required this.onBack, required this.child});

  @override
  State<EscapeBackScope> createState() => _EscapeBackScopeState();
}

class _EscapeBackScopeState extends State<EscapeBackScope> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape) {
      return false;
    }

    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return false;

    widget.onBack();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
