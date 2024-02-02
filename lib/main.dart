import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/screens/login_page.dart';
import 'package:fish_link/screens/signup_landing_page.dart';
import 'package:fish_link/screens/buyer_signup_page.dart';
import 'package:fish_link/screens/seller_signup_page.dart';
import 'package:fish_link/homescreen/buyer_home.dart';
import 'package:fish_link/homescreen/seller_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FishLink App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthChecker(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup_landing': (context) => const SignupLandingPage(),
        '/buyer_signup': (context) => const BuyerSignupPage(),
        '/seller_signup': (context) => const SellerSignupPage(),
        '/buyer_home': (context) => const BuyerHomePage(),
        '/seller_home': (context) => const SellerHomePage(),
      },
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoading = true;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userType = prefs.getString('userType');
    if (userType != null) {
      setState(() {
        _userType = userType;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator(); // Show loading indicator
    } else {
      if (_userType != null) {
        // User is logged in, navigate to respective page based on userType
        if (_userType == 'buyer') {
          return const BuyerHomePage();
        } else if (_userType == 'seller') {
          return const SellerHomePage();
        }
      }
      // User is not logged in, redirect to login page
      return const LoginPage();
    }
  }
}
