import 'package:flutter/material.dart';
import 'package:relaa/services/xdrip_sgv_service.dart';
import 'package:relaa/models/android/xdrip_sgv_model.dart';
import 'package:relaa/utils/xdrip.dart';

import 'package:chart_sparkline/chart_sparkline.dart';
import '../services/bluetooth_manager.dart';

class XDripPage extends StatefulWidget {
  const XDripPage({Key? key}) : super(key: key);
  @override
  _XDripPageState createState() => _XDripPageState();
}

class _XDripPageState extends State<XDripPage> {
  BluetoothManager bM = BluetoothManager();
  late List<SgvResponse> sgvData = []; // Initialize it as an empty list
  late String widgetTitle = 'Loading xDrip+ data...';
  Future<void> fetchSgvData() async {
    final sgvService = SgvService(); // Initialize the service here
    bool renderText = false;
    try {
      sgvData = await sgvService.fetchSgvData();
      if (sgvData.isNotEmpty) {
        widgetTitle = XDripUtils.getWidgetTitle(sgvData.first, fallback: widgetTitle, unitsHint: sgvData.first.unitsHint);
        setState(() {});
      } else {
        setState(() {});
      }


    } catch (e) {
      print('Error making request: $e');
    }
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
                return ListTile(title: Text(XDripUtils.getWidgetTitle(sgvData[index], fallback: widgetTitle, unitsHint: sgvData.first.unitsHint)));
              },
            )
                : const CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
                children: [
                  ListTile(title: Text(widgetTitle)),
                  Container(
                      height: 70,
                      color: Colors.white,
                      child: Sparkline(
                                data: XDripUtils.generateChartData(sgvData),
                                gridLinesEnable: true,
                                pointsMode: PointsMode.last,
                                pointSize: 4.0,
                                pointColor: Colors.blue,
                              ),
                  )
                ]
            ),
          )
      ]
      ),
    );
  }
}