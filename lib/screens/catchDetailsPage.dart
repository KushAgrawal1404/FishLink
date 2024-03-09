import 'package:fish_link/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CatchDetailsPage extends StatelessWidget {
  final Map<String, dynamic> catchDetails;

  const CatchDetailsPage({Key? key, required this.catchDetails})
      : super(key: key);

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
                  padding: EdgeInsets.only(right: 8.0),
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
              // Handle placing bid here
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
