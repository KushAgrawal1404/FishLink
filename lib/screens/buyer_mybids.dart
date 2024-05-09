import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/utils/api.dart';
import 'package:fish_link/screens/catch_details_page.dart';
import 'dart:async';

class MyBidsPage extends StatefulWidget {
  const MyBidsPage({Key? key}) : super(key: key);

  @override
  _MyBidsPageState createState() => _MyBidsPageState();
}

class _MyBidsPageState extends State<MyBidsPage> {
  List<dynamic> myBids = [];
  late Timer _timer; // This variable holds the reference to the timer object.
  // It's declared with the late keyword, indicating that its value will be assigned later.
  late DateTime _currentTime = DateTime.now();

  @override
  void initState() { // when page is loaded it is called
    super.initState();
    _fetchMyBids();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

        // Sort updatedMyBids
        updatedMyBids.sort((a, b) {
          var statusA = a['catchDetails']['status'];
          var statusB = b['catchDetails']['status'];

          // Sort by bid status first
          if (statusA == 'available' && statusB != 'available') {
            return -1; // a comes before b
          } else if (statusA != 'available' && statusB == 'available') {
            return 1; // b comes before a
          } else {
            // If both are of the same status, sort by remaining time
            DateTime endTimeA = DateTime.parse(a['catchDetails']['endTime']);
            DateTime endTimeB = DateTime.parse(b['catchDetails']['endTime']);
            return endTimeA.compareTo(endTimeB);
          }
        });

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
    return Scaffold( //a widget that provides the basic visual layout structure of Material Design.
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
                    bidColor = Colors.blue.shade50; // Blue for bids not won
                  } else {
                    bidColor = Colors.red.shade50; // Red for ongoing bids
                  }

                  // Calculate remaining time
                  DateTime bidEndTime =
                  DateTime.parse(catchDetails['endTime']);
                  Duration remainingTime =
                  bidEndTime.difference(_currentTime);

                  // Determine color for timer text
                  Color timerColor = remainingTime <= Duration(minutes: 2)
                      ? Colors.red // Less than or equal to 2 minutes, red color
                      : Colors.green; // Otherwise, green color

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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0), // Add padding here
                      child: Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        color: Colors.white,
                        child: Material(
                          color: bidColor,
                          borderRadius: BorderRadius.circular(12.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (firstImageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(10.0),
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
                                      Row(
                                        children: [
                                          const Text(
                                            'My Current Bid: ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                              FontWeight.bold, // Making the text bold
                                            ),
                                          ),
                                          Text(
                                            '₹${bid['bidAmount']}',
                                            style: const TextStyle(
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Highest Current Bid: ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                              FontWeight.bold, // Making the text bold
                                            ),
                                          ),
                                          Text(
                                            '₹${catchDetails['currentBid']}',
                                            style: const TextStyle(
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      if (remainingTime >
                                          Duration.zero) // Only display timer if remaining time is positive
                                        Row(
                                          children: [
                                            const Text(
                                              'Time Left: ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.bold, // Making the text bold
                                              ),
                                            ),
                                            Text(
                                              '${remainingTime.inHours}:${remainingTime.inMinutes.remainder(60)}:${remainingTime.inSeconds.remainder(60)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.bold, // Making the timer text bold
                                                color:
                                                timerColor, // Apply the determined color to the timer text
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
