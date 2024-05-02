import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fish_link/utils/api.dart';

class ProfileViewPage extends StatefulWidget {
  final String userId;

  const ProfileViewPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileViewPageState createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http
          .get(Uri.parse('${Api.userProfileUrl}/user/${widget.userId}'));
      if (response.statusCode == 200) {
        setState(() {
          userProfile = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Profile'),
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
      body: userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                GestureDetector(
                  onTap: () {}, // Placeholder for future implementation
                  child: Container(
                    width: 250,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: userProfile!['profilePic'] != null &&
                                userProfile!['profilePic'] != ''
                            ? NetworkImage(
                                Api.baseUrl + userProfile!['profilePic'])
                            : const AssetImage('assets/default_profile_pic.png')
                                as ImageProvider,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildProfileItemBox('Name', userProfile!['name'], Icons.person),
                _buildProfileItemBox('Email', userProfile!['email'], Icons.email),
                _buildProfileItemBox('Phone', userProfile!['phone'], Icons.phone),
                _buildProfileItemBox('Bio', userProfile!['bio'] ?? '', Icons.book),
                _buildProfileItemBox(
                    'Harbour', userProfile!['harbour'] ?? '', Icons.location_on),
              ],
            ),
    );
  }

  Widget _buildProfileItemBox(String label, dynamic value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue), // Blue colored icon
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  value.toString(), // Convert value to String
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
