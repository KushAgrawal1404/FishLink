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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    try {
      final response =
          await http.get(Uri.parse('${Api.userProfileUrl}/seller/$userId'));
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
          userProfile == null
              ? DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xff0f1f30),
                  ),
                  child: CircularProgressIndicator(),
                )
              : Container(
                  height: 200.0, // Increase the height of the container
                  child: UserAccountsDrawerHeader(
                    margin: EdgeInsets.zero,
                    accountName: Text(
                      'Hi, ${userProfile!['name']}',
                      style:
                          TextStyle(fontSize: 20.0), // Increase the font size
                    ),
                    accountEmail:
                        Text(capitalizeFirstLetter(userProfile!['userType'])),
                    currentAccountPicture: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context,
                            '/buyer_profile'); // Navigate to buyer_profile.dart
                      },
                      child: CircleAvatar(
                        radius: 70.0, // Increase the radius of the CircleAvatar
                        backgroundImage: userProfile!['profilePic'] != null &&
                                userProfile!['profilePic'] != ''
                            ? NetworkImage(userProfile!['profilePic'])
                            : AssetImage('assets/default_profile_pic.png')
                                as ImageProvider,
                      ),
                    ),
                  ),
                ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text(
              'Home',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Handle navigation to home screen
              Navigator.pop(context); // Close the drawer
              // Add navigation logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text(
              'My Catches',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Handle navigation to my products screen
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/my_catches');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text(
              'Add Catches',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Handle navigation to my products screen
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/add_catch');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              'Seller Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Handle navigation to seller profile screen
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/seller_profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              logout(context);
              Navigator.pop(context);
            },
          ),
          // Add more menu items as needed
        ],
      ),
    );
  }
}
