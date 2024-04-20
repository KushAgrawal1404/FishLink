import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/utils/api.dart';

class BuyerAnalyticsPage extends StatefulWidget {
  const BuyerAnalyticsPage({Key? key}) : super(key: key);

  @override
  _BuyerAnalyticsPageState createState() => _BuyerAnalyticsPageState();
}

class _BuyerAnalyticsPageState extends State<BuyerAnalyticsPage> {
  int bidsPlaced = 0;
  int bidsWon = 0;
  double averageSpending = 0.0;
  double mostAmountSpent = 0.0;
  double leastAmountSpent = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchBuyerAnalytics();
  }

  Future<void> _fetchBuyerAnalytics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    // Your API endpoint for fetching buyer analytics
    String apiUrl = '${Api.analyticsUrl}/buyer/$userId';
    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          bidsPlaced = data['bidsPlaced'] as int;
          bidsWon = data['bidsWon'] as int;
          averageSpending = (data['averageSpending'] as num).toDouble();
          mostAmountSpent = (data['mostAmountSpent'] as num).toDouble();
          leastAmountSpent = (data['leastAmountSpent'] as num).toDouble();
        });
      } else {
        print('Failed to fetch buyer analytics');
      }
    } catch (e) {
      print('Error fetching buyer analytics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalyticsItem(
                Icons.shopping_basket, 'Bids Placed:', bidsPlaced as String),
            _buildAnalyticsItem(
                Icons.check_circle, 'Bids Won:', bidsWon as String),
            _buildAnalyticsItem(Icons.monetization_on, 'Average Spending:',
                '\$${averageSpending.toStringAsFixed(2)}'),
            _buildAnalyticsItem(Icons.attach_money, 'Most Amount Spent:',
                '\$${mostAmountSpent.toStringAsFixed(2)}'),
            _buildAnalyticsItem(Icons.money_off, 'Least Amount Spent:',
                '\$${leastAmountSpent.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(value, style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}