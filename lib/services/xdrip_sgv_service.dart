import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:fahrplan/models/android/xdrip_sgv_model.dart';
import 'package:fahrplan/services/bluetooth_manager.dart';

class SgvService {
  final String slopeDoubleDown = "DoubleDown";
  final String slopeSingleDown = "SingleDown";
  final String slopeFortyfiveDown = "FortyFiveDown";
  final String slopeFlat = "Flat";
  final String slopeFortyfiveUp = "FortyFiveUp";
  final String slopeSingleUp = "SingleUp";
  final String slopeDoubleUp = "DoubleUp";
  final String slopeNone = "None";
  final String slopeNotComputable = "NotComputable";
  Future<List<SgvResponse>> fetchSgvData() async {
    // Documentation: https://github.com/NightscoutFoundation/xDrip/blob/master/Documentation/technical/Local_Web_Services.md#sgvjson-endpoint
    const String uri = "http://127.0.0.1:17580/sgv.json";
    final bt = BluetoothManager();
    final response = await http.get(Uri.parse(uri));
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
    print('response.body: $response.body');
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body) as List;
      print('Number of entries: ${jsonResponse.length}');
      print(jsonResponse);
      List<SgvResponse> sgvData = jsonResponse.map((e) => SgvResponse.fromJson(e)).toList();
      // Slope related fields
      String currentSlope='';
      List<String> slopeNames = [slopeSingleUp, slopeDoubleUp, slopeSingleDown, slopeDoubleDown, slopeFlat, slopeFortyfiveDown, slopeFortyfiveUp];
      List<String> slopeIcons = [slopeValues[slopeSingleUp]!, slopeValues[slopeDoubleUp]!, slopeValues[slopeSingleDown]!, slopeValues[slopeDoubleDown]!, slopeValues[slopeFlat]!, slopeValues[slopeFortyfiveDown]!, slopeValues[slopeFortyfiveUp]!];
      String direction = jsonResponse.first['direction'];
      for (int i = 0; i < slopeNames.length; i++) {
        if (direction == slopeNames[i]) {
          currentSlope = slopeIcons[i];
          break;
        }
      }
      // Unit related fields:
      List<String> unitNames = ['mgdl', 'mmol'];
      List<String> unitValues = ['mg/dl', 'mmol/L'];
      num mgdlValue = sgvData.first.sgv.toInt();
      num mmolValue = mgdlValue/18;
      List<num> unitValue = [mgdlValue, mmolValue];
      String hint = jsonResponse.first['units_hint'];
      String currentGlucose = '';
      String unitOfMeasure = '';
      for (int i = 0; i < unitNames.length; i++) {
        if (hint == unitNames[i]) {
          unitOfMeasure = unitValues[i];
          currentGlucose = unitValue[i].toString();
          break;
        }
      }
      String currentNotification = '$currentSlope $currentGlucose $unitOfMeasure';
      print('currentNotification $currentNotification');
      bt.sendText(currentNotification);
      return jsonResponse.map((e) => SgvResponse.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load data");
    }
  }
}