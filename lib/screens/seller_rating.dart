import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:fish_link/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerRatingPage extends StatefulWidget {
  final catchDetails;

  const SellerRatingPage({Key? key, required this.catchDetails})
      : super(key: key);

  @override
  _SellerRatingPageState createState() => _SellerRatingPageState();
}

class _SellerRatingPageState extends State<SellerRatingPage> {
  double _rating = 0.0;
  String _comment = '';

  Future<void> _submitRating() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        final response = await http.get(
          Uri.parse('${Api.catchSellerUrl}/${widget.catchDetails['_id']}'),
        );

        if (response.statusCode == 200) {
          final sellerDetails = jsonDecode(response.body);
          final sellerId = sellerDetails['seller'];

          final ratingResponse = await http.post(
            Uri.parse(Api.createSellerRatingUrl),
            body: jsonEncode({
              'ratedSellerId': sellerId,
              'rating': _rating.toString(),
              'comment': _comment,
              'raterUserId': userId,
            }),
            headers: {'Content-Type': 'application/json'},
          );

          if (ratingResponse.statusCode == 201) {
            _showSnackBar('Rating submitted successfully', Colors.green);
          } else {
            _showSnackBar(
                'Failed to submit rating. Please try again.', Colors.red);
          }
        } else {
          _showSnackBar(
              'Failed to fetch seller details. Please try again.', Colors.red);
        }
      } else {
        _showSnackBar('User ID is null. Please try again.', Colors.red);
      }
    } catch (error) {
      _showSnackBar('Error creating seller rating: $error', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Seller'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.1), // Top padding to keep content at the top
            Text(
              'Rate the seller:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Add a comment (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _comment = value;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _submitRating();
              },
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}
