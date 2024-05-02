import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fish_link/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'buyer_rating.dart'; // Importing StarRating from buyer_rating.dart

class SellerRatingPage extends StatefulWidget {
  final catchDetails;

  const SellerRatingPage({Key? key, required this.catchDetails})
      : super(key: key);

  @override
  _SellerRatingPageState createState() => _SellerRatingPageState();
}

class _SellerRatingPageState extends State<SellerRatingPage> {
  double _rating = 0.0;
  late String _comment;

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
              'catchId': widget.catchDetails['_id']
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Rate the seller:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            StarRating(
              rating: _rating,
              onRatingChanged: (newRating) {
                setState(() {
                  _rating = newRating;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _comment = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Add a comment (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRating,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              child:
                  const Text('Submit Rating', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
