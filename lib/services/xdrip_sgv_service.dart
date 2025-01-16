import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fahrplan/models/android/xdrip_sgv_model.dart';
import 'package:fahrplan/services/bluetooth_manager.dart';

class SgvService {
  Future<List<SgvResponse>> fetchSgvData() async {
    const String uri = "http://127.0.0.1:17580/sgv.json";
    final bt = BluetoothManager();
    final response = await http.get(Uri.parse(uri));
    print('response.body');
    print(response.body);
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body) as List;
      print('Number of entries: ${jsonResponse.length}');
      print(jsonResponse);
      List<SgvResponse> sgvData = jsonResponse.map((e) => SgvResponse.fromJson(e)).toList();

      bt.sendText(sgvData.first.sgv.toString());
      return jsonResponse.map((e) => SgvResponse.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load data");
    }
  }
}