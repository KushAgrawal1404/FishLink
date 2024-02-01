import 'package:flutter/material.dart';
import 'package:fish_link/screens/login_page.dart';
import 'package:fish_link/screens/signup_landing_page.dart';
import 'package:fish_link/screens/buyer_signup_page.dart';
import 'package:fish_link/screens/seller_signup_page.dart';
import 'package:fish_link/homescreen/buyer_home.dart';
import 'package:fish_link/homescreen/seller_home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FishLink App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup_landing': (context) => const SignupLandingPage(),
        '/buyer_signup': (context) => const BuyerSignupPage(),
        '/seller_signup': (context) => const SellerSignupPage(),
        '/buyer_home': (context) => const BuyerHomePage(),
        '/seller_home': (context) => const SellerHomePage(),
      },
    );
  }
}
