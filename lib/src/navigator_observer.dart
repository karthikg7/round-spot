import 'package:flutter/widgets.dart';

import 'services/session_manager.dart';
import 'utils/services.dart';

class RoundSpotObserver extends RouteObserver<PageRoute<dynamic>> {
	final _manager = S.get<SessionManager>();

	@override
	void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
		super.didPush(route, previousRoute);
		if (route is! PageRoute)
			return;
		_manager.startSession();
	}

	@override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
		super.didPop(route, previousRoute);
		if (route is! PageRoute)
			return;
		_manager.startSession(name: route.settings.name);
  }
}
