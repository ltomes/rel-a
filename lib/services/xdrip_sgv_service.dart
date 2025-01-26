import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fahrplan/models/android/xdrip_sgv_model.dart';
import 'package:fahrplan/services/bluetooth_manager.dart';
import 'package:fahrplan/utils/xdrip.dart';

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
    print('response.body: $response.body');
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body) as List;
      print('Number of entries: ${jsonResponse.length}');
      print(jsonResponse);
      List<SgvResponse> sgvData = jsonResponse.map((e) => SgvResponse.fromJson(e)).toList();
      String currentNotification = XDripUtils.getFormattedSGVValue(sgvData.first);
      bt.sendText(currentNotification);
      return jsonResponse.map((e) => SgvResponse.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load data");
    }
  }
}