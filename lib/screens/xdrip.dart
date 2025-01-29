import 'package:flutter/material.dart';
import 'package:fahrplan/services/xdrip_sgv_service.dart';
import 'package:fahrplan/models/android/xdrip_sgv_model.dart';
import 'package:fahrplan/utils/xdrip.dart';
import 'package:intl/intl.dart';

import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:fahrplan/utils/bitmap.dart';
import '../services/bluetooth_manager.dart';

class XDripPage extends StatefulWidget {
  const XDripPage({Key? key}) : super(key: key);
  @override
  _XDripPageState createState() => _XDripPageState();
}

class _XDripPageState extends State<XDripPage> {
  BluetoothManager bluetoothManager = BluetoothManager();
  late List<SgvResponse> sgvData = []; // Initialize it as an empty list
  ScreenshotController screenshotController = ScreenshotController();
  Future<void> fetchSgvData() async {
    final sgvService = SgvService(); // Initialize the service here

    try {
      sgvData = await sgvService.fetchSgvData();
      setState(() {});
    } catch (e) {
      print('Error making request: $e');
    }
    double canvasWidth = 576;
    double canvasHeight = 136;
    screenshotController
        .captureFromWidget(SizedBox(
        width: canvasWidth,
        height: canvasHeight,
        child: Sparkline(
          data: XDripUtils.generateChartData(sgvData),
          gridLinesEnable: true,
          pointsMode: PointsMode.last,
          pointSize: 4.0,
          pointColor: Colors.blue,
        )
    ))
        .then((capturedImage) async {
      // Convert png to bmp
      final image = await capturedImage.bmpUint8List;
      final bmpImage = await generateBMPForDisplay(image, canvasWidth.toInt(), canvasHeight.toInt());
      // Convert RGBA to 1-bit monochrome (0=black, 1=white)
      if (bluetoothManager.isConnected) {
        // Skip image sending for now, stick to text.
        // await bluetoothManager.sendBitmap(bmpImage);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Glasses are not connected')),
        );
      }
    });
  }
  @override
  void initState () {
    super.initState();
    fetchSgvData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('xDrip Page')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: fetchSgvData,
            child: const Text('Fetch SGV Data'),
          ),
          Expanded(
            child: sgvData.isNotEmpty
                ? ListView.builder(
              itemCount: sgvData.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(title: Text('${XDripUtils.getFormattedSGVValue(sgvData[index], sgvData.first.unitsHint)} : Time: ${DateFormat('HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(sgvData[index].date, isUtc: false))}'));
              },
            )
                : const CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
                children: [
                  ListTile(title: Text('${XDripUtils.getFormattedSGVValue(sgvData[0], sgvData.first.unitsHint)} : Time: ${DateFormat('HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(sgvData[0].date, isUtc: false))}')),
                  Sparkline(
                    data: XDripUtils.generateChartData(sgvData),
                    gridLinesEnable: true,
                    pointsMode: PointsMode.last,
                    pointSize: 4.0,
                    pointColor: Colors.blue,
                  ),
                ]
            ),
          ),
      ]
      ),
    );
  }
}