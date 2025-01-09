import 'package:flutter/material.dart';
import 'package:fahrplan/services/sgv_service.dart';
import 'package:fahrplan/models/android/sgv_model.dart';

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
            child: sgvData != null
                ? ListView.builder(
              itemCount: sgvData.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(title: Text('${sgvData[index].sgv} : ${sgvData[index].dateString}'));
              },
            )
                : const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}