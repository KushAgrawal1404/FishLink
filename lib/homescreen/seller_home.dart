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
  double ratings = 0.0;

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
          ),
          drawer: const SellerHomeMenu(),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnalyticsItem('Total Catches:', totalCatches),
                _buildAnalyticsItem('Active Catches:', activeCatches),
                _buildAnalyticsItem('Sold Catches:', soldCatches),
                _buildAnalyticsItem('Expired Catches:', expiredCatches),
                _buildAnalyticsItem('Total Revenue:', totalRevenue),
                _buildAnalyticsItem('Average Ratings:', ratings),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsItem(String label, dynamic value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        trailing: Text(
          label == 'Total Revenue:' ? '₹ $value' : value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
