import 'package:flutter/material.dart';
import 'package:fahrplan/services/xdrip_sgv_service.dart';
import 'package:fahrplan/models/android/xdrip_sgv_model.dart';
import 'package:fahrplan/utils/xdrip.dart';
import 'package:intl/intl.dart';

class XDripPage extends StatefulWidget {
  const XDripPage({Key? key}) : super(key: key);

  @override
  _XDripPageState createState() => _XDripPageState();
}

class _XDripPageState extends State<XDripPage> {
  late List<SgvResponse> sgvData = []; // Initialize it as an empty list

  Future<void> fetchSgvData() async {
    final sgvService = SgvService(); // Initialize the service here

    try {
      sgvData = await sgvService.fetchSgvData();
      setState(() {});
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
                return ListTile(title: Text('${XDripUtils.getFormattedSGVValue(sgvData[index], sgvData.first.unitsHint)} : Time: ${DateFormat('HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(sgvData[index].date, isUtc: false))}'));
              },
            )
                : const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}