// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';

// class ShopAnalyticsDashboard extends StatefulWidget {
//   const ShopAnalyticsDashboard({Key? key}) : super(key: key);

//   @override
//   State<ShopAnalyticsDashboard> createState() => _ShopAnalyticsDashboardState();
// }

// class _ShopAnalyticsDashboardState extends State<ShopAnalyticsDashboard> {
//   List<Map<String, dynamic>> analyticsData = [];
//   bool isLoading = true;
//   String selectedTimeRange = 'Last 7 days';
//   List<String> timeRanges = ['Last 7 days', 'Last 30 days', 'Last 90 days'];

//   @override
//   void initState() {
//     super.initState();
//     fetchAnalytics(7);
//   }

//   Future<void> fetchAnalytics(int days) async {
//     setState(() {
//       isLoading = true;
//       analyticsData.clear();
//     });

//     try {
//       print('Fetching analytics for last $days days...');
//       DateTime startDate = DateTime.now().subtract(Duration(days: days));
//       print('Start date: $startDate');

//       // Debug print for query parameters
//       print('Querying Firestore with:');
//       print('Collection: shop_analytics');
//       print('Start date: $startDate');

//       // Fetch all analytics documents
//       QuerySnapshot analyticsSnapshot = await FirebaseFirestore.instance
//           .collection('shop_analytics')
//           .where('timestamp', isGreaterThan: startDate)
//           .get();

//       print('Total documents fetched: ${analyticsSnapshot.docs.length}');

//       // Print raw data for debugging
//       for (var doc in analyticsSnapshot.docs) {
//         print('Document data: ${doc.data()}');
//       }

//       Map<String, Map<String, int>> dailyCounts = {};

//       // Process all documents
//       for (var doc in analyticsSnapshot.docs) {
//         var data = doc.data() as Map<String, dynamic>;
//         Timestamp timestamp = data['timestamp'] as Timestamp;
//         String eventType = data['eventType'] as String;
//         DateTime date = timestamp.toDate();
//         String dateStr = DateFormat('yyyy-MM-dd').format(date);

//         print('Processing document:');
//         print('Date: $dateStr');
//         print('Event Type: $eventType');

//         dailyCounts[dateStr] ??= {'views': 0, 'location_clicks': 0};

//         if (eventType == 'view') {
//           dailyCounts[dateStr]!['views'] =
//               (dailyCounts[dateStr]!['views'] ?? 0) + 1;
//         } else if (eventType == 'location_clicks') {
//           dailyCounts[dateStr]!['location_clicks'] =
//               (dailyCounts[dateStr]!['location_clicks'] ?? 0) + 1;
//         }
//       }

//       // Convert to sorted list
//       var sortedDates = dailyCounts.keys.toList()..sort();
//       analyticsData = sortedDates.map((date) {
//         var counts = dailyCounts[date]!;
//         print('Processed data for $date:');
//         print('Views: ${counts['views']}');
//         print('Location clicks: ${counts['location_clicks']}');

//         return {
//           'date': date,
//           'views': counts['views'] ?? 0,
//           'location_clicks': counts['location_clicks'] ?? 0,
//         };
//       }).toList();

//       print('Final analytics data:');
//       print(analyticsData);

//       setState(() {
//         isLoading = false;
//       });
//     } catch (e, stackTrace) {
//       print('Error fetching analytics: $e');
//       print('Stack trace: $stackTrace');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Shop Analytics',
//           style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         actions: [
//           // Add refresh button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               int days = selectedTimeRange == 'Last 7 days'
//                   ? 7
//                   : selectedTimeRange == 'Last 30 days'
//                       ? 30
//                       : 90;
//               fetchAnalytics(days);
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 DropdownButton<String>(
//                   value: selectedTimeRange,
//                   items: timeRanges.map((String range) {
//                     return DropdownMenuItem<String>(
//                       value: range,
//                       child: Text(range),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     if (newValue != null) {
//                       setState(() {
//                         selectedTimeRange = newValue;
//                         switch (newValue) {
//                           case 'Last 7 days':
//                             fetchAnalytics(7);
//                             break;
//                           case 'Last 30 days':
//                             fetchAnalytics(30);
//                             break;
//                           case 'Last 90 days':
//                             fetchAnalytics(90);
//                             break;
//                         }
//                       });
//                     }
//                   },
//                 ),
//                 // Add debug info button
//                 IconButton(
//                   icon: const Icon(Icons.info_outline),
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: const Text('Debug Info'),
//                         content: SingleChildScrollView(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text('Data points: ${analyticsData.length}'),
//                               const SizedBox(height: 8),
//                               Text('Time range: $selectedTimeRange'),
//                               const SizedBox(height: 8),
//                               const Text('Raw data:'),
//                               Text(analyticsData.toString()),
//                             ],
//                           ),
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text('Close'),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           if (isLoading)
//             const Expanded(
//               child: Center(child: CircularProgressIndicator()),
//             )
//           else if (analyticsData.isEmpty)
//             const Expanded(
//               child: Center(
//                 child: Text(
//                   'No data available\nTry viewing some shops or clicking location icons',
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             )
//           else
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: LineChart(
//                   LineChartData(
//                     lineBarsData: [
//                       // Views line
//                       LineChartBarData(
//                         spots: List.generate(analyticsData.length, (index) {
//                           return FlSpot(
//                             index.toDouble(),
//                             analyticsData[index]['views'].toDouble(),
//                           );
//                         }),
//                         isCurved: true,
//                         color: Colors.blue,
//                         barWidth: 3,
//                         dotData: FlDotData(show: true),
//                       ),
//                       // Location clicks line
//                       LineChartBarData(
//                         spots: List.generate(analyticsData.length, (index) {
//                           return FlSpot(
//                             index.toDouble(),
//                             analyticsData[index]['location_clicks'].toDouble(),
//                           );
//                         }),
//                         isCurved: true,
//                         color: Colors.red,
//                         barWidth: 3,
//                         dotData: FlDotData(show: true),
//                       ),
//                     ],
//                     titlesData: FlTitlesData(
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (value, meta) {
//                             if (value.toInt() >= 0 &&
//                                 value.toInt() < analyticsData.length) {
//                               return Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   DateFormat('MM/dd').format(
//                                     DateTime.parse(
//                                         analyticsData[value.toInt()]['date']),
//                                   ),
//                                   style: const TextStyle(fontSize: 10),
//                                 ),
//                               );
//                             }
//                             return const Text('');
//                           },
//                           reservedSize: 30,
//                         ),
//                       ),
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           reservedSize: 40,
//                         ),
//                       ),
//                       rightTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       topTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                     ),
//                     gridData: FlGridData(show: true),
//                     borderData: FlBorderData(show: true),
//                   ),
//                 ),
//               ),
//             ),
//           // Stats Summary
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildStatCard(
//                   'Total Views',
//                   analyticsData.fold(
//                       0, (sum, item) => sum + (item['views'] as int)),
//                   Colors.blue,
//                 ),
//                 _buildStatCard(
//                   'Total Location Clicks',
//                   analyticsData.fold(
//                       0, (sum, item) => sum + (item['location_clicks'] as int)),
//                   Colors.red,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, int value, Color color) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 color: color,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               value.toString(),
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
    fetchAnalytics(7);
  }

  Future<void> fetchAnalytics(int days) async {
    setState(() {
      isLoading = true;
      analyticsData.clear();
    });

    try {
      DateTime startDate = DateTime.now().subtract(Duration(days: days));

      QuerySnapshot analyticsSnapshot = await FirebaseFirestore.instance
          .collection('shop_analytics')
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
          'Shop Analytics',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
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
                  'No data available\nTry viewing some shops or clicking location icons',
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
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < analyticsData.length) {
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
                      0, (sum, item) => sum + (item['location_clicks'] as int)),
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
