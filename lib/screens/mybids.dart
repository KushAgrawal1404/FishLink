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
      ),
      body: myBids.isEmpty
          ? const Center(child: Text('No bids found'))
          : Padding(
              padding: const EdgeInsets.only(top: 12.0),
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
                    bidColor = Colors.blue; // Blue for won bids
                  } else if (catchDetails['status'] == 'available') {
                    bidColor = Colors.green; // Red for bids not won
                  } else {
                    bidColor = Colors.red; // Green for ongoing bids
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: bidColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      margin:
                          const EdgeInsets.only(left: 7, right: 7, bottom: 10),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Catch Name: ${catchDetails['name']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('My Current Bid: ${bid['bidAmount']}'),
                                  Text(
                                      'Highest Current Bid: ${catchDetails['currentBid']}'),
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
    );
  }
}
