import 'package:flutter/material.dart';

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Home'),
      ),
      body: const Center(
        child: Text('Welcome to Seller Home'),
      ),
    );
  }
}
