import 'package:flutter/material.dart';
import 'package:fish_link/components/BuyerHomeMenu.dart';

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
      drawer: const BuyerHomeMenu(), // Integrate the buyer menu panel here
    );
  }
}
