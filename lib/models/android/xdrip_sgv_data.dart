// Has error, commenting out for now.
// // this model can be used with events broadcast by xdrip when xDrip web service
// // is enabled on a device running the xDrip+ application and this application.
//
// import 'package:http/http.dart' as http;
// import 'dart:convert'; // For parsing JSON data
//
// Future<XdripSGVData?> fetchXdripData() async {
//   final url = Uri.parse('http://127.0.0.1:17580/sgv.json'); // Define the URL for making a GET request
//
//   try {
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       return XdripSGVData.fromJson(jsonDecode(response.body)['XdripData']);
//     } else {
//       print('Error fetching data: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error making request: $e');
//   }
//
//   return null; // Return null if an error occurred
// }
//
// /* Example data
//   {
//     "_id": "dc39aec4-231d-4392-80e0-d7ef0cc74c2c",
//     "device": "UI Based",
//     "dateString": "2025-01-08T11:18:33.921-0600",
//     "sysTime": "2025-01-08T11:18:33.921-0600",
//     "date": 1736356713921,
//     "sgv": 127,
//     "delta": -1.109,
//     "direction": "Flat",
//     "noise": 1,
//     "filtered": 0,
//     "unfiltered": -127,
//     "rssi": 100,
//     "type": "sgv",
//     "units_hint": "mgdl"
//   },
// */
//
// class XDripSpec {
//   static const int VERSION = 4;
//
//   int? id; // id passed from xdrip
//   bool? canReply;
//   String? packageName;
//   String? title;
//   String? content;
//   bool? hasRemoved;
//   bool? haveExtraPicture;
//
//   XDripSpec({
//     this.id,
//     this.canReply,
//     this.packageName,
//     this.title,
//     this.content,
//     this.hasRemoved,
//     this.haveExtraPicture,
//   });
//
//   factory XDripSpec.fromJson(Map<String, dynamic> json) {
//     return XDripSpec(
//       id: json['id'],
//       canReply: json['can reply'],
//       packageName: json['packageName'],
//       title: json['title'],
//       content: json['content'],
//       hasRemoved: json['hasRemoved'],
//       haveExtraPicture: json['haveExtraPicture'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'canReply': canReply,
//       'packageName': packageName,
//       'title': title,
//       'content': content,
//       'hasRemoved': hasRemoved,
//       'haveExtraPicture': haveExtraPicture,
//     };
//   }
// }
