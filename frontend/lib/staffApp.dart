import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff Wi-Fi Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WifiTrackerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WifiTrackerPage extends StatefulWidget {
  const WifiTrackerPage({super.key});

  @override
  _WifiTrackerPageState createState() => _WifiTrackerPageState();
}

class _WifiTrackerPageState extends State<WifiTrackerPage> {
  final TextEditingController _staffIdController = TextEditingController();
  List<String> knownNodes = []; // Fetched from backend
  String? matchedSSID;
  bool isNodeFound = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchKnownNodes();
    _startScanning();
  }

  // Fetch nodes for the staff
  Future<void> _fetchKnownNodes() async {
    final staffId = _staffIdController.text.trim();
    if (staffId.isEmpty) {
      print("[DEBUG] Staff ID is empty. Skipping fetch.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.12:8084/api/nodes"),
      );

      if (response.statusCode == 200) {
        List<dynamic> nodes = jsonDecode(response.body);
        setState(() {
          knownNodes = nodes.map((node) => node['ssid'].toString()).toList();
        });
        print("[DEBUG] Fetched known nodes: $knownNodes");
      } else {
        print("[ERROR] Failed to fetch nodes: ${response.statusCode}");
      }
    } catch (e) {
      print("[ERROR] Fetch nodes failed: $e");
    }
  }

  // Start periodic scanning
  void _startScanning() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _scanForNodes();
    });
    _scanForNodes();
  }

  // Scan Wi-Fi networks
  Future<void> _scanForNodes() async {
    if (_staffIdController.text.trim().isEmpty || knownNodes.isEmpty) {
      print("[DEBUG] Staff ID or known nodes missing. Skipping scan.");
      return;
    }

    try {
      List<WifiNetwork> networks = await WiFiForIoTPlugin.loadWifiList();
      bool found = false;

      for (var network in networks) {
        String ssid = network.ssid ?? "";
        print("[DEBUG] Detected SSID: $ssid");

        if (knownNodes.contains(ssid)) {
          print("[MATCH] Found node: $ssid");
          matchedSSID = ssid;
          found = true;
          await _updateStaffLocation(ssid);
          break;
        }
      }

      setState(() {
        isNodeFound = found;
      });

      if (!found) {
        print("[DEBUG] No matching SSID found.");
      }
    } catch (e) {
      print("[ERROR] Wi-Fi scan failed: $e");
      setState(() {
        isNodeFound = false;
      });
    }
  }

  // Update staff location to backend
  Future<void> _updateStaffLocation(String node) async {
    final staffId = _staffIdController.text.trim();
    if (staffId.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.12:8084/api/staff/update-location?staffId=$staffId&nodeName=$node"),
      );

      if (response.statusCode == 200) {
        print("[SUCCESS] Location updated for $staffId at $node");
      } else {
        print("[ERROR] Update failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("[ERROR] Update failed: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Staff Wi-Fi Tracker')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _staffIdController,
              decoration: InputDecoration(
                labelText: "Enter Staff ID",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _fetchKnownNodes();
                await _scanForNodes();
              },
              child: Text('Fetch Nodes & Scan Now'),
            ),
            SizedBox(height: 40),
            Icon(
              isNodeFound ? Icons.wifi : Icons.wifi_off,
              size: 100,
              color: isNodeFound ? Colors.green : Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              isNodeFound
                  ? "Matched Node: $matchedSSID"
                  : "No Matching Node Found",
              style: TextStyle(fontSize: 24, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
