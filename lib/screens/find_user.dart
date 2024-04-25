import 'package:fish_link/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FindUserPage extends StatefulWidget {
  const FindUserPage({Key? key}) : super(key: key);

  @override
  _FindUserPageState createState() => _FindUserPageState();
}

class _FindUserPageState extends State<FindUserPage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic>? _searchResults;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find User'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _searchUser,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _searchResults == null || _searchResults!.isEmpty
                    ? Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _searchResults!.length,
                        itemBuilder: (context, index) {
                          var user = _searchResults![index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to user profile page
                            },
                            child: Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text('Email: ${user['email']}'),
                                    Text('Phone: ${user['phone']}'),
                                    Text('User Type: ${user['userType']}'),
                                    Text('Bio: ${user['bio']}'),
                                    Text('Harbour: ${user['harbour']}'),
                                    SizedBox(height: 8),
                                    if (user['profilePic'] != null)
                                      Image.network(
                                        user['profilePic'],
                                        height: 100,
                                        width: 100,
                                      ),
                                    if (user['profilePic'] == null)
                                      Image.asset(
                                        'assets/default_profile_pic.png',
                                        height: 100,
                                        width: 100,
                                      ), // Show default profile pic
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchUser() async {
    final trimmedQuery = _searchController.text.trim();
    if (trimmedQuery.isNotEmpty) {
      // Check if the search query is not empty
      final response = await http.get(
        Uri.parse('${Api.userProfileUrl}/search?q=$trimmedQuery'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to search user');
      }
    }
  }
}
