import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/components/seller_menu.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fish_link/utils/api.dart';

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getNameFromSharedPreferences(),
      builder: (context, snapshot) {
        String title =
            snapshot.hasData ? 'Hi, ${snapshot.data}' : 'Seller Home';
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          drawer: const SellerHomeMenu(),
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                _fetchAvailableCatches(context);
              },
              child: Text('View Analytics'),
            ),
          ),
        );
      },
    );
  }

  Future<String> _getNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ??
        ''; // Assuming 'name' is the key for the name in SharedPreferences
  }

  Future<void> _fetchAvailableCatches(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(Api.analyticsUrl));
      if (response.statusCode == 200) {
        List<dynamic> availableCatches = json.decode(response.body);
        // Process availableCatches data to generate analytics and insights
        double totalRevenue = 0;
        double totalBids = 0;
        int numCatches = availableCatches.length;

        for (var catchData in availableCatches) {
          int basePrice = catchData['basePrice'];
          int currentBid = catchData['currentBid'];
          int quantity = catchData['quantity'];

          // Calculate total revenue
          totalRevenue += currentBid;

          // Calculate total bids
          totalBids += currentBid;
        }

        double averageBidAmount = totalBids / numCatches;

        // Navigate to the Analytics and Insights page with calculated data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalyticsInsightsPage(
              totalRevenue: totalRevenue,
              averageBidAmount: averageBidAmount,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch available catches'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching available catches: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class AnalyticsInsightsPage extends StatelessWidget {
  final double totalRevenue;
  final double averageBidAmount;

  const AnalyticsInsightsPage({
    Key? key,
    required this.totalRevenue,
    required this.averageBidAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics and Insights'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display the chart by default
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: _buildChart(),
            ),
          ),
          SizedBox(height: 20),
          Text('Total Revenue: ₹$totalRevenue'),
          Text('Average Bid Amount: ₹$averageBidAmount'),
          // Add more analytics and insights widgets as needed
        ],
      ),
    );
  }

  Widget _buildChart() {
    // Sample data for the chart
    final List<charts.Series<TimeSeriesSales, DateTime>> seriesList = [
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: [
          TimeSeriesSales(DateTime(2022, 1, 1), 5),
          TimeSeriesSales(DateTime(2022, 2, 1), 25),
          TimeSeriesSales(DateTime(2022, 3, 1), 100),
          TimeSeriesSales(DateTime(2022, 4, 1), 75),
        ],
      ),
    ];

    return charts.TimeSeriesChart(
      seriesList,
      animate: true,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }
}

class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
