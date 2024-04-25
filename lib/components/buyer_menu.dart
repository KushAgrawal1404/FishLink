import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/utils/api.dart';

class BuyerHomeMenu extends StatefulWidget {
  const BuyerHomeMenu({Key? key}) : super(key: key);

  @override
  _BuyerHomeMenuState createState() => _BuyerHomeMenuState();
}

class _BuyerHomeMenuState extends State<BuyerHomeMenu> {
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
          // Drawer Header
          userProfile == null
              ? DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xff0f1f30),
                  ),
                  child: CircularProgressIndicator(),
                )
              : UserAccountsDrawerHeader(
                  accountName: Text(
                    'Hi, ${userProfile!['name']}',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  accountEmail: Text(
                    capitalizeFirstLetter(userProfile!['userType']),
                    style: TextStyle(color: Colors.white70),
                  ),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/buyer_profile');
                    },
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundImage: userProfile!['profilePic'] != null &&
                              userProfile!['profilePic'] != ''
                          ? NetworkImage(userProfile!['profilePic'])
                          : AssetImage('assets/default_profile_pic.png')
                              as ImageProvider,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xff0f1f30),
                  ),
                ),

          // Divider
          Divider(),

          // List Items
          ListTile(
            leading: Icon(Icons.home, size: 28),
            title: Text(
              'Home',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Add navigation logic here
            },
          ),
          ListTile(
            leading: Icon(Icons.checklist, size: 28),
            title: Text(
              'My Bids',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/my_bids');
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics, size: 28),
            title: Text(
              'Buyer Analytics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/buyer_analytics');
            },
          ),
          ListTile(
            leading: Icon(Icons.person, size: 28),
            title: Text(
              'My Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/buyer_profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.person, size: 28),
            title: Text(
              'Find Users',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/find_users');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, size: 28),
            title: Text(
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
