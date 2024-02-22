import 'package:flutter/material.dart';
import 'package:fish_link/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyCatchesPage extends StatefulWidget {
  const MyCatchesPage({Key? key}) : super(key: key);

  @override
  _MyCatchesPageState createState() => _MyCatchesPageState();
}

class _MyCatchesPageState extends State<MyCatchesPage> {
  List<dynamic> myCatches = [];

  @override
  void initState() {
    super.initState();
    _fetchMyCatches();
  }

  Future<void> _fetchMyCatches() async {
    // Replace with your API endpoint for fetching seller's catches
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

  Future<void> _deleteCatch(String catchId) async {
    // Replace with your API endpoint for deleting a catch
    String apiUrl = Api.deleteCatchUrl;
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$catchId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Catch deleted successfully, you can update the UI or show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catch deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the list of catches after deletion
        _fetchMyCatches();
      } else {
        // Failed to delete catch, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete catch'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // An error occurred, show an error message
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
                        Text('Start Time: ${catchDetails['startTime']}'),
                        Text('End Time: ${catchDetails['endTime']}'),
                        Text('Status: ${catchDetails['status']}'),
                        if (catchDetails['status'] == 'sold')
                          Text(
                              'Winner: ${catchDetails['winner']['name']} (${catchDetails['winner']['email']})'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Navigate to the edit page with catchDetails
                            Navigator.pushNamed(context, '/edit-catch',
                                arguments: catchDetails);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Implement delete catch logic
                            _deleteCatch(catchDetails['id']);
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
