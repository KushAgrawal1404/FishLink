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
  late final TextEditingController _feedbackController =
      TextEditingController();

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
      body: Theme(
        data: ThemeData.light().copyWith(
            primaryColor: Colors.lightGreen,
            hintColor: Colors.lightBlue,
            errorColor: Color.fromARGB(255, 226, 53, 53)),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(
                      Color.fromARGB(255, 235, 29, 29), 'Unsold, No Winner'),
                  _buildLegendItem(Colors.lightBlue, 'Sold'),
                  _buildLegendItem(Colors.lightGreen, 'Unsold'),
                ],
              ),
            ),
            myCatches.isEmpty
                ? const Center(
                    child: Text('No catches found'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: myCatches.length,
                    itemBuilder: (context, index) {
                      var catchDetails = myCatches[index];
                      // Parse datetime strings into DateTime objects
                      DateTime endTime =
                          DateTime.parse(catchDetails['endTime']);
                      // Compare with DateTime.now()
                      bool isEndTimePassed = endTime.isBefore(DateTime.now());

                      Color boxColor = Colors.lightGreen
                          .withOpacity(0.9); // Default color for unsold catches

                      if (catchDetails['status'] == 'sold' &&
                          catchDetails['highestBidder'] == null) {
                        boxColor = Color.fromARGB(120, 255, 55, 55).withOpacity(
                            0.9); // Red color for unsold with no winner
                      } else if (catchDetails['status'] == 'sold') {
                        boxColor = Colors.lightBlue
                            .withOpacity(0.7); // Blue color for sold catches
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: boxColor, // Set color dynamically
                        child: ListTile(
                          title: Text(
                            catchDetails['name'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          tileColor: Colors.lightBlue.withOpacity(0.05),
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
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.0),
          ),
          margin: const EdgeInsets.only(right: 8.0),
        ),
        Text(text),
      ],
    );
  }
}




// void _showRatingPopup(BuildContext context, String catchId, String sellerId) {
  //   double _rating = 0;

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Rate Buyer'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               const Text('Provide your rating:'),
  //               Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   RatingBar.builder(
  //                     initialRating: _rating,
  //                     minRating: 0,
  //                     direction: Axis.horizontal,
  //                     allowHalfRating: true,
  //                     itemCount: 5,
  //                     itemPadding: const EdgeInsets.symmetric(
  //                         horizontal: 2.0), // Reduced padding
  //                     itemBuilder: (context, _) => const Icon(
  //                       Icons.star,
  //                       color: Colors.amber,
  //                     ),
  //                     onRatingUpdate: (value) {
  //                       setState(() {
  //                         _rating = value;
  //                       });
  //                     },
  //                   ),
  //                 ],
  //               ),
  //               TextField(
  //                 controller: _feedbackController,
  //                 decoration: const InputDecoration(
  //                   labelText: 'Feedback (Optional)',
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () {
  //               String feedback = _feedbackController.text.trim();
  //               _submitRating(catchId, sellerId, _rating.toInt(), feedback);
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Submit'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Future<void> _submitRating(
  //     String catchId, String buyerId, int rating, String feedback) async {
  //   try {
  //     // Create the rating data object
  //     Map<String, dynamic> ratingData = {
  //       'userId': buyerId,
  //       'catchId': catchId,
  //       'rating': rating,
  //       'feedback': feedback,
  //     };

  //     // Convert the rating data to JSON
  //     String jsonData = jsonEncode(ratingData);

  //     // Make the POST request to the server
  //     final response = await http.post(
  //       Uri.parse(Api.createRatingUrl),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonData,
  //     );

  //     // Check if the request was successful (status code 201)
  //     if (response.statusCode == 201) {
  //       print('Success');
  //       // Rating created successfully, you can handle this as needed
  //       // For example, show a success message or update the UI
  //     } else {
  //       // Rating creation failed, show an error message
  //       print('Failed to create rating: ${response.statusCode}');
  //       // You can handle this as needed, e.g., show a snackbar with an error message
  //     }
  //   } catch (error) {
  //     // An error occurred, handle it accordingly
  //     print('Error creating rating: $error');
  //     // You can handle this as needed, e.g., show a snackbar with an error message
  //   }
  // }