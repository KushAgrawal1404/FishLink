import 'package:fish_link/screens/seller_soldbid_page.dart';
import 'package:flutter/material.dart';
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
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this catch?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
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
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 15),
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

                        DateTime endTime =
                            DateTime.parse(catchDetails['endTime']);
                            // Compare with DateTime.now()
                            endTime.isBefore(DateTime.now());

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
                          child: GestureDetector(
                            onTap: () {
                              if (catchDetails['status'] == 'sold') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SoldBidPage(
                                      catchId: catchDetails['_id'],
                                      buyerId: catchDetails['highestBidder'],
                                      catchDetails: catchDetails,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: boxColor,
                                      borderRadius:
                                          const BorderRadius.only(
                                        topLeft: Radius.circular(15.0),
                                        topRight: Radius.circular(15.0),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          catchDetails['name'],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        if (catchDetails['status'] == 'sold')
                                          IconButton(
                                            icon: Icon(Icons.arrow_forward),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SoldBidPage(
                                                    catchId: catchDetails['_id'],
                                                    buyerId: catchDetails[
                                                        'highestBidder'],
                                                    catchDetails:
                                                        catchDetails,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                      ],
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
                                          'Quantity',
                                          '${catchDetails['quantity'].toString()}kg',
                                        ),
                                        _buildDetailRow(
                                          'Auction Base Price',
                                          '\₹${catchDetails['basePrice']}',
                                        ),
                                         _buildDetailRow(
                                            'Base Rate',
                                            '\₹${(catchDetails['basePrice'] / catchDetails['quantity']).toStringAsFixed(2)}/kg',
                                          ),
                                          
                                           _buildDetailRow(
                                          'Highest Bid',
                                          '\₹${catchDetails['currentBid']}',
                                        ),
                                          _buildDetailRow(
                                          'Current Highest Bid',
                                          '\₹${catchDetails['currentBid']}',
                                        ),
                                        _buildDetailRow(
                                          'Start Time',
                                          formatDateTime(
                                              catchDetails['startTime']),
                                        ),
                                        _buildDetailRow(
                                          'End Time',
                                          formatDateTime(
                                              catchDetails['endTime']),
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
                                      if (catchDetails['status'] ==
                                          'available')
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, '/edit_catches',
                                                arguments: catchDetails);
                                          },
                                        ),
                                      if (catchDetails['status'] ==
                                          'available')
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            _deleteCatch(
                                                catchDetails['_id']);
                                          },
                                        ),
                                    ],
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
