import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/utils/api.dart';
import 'package:fish_link/components/seller_menu.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({Key? key}) : super(key: key);

  @override
  _SellerHomePageState createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int totalCatches = 0;
  int activeCatches = 0;
  int soldCatches = 0;
  int expiredCatches = 0;
  int totalRevenue = 0;
  String ratings = "0.0";

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<String> _getNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }

  Future<void> _fetchAnalytics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String sellerId = prefs.getString('userId') ?? '';

    if (sellerId.isNotEmpty) {
      try {
        var response = await http.get(
          Uri.parse('${Api.analyticsUrl}/$sellerId'),
        );
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          setState(() {
            totalCatches = data['totalCatches'];
            activeCatches = data['activeCatches'];
            soldCatches = data['soldCatches'];
            expiredCatches = data['expiredCatches'];
            totalRevenue = data['totalRevenue'];
            ratings = data['ratings'];
          });
        } else {
          print('Failed to fetch analytics');
        }
      } catch (e) {
        print('Error fetching analytics: $e');
      }
    }
  }

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
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          drawer: const SellerHomeMenu(),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnalyticsCard(Icons.shopping_basket, 'Total Catches', totalCatches),
                _buildAnalyticsCard(Icons.access_time, 'Active Catches', activeCatches),
                _buildAnalyticsCard(Icons.check_circle, 'Sold Catches', soldCatches),
                _buildAnalyticsCard(Icons.error_outline, 'Expired Catches', expiredCatches),
                _buildAnalyticsCard(Icons.attach_money, 'Total Revenue', totalRevenue, currency: true),
                _buildAnalyticsCard(Icons.star, 'Average Ratings', double.parse(ratings)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsCard(IconData icon, String label, dynamic value, {bool currency = false}) {
  Color iconColor;
  switch (icon) {
    case Icons.shopping_basket:
      iconColor = Colors.green;
      break;
    case Icons.access_time:
      iconColor = Colors.orange;
      break;
    case Icons.check_circle:
      iconColor = Colors.blue;
      break;
    case Icons.error_outline:
      iconColor = Colors.red;
      break;
    case Icons.attach_money:
      iconColor = Colors.purple;
      break;
    case Icons.star:
      iconColor = Colors.yellow;
      break;
    default:
      iconColor = Colors.blue; // Default color if icon doesn't match any case
  }

  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    color: Colors.white, // Set the background color to white
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor,
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        trailing: Text(
          currency ? '₹$value' : value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}


}
