import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydrapets_flutter_application/models/pet_log_data.dart';
import 'package:hydrapets_flutter_application/models/water_log_data.dart';
import 'package:hydrapets_flutter_application/views/pet_log.dart';
import 'package:hydrapets_flutter_application/views/water_log.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:hydrapets_flutter_application/myconfig.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hydrapets_flutter_application/views/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1; // Default to menu (center)
  
  // Data variables
  WaterLogData? latestWaterData;
  PetLogData? latestPetData;
  List<WaterLogData> waterLogs = [];
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      await Future.wait([
        _fetchLatestWaterData(),
        _fetchLatestPetData(),
      ]);
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchLatestWaterData() async {
    try {
      final response = await http.get(
        Uri.parse('${MyConfig.servername}/Pet_Water_Dispenser/get_water_log.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        if (jsonData.isNotEmpty) {
          setState(() {
            latestWaterData = WaterLogData.fromJson(jsonData.first);
            // Get the last 20 water log entries for the graphs
            waterLogs = jsonData.take(20).map((data) => WaterLogData.fromJson(data)).toList();
            // Reverse to show oldest to newest
            waterLogs = waterLogs.reversed.toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching water data: $e');
    }
  }

  Future<void> _fetchLatestPetData() async {
    try {
      final response = await http.get(
        Uri.parse('${MyConfig.servername}/Pet_Water_Dispenser/get_pet_log.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        if (jsonData.isNotEmpty) {
          setState(() {
            latestPetData = PetLogData.fromJson(jsonData.first);
          });
        }
      }
    } catch (e) {
      print('Error fetching pet data: $e');
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return const Color.fromARGB(255, 14, 14, 126);
      case 'low':
        return Colors.orange;
      case 'overflow':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  Color getDispenserColor(String status) {
    switch (status.toLowerCase()) {
      case 'on':
        return const Color.fromARGB(255, 20, 144, 24);
      case 'off':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  String getPetStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'petdetected':
        return 'Your Pet Is Here !';
      case 'nopet':
        return 'No Pet Detected';
      default:
        return 'Unknown Error';
    }
  }

  @override
  Widget build(BuildContext context) { 
    final String today = DateFormat('d MMMM yyyy').format(DateTime.now());
    
    // Use fetched data or default values
    final int waterPercent = latestWaterData?.waterPercentage ?? 0;
    final int waterNow = latestWaterData?.waterLevel ?? 0;
    final int waterThreshold = 1300;
    final String waterStatus = latestWaterData?.waterStatus ?? 'Normal';
    final String relayStatus = latestWaterData?.relayStatus ?? 'OFF';
    final String petStatus = latestPetData != null 
        ? getPetStatusText(latestPetData!.petStatus)
        : 'No Pet Detected';
    final String petTime = latestPetData?.formattedTime ?? '--:--';
    final String ledStatus = latestPetData?.ledStatus ?? 'OFF';
    
    // Debug print for pet status
    print('Pet Status: $petStatus');
    print('Raw Pet Status from API: ${latestPetData?.petStatus}');
    
    // Format timestamp for display
    final String lastUpdatedTime = latestWaterData != null 
        ? DateFormat('dd:MM:yyyy, HH:mm:ss').format(DateTime.parse(latestWaterData!.timestamp))
        : '--:--:--';
    
    // Format pet timestamp for display
    final String lastUpdatedPetTime = latestPetData != null 
        ? DateFormat('dd:MM:yyyy, HH:mm:ss').format(latestPetData!.timestamp)
        : '--:--:--';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color.fromARGB(255, 160, 222, 85),
            Colors.white,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'HydraPets',
            style: GoogleFonts.righteous(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
          centerTitle: true,
          elevation: 10,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bgmix.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
          toolbarHeight: 100,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [Image.asset('assets/cat_plays.gif')],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hello Buddy !',
                              style: GoogleFonts.righteous(
                                fontSize: 32,
                                color: const Color.fromARGB(255, 163, 255, 15),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12), // Add space between text and date
                            Text(
                              today,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: const Color.fromARGB(255, 163, 255, 15),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: SizedBox(
                            height: 250,
                            width: 250,
                            child: SfRadialGauge(
                              axes: <RadialAxis>[
                                RadialAxis(
                                  minimum: 0,
                                  maximum: 100,
                                  showLabels: false,
                                  showTicks: false,
                                  axisLineStyle: const AxisLineStyle(
                                    thickness: 0.2,
                                    thicknessUnit: GaugeSizeUnit.factor,
                                    cornerStyle: CornerStyle.bothCurve,
                                  ),
                                  pointers: <GaugePointer>[
                                    RangePointer(
                                      value: waterPercent.toDouble(),
                                      width: 0.2,
                                      sizeUnit: GaugeSizeUnit.factor,
                                      cornerStyle: CornerStyle.bothCurve,
                                      gradient: const SweepGradient(
                                        colors: <Color>[
                                          Color.fromARGB(255, 0, 146, 243),
                                          Color.fromARGB(255, 52, 245, 223),
                                          Color.fromARGB(255, 211, 252, 153),
                                        ],
                                        stops: <double>[0.0, 0.5, 1.0],
                                      ),
                                    ),
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                      widget: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/water_drop.gif',
                                            height: 70,
                                            width: 70,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$waterPercent'
                                            '%',
                                            style: GoogleFonts.righteous(
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                255,
                                                14,
                                                107,
                                                183,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Water Pecentage',
                                            style: GoogleFonts.righteous(
                                              fontSize: 15,
                                              color: const Color.fromARGB(
                                                255,
                                                14,
                                                107,
                                                183,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      angle: 90,
                                      positionFactor: 0.1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          color: const Color.fromARGB(255, 91, 171, 237),
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Status: ',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      waterStatus,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 22,
                                        color: getStatusColor(waterStatus),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Dispenser: ',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      relayStatus,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 22,
                                        color: getDispenserColor(relayStatus),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/bgwater.png',
                              ), // Replace with your image path
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 207, 228, 245),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Water Level',
                                style: GoogleFonts.righteous(
                                  fontSize: 23,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$waterNow      ',
                                    style: GoogleFonts.righteous(
                                      fontSize: 35,
                                      color: const Color.fromARGB(255, 254, 254, 254),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '|',
                                    style: GoogleFonts.righteous(
                                      fontSize: 30,
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '     $waterThreshold  ',
                                    style: GoogleFonts.righteous(
                                      fontSize: 35,
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'Now',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '  Treshold',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text('Last Updated: $lastUpdatedTime',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WaterLog(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'View Logs',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95, // or 0.9 for 90%
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), // remove horizontal margin
                              color: Colors.white,
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  initiallyExpanded: true,
                                  collapsedIconColor: Colors.blue,
                                  iconColor: Colors.blue,
                                  title: Row(
                                    children: [
                                      const Icon(Icons.water_drop, color: Colors.blue, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Water Level Trend',
                                        style: GoogleFonts.righteous(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      )
                                    ],
                                  ),
                                  children: [
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: SizedBox(
                                        height: 200,
                                        width: double.infinity,
                                        child: LineChart(
                                          LineChartData(
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              horizontalInterval: 200,
                                              getDrawingHorizontalLine: (value) => FlLine(
                                                color: Colors.blue.withOpacity(0.08),
                                                strokeWidth: 1,
                                              ),
                                            ),
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(0)}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
                                                axisNameWidget: const Padding(
                                                  padding: EdgeInsets.only(right: 6.0),
                                                  child: Text('ml', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
                                                ),
                                                axisNameSize: 20,
                                              ),
                                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (value, meta) {
                                                    int index = value.toInt();
                                                    if (index % 2 == 0 && index <= 20 && index < waterLogs.length) {
                                                      return Text('$index', style: const TextStyle(fontSize: 10, color: Colors.blue));
                                                    }
                                                    return Container();
                                                  },
                                                  interval: 1,
                                                  reservedSize: 24,
                                                ),
                                                axisNameWidget: const Padding(
                                                  padding: EdgeInsets.only(top: 6.0),
                                                  child: Text('Time (10s)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
                                                ),
                                                axisNameSize: 20,
                                              ),
                                            ),
                                            borderData: FlBorderData(show: false),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: waterLogs.asMap().entries.map((entry) {
                                                  return FlSpot(entry.key.toDouble(), entry.value.waterLevel.toDouble());
                                                }).toList(),
                                                isCurved: true,
                                                color: Colors.blue.shade400,
                                                barWidth: 3,
                                                isStrokeCapRound: true,
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                                    radius: 5,
                                                    color: Colors.white,
                                                    strokeWidth: 3,
                                                    strokeColor: Colors.blue,
                                                  ),
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.blue,
                                                      const Color.fromARGB(255, 189, 245, 100).withOpacity(0.2),
                                                      Colors.transparent,
                                                    ],
                                                    stops: [0.1, 0.6, 1.0],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            lineTouchData: LineTouchData(
                                              touchTooltipData: LineTouchTooltipData(
                                                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                                  return touchedBarSpots.map((barSpot) {
                                                    final d = waterLogs[barSpot.x.toInt()];
                                                    return LineTooltipItem(
                                                      'Water Level: ${d.waterLevel}ml\n${d.timestamp}',
                                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                                    );
                                                  }).toList();
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: SizedBox(
                                        height: 200,
                                        width: double.infinity,
                                        child: BarChart(
                                          BarChartData(
                                            alignment: BarChartAlignment.spaceBetween,
                                            maxY: waterLogs.isNotEmpty ? waterLogs.map((d) => d.waterLevel.toDouble()).fold<double>(0, (prev, t) => t > prev ? t : prev) + 2 : 50,
                                            minY: waterLogs.isNotEmpty ? waterLogs.map((d) => d.waterLevel.toDouble()).fold<double>(100, (prev, t) => t < prev ? t : prev) - 2 : 0,
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              horizontalInterval: 200,
                                              getDrawingHorizontalLine: (value) => FlLine(
                                                color: Colors.blue.withOpacity(0.08),
                                                strokeWidth: 1,
                                              ),
                                            ),
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(1)}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
                                                axisNameWidget: const Padding(
                                                  padding: EdgeInsets.only(right: 6.0),
                                                  child: Text('ml', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
                                                ),
                                                axisNameSize: 20,
                                              ),
                                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (value, meta) {
                                                    int index = value.toInt();
                                                    if (index % 2 == 0 && index <= 20 && index < waterLogs.length) {
                                                      return Text('$index', style: const TextStyle(fontSize: 10, color: Colors.blue));
                                                    }
                                                    return Container();
                                                  },
                                                  interval: 1,
                                                  reservedSize: 24,
                                                ),
                                                axisNameWidget: const Padding(
                                                  padding: EdgeInsets.only(top: 6.0),
                                                  child: Text('Time (10s)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
                                                ),
                                                axisNameSize: 20,
                                              ),
                                            ),
                                            barGroups: waterLogs.asMap().entries.map((entry) {
                                              int index = entry.key;
                                              final d = entry.value;
                                              return BarChartGroupData(
                                                x: index,
                                                barRods: [
                                                  BarChartRodData(
                                                  toY: d.waterLevel.toDouble(),
                                                  width: 8, // Slightly thinner
                                                  borderRadius: BorderRadius.circular(6),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.blue,
                                                      const Color.fromARGB(255, 189, 245, 100).withOpacity(0.2),
                                                      Colors.transparent,
                                                    ],
                                                    stops: [0.0, 0.7, 1.0],
                                                    begin: Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                  ),
                                                  rodStackItems: [],
                                                ),
                                                ],
                                              );
                                            }).toList(),
                                            barTouchData: BarTouchData(
                                              enabled: true,
                                              touchTooltipData: BarTouchTooltipData(
                                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                                  final d = waterLogs[group.x.toInt()];
                                                  return BarTooltipItem(
                                                    'Water Level: ${d.waterLevel}ml\n${d.timestamp}',
                                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), // Adjusted font size
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/bgclean.png',
                              ), // Replace with your image path
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color.fromARGB(255, 138, 253, 30),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  7,
                                  19,
                                  7,
                                ).withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'Pet Tracker',
                                  style: GoogleFonts.righteous(
                                    fontSize: 23,
                                    color: const Color.fromARGB(255, 77, 198, 83),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Image.asset(
                                  'assets/pets.png',
                                  width: 300,
                                  height: 100,
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Status: ',
                                      style: GoogleFonts.righteous(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      petStatus,
                                      style: GoogleFonts.righteous(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: petStatus == 'No Pet Detected'
                                            ? Colors.red
                                            : const Color.fromARGB(255, 77, 198, 83),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Time: ',
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    petTime,
                                    style: GoogleFonts.righteous(
                                      fontSize: 30,
                                      color: const Color.fromARGB(255, 77, 198, 83),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PetLogScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        113,
                                        228,
                                        116,
                                      ),
                                      foregroundColor: Colors.green[800],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Text(
                                      'View Logs',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Led light: $ledStatus',
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 77, 198, 83),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Last Updated: $lastUpdatedPetTime',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomAppBar(
              height: 70,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    iconSize: 28, // Increased icon size
                    icon: Icon(
                      Icons.water_drop,
                      color: _selectedIndex == 0
                          ? const Color.fromARGB(255, 0, 146, 243)
                          : Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WaterLog(),
                        ),
                      );
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  IconButton(
                    iconSize: 40, // Increased icon size
                    icon: Icon(
                      Icons.home,
                      color: _selectedIndex == 1
                          ? const Color.fromARGB(255, 76, 23, 175)
                          : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                  IconButton(
                    iconSize: 32, // Increased icon size
                    icon: Icon(
                      Icons.pets,
                      color: _selectedIndex == 2
                          ? const Color.fromARGB(255, 115, 232, 52)
                          : Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PetLogScreen(),
                        ),
                      );
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
