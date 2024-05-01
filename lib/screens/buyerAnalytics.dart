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
        backgroundColor: Color(0xff0f1f30), // Set the previous app bar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalyticsItem(
              Icons.shopping_basket,
              'Bids Placed:',
              bidsPlaced.toString(),
              Colors.orange,
            ),
            _buildAnalyticsItem(
              Icons.check_circle,
              'Bids Won:',
              bidsWon.toString(),
              Colors.green,
            ),
            _buildAnalyticsItem(
              Icons.monetization_on,
              'Average Spending:',
              '\₹${averageSpending.toStringAsFixed(2)}',
              Colors.blue,
            ),
            _buildAnalyticsItem(
              Icons.attach_money,
              'Most Amount Spent:',
              '\₹${mostAmountSpent.toStringAsFixed(2)}',
              Colors.red,
            ),
            _buildAnalyticsItem(
              Icons.money_off,
              'Least Amount Spent:',
              '\₹${leastAmountSpent.toStringAsFixed(2)}',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
