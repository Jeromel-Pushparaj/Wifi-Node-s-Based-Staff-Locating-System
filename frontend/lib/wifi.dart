import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Wi-Fi Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WifiDetectorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WifiDetectorPage extends StatefulWidget {
  const WifiDetectorPage({super.key});

  @override
  _WifiDetectorPageState createState() => _WifiDetectorPageState();
}

class _WifiDetectorPageState extends State<WifiDetectorPage> {
  String esp32SSID = "ESP32-Access-Point"; // Change this to your ESP32 SSID
  bool isESP32Found = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkESP32Presence();
    });
    _checkESP32Presence();
  }

  Future<void> _checkESP32Presence() async {
    try {
      List<WifiNetwork> networks = await WiFiForIoTPlugin.loadWifiList();
      bool found = networks.any((network) => network.ssid == esp32SSID);

      setState(() {
        isESP32Found = found;
      });
      print(found
          ? "[+] ESP32 '$esp32SSID' FOUND!"
          : "[-] ESP32 '$esp32SSID' NOT FOUND");
    } catch (e) {
      print("Wi-Fi Scan Error: $e");
      setState(() {
        isESP32Found = false;
      });
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
      appBar: AppBar(
        title: Text('ESP32 Wi-Fi Detector'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isESP32Found ? Icons.wifi : Icons.wifi_off,
              size: 100,
              color: isESP32Found ? Colors.green : Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              isESP32Found
                  ? "ESP32 '$esp32SSID' FOUND"
                  : "ESP32 '$esp32SSID' NOT FOUND",
              style: TextStyle(
                fontSize: 24,
                color: isESP32Found ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _checkESP32Presence,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text('Scan Now'),
            ),
          ],
        ),
      ),
    );
  }
}
