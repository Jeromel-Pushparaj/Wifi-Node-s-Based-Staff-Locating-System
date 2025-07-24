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
  WidgetsFlutterBinding.ensureInitialized();


  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'staff_presence_channel',
      channelName: 'Staff Presence Service',
      channelDescription: 'This service keeps the staff presence active.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 5000,
      autoRunOnBoot: true,
      allowWakeLock: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff Presence',
      home: const StaffIdScreen(),
    );
  }
}

class StaffIdScreen extends StatefulWidget {
  const StaffIdScreen({super.key});

  @override
  _StaffIdScreenState createState() => _StaffIdScreenState();
}

class _StaffIdScreenState extends State<StaffIdScreen> {
  final TextEditingController _controller = TextEditingController();

  void _askPermissions() async {
    print("[DEBUG] Requesting permissions...");
    await Permission.location.request();
    await Permission.ignoreBatteryOptimizations.request();
    print("[DEBUG] Permissions requested");
  }

  void _saveStaffId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('staffId', _controller.text);
    print("[DEBUG] Staff ID saved: ${_controller.text}");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Staff ID Saved! Starting background service...')),
    );
    _startForegroundService();
  }

  void _startForegroundService() {
    print("[DEBUG] Starting foreground service...");
    FlutterForegroundTask.startService(
      notificationTitle: 'Staff Presence Active',
      notificationText: 'Monitoring Wi-Fi for location updates',
      callback: startCallback,
    );
  }

  void _testBackendUpdate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? staffId = prefs.getString('staffId');
    if (staffId != null) {
      print("[DEBUG] Sending test update for StaffID: $staffId");
      try {
        final response = await http.post(
          Uri.parse("http://192.168.1.12:8084/api/staff/update-location?staffId=$staffId&nodeName=staffRoom"),
        );
        print("[DEBUG] Backend responded: ${response.statusCode} ${response.body}");
      } catch (e) {
        print("[DEBUG] Backend test error: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _askPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Staff Presence Setup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Enter your Staff ID"),
            TextField(controller: _controller),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveStaffId,
              child: const Text("Save & Start"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _testBackendUpdate,
              child: const Text("Test Backend Update"),
            ),
          ],
        ),
      ),
    );
  }
}

void startCallback() {
  print("[DEBUG] startCallback called");
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  Timer? _timer;
  List<String> knownSSIDs = [];
  String? staffId;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    print("[DEBUG] MyTaskHandler.onStart called");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    staffId = prefs.getString('staffId');
    print("[DEBUG] Loaded staff ID: $staffId");

    await _fetchKnownNodes();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      print("[DEBUG] Timer tick - scanning Wi-Fi");
      await _scanAndUpdate();
    });

    Timer.periodic(const Duration(minutes: 5), (_) async {
      print("[DEBUG] Refreshing known nodes from server...");
      await _fetchKnownNodes();
    });
  }

  Future<void> _fetchKnownNodes() async {
    if (staffId == null) return;
    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.12:8084/api/nodes"),
      );
      if (response.statusCode == 200) {
        List<dynamic> nodes = jsonDecode(response.body);
        knownSSIDs = nodes.map<String>((node) => node['ssid'] as String).toList();
        print("[DEBUG] Fetched nodes: $knownSSIDs");
      } else {
        print("[DEBUG] Error fetching nodes: ${response.statusCode}");
      }
    } catch (e) {
      print("[DEBUG] Fetch nodes error: $e");
    }
  }

  Future<void> _scanAndUpdate() async {
    if (staffId == null || knownSSIDs.isEmpty) {
      print("[DEBUG] No StaffID or nodes. Skipping scan.");
      return;
    }
    try {
      String? ssid = await WiFiForIoTPlugin.getSSID();
      print("[DEBUG] Currently connected SSID: $ssid");
      if (ssid != null && knownSSIDs.contains(ssid)) {
        print("[DEBUG] Matched SSID: $ssid");
        await _updateLocation(ssid);
      } else {
        print("[DEBUG] No matching SSID found");
      }
    } catch (e) {
      print("[DEBUG] Wi-Fi scan error: $e");
    }
  }

  Future<void> _updateLocation(String node) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.12:8084/api/staff/update-location?staffId=$staffId&nodeName=$node"),
      );
      print("[DEBUG] Location update response: ${response.statusCode} ${response.body}");
    } catch (e) {
      print("[DEBUG] Update location error: $e");
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print("[DEBUG] MyTaskHandler.onDestroy called");
    _timer?.cancel();
  }

  @override
  void onButtonPressed(String id) {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    print("[DEBUG] MyTaskHandler.onEvent called");
  }
}
