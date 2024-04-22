import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyerProfilePage extends StatefulWidget {
  const BuyerProfilePage({Key? key}) : super(key: key);

  @override
  _BuyerProfilePageState createState() => _BuyerProfilePageState();
}

class _BuyerProfilePageState extends State<BuyerProfilePage> {
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    // Fetch user profile data from your API or database
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    try {
      final response =
          await http.get(Uri.parse('${Api.userProfileUrl}/buyer/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          userProfile = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
      // Handle error state or display a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyer Profile'),
      ),
      body: userProfile == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                Text('Name: ${userProfile!['name']}'),
                Text('Email: ${userProfile!['email']}'),
                Text('Phone: ${userProfile!['phone']}'),
                // Display other profile details as needed
              ],
            ),
    );
  }
}
