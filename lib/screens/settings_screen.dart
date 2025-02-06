import 'package:relaa/screens/settings/dashboard_screen.dart';
import 'package:relaa/screens/settings/debug_screen.dart';
import 'package:relaa/screens/settings/homeassistant_screen.dart';
import 'package:relaa/screens/settings/whisper_screen.dart';
import 'package:flutter/material.dart';

import 'package:relaa/utils/ui_perfs.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});


  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late UiPerfs _uiPerfs;
  late bool xDripmode;
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _uiPerfs = UiPerfs.singleton;
    await _uiPerfs.load();
    setState(() {
      xDripmode = _uiPerfs.xDripImageMode;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('xDrip+ image mode'),
            value: _uiPerfs.xDripImageMode,
            onChanged: (bool value) {
              _uiPerfs.xDripImageMode = value;
              setState(() {
                xDripmode = value;
              });
            },
          ),

          ListTile(
            title: Row(
              children: [
                Icon(Icons.dashboard),
                SizedBox(width: 10),
                Text('G1 Dashboard'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardSettingsPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.home),
                SizedBox(width: 10),
                Text('HomeAssistant'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeAssistantSettingsPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.mic),
                SizedBox(width: 10),
                Text('Whisper'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WhisperSettingsPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.bug_report),
                SizedBox(width: 10),
                Text('Debug'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DebugPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
