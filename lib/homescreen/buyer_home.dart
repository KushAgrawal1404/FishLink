import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/components/BuyerHomeMenu.dart';
import 'package:fish_link/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({Key? key}) : super(key: key);

  @override
  _BuyerHomePage createState() => _BuyerHomePage();
}

class _BuyerHomePage extends State<BuyerHomePage> {
  List<dynamic> Catches = [];
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
          Catches = jsonDecode(response.body);
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
          body: Catches.isEmpty
              ? const Center(
                  child: Text('No catches found'),
                )
              : ListView.builder(
                  itemCount: Catches.length,
                  itemBuilder: (context, index) {
                    var catchDetails = Catches[index];
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
                          ],
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
