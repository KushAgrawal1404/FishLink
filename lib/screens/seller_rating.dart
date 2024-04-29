import 'package:flutter/material.dart';

class SellerRatingPage extends StatefulWidget {
  final String catchId;

  const SellerRatingPage({Key? key, required this.catchId}) : super(key: key);

  @override
  _SellerRatingPageState createState() => _SellerRatingPageState();
}

class _SellerRatingPageState extends State<SellerRatingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Seller'),
      ),
      body: Center(
        child: Text('Seller Rating Page for Catch ID: ${widget.catchId}'),
      ),
    );
  }
}
