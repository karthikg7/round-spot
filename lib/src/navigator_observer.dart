import 'package:flutter/widgets.dart';

import 'components/session_manager.dart';
import 'utils/components.dart';

class Observer extends RouteObserver<PageRoute<dynamic>> {
  final _manager = S.get<SessionManager>();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is! PageRoute) return;
    _manager.onRouteOpened(name: route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is! PageRoute) return;
    _manager.onRouteOpened(name: previousRoute.settings.name);
  }
}
