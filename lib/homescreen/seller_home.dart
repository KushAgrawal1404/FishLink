import 'package:flutter/material.dart';
import 'package:fish_link/components/SellerHomeMenu.dart';

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Home'),
      ),
      drawer: const SellerHomeMenu(),
      body: const Center(
        child: Text('Welcome to Seller Home'),
      ),
    );
  }
}
