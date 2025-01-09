import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fahrplan/models/android/sgv_model.dart';

class SgvService {
  Future<List<SgvResponse>> fetchSgvData() async {
    const String uri = "http://127.0.0.1:17580/sgv.json";

    final response = await http.get(Uri.parse(uri));
    print('response.body');
    print(response.body);
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body) as List;
      print('Number of entries: ${jsonResponse.length}');
      print(jsonResponse);
      return jsonResponse.map((e) => SgvResponse.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load data");
    }
  }
}