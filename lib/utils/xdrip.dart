import 'dart:math';

import 'package:fahrplan/models/android/xdrip_sgv_model.dart';

extension TruncateDoubles on double {
  double truncateToDecimalPlaces(int fractionalDigits) => (this * pow(10,
      fractionalDigits)).truncate() / pow(10, fractionalDigits);
}

class XDripUtils {

  static String  getFormattedSGVValue(SgvResponse sgvResponse, [unitHint]) {
    if (unitHint==null && sgvResponse.unitsHint==null) {
      throw Exception('Units not provided by xDrip via hints.');
    }
    final String slopeDoubleDown = "DoubleDown";
    final String slopeSingleDown = "SingleDown";
    final String slopeFortyfiveDown = "FortyFiveDown";
    final String slopeFlat = "Flat";
    final String slopeFortyfiveUp = "FortyFiveUp";
    final String slopeSingleUp = "SingleUp";
    final String slopeDoubleUp = "DoubleUp";
    final String slopeNone = "None";
    final String slopeNotComputable = "NotComputable";
    final Map<String, String> slopeValues = {
      slopeSingleUp: '↑',
      slopeSingleDown: '↓',
      slopeDoubleUp: '⇈',
      slopeDoubleDown: '⇊',
      slopeFlat: '→',
      slopeFortyfiveDown: '↘',
      slopeFortyfiveUp: '↗',
      slopeNone: '', // Empty string for no slope
      slopeNotComputable: '', // Empty string for not computable slope
    };
    // Slope related fields
    String currentSlope='';
    List<String> slopeNames = [slopeSingleUp, slopeDoubleUp, slopeSingleDown, slopeDoubleDown, slopeFlat, slopeFortyfiveDown, slopeFortyfiveUp];
    List<String> slopeIcons = [slopeValues[slopeSingleUp]!, slopeValues[slopeDoubleUp]!, slopeValues[slopeSingleDown]!, slopeValues[slopeDoubleDown]!, slopeValues[slopeFlat]!, slopeValues[slopeFortyfiveDown]!, slopeValues[slopeFortyfiveUp]!];
    String direction = sgvResponse.direction;
    for (int i = 0; i < slopeNames.length; i++) {
      if (direction == slopeNames[i]) {
        currentSlope = slopeIcons[i];
        break;
      }
    }
    // Unit related fields:
    List<String> unitNames = ['mgdl', 'mmol'];
    List<String> unitValues = ['mg/dl', 'mmol/L'];
    num mgdlValue = sgvResponse.sgv.toInt();
    // Based on this page (https://www.disabled-world.com/calculators-charts/bgl.php)
    // I decided to implement mmol rendering as 3 decimal places without rounding.
    // A user of mmol values should let me know if this matches what they expect.
    double mmolValue = ((mgdlValue / 18.0).toDouble()).truncateToDecimalPlaces(3);
    List<num> unitValue = [mgdlValue, mmolValue];
    String hint = unitHint ?? sgvResponse.unitsHint;
    String currentGlucose = '';
    String unitOfMeasure = '';

    for (
    int i = 0; i < unitNames.length; i++) {
      if (hint == unitNames[i]) {
        unitOfMeasure = unitValues[i];
        currentGlucose = unitValue[i].toString();
        break;
      }
    }
    String currentNotification = '$currentSlope $currentGlucose $unitOfMeasure';
    print('currentNotification $currentNotification');
    return currentNotification;
  }
}