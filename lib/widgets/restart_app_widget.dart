import 'package:flutter/material.dart';

class RestartAppWidget extends StatefulWidget {
  const RestartAppWidget({required this.child, Key? key}) : super(key: key);
  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartAppWidgetState>()?.restartApp();
  }

  @override          
  State<RestartAppWidget> createState() => _RestartAppWidgetState();
}

class _RestartAppWidgetState extends State<RestartAppWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}
