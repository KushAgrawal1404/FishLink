import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/utils/api.dart';
import 'package:fish_link/screens/catch_details_page.dart';

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
      body: myBids.isEmpty
          ? const Center(child: Text('No bids found'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: myBids.length,
                      itemBuilder: (context, index) {
                        var bid = myBids[index];
                        var catchDetails = bid['catchDetails'];
                        List<dynamic> images = catchDetails['images'];
                        String firstImageUrl =
                            images.isNotEmpty ? Api.baseUrl + images[0] : '';

                        // Determine color based on bid status
                        Color bidColor;
                        if (catchDetails['status'] == 'won') {
                          bidColor = Colors.green.shade50; // Green for won bids
                        } else if (catchDetails['status'] == 'available') {
                          bidColor =
                              Colors.blue.shade50; // Red for bids not won
                        } else {
                          bidColor = Colors.red.shade50; // Blue for ongoing bids
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CatchDetailsPage(
                                  catchId: catchDetails['_id'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            color: bidColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (firstImageUrl.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        firstImageUrl,
                                        width: 130,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${catchDetails['name']}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'My Current Bid: ₹${bid['bidAmount']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          'Highest Current Bid: ₹${catchDetails['currentBid']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
