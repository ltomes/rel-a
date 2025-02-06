import 'package:relaa/screens/settings_screen.dart';
import 'package:relaa/screens/xdrip.dart';
import 'package:relaa/utils/ui_perfs.dart';
import 'package:relaa/widgets/glass_status.dart';
import 'package:flutter/material.dart';

import 'package:chart_sparkline/chart_sparkline.dart';

import 'package:relaa/services/xdrip_sgv_service.dart';
import 'package:relaa/models/android/xdrip_sgv_model.dart';
import 'package:relaa/utils/xdrip.dart';

extension DarkMode on BuildContext {
  /// is dark mode currently enabled?
  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<SgvResponse> sgvData = []; // Initialize it as an empty list
  late String widgetTitle = 'Loading xDrip+ data...';

  Future<void> fetchSgvData() async {
    final sgvService = SgvService(); // Initialize the service here
    try {
      sgvData = await sgvService.fetchSgvData();
      if (sgvData.isNotEmpty) {
        widgetTitle = XDripUtils.getWidgetTitle(sgvData.first,
            fallback: widgetTitle, unitsHint: sgvData.first.unitsHint);
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
            child: Text('Force Fetch SGV Data',
                style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.grey)),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Container(
                height: 70,
                color: Colors.white,
                child: sgvData.isNotEmpty
                    ? Sparkline(
                        data: XDripUtils.generateChartData(sgvData),
                        gridLinesEnable: true,
                        pointsMode: PointsMode.last,
                        pointSize: 4.0,
                        pointColor: Colors.blue,
                        backgroundColor:
                            context.isDarkMode ? Colors.black87 : Colors.white,
                      )
                    : Text('...'),
              ),
              ListTile(
                  title: Text(sgvData.isNotEmpty
                      ? widgetTitle
                      : 'Loading xDrip+ data...',
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 10, )),
                horizontalTitleGap: -15,
              ),
            ]),
          ),
          ListTile(
            title: Row(
              children: [
                Image(
                  image: AssetImage('assets/icons/xDrip+.png'),
                  height: 20,
                ),
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
          Container(height: 400, child: SettingsPage()),
        ],
      ),
    );
  }
}
