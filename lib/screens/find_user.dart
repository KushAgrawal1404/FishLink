import 'package:fish_link/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class FindUserPage extends StatefulWidget {
  const FindUserPage({Key? key}) : super(key: key);

  @override
  _FindUserPageState createState() => _FindUserPageState();
}

class _FindUserPageState extends State<FindUserPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic>? _searchResults;
  Timer? _debounce;
  bool _showNoResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find User'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // Change the background color
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(15.0),
                  hintText: 'Search with Username, Email or Phone number',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _searchUser(); // Search when the search button is clicked
                    },
                  ),
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 100), () {
                    _searchUser(); // Search after the user stops typing for 1 second
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _searchResults == null && _showNoResults == false
                  ? const Center(child: Text('Start typing to find users'))
                  : _searchResults != null && _searchResults!.isEmpty
                      ? const Center(child: Text('No results found'))
                      : _searchResults != null
                          ? ListView.builder(
                              itemCount: _searchResults!.length,
                              itemBuilder: (context, index) {
                                var user = _searchResults![index];
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to user profile page
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16.0),
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: user['profilePic'] != null
                                                  ? NetworkImage(Api.baseUrl +
                                                      user['profilePic'])
                                                  : const AssetImage(
                                                          'assets/default_profile_pic.png')
                                                      as ImageProvider,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildProfileItemBox(
                                            'Name', user['name']),
                                        const SizedBox(height: 8),
                                        _buildProfileItemBox(
                                            'Email', user['email']),
                                        const SizedBox(height: 8),
                                        _buildProfileItemBox(
                                            'Phone', user['phone']),
                                        const SizedBox(height: 8),
                                        _buildProfileItemBox(
                                            'User Type', user['userType']),
                                        const SizedBox(height: 8),
                                        _buildProfileItemBox(
                                            'Bio', user['bio']),
                                        const SizedBox(height: 8),
                                        _buildProfileItemBox(
                                            'Harbour', user['harbour']),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(child: Text('No results found')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItemBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchUser() async {
    final trimmedQuery = _searchController.text.trim();
    if (trimmedQuery.isNotEmpty) {
      final response = await http.get(
        Uri.parse('${Api.userProfileUrl}/search?q=$trimmedQuery'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body);
          if (_searchResults!.isEmpty) {
            _showNoResults = true;
          } else {
            _showNoResults = false;
          }
        });
      } else {
        throw Exception('Failed to search user');
      }
    } else {
      setState(() {
        _searchResults = null;
        _showNoResults = false;
      });
    }
  }
}
