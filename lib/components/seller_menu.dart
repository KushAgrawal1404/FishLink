import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/utils/api.dart';

class SellerHomeMenu extends StatefulWidget {
  const SellerHomeMenu({Key? key}) : super(key: key);

  @override
  _SellerHomeMenuState createState() => _SellerHomeMenuState();
}

class _SellerHomeMenuState extends State<SellerHomeMenu> {
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    // Attempt to load user profile from SharedPreferences first
    userProfile = await loadUserProfile();

    if (userProfile == null) {
      // Load from online source if not available in SharedPreferences
      await fetchUserProfileFromServer();
    }

    setState(() {}); // Update UI once userProfile is loaded
  }

  // Load user profile from SharedPreferences
  Future<Map<String, dynamic>?> loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userProfileJson = prefs.getString('userProfile');
    if (userProfileJson != null) {
      return json.decode(userProfileJson);
    } else {
      return null;
    }
  }

  // Fetch user profile from the server, store it in SharedPreferences
  Future<void> fetchUserProfileFromServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    try {
      final response =
          await http.get(Uri.parse('${Api.userProfileUrl}/user/$userId'));
      if (response.statusCode == 200) {
        Map<String, dynamic> decodedResponse = json.decode(response.body);
        await prefs.setString('userProfile', json.encode(decodedResponse));
        userProfile = decodedResponse;
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
    }
  }

  void logout(BuildContext context) async {
    // Clear the stored login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Navigate to the login screen
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Custom Drawer Header
          Container(
            color: Colors.blue.shade300,
            padding: const EdgeInsets.only(right: 20, top: 30, bottom: 20),
            alignment: Alignment.center,
            child: userProfile == null
                ? const SkeletonUserProfile() // Show skeleton UI while loading
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/buyer_profile');
                        },
                        child: CircleAvatar(
                          radius: 45.0,
                          backgroundImage: userProfile!['profilePic'] != null &&
                                  userProfile!['profilePic'] != ''
                              ? NetworkImage(
                                  Api.baseUrl + userProfile!['profilePic'])
                              : const AssetImage(
                                      'assets/default_profile_pic.png')
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${userProfile!['name']}',
                        style:
                            const TextStyle(fontSize: 20, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '(${capitalizeFirstLetter(userProfile!['userType'])})',
                        style:
                            const TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),

          // List Items
          ListTile(
            leading: const Icon(
              Icons.history,
              size: 28,
              color: Colors.green,
            ),
            title: const Text(
              'My Catches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/my_catches');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.add,
              size: 28,
              color: Colors.blue,
            ),
            title: const Text(
              'Add Catches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/add_catch');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.person,
              size: 28,
              color: Colors.blue,
            ),
            title: const Text(
              'My Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/seller_profile');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.person_search,
              size: 28,
              color: Colors.blue,
            ),
            title: const Text(
              'Find Users',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/find_users');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              size: 28,
              color: Colors.red,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              logout(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class SkeletonUserProfile extends StatelessWidget {
  const SkeletonUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 120,
          height: 18,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 5),
        Container(
          width: 100,
          height: 14,
          color: Colors.grey[300],
        ),
      ],
    );
  }
}
