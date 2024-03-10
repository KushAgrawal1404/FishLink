import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/components/buyer_menu.dart';
import 'package:fish_link/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fish_link/screens/catch_details_page.dart';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({Key? key}) : super(key: key);

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  List<dynamic> catches = [];

  @override
  void initState() {
    super.initState();
    _fetchCatches();
  }

  Future<void> _fetchCatches() async {
    // Replace with your API endpoint for fetching seller's catches
    String apiUrl = Api.catchesUrl;
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          catches = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch catches'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String formatDateTime(String datetimeString) {
    // Parse the datetime string into a DateTime object
    DateTime datetime = DateTime.parse(datetimeString);

    // Convert the DateTime object to local time
    DateTime localDatetime = datetime.toLocal();

    // Define the date and time format
    DateFormat formatter = DateFormat('dd-MM-yyyy h:mma');

    // Format the local datetime and return the formatted string
    return formatter.format(localDatetime);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getNameFromSharedPreferences(),
      builder: (context, snapshot) {
        String title = snapshot.hasData ? 'Hi, ${snapshot.data}' : 'Buyer Home';
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          drawer: const BuyerHomeMenu(), // Integrate the buyer menu panel here
          body: catches.isEmpty
              ? const Center(
                  child: Text('No catches found'),
                )
              : ListView.builder(
                  itemCount: catches.length,
                  itemBuilder: (context, index) {
                    var catchDetails = catches[index];
                    List<dynamic> images = catchDetails['images'];
                    String firstImageUrl = images.isNotEmpty
                        ? Api.baseUrl + images[0]
                        : ''; // Construct the full image URL

                    return GestureDetector(
                      onTap: () {
                        // Navigate to the CatchDetailsPage when the item is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CatchDetailsPage(catchId: catchDetails['_id']),
                          ),
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display the first image if available
                              if (firstImageUrl.isNotEmpty)
                                Image.network(
                                  firstImageUrl,
                                  width:
                                      130, // Adjust the width of the image as needed
                                  height:
                                      130, // Adjust the height of the image as needed
                                  fit: BoxFit
                                      .cover, // Adjust the fit of the image as needed
                                ),
                              const SizedBox(
                                  width:
                                      10), // Add some spacing between the image and catch details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(catchDetails['name'],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        'Location: ${catchDetails['location']}'),
                                    Text(
                                        'Base Price: ₹${catchDetails['basePrice']}'),
                                    Text(
                                        'Quantity: ${catchDetails['quantity']}'),
                                    Text(
                                        'Starts: ${formatDateTime(catchDetails['startTime'])}'),
                                    Text(
                                        'Ends: ${formatDateTime(catchDetails['endTime'])}'),
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
        );
      },
    );
  }

  Future<String> _getNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ??
        ''; // Assuming 'name' is the key for the name in SharedPreferences
  }
}
