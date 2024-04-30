import 'dart:async';
import 'dart:convert';
import 'package:fish_link/screens/view_profile.dart';
import 'package:fish_link/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CatchDetailsPage extends StatefulWidget {
  final String catchId;

  const CatchDetailsPage({Key? key, required this.catchId}) : super(key: key);

  @override
  _CatchDetailsPageState createState() => _CatchDetailsPageState();
}

class _CatchDetailsPageState extends State<CatchDetailsPage> {
  late Map<String, dynamic> catchDetails = {};
  String sid = "";
  late Timer timer;

  @override
  void initState() {
    super.initState();
    // Fetch catch details initially
    _fetchCatchDetails();

    // Set up a timer to refresh catch details every second
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _fetchCatchDetails();
    });
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    timer.cancel();
    super.dispose();
  }

  Future<void> _fetchCatchDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${Api.catchDetailsUrl}/${widget.catchId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          catchDetails = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch catch details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching catch details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _postBid(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    TextEditingController bidController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Place Bid'),
          content: TextField(
            controller: bidController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter Bid Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Get the bid amount from the text field
                String bidAmount = bidController.text.trim();

                // Check if the bid amount is valid
                if (bidAmount.isNotEmpty) {
                  // Post the bid amount to the server
                  try {
                    final response = await http.post(
                      Uri.parse(Api.placeBidUrl),
                      body: jsonEncode({
                        'userId': userId,
                        'bidAmount': bidAmount,
                        'catchId': widget.catchId,
                      }),
                      headers: {'Content-Type': 'application/json'},
                    );

                    var responseBody = json.decode(response.body);
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bid placed successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context); // Close the dialog
                    } else {
                      String msg = responseBody['error'];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    print('Error placing bid: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error placing bid')),
                    );
                  }
                }
              },
              child: const Text('Place Bid'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(catchDetails['name'] ?? ''),
      ),
      body: catchDetails.isNotEmpty
          ? ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Display images
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: catchDetails['images'].length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.network(
                          Api.baseUrl + catchDetails['images'][index],
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                // Display other catch details
                _buildListItem('Location:', catchDetails['location']),
                _buildListItem('Base Price:', '₹${catchDetails['basePrice']}'),
                _buildListItem(
                    'Current Price:', '₹${catchDetails['currentBid']}'),
                _buildListItem(
                    'Highest bidder:', catchDetails['highestBidder']),
                _buildListItem('Quantity:', catchDetails['quantity']),
                _buildListItem(
                    'Starts:', formatDateTime(catchDetails['startTime'])),
                _buildListItem(
                    'Ends:', formatDateTime(catchDetails['endTime'])),

                // Button to view seller details
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileViewPage(
                            userId: catchDetails['seller']['_id']),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Seller Details'),
                ),

                // Add a button to place bid
                ElevatedButton(
                  onPressed: catchDetails['endTime'] != null &&
                          DateTime.now()
                              .isBefore(DateTime.parse(catchDetails['endTime']))
                      ? () {
                          _postBid(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    catchDetails['endTime'] != null &&
                            DateTime.now().isAfter(
                                DateTime.parse(catchDetails['endTime']))
                        ? 'Bidding is over'
                        : 'Place Bid',
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildListItem(String label, dynamic value) {
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

  String formatDateTime(String datetimeString) {
    DateFormat formatter = DateFormat('dd-MM-yyyy h:mma');
    DateTime datetime = DateTime.parse(datetimeString);
    DateTime localDatetime = datetime.toLocal();
    return formatter.format(localDatetime);
  }
}
