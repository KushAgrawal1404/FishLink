import 'dart:convert';

import 'package:fish_link/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CatchDetailsPage extends StatelessWidget {
  final Map<String, dynamic> catchDetails;

  const CatchDetailsPage({Key? key, required this.catchDetails})
      : super(key: key);

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
                    // Replace 'YOUR_BID_API_ENDPOINT' with your actual bid API endpoint
                    final response = await http.post(
                      Uri.parse(Api.placeBidUrl),
                      body: jsonEncode({
                        'userId': userId,
                        'bidAmount': bidAmount,
                        'catchId': catchDetails['_id'],
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
        title: Text(catchDetails['name']), // Set the title to the catch name
      ),
      body: ListView(
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
                    width: 200, // Adjust the width of the image as needed
                    height: 200, // Adjust the height of the image as needed
                    fit: BoxFit.cover, // Adjust the fit of the image as needed
                  ),
                );
              },
            ),
          ),

          // Display other catch details
          Text('Location: ${catchDetails['location']}'),
          Text('Base Price: ₹${catchDetails['basePrice']}'),
          Text('Quantity: ${catchDetails['quantity']}'),
          Text('Starts: ${formatDateTime(catchDetails['startTime'])}'),
          Text('Ends: ${formatDateTime(catchDetails['endTime'])}'),

          // Add a button to place bid
          ElevatedButton(
            onPressed: () {
              _postBid(context); // Call the function to place bid
            },
            child: const Text('Place Bid'),
          ),
        ],
      ),
    );
  }

  String formatDateTime(String datetimeString) {
    // Define the date and time format
    DateFormat formatter = DateFormat('dd-MM-yyyy h:mma');
    // Parse the datetime string into a DateTime object
    DateTime datetime = DateTime.parse(datetimeString);
    // Convert the DateTime object to local time
    DateTime localDatetime = datetime.toLocal();
    // Format the local datetime and return the formatted string
    return formatter.format(localDatetime);
  }
}
