import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/components/SellerHomeMenu.dart';

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getNameFromSharedPreferences(),
      builder: (context, snapshot) {
        String title =
            snapshot.hasData ? 'Hi, ${snapshot.data}' : 'Seller Home';
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          drawer: const SellerHomeMenu(),
          body: const Center(
            child: Text('Welcome to Seller Home'),
          ),
        );
      },
    );
  }

  Future<String> _getNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ??
        ''; // Assuming 'name' is the key for the name in SharedPreferences
  }
}
