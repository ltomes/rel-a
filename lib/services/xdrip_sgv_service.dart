import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:relaa/models/android/xdrip_sgv_model.dart';
import '../services/bluetooth_manager.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:relaa/utils/bitmap.dart';
import 'package:flutter/material.dart';
import 'package:relaa/utils/ui_perfs.dart';

import 'package:relaa/utils/xdrip.dart';
import 'package:chart_sparkline/chart_sparkline.dart';

//Just for debug
// import 'package:share_plus/share_plus.dart';
// import 'package:path_provider/path_provider.dart';

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
    BluetoothManager bm = BluetoothManager();
    final UiPerfs _ui = UiPerfs.singleton;
    final bool renderText = !_ui.xDripImageMode;
    print("fetchSgvData called. renderMode: ${renderText ? 'Text' : 'Image'}");
    // Documentation: https://github.com/NightscoutFoundation/xDrip/blob/master/Documentation/technical/Local_Web_Services.md#sgvjson-endpoint
    const String uri = "http://127.0.0.1:17580/sgv.json";
    final response = await http.get(Uri.parse(uri));
    print('response.body: $response.body');
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body) as List;
      print('Number of entries: ${jsonResponse.length}');
      print(jsonResponse);
      List<SgvResponse> sgvData =
          jsonResponse.map((e) => SgvResponse.fromJson(e)).toList();
      String widgetTitle = 'Loading xDrip+ data...';
      widgetTitle = XDripUtils.getWidgetTitle(sgvData.first,
          fallback: widgetTitle, unitsHint: sgvData.first.unitsHint);
      if (bm.isConnected) {
        if (renderText) {
          print('renderText is true, printing $widgetTitle');
          bm.sendText(widgetTitle);
        } else {
            final bmpOneBitImage = await generateImageForDisplay(sgvData, widgetTitle);
            //Just for debug
            //End Just for debug
            await bm.sendBitmap(bmpOneBitImage);

            // // Generate debug image for share plugin
            // final directory = await getApplicationDocumentsDirectory();
            // final imagePath = await File('${directory.path}/image.png').create();
            // await imagePath.writeAsBytes(bmpOneBitImage);
            //
            // /// Share Plugin
            // final files = <XFile>[];
            // files.add(XFile(imagePath.path, name: 'image.png'));
            // await Share.shareXFiles(files);
        }
      }
      return sgvData;
    } else {
      throw Exception("Failed to load data");
    }
  }
}

Future<Uint8List> generateImageForDisplay(sgvData, String widgetTitle) async {

  ScreenshotController screenshotController = ScreenshotController();
  double canvasWidth = 576;
  double canvasHeight = 136; // 136;
  return screenshotController
      .captureFromWidget(
      pixelRatio: 1,
      targetSize: Size(canvasWidth, canvasHeight),
      SizedBox(
          width: canvasWidth,
          height: canvasHeight,
          child: Container(
              width: canvasWidth,
              height: canvasHeight,
              color: Colors.white,
              child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(children: [
                    Container(
                        width: canvasWidth,
                        height: 80,
                        color: Colors.white,
                        child: Sparkline(
                          data:
                          XDripUtils.generateChartData(sgvData),
                          gridLinesEnable: true,
                          gridLineWidth: 1,
                          gridLineLabelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                          pointsMode: PointsMode.all,
                          pointSize: 4.0,
                          fillColor: Colors.black,
                          lineColor: Colors.black,
                          lineWidth: 2,
                          averageLineColor: Colors.black,
                          pointColor: Colors.black,
                          backgroundColor: Colors.white,
                        )),
                    Text(
                      widgetTitle,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ])))))
      .then((capturedImage) async {
        print('renderText is false, rendering image info will be $widgetTitle');
        final bmpImage = await capturedImage.bmpUint8List;
        final bmpOneBitImage = generateBMPForDisplay(
            bmpImage, canvasWidth. toInt(), canvasHeight.toInt());
        return bmpOneBitImage;
      });
}