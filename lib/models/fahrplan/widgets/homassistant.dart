import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class HomeAssistantWidget {
  String? url;
  String? token;

  Future<void> loadCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    url = prefs.getString('homeassistant_url');
    token = prefs.getString('homeassistant_token');
  }

  Future<void> saveCredentials(String url, String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('homeassistant_url', url);
    await prefs.setString('homeassistant_token', token);

    await loadCredentials();
  }

  Future<String> handleQuery(String query) async {
    await loadCredentials();

    if (url == null || token == null) {
      return 'Please enter your HomeAssistant URL and token';
    }

    final resp = await _getResponse(query);

    return resp.response?.speech?.plain?.speech ?? 'No response';
  }

  Future<HAResponse> _getResponse(String query) async {
    final response = await http.post(
      Uri.parse('$url/api/conversation/process'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'text': query,
        'language': 'en',
      }),
    );

    if (response.statusCode == 200) {
      return HAResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load HA response');
    }
  }
}

class HAResponse {
  Response? response;
  String? conversationId;

  HAResponse({this.response, this.conversationId});

  HAResponse.fromJson(Map<String, dynamic> json) {
    response = json['response'] != null
        ? new Response.fromJson(json['response'])
        : null;
    conversationId = json['conversation_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.response != null) {
      data['response'] = this.response!.toJson();
    }
    data['conversation_id'] = this.conversationId;
    return data;
  }
}

class Response {
  String? responseType;
  String? language;
  Data? data;
  Speech? speech;

  Response({this.responseType, this.language, this.data, this.speech});

  Response.fromJson(Map<String, dynamic> json) {
    responseType = json['response_type'];
    language = json['language'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    speech =
        json['speech'] != null ? new Speech.fromJson(json['speech']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response_type'] = this.responseType;
    data['language'] = this.language;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (this.speech != null) {
      data['speech'] = this.speech!.toJson();
    }
    return data;
  }
}

class Data {
  List<Targets>? targets;

  Data({this.targets});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['targets'] != null) {
      targets = <Targets>[];
      json['targets'].forEach((v) {
        targets!.add(new Targets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.targets != null) {
      data['targets'] = this.targets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Targets {
  String? type;
  String? name;
  String? id;

  Targets({this.type, this.name, this.id});

  Targets.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['name'] = this.name;
    data['id'] = this.id;
    return data;
  }
}

class Speech {
  Plain? plain;

  Speech({this.plain});

  Speech.fromJson(Map<String, dynamic> json) {
    plain = json['plain'] != null ? new Plain.fromJson(json['plain']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.plain != null) {
      data['plain'] = this.plain!.toJson();
    }
    return data;
  }
}

class Plain {
  String? speech;

  Plain({this.speech});

  Plain.fromJson(Map<String, dynamic> json) {
    speech = json['speech'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['speech'] = this.speech;
    return data;
  }
}
