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
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _fetchCatchDetails();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _fetchCatchDetails();
    });
  }

  @override
  void dispose() {
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
                String bidAmount = bidController.text.trim();

                if (bidAmount.isNotEmpty) {
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
                      Navigator.pop(context);
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
        title: const Text('Auction Details'),
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
                const SizedBox(height: 16),
                // Display other catch details
                _buildCardItem(
                    Icons.label, 'Catch Name:', catchDetails['name']),
                _buildCardItem(
                    Icons.location_on, 'Location:', catchDetails['location']),
                _buildCardItem(Icons.format_list_numbered, 'Quantity:',
                    '${catchDetails['quantity']}kg'),
                _buildCardItem(Icons.attach_money, 'Base Price:',
                    '₹${catchDetails['basePrice']}'),
                _buildCardItem(Icons.attach_money, 'Current Price:',
                    '₹${catchDetails['currentBid']}'),
                _buildCardItem(Icons.person, 'Highest bidder:',
                    catchDetails['highestBidder']),
                _buildCardItem(Icons.access_time, 'Starts:',
                    formatDateTime(catchDetails['startTime'])),
                _buildCardItem(Icons.access_time, 'Ends:',
                    formatDateTime(catchDetails['endTime'])),
                // Display the auction timer
                _buildAuctionTimer(),
                // Button to view seller details
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileViewPage(
                          userId: catchDetails['seller']['_id'],
                        ),
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
                _buildPlaceBidButton(),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildCardItem(IconData icon, String label, dynamic value) {
    Color iconColor;
    switch (label) {
      case 'Location:':
        iconColor = Colors.red;
        break;
      case 'Quantity:':
        iconColor = Colors.green;
        break;
      case 'Base Price:':
        iconColor = Colors.blue;
        break;
      case 'Current Price:':
        iconColor = Colors.orange;
        break;
      case 'Highest bidder:':
        iconColor = Colors.purple;
        break;
      case 'Starts:':
        iconColor = Colors.blue;
      case 'Ends:':
        iconColor = Colors.red;
        break;
      default:
        iconColor = Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
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
          subtitle: Text(
            label == 'Total Revenue:' ? '₹ $value' : value.toString(),
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

  Widget _buildPlaceBidButton() {
    DateTime currentTime = DateTime.now();
    DateTime bidStartTime = DateTime.parse(catchDetails['startTime']);
    bool isBiddingStarted = currentTime.isAfter(bidStartTime);
    bool isBiddingEnded = catchDetails['endTime'] != null &&
        DateTime.now().isAfter(DateTime.parse(catchDetails['endTime']));
    bool isPlaceBidEnabled = isBiddingStarted && !isBiddingEnded;

    return ElevatedButton(
      onPressed: isPlaceBidEnabled
          ? () {
              _postBid(context);
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPlaceBidEnabled ? Colors.green : Colors.grey,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        isBiddingEnded ? 'Bidding is over' : 'Place Bid',
      ),
    );
  }

  Widget _buildAuctionTimer() {
    DateTime currentTime = DateTime.now();
    DateTime bidStartTime = DateTime.parse(catchDetails['startTime']);
    DateTime bidEndTime = DateTime.parse(catchDetails['endTime']);
    bool hasAuctionStarted = currentTime.isAfter(bidStartTime);
    bool hasAuctionEnded = currentTime.isAfter(bidEndTime);

    // Return an empty container if auction has ended
    if (hasAuctionEnded) {
      return Container();
    }

    Duration remainingTime = Duration.zero;
    String timerText = '';
    if (!hasAuctionStarted) {
      remainingTime = bidStartTime.difference(currentTime);
      timerText = 'Auction Starts in:';
    } else if (!hasAuctionEnded) {
      remainingTime = bidEndTime.difference(currentTime);
      timerText = 'Auction Ends in:';
    }
    String formattedTime =
        '${remainingTime.inHours}:${remainingTime.inMinutes.remainder(60)}:${remainingTime.inSeconds.remainder(60)}';
    Color timerColor = hasAuctionStarted && !hasAuctionEnded
        ? remainingTime.inMinutes < 2
            ? Colors.black
            : Colors.black
        : Colors.black;
    Color timerBackgroundColor = !hasAuctionStarted
        ? Colors.blue.withOpacity(0.65)
        : Colors.red.withOpacity(0.65);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: timerBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: const Icon(
            Icons.timer,
            color: Colors.black,
          ),
          title: Text(
            timerText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            formattedTime,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: timerColor,
              fontSize: 16,
            ),
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
