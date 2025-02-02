import 'package:flutter_test/flutter_test.dart';
import 'package:relaa/utils/xdrip.dart';
import 'package:relaa/models/android/xdrip_sgv_model.dart';

void main() {
  group('Xdrip', () {
    test('getFormattedSGVValue mgdl returns proper value', () {
      int sgValue = 127;
      var unitsHint = "mgdl";
      var expected = "→ $sgValue mg/dl";
      SgvResponse mockData = SgvResponse.fromJson({
        "_id": "dc39aec4-231d-4392-80e0-d7ef0cc74c2c",
        "device": "UI Based",
        "dateString": "2025-01-08T11:18:33.921-0600",
        "sysTime": "2025-01-08T11:18:33.921-0600",
        "date": 1736356713921,
        "sgv": sgValue,
        "delta": -1.109,
        "direction": "Flat",
        "noise": 1,
        "filtered": 0,
        "unfiltered": -127,
        "rssi": 100,
        "type": "sgv",
        "units_hint": unitsHint
      });
      final result = XDripUtils.getFormattedSGVValue(mockData);
      expect(result, expected);
    });
    test('getFormattedSGVValue mmol returns proper value', () {
      int sgValue = 127;
      var unitsHint = "mmol";
      var expected = "→ 7.055 mmol/L";
      SgvResponse mockData = SgvResponse.fromJson({
        "_id": "dc39aec4-231d-4392-80e0-d7ef0cc74c2c",
        "device": "UI Based",
        "dateString": "2025-01-08T11:18:33.921-0600",
        "sysTime": "2025-01-08T11:18:33.921-0600",
        "date": 1736356713921,
        "sgv": sgValue,
        "delta": -1.109,
        "direction": "Flat",
        "noise": 1,
        "filtered": 0,
        "unfiltered": -127,
        "rssi": 100,
        "type": "sgv",
        "units_hint": unitsHint
      });
      final result = XDripUtils.getFormattedSGVValue(mockData);
      expect(result, expected);
    });
    test('getFormattedSGVValue blow up without a hint, and passes if set.', () {
      int sgValue = 127;
      var expected = "→ $sgValue mg/dl";
      SgvResponse mockData = SgvResponse.fromJson({
        "_id": "dc39aec4-231d-4392-80e0-d7ef0cc74c2c",
        "device": "UI Based",
        "dateString": "2025-01-08T11:18:33.921-0600",
        "sysTime": "2025-01-08T11:18:33.921-0600",
        "date": 1736356713921,
        "sgv": sgValue,
        "delta": -1.109,
        "direction": "Flat",
        "noise": 1,
        "filtered": 0,
        "unfiltered": -127,
        "rssi": 100,
        "type": "sgv",
      });
      expect(() => XDripUtils.getFormattedSGVValue(mockData), throwsException);
      final result = XDripUtils.getFormattedSGVValue(mockData, "mgdl");
      expect(result, expected);
    });
  });
}
