import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/utils/api.dart';
import 'package:intl/intl.dart';

class WinDetailsPage extends StatefulWidget {
  final String catchId;
  final String sellerId;

  const WinDetailsPage(
      {Key? key, required this.catchId, required this.sellerId})
      : super(key: key);

  @override
  _WinDetailsPageState createState() => _WinDetailsPageState();
}

class _WinDetailsPageState extends State<WinDetailsPage> {
  Map<String, dynamic> catchDetails = {};
  Map<String, dynamic> userProfile = {};
  bool isCatchDetailsExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchCatchDetails();
    fetchUserProfile();
  }

  Future<void> _fetchCatchDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${Api.catchDetailsUrl}/${widget.catchId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          catchDetails = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch catch details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching catch details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http
          .get(Uri.parse('${Api.userProfileUrl}/seller/${widget.sellerId}'));

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
        title: Text('Win Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: ExpansionTile(
                leading: Icon(Icons.details),
                title: Text(
                  'Catch Details',
                  style: TextStyle(
                      fontWeight: FontWeight.bold), // Make the title bold
                ),
                initiallyExpanded: isCatchDetailsExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isCatchDetailsExpanded = expanded;
                  });
                },
                children: <Widget>[
                  if (catchDetails.isNotEmpty)
                    Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: catchDetails['images'].length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Image.network(
                                  Api.baseUrl + catchDetails['images'][index],
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                        ListTile(
                          title: Text('Location: ${catchDetails['location']}'),
                        ),
                        ListTile(
                          title:
                              Text('Base Price: ${catchDetails['basePrice']}'),
                        ),
                        ListTile(
                          title: Text('Quanity: ${catchDetails['quantity']}'),
                        ),
                        ListTile(
                          title: Text(
                              'Winning Price: ${catchDetails['currentBid']}'),
                        ),
                        ListTile(
                          title: Text(
                            'Bid Start Time: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(catchDetails['startTime']))}',
                          ),
                        ),
                        ListTile(
                            title: Text(
                          'Bid End Time: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(catchDetails['endTime']))}',
                        )),
                      ],
                    )
                  else
                    ListTile(
                      title: Text('Loading Catch Details...'),
                    )
                ],
              ),
            ),
            Card(
              child: ExpansionTile(
                leading: Icon(Icons.person),
                title: Text(
                  'Seller Profile',
                  style: TextStyle(
                      fontWeight: FontWeight.bold), // Make the title bold
                ),
                children: <Widget>[
                  if (userProfile.isNotEmpty)
                    Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 80,
                              backgroundImage: userProfile['profilePic'] !=
                                          null &&
                                      userProfile['profilePic'] != ''
                                  ? NetworkImage(
                                      Api.baseUrl + userProfile['profilePic'])
                                  : AssetImage('assets/default_profile_pic.png')
                                      as ImageProvider,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text('Name: ${userProfile['name']}'),
                        ),
                        ListTile(
                          title: Text('Email: ${userProfile['email']}'),
                        ),
                        ListTile(
                          title: Text('Phone: ${userProfile['phone']}'),
                        ),
                        ListTile(
                          title: Text('Bio: ${userProfile['bio'] ?? ''}'),
                        ),
                        ListTile(
                          title:
                              Text('Harbour: ${userProfile['harbour'] ?? ''}'),
                        ),
                      ],
                    )
                  else
                    ListTile(
                      title: Text('Loading Seller Profile...'),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
