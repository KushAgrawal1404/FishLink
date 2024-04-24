import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/components/buyer_menu.dart';
import 'package:fish_link/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fish_link/screens/catch_details_page.dart';
import 'dart:async';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({Key? key}) : super(key: key);

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  List<dynamic> catches = [];
  List<dynamic> filteredCatches = [];
  TextEditingController searchController = TextEditingController();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchCatches();
    _timer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => _fetchCatches());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchCatches() async {
    String apiUrl = Api.catchesUrl;
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          catches = jsonDecode(response.body);
          filteredCatches = catches;
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
    DateTime datetime = DateTime.parse(datetimeString);
    DateTime localDatetime = datetime.toLocal();
    DateFormat formatter = DateFormat('dd-MM-yyyy h:mma');
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
          drawer: const BuyerHomeMenu(),
          body: catches.isEmpty
              ? const Center(
                  child: Text('No catches found'),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          _filterCatches();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search catches by name or location',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0), // Set border radius here
                            ),
                            borderSide: BorderSide.none, // Remove border
                          ),
                          filled: true,
                          fillColor: Colors.grey[200], // Set background color
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    _filterCatches();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredCatches.isEmpty
                          ? const Center(
                              child: Text('No catches found'),
                            )
                          : ListView.builder(
                              itemCount: filteredCatches.length,
                              itemBuilder: (context, index) {
                                var catchDetails = filteredCatches[index];
                                List<dynamic> images = catchDetails['images'];
                                String firstImageUrl = images.isNotEmpty
                                    ? Api.baseUrl + images[0]
                                    : '';
                                // Get the current time
                                DateTime currentTime = DateTime.now();
                                // Convert the start time string to DateTime object
                                DateTime bidStartTime =
                                    DateTime.parse(catchDetails['startTime']);

                                // Check if the current time is less than the bid start time
                                bool isBiddingStarted =
                                    currentTime.isAfter(bidStartTime);
                                return GestureDetector(
                                  onTap: isBiddingStarted
                                      ? () {
                                          // Navigate to the CatchDetailsPage when the item is tapped
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CatchDetailsPage(
                                                      catchId:
                                                          catchDetails['_id']),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    margin: const EdgeInsets.only(
                                        left: 7, right: 7, bottom: 10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Display the first image if available
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
                                                  catchDetails['name'],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Location: ${catchDetails['location']}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  'Base Price: ₹${catchDetails['basePrice']}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  'Quantity: ${catchDetails['quantity']}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                if (!isBiddingStarted)
                                                  const Text(
                                                    'Bidding is not started yet',
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 14),
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
        );
      },
    );
  }

  Future<String> _getNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }

  void _filterCatches() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredCatches = catches.where((catchDetails) {
        String name = catchDetails['name'].toLowerCase();
        String location = catchDetails['location'].toLowerCase();
        return name.contains(query) || location.contains(query);
      }).toList();
    });
  }
}
