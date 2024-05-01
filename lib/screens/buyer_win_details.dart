import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/utils/api.dart';
import 'package:intl/intl.dart';
import 'package:fish_link/screens/seller_rating.dart';

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
  List<dynamic> sellerRatings = [];
  bool isLoadingRatings = false;

  @override
  void initState() {
    super.initState();
    _fetchCatchDetails();
    fetchUserProfile();
    _getSellerRatings();
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
          const SnackBar(
            content: Text('Failed to fetch catch details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching catch details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http
          .get(Uri.parse('${Api.userProfileUrl}/user/${widget.sellerId}'));

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

  Future<void> _getSellerRatings() async {
    setState(() {
      isLoadingRatings = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        final response = await http.get(
          Uri.parse(
              '${Api.getSellerRatingsUrl}/${widget.sellerId}/${widget.catchId}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          setState(() {
            sellerRatings = jsonDecode(response.body);
            isLoadingRatings = false;
          });
        } else {
          print('Failed to fetch seller ratings: ${response.statusCode}');
          setState(() {
            isLoadingRatings = false;
          });
        }
      } else {
        print('User ID is null');
        setState(() {
          isLoadingRatings = false;
        });
      }
    } catch (error) {
      print('Error fetching seller ratings: $error');
      setState(() {
        isLoadingRatings = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Win Details'),
        backgroundColor:
            const Color(0xff0f1f30), // Set the app bar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildDetailsCard(),
              _buildProfileCard(),
              _buildRatingsCard(),
              if (isLoadingRatings) _buildLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      color: Colors.white, // Set background color to white
      child: ExpansionTile(
        leading: const Icon(Icons.details,
            color: Colors.orange), // Added color to the icon
        title: const Text(
          'Catch Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: isCatchDetailsExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            isCatchDetailsExpanded = expanded;
          });
        },
        backgroundColor: isCatchDetailsExpanded
            ? Colors.grey[200]
            : null, // Change background color when expanded
        children: <Widget>[
          if (catchDetails.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Location: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${catchDetails['location']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Base Price: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${catchDetails['basePrice']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Quantity: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${catchDetails['quantity']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Winning Price: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${catchDetails['currentBid']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Bid Start Time: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        DateFormat.yMMMd()
                            .add_jm()
                            .format(DateTime.parse(catchDetails['startTime'])),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Bid End Time: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        DateFormat.yMMMd()
                            .add_jm()
                            .format(DateTime.parse(catchDetails['endTime'])),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            const ListTile(
              title: Text('Loading Catch Details...'),
            )
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      color: Colors.white, // Set background color to white
      child: ExpansionTile(
        leading: const Icon(Icons.person,
            color: Colors.blue), // Added color to the icon
        title: const Text(
          'Seller Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: <Widget>[
          if (userProfile.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: userProfile['profilePic'] != null &&
                                userProfile['profilePic'] != ''
                            ? NetworkImage(
                                Api.baseUrl + userProfile['profilePic'])
                            : const AssetImage('assets/default_profile_pic.png')
                                as ImageProvider,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Name: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${userProfile['name']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Email: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${userProfile['email']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Phone: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${userProfile['phone']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Bio: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${userProfile['bio'] ?? ''}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Harbour: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${userProfile['harbour'] ?? ''}'),
                    ],
                  ),
                ],
              ),
            )
          else
            const ListTile(
              title: Text('Loading Seller Profile...'),
            )
        ],
      ),
    );
  }

  Widget _buildRatingsCard() {
    return Card(
      color: Colors.white, // Set background color to white
      child: ExpansionTile(
        leading: const Icon(Icons.star,
            color: Colors.yellow), // Added color to the icon
        title: const Text(
          'Seller Rating',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: <Widget>[
          if (!isLoadingRatings)
            if (catchDetails['isSellerRated'] == true)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sellerRatings.map((rating) {
                    return ListTile(
                      title: Text(
                        'Rating: ${rating['rating']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Comment: ${rating['comment'] ?? 'No comment'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SellerRatingPage(
                              catchDetails: catchDetails,
                            ),
                          ),
                        );
                      },
                      child: const Text('Please rate the seller'),
                    ),
                  ],
                ),
              )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
