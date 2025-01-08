// we use https://gadgetbridge.org/internals/development/weather-support/ to get the weather data
// suggested app is Breezy Weather
// this is received in Kotlin code and saved into shared preferences

import 'dart:convert';


import 'package:shared_preferences/shared_preferences.dart';

class XDripProvider {
  static const String _sharedPrefsKey = 'XdripJson';

  static Future<XDripSpec?> getXDrip() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_sharedPrefsKey);
    if (json == null) {
      return null;
    }

    final event = XDripSpec.fromJson(jsonDecode(json));
    if (event.packageName == 'com.eveningoutpost.dexdrip') {
      // debugPrint('XdripData received: $event');
      return event;
    } else {
      return null;
    }

  }
}
// Example data
// I/flutter (24479):       id: 8811
// I/flutter (24479):       can reply: false
// I/flutter (24479):       packageName: com.eveningoutpost.dexdrip
// I/flutter (24479):       title: 140 →︎
// I/flutter (24479):       content: Delta: +2.2 mg/dl
// I/flutter (24479):       hasRemoved: false
// I/flutter (24479):       haveExtraPicture: false
// I/flutter (24479):        from com.eveningoutpost.dexdrip


class XDripSpec {
  static const int VERSION = 4;

  int? id; // id passed from xdrip
  bool? canReply;
  String? packageName;
  String? title;
  String? content;
  bool? hasRemoved;
  bool? haveExtraPicture;

  XDripSpec({
    this.id,
    this.canReply,
    this.packageName,
    this.title,
    this.content,
    this.hasRemoved,
    this.haveExtraPicture,
  });

  factory XDripSpec.fromJson(Map<String, dynamic> json) {
    return XDripSpec(
      id: json['id'],
      canReply: json['can reply'],
      packageName: json['packageName'],
      title: json['title'],
      content: json['content'],
      hasRemoved: json['hasRemoved'],
      haveExtraPicture: json['haveExtraPicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'canReply': canReply,
      'packageName': packageName,
      'title': title,
      'content': content,
      'hasRemoved': hasRemoved,
      'haveExtraPicture': haveExtraPicture,
    };
  }
}
