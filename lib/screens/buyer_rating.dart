import 'package:flutter/material.dart';
import 'package:fish_link/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StarRating extends StatefulWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;

  const StarRating({
    Key? key,
    required this.rating,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starColor = _getStarColor(index);
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
              widget.onRatingChanged(_rating);
            });
          },
          icon: Icon(
            index < _rating.floor() ? Icons.star : Icons.star_border,
            color: starColor,
          ),
        );
      }),
    );
  }

  Color _getStarColor(int index) {
    final filledStarCount = _rating.floor();
    if (filledStarCount >= index + 1) {
      if (filledStarCount <= 2) {
        return Colors.red;
      } else if (filledStarCount == 3) {
        return Colors.yellow;
      } else {
        return Colors.green;
      }
    } else {
      return Colors.grey; // Color for empty stars
    }
  }
}

class WinnerPage extends StatefulWidget {
  final Map<String, dynamic> catchDetails;

  const WinnerPage({Key? key, required this.catchDetails}) : super(key: key);

  @override
  _WinnerPageState createState() => _WinnerPageState();
}

class _WinnerPageState extends State<WinnerPage> {
  double _rating = 1.0;
  late final TextEditingController _commentController = TextEditingController();

  Future<void> _submitRating() async {
    String apiUrl = Api.createRatingUrl;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? winnerId = widget.catchDetails['highestBidder'];
    String catchId = widget.catchDetails['_id']; // Retrieve catchId

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ratedUserId': winnerId,
          'rating': _rating,
          'comment': _commentController.text,
          'commenterUsername': userId,
          'catchId': catchId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close the winner page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit rating'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Winner Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Rate the winner',
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
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comment (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRating,
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Button color
                onPrimary: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Button border
                ),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Button padding
              ),
              child: const Text(
                'Submit Rating',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
