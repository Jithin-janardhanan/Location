import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Make sure to add this dependency

class ShopOwnerAnalyticsBarChart extends StatefulWidget {
  const ShopOwnerAnalyticsBarChart({Key? key}) : super(key: key);

  @override
  State<ShopOwnerAnalyticsBarChart> createState() =>
      _ShopOwnerAnalyticsBarChartState();
}

class _ShopOwnerAnalyticsBarChartState
    extends State<ShopOwnerAnalyticsBarChart> {
  List<Map<String, dynamic>> analyticsData = [];
  bool isLoading = true;
  String selectedTimeRange = 'Last 7 days';
  List<String> timeRanges = ['Last 7 days', 'Last 30 days', 'Last 90 days'];
  String? currentShopId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentShopId();
  }

  Future<void> _fetchCurrentShopId() async {
    // Assuming the current user's UID is associated with their shop
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        // Fetch the shop document associated with the current user
        QuerySnapshot shopSnapshot = await FirebaseFirestore.instance
            .collection('shops')
            .where('ownerId', isEqualTo: currentUser.uid)
            .limit(1)
            .get();

        if (shopSnapshot.docs.isNotEmpty) {
          setState(() {
            currentShopId = shopSnapshot.docs.first.id;
            fetchAnalytics(7); // Fetch initial 7 days data
          });
        } else {
          // Handle case where no shop is found for the current user
          setState(() {
            isLoading = false;
            currentShopId = null;
          });
        }
      } catch (e) {
        print('Error fetching shop ID: $e');
        setState(() {
          isLoading = false;
          currentShopId = null;
        });
      }
    }
  }

  Future<void> fetchAnalytics(int days) async {
    // If no shop is found for the current user, return early
    if (currentShopId == null) return;

    setState(() {
      isLoading = true;
      analyticsData.clear();
    });

    try {
      DateTime startDate = DateTime.now().subtract(Duration(days: days));

      QuerySnapshot analyticsSnapshot = await FirebaseFirestore.instance
          .collection('shop_analytics')
          .where('shopId', isEqualTo: currentShopId) // Filter by specific shop
          .where('timestamp', isGreaterThan: startDate)
          .get();

      Map<String, Map<String, int>> dailyCounts = {};

      for (var doc in analyticsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        Timestamp timestamp = data['timestamp'] as Timestamp;
        String eventType = data['eventType'] as String;
        DateTime date = timestamp.toDate();
        String dateStr = DateFormat('yyyy-MM-dd').format(date);

        dailyCounts[dateStr] ??= {'views': 0, 'location_clicks': 0};

        if (eventType == 'view') {
          dailyCounts[dateStr]!['views'] =
              (dailyCounts[dateStr]!['views'] ?? 0) + 1;
        } else if (eventType == 'location_clicks') {
          dailyCounts[dateStr]!['location_clicks'] =
              (dailyCounts[dateStr]!['location_clicks'] ?? 0) + 1;
        }
      }

      var sortedDates = dailyCounts.keys.toList()..sort();
      analyticsData = sortedDates.map((date) {
        var counts = dailyCounts[date]!;
        return {
          'date': date,
          'views': counts['views'] ?? 0,
          'location_clicks': counts['location_clicks'] ?? 0,
        };
      }).toList();

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
        title: const Text(
          'My Shop Analytics',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: currentShopId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No shop found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Please create a shop or contact support',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButton<String>(
                    value: selectedTimeRange,
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
                          switch (newValue) {
                            case 'Last 7 days':
                              fetchAnalytics(7);
                              break;
                            case 'Last 30 days':
                              fetchAnalytics(30);
                              break;
                            case 'Last 90 days':
                              fetchAnalytics(90);
                              break;
                          }
                        });
                      }
                    },
                  ),
                ),
                if (isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (analyticsData.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No data available\nTry getting more views or location clicks',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        DateFormat('MM/dd').format(
                                          DateTime.parse(
                                              analyticsData[index]['date']),
                                        ),
                                        style: const TextStyle(fontSize: 10),
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
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                        ),
                      ),
                    ),
                  ),
                // Stats Summary
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        'Total Views',
                        analyticsData.fold(
                            0, (sum, item) => sum + (item['views'] as int)),
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Total Location Clicks',
                        analyticsData.fold(
                            0,
                            (sum, item) =>
                                sum + (item['location_clicks'] as int)),
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(analyticsData.length, (index) {
      final data = analyticsData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data['views'].toDouble(),
            color: Colors.blue,
            width: 15,
          ),
          BarChartRodData(
            toY: data['location_clicks'].toDouble(),
            color: Colors.red,
            width: 15,
          ),
        ],
      );
    });
  }

  double _getMaxY() {
    if (analyticsData.isEmpty) return 10;

    final viewsMax = analyticsData
        .map((data) => data['views'] as int)
        .reduce((curr, next) => curr > next ? curr : next)
        .toDouble();

    final clicksMax = analyticsData
        .map((data) => data['location_clicks'] as int)
        .reduce((curr, next) => curr > next ? curr : next)
        .toDouble();

    return [viewsMax, clicksMax]
            .reduce((curr, next) => curr > next ? curr : next) *
        1.2;
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
