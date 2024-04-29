import 'package:fish_link/screens/buyer_profile.dart';
import 'package:fish_link/screens/find_user.dart';
import 'package:fish_link/screens/seller_profile.dart';
import 'package:fish_link/screens/winner_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/screens/login_page.dart';
import 'package:fish_link/screens/signup_landing_page.dart';
import 'package:fish_link/screens/buyer_signup_page.dart';
import 'package:fish_link/screens/seller_signup_page.dart';
import 'package:fish_link/homescreen/buyer_home.dart';
import 'package:fish_link/homescreen/seller_home.dart';
import 'package:fish_link/screens/add_catch.dart';
import 'package:fish_link/screens/my_catches.dart';
import 'package:fish_link/screens/edit_catches.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:fish_link/screens/mybids.dart';
import 'package:fish_link/screens/buyerAnalytics.dart';
import 'package:fish_link/screens/buyer_my_wins.dart';

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
              case '/my_catches':
                return const MyCatchesPage();
              case '/edit_catches':
                var arguments = settings.arguments;
                return EditCatchPage(
                    catchDetails: arguments as Map<String, dynamic>);
              case '/seller_profile':
                return const SellerProfilePage();
              case '/buyer_profile':
                return const BuyerProfilePage();
              case '/my_bids':
                return const MyBidsPage();
              case '/buyer_analytics':
                return const BuyerAnalyticsPage();
              case '/find_users':
                return const FindUserPage();
              case '/winner_page':
                return const WinnerPage(catchDetails: {});
              case '/buyer_wins':
                return const BuyerWonCatchesPage();
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
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoading = true;
  String? _userType;

  @override
  void initState() {
    super.initState();
    initOneSignal();
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

  Future<void> initOneSignal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    // OneSignal Initialization
    OneSignal.shared.setAppId("4e0cccf9-332a-4d02-9d25-3004704064d1");

    // Optional: Prompt for notification permissions
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });

    OneSignal.shared.getDeviceState().then((deviceState) {
      if (deviceState == null || deviceState.userId == null) return;

      final deviceToken = deviceState.userId;
      prefs.setString('deviceToken', deviceToken!);
    });
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
