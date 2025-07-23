import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Staff',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade900,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DepartmentScreen()),
            );
          },
          child: Text('Find Staff'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  _DepartmentScreenState createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  Map<String, List<String>> roomStaffMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStaffLocations();
    Timer.periodic(Duration(seconds: 10), (_) {
    fetchStaffLocations();
  });
  }

  Future<void> fetchStaffLocations() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.12:8084/api/staff/all"),
      );

      if (response.statusCode == 200) {
        List<dynamic> staffList = jsonDecode(response.body);
        Map<String, List<String>> tempMap = {};


        for (var staff in staffList) {
          String location = staff['location'] ?? "Unknown";
          String name = staff['name'] ?? "No Staff";
          tempMap.putIfAbsent(location, () => []).add(name);
        }
        print("[DEBUG]: $staffList");

        setState(() {
          roomStaffMap = tempMap;
          isLoading = false;
        });
        print("[DEBUG]: $roomStaffMap");
      } else {
        print("[ERROR] Failed to fetch staff: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("[ERROR] Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> rooms = [
      "Lab1",
      "Lab2",
      "Lab3",
      "Lab4",
      "Lab5",
      "StaffRoom"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Computer Science Department'),
        leading: BackButton(),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: rooms.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  String room = rooms[index];
                  print("[DEBUG]: $room - $roomStaffMap[room]");
                  List<String>? staffNames = roomStaffMap[room];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade800,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            room,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: staffNames != null
                              ? staffNames.map((name) => Text(name, style: TextStyle(color: Colors.white))).toList()
                              : [Text("No Staff", style: TextStyle(color: Colors.white))],
                            )

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
