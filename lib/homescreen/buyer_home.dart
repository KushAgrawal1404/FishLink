import 'package:flutter/material.dart';

class BuyerHomePage extends StatelessWidget {
  const BuyerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Home'),
      ),
      body: const Center(
        child: Text('Welcome to Buyer Home'),
      ),
    );
  }
}
