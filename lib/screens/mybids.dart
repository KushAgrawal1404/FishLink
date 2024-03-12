import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BidService {
  
  static Future<List<dynamic>> getMyBids(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${Api.fetchbids}/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Handle error response
        throw Exception('Failed to fetch bids');
      }
    } catch (e) {
      // Handle network error
      throw Exception('Network error: $e');
    }
  }

}

class MyBidsPage extends StatefulWidget {
  const MyBidsPage({Key? key}) : super(key: key);

  @override
  State<MyBidsPage> createState() => _MyBidsPageState();
}

class _MyBidsPageState extends State<MyBidsPage> {
  late SharedPreferences _prefs;
  List<dynamic> myBids = [];

  @override
  void initState() {
    super.initState();
    _fetchMyBids();
  }

  Future<void> _fetchMyBids() async {
    _prefs = await SharedPreferences.getInstance();
    // Check if user already logged in
    String? userId = _prefs.getString('userId');
    // Replace 'userId' with the actual logged-in user's ID

    try {
      final bids = await BidService.getMyBids(userId!);

      setState(() {
        myBids = bids;
      });
    } catch (e) {
      // Handle error
      print('Error fetching bids: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build your UI using the 'myBids' list
    // Example: ListView.builder, GridView.builder, etc.
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bids'),
      ),
      body: myBids.isEmpty
          ? const Center(
              child: Text('No bids found'),
            )
          : ListView.builder(
              itemCount: myBids.length,
              itemBuilder: (context, index) {
                var bidDetails = myBids[index];
                // Build UI for each bid
                return ListTile(
                  title: Text('Bid Amount: ${bidDetails['bidAmount']}'),
                  // Add more details as needed
                );
              },
            ),
    );
  }
}
