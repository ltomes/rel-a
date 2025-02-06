import 'dart:async';

import 'package:relaa/services/bluetooth_manager.dart';
import 'package:flutter/material.dart';
import 'package:relaa/utils/themes.dart';

class GlassStatus extends StatefulWidget {
  const GlassStatus({super.key});

  @override
  State<GlassStatus> createState() => GlassStatusState();
}

class GlassStatusState extends State<GlassStatus> {
  BluetoothManager bluetoothManager = BluetoothManager();

  bool isConnected = false;
  bool isScanning = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
    }
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      isConnected = bluetoothManager.isConnected;
      isScanning = bluetoothManager.isScanning;
    });
  }

  void _scanAndConnect() {
    try {
      bluetoothManager.startScanAndConnect(
        onUpdate: (_) => _refreshData(),
      );
    } catch (e) {
      debugPrint('Error in _scanAndConnect: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: context.isDarkMode ? Colors.white70 : Colors.black54);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            bluetoothManager.isConnected
                ? const Text(
                    'Connected to G1 glasses',
                    style: TextStyle(color: Colors.green),
                  )
                : ElevatedButton(
                    onPressed: isScanning ? null : _scanAndConnect,
                    child: isScanning
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 10),
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              Text('Scanning for G1 glasses',
                                  style: TextStyle(color: context.isDarkMode ? Colors.white70 : Colors.black54)),
                            ],
                          )
                        : Text('Connect to G1',
                      style: TextStyle(color: context.isDarkMode ? Colors.white70 : Colors.black54),),
                  ),
          ],
        ),
      ),
    );
  }
}
