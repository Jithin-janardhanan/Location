import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopAnalyticsBarChart extends StatefulWidget {
  const ShopAnalyticsBarChart({Key? key}) : super(key: key);

  @override
  State<ShopAnalyticsBarChart> createState() => _ShopAnalyticsBarChartState();
}

class _ShopAnalyticsBarChartState extends State<ShopAnalyticsBarChart> {
  List<Map<String, dynamic>> analyticsData = [];
  bool isLoading = true;
  String selectedTimeRange = 'Last 7 days';
  List<String> timeRanges = ['Last 7 days', 'Last 30 days', 'Last 90 days'];

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    setState(() {
      isLoading = true;
      analyticsData.clear();
    });

    try {
      // Fetch total users from 'user_reg' collection
      QuerySnapshot userRegSnapshot =
          await FirebaseFirestore.instance.collection('user_reg').get();
      int totalUsers = userRegSnapshot.docs.length;

      // Fetch total vendors and charities from 'CV_users' collection
      QuerySnapshot cvUsersSnapshot =
          await FirebaseFirestore.instance.collection('CV_users').get();
      int totalVendors = 0;
      int totalCharities = 0;

      for (var doc in cvUsersSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String role = data['role'] as String;
        if (role == 'vendor') {
          totalVendors++;
        } else if (role == 'charity') {
          totalCharities++;
        }
      }

      // Prepare data for the bar chart
      analyticsData = [
        {'type': 'Users', 'count': totalUsers},
        {'type': 'Vendors', 'count': totalVendors},
        {'type': 'Charities', 'count': totalCharities},
      ];

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching analytics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 10,
        shadowColor: const Color.fromARGB(255, 214, 220, 229),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1F2937),
              const Color(0xFF111827),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: selectedTimeRange,
                  dropdownColor: const Color(0xFF1F2937),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  underline: Container(),
                  items: timeRanges.map((String range) {
                    return DropdownMenuItem<String>(
                      value: range,
                      child: Text(range),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedTimeRange = newValue;
                        fetchAnalytics();
                      });
                    }
                  },
                ),
              ),
            ),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            else if (analyticsData.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: const Color(0xFF374151),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Statistics',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedTimeRange,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _getMaxY(),
                                barGroups: _generateBarGroups(),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        final index = value.toInt();
                                        if (index >= 0 &&
                                            index < analyticsData.length) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              analyticsData[index]['type'],
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                      reservedSize: 30,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: GoogleFonts.poppins(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.white.withOpacity(0.1),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
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
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    // Define gradient colors for each bar
    final List<List<Color>> gradientColors = [
      // Users gradient - Blue to Purple
      [
        const Color(0xFF6366F1),
        const Color(0xFF8B5CF6),
      ],
      // Vendors gradient - Teal to Emerald
      [
        const Color(0xFF14B8A6),
        const Color(0xFF059669),
      ],
      // Charities gradient - Rose to Pink
      [
        const Color(0xFFF43F5E),
        const Color(0xFFE11D48),
      ],
    ];

    return List.generate(analyticsData.length, (index) {
      final data = analyticsData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data['count'].toDouble(),
            gradient: LinearGradient(
              colors: gradientColors[index],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            width: 28,
            borderRadius: BorderRadius.circular(12),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ],
      );
    });
  }

  double _getMaxY() {
    if (analyticsData.isEmpty) return 10;

    final maxCount = analyticsData
        .map((data) => data['count'] as int)
        .reduce((curr, next) => curr > next ? curr : next)
        .toDouble();

    return maxCount * 1.2;
  }
}
