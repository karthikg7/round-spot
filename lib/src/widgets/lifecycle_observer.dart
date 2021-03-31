// ignore_for_file: prefer_mixin
import 'package:flutter/widgets.dart';
import '../components/session_manager.dart';

import '../utils/components.dart';

class LifecycleObserver extends StatefulWidget {
  final Widget child;

  LifecycleObserver({required this.child});

  @override
  _LifecycleObserverState createState() => _LifecycleObserverState();
}

class _LifecycleObserverState extends State<LifecycleObserver>
    with WidgetsBindingObserver {
  final _manager = S.get<SessionManager>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _manager.onLifecycleStateChanged(state);

  @override
  Widget build(BuildContext context) => widget.child;
}
