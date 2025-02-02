import 'package:relaa/screens/calendars_screen.dart';
import 'package:relaa/screens/settings_screen.dart';
import 'package:relaa/screens/xdrip.dart';
import 'package:relaa/utils/ui_perfs.dart';
import 'package:relaa/widgets/glass_status.dart';
import 'package:flutter/material.dart';

import 'package:chart_sparkline/chart_sparkline.dart';

import 'package:relaa/services/xdrip_sgv_service.dart';
import 'package:relaa/models/android/xdrip_sgv_model.dart';
import 'package:relaa/utils/xdrip.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UiPerfs _ui = UiPerfs.singleton;
  late List<SgvResponse> sgvData = []; // Initialize it as an empty list
  late String widgetTitle = 'Loading xDrip+ data...';
  Future<void> fetchSgvData() async {
    final sgvService = SgvService(); // Initialize the service here
    try {
      sgvData = await sgvService.fetchSgvData();
      if (sgvData.isNotEmpty) {
        widgetTitle = XDripUtils.getWidgetTitle(sgvData.first, fallback: widgetTitle, unitsHint: sgvData.first.unitsHint);
        setState(() {
          this.widgetTitle = widgetTitle;
          this.sgvData = sgvData;
        });
      } else {
        setState(() {
          this.sgvData = sgvData;
        });
      }


    } catch (e) {
      print('Error making request: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSgvData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reläa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              ).then((_) => setState(() {}));
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GlassStatus(),
          ElevatedButton(
            onPressed: fetchSgvData,
            child: const Text('Force Fetch SGV Data'),
          ),
          // Expanded(
          //   child: sgvData.isNotEmpty
          //       ? ListView.builder(
          //     itemCount: sgvData.length,
          //     itemBuilder: (BuildContext context, int index) {
          //       return ListTile(title: Text(XDripUtils.getWidgetTitle(sgvData[index], fallback: widgetTitle, unitsHint: sgvData.first.unitsHint)));
          //     },
          //   )
          //       : SizedBox(
          //     height: 40,
          //     width: 40,
          //     child: CircularProgressIndicator(),
          //   )
          // ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
                children: [
                  ListTile(title: Text(sgvData.isNotEmpty ? widgetTitle : 'Loading xDrip+ data...')),
                  Container(
                    height: 70,
                    color: Colors.white,
                    child: sgvData.isNotEmpty ? Sparkline(
                      data: XDripUtils.generateChartData(sgvData),
                      gridLinesEnable: true,
                      pointsMode: PointsMode.last,
                      pointSize: 4.0,
                      pointColor: Colors.blue,
                    ) : Text('...'),
                  )
                ]
            ),
          ),
          ListTile(
            title: Row(
              children: [
                _ui.xDripImageMode
                    ? Image(
                  image: AssetImage('assets/icons/xDrip+.png'),
                  height: 20,
                )
                    : Icon(Icons.notifications),
                SizedBox(width: 10),
                Text('xDrip+ values'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => XDripPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                _ui.trainNerdMode
                    ? Image(
                        image: AssetImage('assets/icons/groen.png'),
                        height: 20,
                      )
                    : Icon(Icons.calendar_today),
                SizedBox(width: 10),
                Text('Calendar Integration'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
