import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/components/buyer_menu.dart';
import 'package:fish_link/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/screens/buyer_catch_details_page.dart';
import 'dart:async';
import 'dart:math' as math;

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
  bool _sortByPriceAscending = true; // Flag to toggle sorting order

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
        List<dynamic> fetchedCatches = jsonDecode(response.body);
        setState(() {
          catches.clear();
          catches.addAll(fetchedCatches);
          _filterCatches(); // Filter catches when fetched
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

  void _sortByPrice() {
    setState(() {
      _sortByPriceAscending = !_sortByPriceAscending;
      _sortCatches();
    });
  }

  void _sortCatches() {
    if (_sortByPriceAscending) {
      filteredCatches = List.from(catches)
        ..sort((a, b) => a['basePrice'].compareTo(b['basePrice']));
    } else {
      filteredCatches = List.from(catches)
        ..sort((a, b) => b['basePrice'].compareTo(a['basePrice']));
    }
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
          drawer: const BuyerHomeMenu(),
          body: catches.isEmpty
              ? const Center(
                  child: Text('No catches found'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                _filterCatches();
                              },
                              decoration: InputDecoration(
                                hintText: 'Search catches by name or location',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.grey),
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
                          IconButton(
                            icon: Transform(
                              alignment: Alignment.center,
                              transform: _sortByPriceAscending
                                  ? Matrix4.identity()
                                  : Matrix4.rotationX(math.pi),
                              child: Icon(Icons.sort),
                            ),
                            onPressed: _sortByPrice,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCatches.length,
                        itemBuilder: (context, index) {
                          var catchDetails = filteredCatches[index];
                          List<dynamic> images = catchDetails['images'];
                          String firstImageUrl =
                              images.isNotEmpty ? Api.baseUrl + images[0] : '';
                          DateTime currentTime = DateTime.now();
                          DateTime bidStartTime =
                              DateTime.parse(catchDetails['startTime']);
                          bool isBiddingStarted =
                              currentTime.isAfter(bidStartTime);
                          return GestureDetector(
                            onTap: isBiddingStarted || !isBiddingStarted
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CatchDetailsPage(
                                            catchId: catchDetails['_id']),
                                      ),
                                    );
                                  }
                                : null,
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              color: Colors
                                  .white, // Set the background color to white
                              child: Material(
                                // Wrap your content with Material widget
                                color: Colors
                                    .blue.shade50, // Set the overlay color
                                borderRadius: BorderRadius.circular(
                                    12.0), // Ensure the same corner radius
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              catchDetails['name'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Location: ',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight
                                                        .bold, // Making the text bold
                                                  ),
                                                ),
                                                Text(
                                                  catchDetails['location'],
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Quantity: ',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight
                                                        .bold, // Making the text bold
                                                  ),
                                                ),
                                                Text(
                                                  '${catchDetails['quantity']}kg',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Base Price: ',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight
                                                        .bold, // Making the text bold
                                                  ),
                                                ),
                                                Text(
                                                  '₹${catchDetails['basePrice']}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            if (isBiddingStarted)
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Current Highest Bid: ',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight
                                                          .bold, // Making the text bold
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${catchDetails['currentBid']}',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            if (!isBiddingStarted)
                                              const Text(
                                                'Bidding is not started yet',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
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
