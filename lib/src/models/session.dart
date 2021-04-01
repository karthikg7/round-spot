import 'dart:math';
import 'dart:ui';

import '../utils/utils.dart';
import 'event.dart';
import 'output_info.dart';

/// Holds information about user interactions with a particular
/// [area] on some [page] during some period of time.
class Session implements OutputInfo {
  final String? page;
  final String area;
  final int startTime;
  int endTime;

  Image? screenSnap;
  final List<Event> _events = [];
  List<Event> get events => _events;

  Session({this.page, required this.area})
      : startTime = getTimestamp(),
        endTime = getTimestamp();

  void addEvent(Event event) {
    _events.add(event);
    endTime = max(endTime, event.timestamp);
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'area': area,
        'span': {'start': startTime, 'end': endTime},
        'events': [for (var event in _events) event.toJson()],
      };
}
