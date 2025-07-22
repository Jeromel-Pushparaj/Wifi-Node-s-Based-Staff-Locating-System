import 'dart:convert';
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff Presence',
      home: StaffIdScreen(),
    );
  }
}

class StaffIdScreen extends StatefulWidget {
  @override
  _StaffIdScreenState createState() => _StaffIdScreenState();
}

class _StaffIdScreenState extends State<StaffIdScreen> {
  final TextEditingController _controller = TextEditingController();

  void _askPermissions() async {
    await Permission.location.request();
    await Permission.ignoreBatteryOptimizations.request();
  }

  void _saveStaffId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('staffId', _controller.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Staff ID Saved! Starting background service...')),
    );
    _startForegroundService();
  }

  void _startForegroundService() {
    FlutterForegroundTask.startService(
      notificationTitle: 'Staff Presence Active',
      notificationText: 'Monitoring Wi-Fi for location updates',
      callback: startCallback,
    );
  }

  @override
  void initState() {
    super.initState();
    _askPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Staff Presence Setup")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Enter your Staff ID"),
            TextField(controller: _controller),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveStaffId,
              child: Text("Save & Start"),
            ),
          ],
        ),
      ),
    );
  }
}

void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  Timer? _timer;
  List<String> knownSSIDs = [];
  String? staffId;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    staffId = prefs.getString('staffId');
    await _fetchKnownNodes();

    _timer = Timer.periodic(Duration(seconds: 30), (_) async {
      await _scanAndUpdate();
    });

    Timer.periodic(Duration(minutes: 5), (_) async {
      await _fetchKnownNodes(); // Refresh nodes every 5 min
    });
  }

  Future<void> _fetchKnownNodes() async {
    if (staffId == null) return;
    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.12:8081/api/nodes/for-staff/$staffId"),
      );
      if (response.statusCode == 200) {
        List<dynamic> nodes = jsonDecode(response.body);
        knownSSIDs = nodes.map<String>((node) => node['ssid'] as String).toList();
        print("Fetched nodes: $knownSSIDs");
      } else {
        print("Error fetching nodes: ${response.statusCode}");
      }
    } catch (e) {
      print("Fetch nodes error: $e");
    }
  }

  Future<void> _scanAndUpdate() async {
    if (staffId == null || knownSSIDs.isEmpty) return;
    List<WifiNetwork>? networks = await WiFiForIoTPlugin.loadWifiList();
    for (var network in networks) {
      String ssid = network.ssid ?? "";
      if (knownSSIDs.contains(ssid)) {
        print("Matched SSID: $ssid");
        await _updateLocation(ssid);
        break;
      }
    }
  }

  Future<void> _updateLocation(String node) async {
    try {
      final response = await http.post(
        Uri.parse("http://your-server-ip:8081/api/staff/update-location"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"staffId": staffId, "node": node}),
      );
      print("Updated location: ${response.statusCode}");
    } catch (e) {
      print("Update location error: $e");
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _timer?.cancel();
  }

  @override
  void onButtonPressed(String id) {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) {
    // TODO: implement onEvent
    throw UnimplementedError();
  }
}
