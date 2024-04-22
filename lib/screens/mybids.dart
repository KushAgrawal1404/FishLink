import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/utils/api.dart';

class MyBidsPage extends StatefulWidget {
  const MyBidsPage({Key? key}) : super(key: key);

  @override
  _MyBidsPageState createState() => _MyBidsPageState();
}

class _MyBidsPageState extends State<MyBidsPage> {
  List<dynamic> myBids = [];

  @override
  void initState() {
    super.initState();
    _fetchMyBids();
  }

  Future<void> _fetchMyBids() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    String apiUrl = '${Api.fetchbids}/$userId';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> bids = jsonDecode(response.body);
        List<dynamic> updatedMyBids = [];

        for (var bid in bids) {
          final catchResponse = await http
              .get(Uri.parse('${Api.catchDetailsUrl}/${bid['catchId']}'));
          if (catchResponse.statusCode == 200) {
            var catchDetails = jsonDecode(catchResponse.body);
            Map<String, dynamic> mergedDetails = {
              ...bid,
              'catchDetails': catchDetails
            };
            updatedMyBids.add(mergedDetails);
          }
        }

        setState(() {
          myBids = updatedMyBids;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch my bids'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching my bids: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bids'),
      ),
      body: myBids.isEmpty
          ? const Center(child: Text('No bids found'))
          : ListView.separated(
              itemCount: myBids.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (context, index) {
                var bid = myBids[index];
                var catchDetails = bid['catchDetails'];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Catch Name: ${catchDetails['name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('My Current Bid: ${bid['bidAmount']}'),
                      Text(
                          'Highest Current Bid: ${catchDetails['currentBid']}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
