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
  late final TextEditingController _feedbackController =
      TextEditingController();
  late final TextEditingController _ratingController = TextEditingController();

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

  void _showRatingPopup(BuildContext context, String catchId, String buyerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rate Buyer'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Text('Provide your rating:'),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _ratingController,
                  decoration: const InputDecoration(
                    labelText: 'Rating',
                  ),
                ),
                TextField(
                  controller: _feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Feedback (Optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String feedback = _feedbackController.text.trim();
                int rating = int.parse(_ratingController.text.trim());
                _submitRating(catchId, buyerId, rating, feedback);
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRating(
      String catchId, String buyerId, int rating, String feedback) async {
    try {
      // Create the rating data object
      Map<String, dynamic> ratingData = {
        'userId': buyerId,
        'catchId': catchId,
        'rating': rating,
        'feedback': feedback,
      };

      // Convert the rating data to JSON
      String jsonData = jsonEncode(ratingData);

      // Make the POST request to the server
      final response = await http.post(
        Uri.parse(Api.createRatingUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Check if the request was successful (status code 201)
      if (response.statusCode == 201) {
        print('Success');
        // Rating created successfully, you can handle this as needed
        // For example, show a success message or update the UI
      } else {
        // Rating creation failed, show an error message
        print('Failed to create rating: ${response.statusCode}');
        // You can handle this as needed, e.g., show a snackbar with an error message
      }
    } catch (error) {
      // An error occurred, handle it accordingly
      print('Error creating rating: $error');
      // You can handle this as needed, e.g., show a snackbar with an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Catches'),
      ),
      body: myCatches.isEmpty
          ? const Center(
              child: Text('No catches found'),
            )
          : ListView.builder(
              itemCount: myCatches.length,
              itemBuilder: (context, index) {
                var catchDetails = myCatches[index];
                return Card(
                  child: ListTile(
                    title: Text(catchDetails['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location: ${catchDetails['location']}'),
                        Text('Base Price: ${catchDetails['basePrice']}'),
                        Text('Quantity: ${catchDetails['quantity']}'),
                        Text(
                            'Start Time: ${formatDateTime(catchDetails['startTime'])}'),
                        Text(
                            'End Time: ${formatDateTime(catchDetails['endTime'])}'),
                        Text('Status: ${catchDetails['status']}'),
                        if (catchDetails['status'] == 'sold')
                          Text('Winner: ${catchDetails['highestBidder']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (catchDetails['status'] == 'available')
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.pushNamed(context, '/edit_catches',
                                  arguments: catchDetails);
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteCatch(catchDetails['_id']);
                          },
                        ),
                        if (catchDetails['status'] == 'sold')
                          IconButton(
                            icon: const Icon(Icons.star),
                            onPressed: () {
                              _showRatingPopup(context, catchDetails['_id'],
                                  catchDetails['highestBidder']);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
