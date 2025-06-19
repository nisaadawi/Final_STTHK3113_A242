import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:hydrapets_flutter_application/views/dashboard_screen.dart';
import 'package:hydrapets_flutter_application/views/water_log.dart';
import 'package:intl/intl.dart';
import 'package:hydrapets_flutter_application/myconfig.dart';
import 'package:hydrapets_flutter_application/models/pet_log_data.dart';

class PetLogScreen extends StatefulWidget {
  const PetLogScreen({super.key});

  @override
  State<PetLogScreen> createState() => _PetLogScreenState();
}

class _PetLogScreenState extends State<PetLogScreen> {
  int _selectedIndex = 2; // Add this line to define the selected index
  List<PetLogData> petLogs = [];
  List<PetLogData> filteredLogs = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchPetLogs();
  }

  Future<void> fetchPetLogs() async {
    try {
      final response = await http.get(
        Uri.parse('${MyConfig.servername}/Pet_Water_Dispenser/get_pet_log.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          petLogs = responseData.map((data) => PetLogData.fromJson(data)).toList();
          filterLogsByDate(selectedDate);
          isLoading = false;
        });
      } else {
        print('Failed to load pet logs: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching pet logs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterLogsByDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    filteredLogs = petLogs.where((log) {
      return log.timestamp.toString().startsWith(dateStr);
    }).toList();
    // Sort logs by timestamp for correct line graph plotting
    filteredLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
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

  List<FlSpot> getDetectionSpots() {
    if (filteredLogs.isEmpty) {
      return [];
    }
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return filteredLogs.map<FlSpot>((log) {
      final x = log.timestamp.difference(startOfDay).inMinutes.toDouble();
      final y = log.petStatus.toLowerCase() == 'petdetected' ? 1.0 : 0.0;
      return FlSpot(x, y);
    }).toList();
  }

  double get minLogMinute {
    if (filteredLogs.isEmpty) return 0.0;
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return filteredLogs.map((log) => log.timestamp.difference(startOfDay).inMinutes.toDouble()).reduce((a, b) => a < b ? a : b);
  }

  double get maxLogMinute {
    if (filteredLogs.isEmpty) return 60.0;
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return filteredLogs.map((log) => log.timestamp.difference(startOfDay).inMinutes.toDouble()).reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Color.fromARGB(255, 181, 254, 186), Colors.white],
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
                image: AssetImage('assets/bggreen.png'), // Using a green background for pet logs
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pet Logs',
                        style: GoogleFonts.righteous(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.green[700], size: 18),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Text(
                              DateFormat('d MMMM yyyy').format(selectedDate),
                              style: GoogleFonts.montserrat(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.green[700]),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white, // White background
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
                                  'Pet Detection Trend',
                                  style: GoogleFonts.righteous(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Icon(Icons.pets, color: Colors.green, size: 24),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              width: double.infinity,
                              child: filteredLogs.isEmpty
                                  ? const Center(child: Text('No detection data for this day'))
                                  : LineChart(
                                      LineChartData(
                                        minX: minLogMinute,
                                        maxX: maxLogMinute,
                                        minY: -0.1,
                                        maxY: 1.1,
                                        gridData: FlGridData(
                                          show: true,
                                          drawHorizontalLine: true,
                                          drawVerticalLine: true,
                                          horizontalInterval: 1.0,
                                          verticalInterval: 15.0, // every 15 minutes
                                          getDrawingHorizontalLine: (value) => FlLine(
                                            color: Colors.grey.withOpacity(0.2),
                                            strokeWidth: 1,
                                          ),
                                          getDrawingVerticalLine: (value) => FlLine(
                                            color: Colors.grey.withOpacity(0.2),
                                            strokeWidth: 1,
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border.all(
                                            color: const Color(0xff37434d),
                                            width: 1,
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            axisNameWidget: Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Text(
                                                'Pet Detected',
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.green[700],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              interval: 1.0,
                                              getTitlesWidget: (value, meta) {
                                                if (value == 1.0) {
                                                  return Text('Detected', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.green[900]));
                                                } else if (value == 0.0) {
                                                  return Text('No Pet', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.green[900]));
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            axisNameWidget: Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                'Time',
                                                style: GoogleFonts.montserrat(
                                                  color: Colors.green[700],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              interval: 1.0, // not used, custom logic below
                                              getTitlesWidget: (value, meta) {
                                                final minX = minLogMinute;
                                                final maxX = maxLogMinute;
                                                // Show only for start and end
                                                if ((value - minX).abs() < 1e-2) {
                                                  final time = selectedDate.add(Duration(minutes: minX.toInt()));
                                                  return Text(DateFormat('HH:mm').format(time), style: GoogleFonts.montserrat(fontSize: 11, color: Colors.green[900]));
                                                } else if ((value - maxX).abs() < 1e-2) {
                                                  final time = selectedDate.add(Duration(minutes: maxX.toInt()));
                                                  return Text(DateFormat('HH:mm').format(time), style: GoogleFonts.montserrat(fontSize: 11, color: Colors.green[900]));
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: getDetectionSpots(),
                                            isCurved: false,
                                            barWidth: 3,
                                            color: Colors.green,
                                            dotData: FlDotData(show: true),
                                            belowBarData: BarAreaData(show: false),
                                            isStepLineChart: true,
                                          ),
                                        ],
                                        lineTouchData: LineTouchData(
                                          enabled: true,
                                          touchTooltipData: LineTouchTooltipData(
                                            getTooltipItems: (spots) {
                                              return spots.map((spot) {
                                                final time = selectedDate.add(Duration(minutes: spot.x.toInt()));
                                                final status = spot.y == 1.0 ? 'Detected' : 'No Pet';
                                                // Find the closest log entry for tooltip
                                                final closestLog = filteredLogs.reduce((a, b) => (a.timestamp.difference(time).abs() < b.timestamp.difference(time).abs()) ? a : b);
                                                final ledStatus = closestLog.ledStatus;
                                                return LineTooltipItem(
                                                  'Time: ${DateFormat('HH:mm').format(time)}\nStatus: $status\nLED: $ledStatus',
                                                  GoogleFonts.montserrat(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                );
                                              }).toList();
                                            },
                                          ),
                                        ),
                                      ),
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.easeOutCubic,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // History section
                      Text(
                        'History',
                        style: GoogleFonts.righteous(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox(
                          height: 400,// Adjusted height for pet log list
                          child: filteredLogs.isEmpty
                              ? Center(child: Text('No logs found.', style: GoogleFonts.montserrat(fontSize: 16, color: Colors.green[700])))
                              : ListView.builder(
                                  itemCount: filteredLogs.length,
                                  itemBuilder: (context, index) {
                                    final log = filteredLogs[index];
                                    return ListTile(
                                      leading: Icon(
                                        log.petStatus == 'PetDetected' ? Icons.pets : Icons.not_interested,
                                        color: log.petStatus == 'PetDetected' ? Colors.green : Colors.red,
                                      ),
                                      title: Text(
                                        'Status: ${log.petStatus}',
                                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'LED: ${log.ledStatus} | Time: ${log.formattedTime}',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      trailing: Text(log.formattedDate, style: GoogleFonts.montserrat(color: Colors.grey[700])), // Display date
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
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