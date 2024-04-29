import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/screens/seller_rating.dart';

class BuyerWonCatchesPage extends StatefulWidget {
  const BuyerWonCatchesPage({Key? key}) : super(key: key);

  @override
  _BuyerWonCatchesPageState createState() => _BuyerWonCatchesPageState();
}

class _BuyerWonCatchesPageState extends State<BuyerWonCatchesPage> {
  List<dynamic> wonCatches = [];

  @override
  void initState() {
    super.initState();
    _fetchWonCatches();
  }

  Future<void> _fetchWonCatches() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';

      final url = Uri.parse('${Api.fetchMyWins}/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          wonCatches = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch won catches: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching won catches: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wins'),
      ),
      body: wonCatches.isEmpty
          ? const Center(
              child: Text('No won catches found'),
            )
          : ListView.builder(
              itemCount: wonCatches.length,
              itemBuilder: (context, index) {
                var catchDetails = wonCatches[index];
                List<dynamic> images = catchDetails['images'];
                String firstImageUrl =
                    images.isNotEmpty ? Api.baseUrl + images[0] : '';
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerRatingPage(
                          catchDetails: catchDetails,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
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
                                  '${catchDetails['name']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Location: ${catchDetails['location']}'),
                                Text('Quantity: ${catchDetails['quantity']}'),
                                Text(
                                    'Winning Price: ${catchDetails['currentBid']}'),
                                Icon(Icons
                                    .star), // Assuming this is your star button
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
  }
}
