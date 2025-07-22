import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff & Student App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 60),
                textStyle: TextStyle(fontSize: 24),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StaffLoginPage()),
                );
              },
              child: Text('Staff'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 60),
                textStyle: TextStyle(fontSize: 24),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentPage()),
                );
              },
              child: Text('Find Staff'),
            ),
          ],
        ),
      ),
    );
  }
}

class StaffLoginPage extends StatefulWidget {
  const StaffLoginPage({super.key});

  @override
  _StaffLoginPageState createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Simulated admin data (replace with API later)
  final Map<String, String> adminData = {
    "12345": "password123", // id: password
    "67890": "pass67890"
  };

  void _login() {
    final id = _idController.text.trim();
    final password = _passwordController.text;

    if (adminData.containsKey(id) && adminData[id] == password) {
      // Correct credentials
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StaffDashboardPage()),
      );
    } else {
      // Wrong credentials
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid ID or Password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'Staff ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Staff ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Login', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StaffDashboardPage extends StatelessWidget {
  const StaffDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Dashboard'),
      ),
      body: Center(
        child: Text(
          'Welcome to Staff Dashboard!',
          style: TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}

class StudentPage extends StatelessWidget {
  final List<Map<String, dynamic>> departments = [
    {
      "name": "Computer Science",
      "staff": [
        {"name": "Dr. John Smith", "inCabin": true},
        {"name": "Prof. Lisa Ray", "inCabin": false},
        {"name": "Mr. Kevin Hart", "inCabin": true},
      ],
    },
    {
      "name": "Electronics",
      "staff": [
        {"name": "Dr. Susan Lee", "inCabin": false},
        {"name": "Prof. David Kim", "inCabin": false},
        {"name": "Ms. Emma Watson", "inCabin": true},
      ],
    },
    {
      "name": "Mechanical",
      "staff": [
        {"name": "Dr. Mike Tyson", "inCabin": true},
        {"name": "Prof. Rachel Green", "inCabin": false},
      ],
    },
  ];

   StudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Page'),
      ),
      body: ListView.builder(
        itemCount: departments.length,
        itemBuilder: (context, index) {
          var department = departments[index];
          return ExpansionTile(
            title: Text(
              department['name'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            children: department['staff'].map<Widget>((staff) {
              return ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
                title: Text(staff['name']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      staff['inCabin'] ? Icons.circle : Icons.circle_outlined,
                      color: staff['inCabin'] ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      staff['inCabin'] ? "In Cabin" : "Not In Cabin",
                      style: TextStyle(
                        color: staff['inCabin'] ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}