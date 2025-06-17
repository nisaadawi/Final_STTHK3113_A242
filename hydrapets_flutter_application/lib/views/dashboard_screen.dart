import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydrapets_flutter_application/models/pet_log_data.dart';
import 'package:hydrapets_flutter_application/views/pet_log.dart';
import 'package:hydrapets_flutter_application/views/water_log.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1; // Default to menu (center)

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

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('d MMMM yyyy').format(DateTime.now());
    final int waterPercent = 75;
    final int waterNow = 100;
    final int waterThreshold = 200;
    final String waterStatus = 'Normal';
    final String dispenserStatus = 'Off';
    final String petStatus = 'Your Pet Is Here !';
    final String petTime = '4.05 p.m.';
    final String ledStatus = 'ON';

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
                image: AssetImage('assets/bgmix.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
          toolbarHeight: 100,
        ),
        body: SingleChildScrollView(
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
                                    'Water Level',
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
                        'Water Reading',
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
                            '$waterNow ml   ',
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
                            '   $waterThreshold ml',
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
                      Row(
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
                                dispenserStatus,
                                style: GoogleFonts.montserrat(
                                  fontSize: 22,
                                  color: getDispenserColor(dispenserStatus),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {},
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
                                color: const Color.fromARGB(255, 77, 198, 83),
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
                            onPressed: () {},
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
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
