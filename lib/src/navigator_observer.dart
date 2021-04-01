import 'package:flutter/widgets.dart';

import 'components/session_manager.dart';
import 'utils/components.dart';

/// Keeps track of [Navigator] [PageRoute] changes.
///
/// Route names are used to differentiate between pages.
/// Make sure you are consistently specifying them both when:
/// * using [named routes](https://flutter.dev/docs/cookbook/navigation/named-routes) and
/// * pushing a [PageRoute] - using [RouteSettings]
///
/// Without that the events will not get grouped correctly,
/// either resulting in multiple outputs per page/area
/// or a single output that's a mix of multiple pages/areas
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
