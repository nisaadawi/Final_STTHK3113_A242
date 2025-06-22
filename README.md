# 🐾 HydraPets - HydraPets: Pet Water Dispenser and Pet Motion Tracker

A comprehensive IoT solution that combines hardware automation with a mobile application to provide intelligent pet water dispensing and monitoring. The system automatically detects pets, monitors water levels, and provides real-time data visualization through a Flutter mobile app.

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Hardware Components](#hardware-components)
- [Software Components](#software-components)
- [Installation & Setup](#installation--setup)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

HydraPets is an intelligent pet water dispensing system that combines:
- **ESP32-based hardware** with sensors for water level detection and pet motion sensing
- **Flutter mobile application** for real-time monitoring and data visualization
- **PHP backend** for data logging and user management
- **Automated water dispensing** based on sensor readings

The system ensures your pets always have access to fresh water while providing you with detailed insights into their drinking patterns and water consumption.

## ✨ Features

### 🏠 Hardware Features
- **Automatic Water Dispensing**: Smart relay control based on water level sensors
- **Pet Detection**: PIR motion sensor to detect when pets approach the dispenser
- **Water Level Monitoring**: Ultrasonic and analog sensors for precise water level measurement
- **Visual Feedback**: OLED display showing real-time water level and distance
- **LED Indicators**: Visual status indicators for pet detection
- **WiFi Connectivity**: Real-time data transmission to cloud backend

### 📱 Mobile App Features
- **Real-time Dashboard**: Live water level monitoring with gauge visualization
- **Pet Activity Tracking**: Monitor when pets approach the water dispenser
- **Historical Data**: Charts and graphs showing water consumption patterns
- **User Authentication**: Secure login and registration system
- **Platform**: Works on Android

**🧑🏻‍💻 Application Interface**

**Login & Register**

![image](https://github.com/user-attachments/assets/fd5be718-3e19-4aae-b180-366fc6caf525)

**Homepage/Dashboard**

![image](https://github.com/user-attachments/assets/4029e992-ff9b-4d33-a47e-4e00a070e6ca)

**Water Logs**

![image](https://github.com/user-attachments/assets/14e756b2-7b64-4f94-be0f-ff3c1f21d614)

**Pet Logs**

![image](https://github.com/user-attachments/assets/63b49c1b-3709-47ba-8ced-6f65748706fb)


### 🔧 System Features
- **Smart Automation**: Automatic water refill when levels are low
- **Overflow Protection**: Prevents water overflow with intelligent sensor thresholds
- **Data Logging**: Comprehensive logging of all sensor readings and events
- **Cloud Integration**: Real-time data synchronization with web backend
- **Error Handling**: Robust error handling and WiFi reconnection

## 🏗️ System Architecture

```
┌─────────────────┐    WiFi    ┌─────────────────┐    HTTP    ┌─────────────────┐
│   ESP32 Device  │ ────────── │   PHP Backend   │ ────────── │ Flutter Mobile  │
│                 │            │                 │            │     App         │
│ • Water Sensors │            │ • Data Logging  │            │ • Dashboard     │
│ • PIR Sensor    │            │ • User Auth     │            │ • Charts        │
│ • Relay Control │            │ • API Endpoints │            │ • Real-time     │
│ • OLED Display  │            │ • Database      │            │   Monitoring    │
└─────────────────┘            └─────────────────┘            └─────────────────┘
```

## 🔌 Hardware Components

### Required Components
- **ESP32 Development Board**
- **Water Level Sensor** (Analog)
- **Ultrasonic Distance Sensor** (HC-SR04)
- **PIR Motion Sensor**
- **5V Relay Module**
- **OLED Display** (128x32 SSD1306)
- **LED Indicator**
- **Water Pump** (12V)
- **Water Container**
- **Breadboard & Jumper Wires**

### Pin Connections
| Component | ESP32 Pin | Description |
|-----------|-----------|-------------|
| Water Sensor | GPIO 36 | Analog water level reading |
| PIR Sensor | GPIO 13 | Digital pet detection |
| Ultrasonic Trig | GPIO 5 | Distance measurement trigger |
| Ultrasonic Echo | GPIO 18 | Distance measurement echo |
| Relay | GPIO 25 | Water pump control |
| LED | GPIO 2 | Status indicator |
| OLED SDA | GPIO 21 | I2C data line |
| OLED SCL | GPIO 22 | I2C clock line |

## 💻 Software Components

### 1. Arduino Code (`Water_Dispenser_and_Pet_Motion/`)
- **Main Features**:
  - WiFi connectivity management
  - Sensor data collection and processing
  - Automatic water dispensing logic
  - Real-time data transmission to backend
  - OLED display updates
  - Error handling and recovery

### 2. Flutter Mobile App (`hydrapets_flutter_application/`)
- **Key Dependencies**:
  - `syncfusion_flutter_gauges`: Water level gauge visualization
  - `syncfusion_flutter_charts`: Historical data charts
  - `fl_chart`: Additional charting capabilities
  - `http`: API communication
  - `google_fonts`: Typography
  - `shared_preferences`: Local data storage

- **Screens**:
  - Splash Screen
  - Login/Registration
  - Dashboard (Main monitoring interface)
  - Water Log (Historical water data)
  - Pet Log (Pet activity history)

### 3. PHP Backend (`backend/`)
- **API Endpoints**:
  - `login_user.php`: User authentication
  - `add_user.php`: User registration
  - `log_water.php`: Water sensor data logging
  - `log_pet.php`: Pet detection data logging
  - `get_water_log.php`: Retrieve water data
  - `get_pet_log.php`: Retrieve pet activity data

## 🚀 Installation & Setup

### Prerequisites
- Arduino IDE with ESP32 board support
- Flutter SDK (3.8.0 or higher)
- PHP server with MySQL database
- Android Studio / VS Code

### Hardware Setup
1. **Assemble the circuit** according to the pin connections above
2. **Connect water pump** to the relay module
3. **Mount sensors** in appropriate positions on the water container
4. **Power the system** with 12V power supply

### Arduino Setup
1. Open `Water_Dispenser_and_Pet_Motion.ino` in Arduino IDE
2. Install required libraries:
   - WiFi.h (built-in)
   - HTTPClient.h (built-in)
   - ArduinoJson.h
   - Adafruit_GFX.h
   - Adafruit_SSD1306.h
3. Update WiFi credentials in the code
4. Update server URLs to match your backend
5. Upload to ESP32

### Backend Setup
1. **Database Configuration**:
   ```sql
   -- Create database and tables
   CREATE DATABASE hydrapets;
   USE hydrapets;
   
   -- Users table
   CREATE TABLE users (
       id INT AUTO_INCREMENT PRIMARY KEY,
       username VARCHAR(50) UNIQUE NOT NULL,
       password VARCHAR(255) NOT NULL,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   
   -- Water logs table
   CREATE TABLE water_logs (
       id INT AUTO_INCREMENT PRIMARY KEY,
       water_level INT NOT NULL,
       water_percentage INT NOT NULL,
       water_status VARCHAR(20) NOT NULL,
       relay_status VARCHAR(10) NOT NULL,
       timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   
   -- Pet logs table
   CREATE TABLE pet_logs (
       id INT AUTO_INCREMENT PRIMARY KEY,
       pet_status VARCHAR(20) NOT NULL,
       led_status VARCHAR(10) NOT NULL,
       timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   ```

2. **Update `dbconfig.php`** with your database credentials
3. **Upload backend files** to your web server
4. **Test API endpoints** using Postman or similar tool

### Flutter App Setup
1. **Navigate to app directory**:
   ```bash
   cd hydrapets_flutter_application
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Update server configuration** in `lib/myconfig.dart`:
   ```dart
   class MyConfig {
     static const String servername = "https://your-domain.com";
   }
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📱 Usage

### Initial Setup
1. **Power on the ESP32 device**
2. **Wait for WiFi connection** (LED indicator will show status)
3. **Open the Flutter app** on your mobile device
4. **Register a new account** or login with existing credentials
5. **View the dashboard** to see real-time data

### Monitoring Features
- **Water Level Gauge**: Real-time water level percentage
- **Pet Detection Status**: Shows when pets are near the dispenser
- **Historical Charts**: View water consumption patterns over time
- **System Status**: Monitor relay and sensor status

### Automation
The system automatically:
- **Refills water** when levels drop below threshold
- **Stops dispensing** when water reaches optimal level
- **Prevents overflow** with intelligent sensor monitoring
- **Logs all activities** for historical analysis


**Made with ❤️ for happy pets everywhere! 🐕🐱** 
