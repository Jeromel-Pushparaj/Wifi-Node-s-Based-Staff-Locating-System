# Wifi-Node-s-Based-Staff-Locating-System 
<img width="1102" height="829" alt="image" src="https://github.com/user-attachments/assets/5a0fba9c-106b-48b1-abdd-b3fa54c30ad0" />


A Flutter application that detects and displays the presence of staff members in different rooms using  Wi-Fi-Nodes in each rooms and place in thier departmen.

##  Features

-  Detects staff mobile phones detects one of wifi based Access point
-  Maps each staff member to detected Wifi node
-  Real-time UI updates using setState
-  Works on local server with device presence detection
-  Clean, minimal Flutter UI for grid-based room display

## 🛠️ Tech Stack

| Layer         | Technology       |
|---------------|------------------|
| Frontend      | Flutter (Dart)   |
| Backend       |Java Spring boot, Mysql |
| Network       | Wi-Fi Scanning   |
| UI Toolkit    | Material Design  |
| Device Logic  | ESP32 Access Points |

##  UI Overview

Each room is displayed as a card. If multiple staff are present, their names appear as a vertical list inside the card.

###  Example Grid:

| Room         | Staff Present         |
|--------------|------------------------|
| Lab1       | Dr. kesavaraja        |
| Lab2       | —                      |
| StaffRoom       | Dr. Bavani             |

##  How It Works

1.  Each staff member’s mobile device is identified by their MAC or device name.
2.  The ESP32 or scanner checks which devices are connected to the Wi-Fi network.
3.  Flutter app receives this data and maps it to known staff.
4. 🖥 Displays a real-time dashboard of room occupancy.

##  Folder Structure

```bash
lib/
├── main.dart
├── services/
│   └── wifi_scanner.dart
├── models/
│   └── staff_model.dart
└── widgets/
    └── staff_card.dart
```

📦 Setup Instructions
Clone the repo

```bash
git clone https://github.com/Jeromel-Pushparaj/Wifi-Node-s-Based-Staff-Locating-System.git
cd Wifi-Node-s-Based-Staff-Locating-System.git

# To run a backend service
# you need a Mysql and the table which you can create using the mysql file in the backend foler

cd backend
gradlew build

gradlew bootrun

```

Install Flutter dependencies
```bash
cd frontend
flutter pub get
```

Run the app
```bash
flutter run
```

# Screenshots
### Staff App UI
<img width="250" alt="image" src="https://github.com/user-attachments/assets/5ff69741-eca7-4d9a-bb22-8fb1e49c065e" /><br>
### Student App UI
**Room Grid	Multiple Staff in One Room**
<br><img width="250" alt="image" src="https://github.com/user-attachments/assets/7ee0bb03-c84d-4a17-8ce8-9271beb66aff" /><br>


# Author
Jeromel Pushparaj
 Discord - https://discordapp.com/users/jeromel6724

Feel free to use and modify for personal or academic projects.

