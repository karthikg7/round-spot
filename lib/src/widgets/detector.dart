import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../components/session_manager.dart';
import '../models/detector_status.dart';
import '../models/event.dart';
import '../utils/components.dart';

/// Detects user interactions in the [child] widget tree.
///
/// {@template Detector.description}
/// ## Scrollable widgets
/// To correctly monitor interactions with any scrollable space a [Detector]
/// has to be placed as a direct parent of that widget:
/// ```dart
/// round_spot.Detector(
///   areaID: id,
///   child: ListView(
///     children: /* children */,
///   ),
/// )
/// ```
///
/// Widgets provided by Flutter, like [ListView], [SingleChildScrollView],
/// [GridView] or [CustomScrollView] are recognised automatically.
/// In case you are using a custom scrolling widget from external package,
/// and cannot put the [Detector] directly around one of the widgets
/// listed above, provide the [customScrollWidgetAxis] parameter.
///
/// Nested scroll views are currently not supported and can impact
/// the way that the outer scroll area is reported.
///
/// ## Detector scope
/// Detectors can either have a _local_ or a _global_ scope:
/// * The default _local_ scope should generally be used whenever a unique area
/// that only exist in one place on a single screen needs to be observed.
/// * The _global_ scope is designed to allow for monitoring interactions with
/// elements that appear in the same form on multiple pages.
///
/// As a result of a global scope events from all of the detectors grouped
/// by the same [areaID] will contribute to the same heat maps.
/// This is useful in situations where want to monitor
/// the cumulative use of a common interface element that's
/// shared between pages, like a navigation bar or a menu.
///
/// By default (with no additional _global_ scoped [Detector]) you only
/// get the information about how the user exits every page.
/// {@endtemplate}
class Detector extends StatefulWidget {
  /// The widget below this widget to be observed.
  ///
  /// If you need to lay out multiple children in a column use [ListDetector].
  final Widget child;

  /// {@template Detector.areaID}
  /// Consistently identifies the same visual region
  /// across widget tree rebuilds and multiple visits.
  ///
  /// It should be unique in its scope - see [hasGlobalScope].
  /// The empty ID is reserved as it's used by the root detector on every page.
  /// {@endtemplate}
  final String areaID;

  /// {@template Detector.hasGlobalScope}
  /// Determines the scope of this Detector's area:
  ///
  /// * **false** means the scope is local and limited
  /// to the enclosing [PageRoute]
  /// * **true** expands the scope beyond a single page.
  /// Every [Detector] with the same [areaID] on any page will become
  /// part of a group observing the same area. Keep in mind that
  /// each one of them needs to have the scope set to global.
  /// {@endtemplate}
  final bool hasGlobalScope;

  /// Signals to the [Detector] that it's monitoring a custom scrolling widget.
  ///
  /// In that case that widget scrolling [Axis] must be provided.
  final Axis? customScrollWidgetAxis;

  late final bool _isScrollDetector;

  /// {@template Detector.constructor}
  /// Creates a widget detector
  ///
  /// The default scope is local.
  /// {@endtemplate}
  Detector({
    required this.child,
    required this.areaID,
    this.hasGlobalScope = false,
    this.customScrollWidgetAxis,
  }) {
    _isScrollDetector = customScrollWidgetAxis != null ||
        child is ScrollView ||
        child is SingleChildScrollView ||
        child is PageView ||
        child is ListWheelScrollView;
  }

  @override
  _DetectorState createState() => _DetectorState();
}

class _DetectorState extends State<Detector> {
  late final DetectorStatus _status;

  final _manager = S.get<SessionManager>();

  @override
  void initState() {
    super.initState();
    _status = widget._isScrollDetector
        ? ScrollDetectorStatus(
            areaKey: GlobalKey(),
            areaID: widget.areaID,
            hasGlobalScope: widget.hasGlobalScope,
            scrollAxis: widget.customScrollWidgetAxis ?? _getScrollAxis()!,
          )
        : DetectorStatus(
            areaKey: GlobalKey(),
            areaID: widget.areaID,
            hasGlobalScope: widget.hasGlobalScope,
          );
  }

  void _onTap(PointerDownEvent event) {
    _manager.onEvent(
      event: Event.fromPointer(event),
      status: _status,
    );
  }

  bool _onNotification(ScrollNotification notification) {
    var status = _status as ScrollDetectorStatus;
    status.scrollPosition = notification.metrics.pixels;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Widget detector = Listener(
      onPointerDown: _onTap,
      behavior: HitTestBehavior.translucent,
      child: RepaintBoundary(
        key: _status.areaKey,
        child: widget.child,
      ),
    );
    if (widget._isScrollDetector) {
      detector = NotificationListener(
        onNotification: _onNotification,
        child: detector,
      );
    }
    return detector;
  }

  Axis? _getScrollAxis() {
    var child = widget.child;
    if (child is ScrollView) return child.scrollDirection;
    if (child is ListWheelScrollView) return Axis.vertical;
    if (child is SingleChildScrollView) return child.scrollDirection;
    if (child is PageView) child.scrollDirection;
  }
}
