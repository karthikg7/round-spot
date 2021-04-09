import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:logging/logging.dart';

import '../../models/config/heat_map_style.dart';
import '../../models/session.dart';
import '../../utils/utils.dart';
import '../heat_map.dart';
import 'session_processor.dart';

/// Processes sessions into heat maps
class GraphicalProcessor extends SessionProcessor {
  final _logger = Logger('RoundSpot.GraphicalProcessor');

  @override
  Future process(Session session) async {
    if (session.screenSnap == null) {
      _logger.warning('Got session with no image attached, skipping.');
      return;
    }
    var image = session.screenSnap!;
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    canvas.drawImage(image, Offset.zero, Paint());

    var alpha = (config.heatMapTransparency * 255).toInt();
    canvas.saveLayer(null, Paint()..color = Color.fromARGB(alpha, 0, 0, 0));
    _drawHeatMap(canvas, session);
    canvas.restore();

    var canvasPicture = pictureRecorder.endRecording();
    var sessionImage = await canvasPicture.toImage(image.width, image.height);
    return exportHeatMap(sessionImage);
  }

  void _drawHeatMap(Canvas canvas, Session session) {
    var heatMap =
        HeatMap(session: session, pointProximity: config.uiElementSize);

    layerCount() {
      if (heatMap.largestCluster == 1) return 1;
      return heatMap.largestCluster * config.heatMapStyle.multiplier;
    }

    calcFraction(int i) => (i - 1) / max((layerCount() - 1), 1);
    calcBlur(double val) => (4 * val * val + 2) * config.uiElementSize / 10;
    for (var i = 1; i <= layerCount(); i++) {
      var fraction = calcFraction(i);
      var paint = Paint()..color = _getSpectrumColor(fraction);
      if (config.heatMapStyle == HeatMapStyle.smooth) {
        paint.maskFilter =
            MaskFilter.blur(BlurStyle.normal, calcBlur(1 - fraction));
      }
      canvas.drawPath(heatMap.getPathLayer(fraction), paint);
    }
  }

  Color _getSpectrumColor(double value, {double alpha = 1}) =>
      HSVColor.fromAHSV(alpha, (1 - value) * 225, 1, 1).toColor();
}
