import 'package:fish_link/screens/winner_page.dart';
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
      body: Column(
        children: [
          SizedBox(
            height: 10, // Add margin above buttons
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryButton(
                    'Ongoing', 'available', Colors.blue.shade50),
                _buildCategoryButton('Sold', 'sold', Colors.green.shade50),
                _buildCategoryButton('Expired', 'expired', Colors.red.shade50),
              ],
            ),
          ),
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
                        return SizedBox.shrink();
                      }

                      // Parse datetime strings into DateTime objects
                      DateTime endTime =
                          DateTime.parse(catchDetails['endTime']);
                      // Compare with DateTime.now()
                      bool isEndTimePassed = endTime.isBefore(DateTime.now());

                      Color boxColor;
                      switch (_selectedStatus) {
                        case 'available':
                          boxColor = Colors.blue.shade50;
                          break;
                        case 'sold':
                          boxColor = Colors.green.shade50;
                          break;
                        case 'expired':
                          boxColor = Colors.red.shade50;
                          break;
                        default:
                          boxColor = Colors.grey;
                      }

                      return Card(
                        elevation: 4, // Add elevation for better UI
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color:
                            boxColor, // Set color dynamically based on status
                        child: ListTile(
                          title: Text(
                            catchDetails['name'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location: ${catchDetails['location']}',
                                  style: const TextStyle(fontSize: 16)),
                              Text('Base Price: ${catchDetails['basePrice']}',
                                  style: const TextStyle(fontSize: 16)),
                              Text('Quantity: ${catchDetails['quantity']}',
                                  style: const TextStyle(fontSize: 16)),
                              Text(
                                  'Start Time: ${formatDateTime(catchDetails['startTime'])}',
                                  style: const TextStyle(fontSize: 16)),
                              Text(
                                  'End Time: ${formatDateTime(catchDetails['endTime'])}',
                                  style: const TextStyle(fontSize: 16)),
                              Text('Status: ${catchDetails['status']}',
                                  style: const TextStyle(fontSize: 16)),
                              if (catchDetails['status'] == 'sold')
                                Text('Winner: ${catchDetails['highestBidder']}',
                                    style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
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
                                          // Pass the catchDetails
                                        ),
                                      ),
                                    );
                                  },
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
    );
  }

  Widget _buildCategoryButton(String text, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedStatus = status;
              });
            },
            child: Text(
              text,
              style: TextStyle(color: Colors.black), // Set text color to black
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10.0), // Adjust border radius for better UI
              ),
              backgroundColor: color, // Set button color based on status
            ),
          ),
          SizedBox(width: 10), // Add some space between button and bid
        ],
      ),
    );
  }
}
