import '../widgets/detector.dart';

/// Holds additional information about the exported heat map.
abstract class OutputInfo {
	/// A page where the heat map was captured.
	String get page;
	/// [Detector.areaID] of the heat map.
	String get area;
	/// Timestamp of the first event included in the heat map (in ms)
  int get startTime;
	/// Timestamp of the last event included in the heat map (in ms)
  int get endTime;
}
