import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/screens/login_page.dart';
import 'package:fish_link/screens/signup_landing_page.dart';
import 'package:fish_link/screens/buyer_signup_page.dart';
import 'package:fish_link/screens/seller_signup_page.dart';
import 'package:fish_link/homescreen/buyer_home.dart';
import 'package:fish_link/homescreen/seller_home.dart';
import 'package:fish_link/screens/add_catch.dart';

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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff0f1f30),
          elevation: 5.0,
          shadowColor: Colors.black87,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthChecker(),
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            // Replace with the appropriate page based on route name
            switch (settings.name) {
              case '/login':
                return const LoginPage();
              case '/signup_landing':
                return const SignupLandingPage();
              case '/buyer_signup':
                return const BuyerSignupPage();
              case '/seller_signup':
                return const SellerSignupPage();
              case '/buyer_home':
                return const BuyerHomePage();
              case '/seller_home':
                return const SellerHomePage();
              case '/add_catch':
                return const AddCatchPage();
              default:
                return const LoginPage();
            }
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
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
