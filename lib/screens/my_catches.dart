import 'package:flutter/material.dart';
import 'package:fish_link/screens/buyer_rating.dart';
import 'package:fish_link/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MyCatchesPage extends StatefulWidget {
  const MyCatchesPage({Key? key}) : super(key: key);

  @override
  State<MyCatchesPage> createState() => _MyCatchesPageState();
}

class _MyCatchesPageState extends State<MyCatchesPage> {
  List<dynamic> myCatches = [];
  late String _selectedStatus = 'available';

  @override
  void initState() {
    super.initState();
    _fetchMyCatches();
  }

  Future<void> _fetchMyCatches() async {
    String apiUrl = Api.sellerCatchesUrl;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          myCatches = jsonDecode(response.body);
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

  Future<void> _deleteCatch(String catchId) async {
    String apiUrl = Api.deleteCatchUrl;
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/$catchId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catch deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchMyCatches();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete catch'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Catches'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SizedBox(
            //   height: 10, // Add margin above buttons
            // ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryButton(
                      'Ongoing', 'available', Colors.blue.shade100),
                  _buildCategoryButton('Sold', 'sold', Colors.green.shade100),
                  _buildCategoryButton(
                      'Expired', 'expired', Colors.red.shade100),
                ],
              ),
            ),
            const SizedBox(height: 15), // Add space between buttons and catches
            Expanded(
              child: myCatches.isEmpty
                  ? const Center(
                      child: Text('No catches found'),
                    )
                  : ListView.builder(
                      itemCount: myCatches.length,
                      itemBuilder: (context, index) {
                        var catchDetails = myCatches[index];
                        if (catchDetails['status'] != _selectedStatus) {
                          return const SizedBox.shrink();
                        }

                        // Parse datetime strings into DateTime objects
                        DateTime endTime =
                            DateTime.parse(catchDetails['endTime']);
                        // Compare with DateTime.now()
                        bool isEndTimePassed = endTime.isBefore(DateTime.now());

                        Color boxColor;
                        switch (_selectedStatus) {
                          case 'available':
                            boxColor = Colors.blue.shade100;
                            break;
                          case 'sold':
                            boxColor = Colors.green.shade100;
                            break;
                          case 'expired':
                            boxColor = Colors.red.shade100;
                            break;
                          default:
                            boxColor = Colors.grey;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: boxColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15.0),
                                      topRight: Radius.circular(15.0),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    catchDetails['name'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow(
                                        'Location',
                                        catchDetails['location'],
                                      ),
                                      _buildDetailRow(
                                        'Base Price',
                                        '\$${catchDetails['basePrice']}',
                                      ),
                                      _buildDetailRow(
                                        'Quantity',
                                        catchDetails['quantity'].toString(),
                                      ),
                                      _buildDetailRow(
                                        'Start Time',
                                        formatDateTime(
                                            catchDetails['startTime']),
                                      ),
                                      _buildDetailRow(
                                        'End Time',
                                        formatDateTime(catchDetails['endTime']),
                                      ),
                                      _buildDetailRow(
                                        'Status',
                                        catchDetails['status'],
                                      ),
                                      if (catchDetails['status'] == 'sold')
                                        _buildDetailRow(
                                          'Winner',
                                          catchDetails['highestBidder'],
                                        ),
                                    ],
                                  ),
                                ),
                                ButtonBar(
                                  alignment: MainAxisAlignment.end,
                                  children: [
                                    if (catchDetails['status'] == 'available')
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/edit_catches',
                                              arguments: catchDetails);
                                        },
                                      ),
                                    if (catchDetails['status'] == 'available')
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          _deleteCatch(catchDetails['_id']);
                                        },
                                      ),
                                    if (catchDetails['status'] == 'sold' &&
                                        isEndTimePassed &&
                                        catchDetails['buyerRated'] == false &&
                                        catchDetails['highestBidder'] != null)
                                      IconButton(
                                        icon: const Icon(Icons.star),
                                        onPressed: () {
                                          // Navigate to winner page with catchDetails
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => WinnerPage(
                                                catchDetails: catchDetails,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ],
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

  Widget _buildCategoryButton(String text, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedStatus = status;
          });
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: color,
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
