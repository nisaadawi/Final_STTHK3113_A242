import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:hydrapets_flutter_application/views/dashboard_screen.dart';
import 'package:hydrapets_flutter_application/views/pet_log.dart';
import 'package:intl/intl.dart';
import 'package:hydrapets_flutter_application/myconfig.dart';

class WaterLog extends StatefulWidget {
  const WaterLog({super.key});

  @override
  State<WaterLog> createState() => _WaterLogState();
}

class _WaterLogState extends State<WaterLog> {
  int _selectedIndex = 0; // Track selected navigation index
  List<dynamic> waterLogs = [];
  List<dynamic> filteredLogs = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  final int waterThreshold = 2000; // Your water tank threshold, used for Y-axis max

  @override
  void initState() {
    super.initState();
    fetchWaterLogs();
  }

  Future<void> fetchWaterLogs() async {
    final response = await http.get(
      Uri.parse('${MyConfig.servername}/Pet_Water_Dispenser/get_water_log.php'),
    );
    if (response.statusCode == 200) {
      setState(() {
        waterLogs = json.decode(response.body);
        filterLogsByDate(selectedDate);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  void filterLogsByDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    List<dynamic> dailyLogs = waterLogs.where((log) {
      return log['timestamp'].toString().startsWith(dateStr);
    }).toList();
    dailyLogs.sort(
      (a, b) => DateTime.parse(
        a['timestamp'],
      ).compareTo(DateTime.parse(b['timestamp'])),
    );

    if (dailyLogs.isEmpty) {
      filteredLogs = [];
      return;
    }

    List<dynamic> tempFilteredLogs = [];
    tempFilteredLogs.add(dailyLogs.first); // Always add the first point

    for (int i = 1; i < dailyLogs.length; i++) {
      final currentLog = dailyLogs[i];
      final previousLog = dailyLogs[i - 1];

      final currentLevel =
          int.tryParse(currentLog['water_level'].toString()) ?? 0;
      final previousLevel =
          int.tryParse(previousLog['water_level'].toString()) ?? 0;

      // Add if the water level has changed
      if (currentLevel != previousLevel) {
        tempFilteredLogs.add(currentLog);
      } else if (i == dailyLogs.length - 1) {
        // If it's the last point and the value hasn't changed, add it to ensure the graph extends to the last recorded time
        tempFilteredLogs.add(currentLog);
      }
    }

    filteredLogs = tempFilteredLogs;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        filterLogsByDate(selectedDate);
      });
    }
  }

  List<FlSpot> getLineSpots() {
    if (filteredLogs.isEmpty) {
      return [];
    }

    final startOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    return filteredLogs.map<FlSpot>((log) {
      final time = DateTime.parse(log['timestamp']);
      final waterLevel = double.tryParse(log['water_level'].toString()) ?? 0.0;

      // X value: minutes from the start of the day.
      final x = time.difference(startOfDay).inMinutes.toDouble();
      final y = waterLevel;
      return FlSpot(x, y);
    }).toList();
  }

  double get minLogMinute {
    if (filteredLogs.isEmpty) return 0.0;
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return filteredLogs.map((log) => DateTime.parse(log['timestamp']).difference(startOfDay).inMinutes.toDouble()).reduce((a, b) => a < b ? a : b);
  }

  double get maxLogMinute {
    if (filteredLogs.isEmpty) return 60.0;
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return filteredLogs.map((log) => DateTime.parse(log['timestamp']).difference(startOfDay).inMinutes.toDouble()).reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Color.fromRGBO(181, 226, 254, 1), Colors.white],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
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
          centerTitle: true,
          elevation: 10,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bgblue.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
          toolbarHeight: 100,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Water Logs',
                        style: GoogleFonts.righteous(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Text(
                              DateFormat('d MMMM yyyy').format(selectedDate),
                              style: GoogleFonts.montserrat(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 16), // Increased spacing
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white, // White background as in image
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Water Level Trend', // Graph title
                                  style: GoogleFonts.righteous(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Icon(
                                  Icons.show_chart,
                                  color: Colors.blue,
                                  size: 24,
                                ), // Chart icon
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 350, // Increased height for trend graph
                              child: filteredLogs.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No data for this day',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.blue,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : LineChart(
                                      LineChartData(
                                        maxY: 2000.0,
                                        minY: 0,
                                        lineTouchData: LineTouchData(
                                          enabled: true,
                                          touchTooltipData: LineTouchTooltipData(
                                            getTooltipItems: (spots) {
                                              return spots.map((spot) {
                                                // Convert x (minutes) back to time
                                                final time = selectedDate.add(
                                                  Duration(
                                                    minutes: spot.x.toInt(),
                                                  ),
                                                );
                                                return LineTooltipItem(
                                                  'Time: ${DateFormat('HH:mm').format(time)}\nLevel: ${spot.y.toInt()} ml',
                                                  GoogleFonts.montserrat(
                                                    color: Colors.blue[900],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ), // Spacing between text and icon
                                                );
                                              }).toList();
                                            },
                                          ),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine:
                                              true, // Vertical grid lines
                                          horizontalInterval:
                                              50, // Example interval for Y-axis grid
                                          getDrawingHorizontalLine: (value) =>
                                              FlLine(
                                                color: Colors.grey.withOpacity(
                                                  0.2,
                                                ),
                                                strokeWidth: 1,
                                              ),
                                          getDrawingVerticalLine: (value) =>
                                              FlLine(
                                                color: Colors.grey.withOpacity(
                                                  0.2,
                                                ),
                                                strokeWidth: 1,
                                              ),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border.all(
                                            color: const Color(
                                              0xff37434d,
                                            ), // Dark border color
                                            width: 1,
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            axisNameWidget: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              child: Text(
                                                'ml', // Y-axis unit for water level
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              interval:
                                                  250, // Interval for Y-axis labels (0, 250, 500, 750, 1000)
                                              getTitlesWidget: (value, meta) =>
                                                  Text(
                                                    value
                                                        .toInt()
                                                        .toString(), // Show integer water level
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          color: Colors.blue,
                                                          fontSize: 12,
                                                        ),
                                                  ),
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            axisNameWidget: Padding(
                                              padding: EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                'Time (30 minutes)',
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            axisNameSize:
                                                40, // Increased to provide more space for the title
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40, // Ensure individual labels also have space
                                              interval: 1.0, // not used, custom logic below
                                              getTitlesWidget: (value, meta) {
                                                final minX = minLogMinute;
                                                final maxX = maxLogMinute;
                                                if ((value - minX).abs() < 1e-2) {
                                                  final time = selectedDate.add(Duration(minutes: minX.toInt()));
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 4.0),
                                                    child: Text(
                                                      DateFormat('HH:mm').format(time),
                                                      style: GoogleFonts.montserrat(fontSize: 11, color: Colors.blue[900]),
                                                    ),
                                                  );
                                                } else if ((value - maxX).abs() < 1e-2) {
                                                  final time = selectedDate.add(Duration(minutes: maxX.toInt()));
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 4.0),
                                                    child: Text(
                                                      DateFormat('HH:mm').format(time),
                                                      style: GoogleFonts.montserrat(fontSize: 11, color: Colors.blue[900]),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                              reservedSize:
                                                  40, // Ensure individual labels also have space
                                              interval: 30.0,
                                              getTitlesWidget: (value, meta) {
                                                final timeFromValue =
                                                    selectedDate.add(
                                                      Duration(
                                                        minutes: value.toInt(),
                                                      ),
                                                    );
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4.0,
                                                      ),
                                                  child: Text(
                                                    DateFormat(
                                                      'HH:mm',
                                                    ).format(timeFromValue),
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize: 11,
                                                          color:
                                                              Colors.blue[900],
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: getLineSpots(),
                                            isCurved: true,
                                            barWidth: 3,
                                            color: Colors
                                                .blue, // Orange line color
                                            dotData: FlDotData(
                                              show: true,
                                              getDotPainter:
                                                  (spot, percent, bar, index) =>
                                                      FlDotCirclePainter(
                                                        radius: 4,
                                                        color: Colors.blue,
                                                        strokeWidth: 1,
                                                        strokeColor:
                                                            Colors.white,
                                                      ),
                                            ),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue.withOpacity(0.3),
                                                  Colors.blue.withOpacity(0.0),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      duration: const Duration(
                                        milliseconds: 800,
                                      ), // Animation duration
                                      curve: Curves
                                          .easeOutCubic, // Animation curve
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'History',
                        style: GoogleFonts.righteous(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox(
                          height: 400,
                          child: filteredLogs.isEmpty
                              ? Center(
                                  child: Text(
                                    'No logs found.',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredLogs.length,
                                  itemBuilder: (context, index) {
                                    final log = filteredLogs[index];
                                    final time = DateFormat(
                                      'HH:mm',
                                    ).format(DateTime.parse(log['timestamp']));
                                    final waterLevel =
                                        int.tryParse(
                                          log['water_level'].toString(),
                                        ) ??
                                        0;
                                    return ListTile(
                                      leading: Icon(
                                        Icons.water_drop,
                                        color: Colors.blue[400],
                                      ),
                                      title: Text(
                                        'Level: $waterLevel ml | Status: ${log['water_status']}',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Time: $time | Percentage: ${log['water_percentage']}%',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
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
                      // Navigate to the Pet Log screen
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const PetLogScreen(),
                      ));
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
