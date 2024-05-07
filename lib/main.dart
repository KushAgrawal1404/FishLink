import 'package:fish_link/screens/buyer_profile.dart';
import 'package:fish_link/screens/common_chat.dart';
import 'package:fish_link/screens/common_find_user.dart';
import 'package:fish_link/screens/seller_profile.dart';
import 'package:fish_link/screens/seller_rating_buyer.dart';
import 'package:fish_link/screens/buyer_rating_seller.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/screens/common_login_page.dart';
import 'package:fish_link/screens/common_signup_landing_page.dart';
import 'package:fish_link/screens/buyer_signup_page.dart';
import 'package:fish_link/screens/seller_signup_page.dart';
import 'package:fish_link/homescreen/buyer_home.dart';
import 'package:fish_link/homescreen/seller_home.dart';
import 'package:fish_link/screens/seller_add_catch.dart';
import 'package:fish_link/screens/seller_my_catches.dart';
import 'package:fish_link/screens/seller_edit_catches.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:fish_link/screens/buyer_mybids.dart';
import 'package:fish_link/screens/buyer_analytics.dart';
import 'package:fish_link/screens/buyer_my_wins.dart';
import 'package:fish_link/screens/buyer_win_details.dart';
import 'package:fish_link/screens/seller_soldbid_page.dart';
import 'package:google_fonts/google_fonts.dart';

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
        fontFamily: GoogleFonts.openSans().fontFamily,
      ),
      home: const AuthChecker(),
      onGenerateRoute: (settings) {
        // Route generator for dynamic routing
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            // Switch statement to determine which screen to navigate to based on route settings
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
              case '/chat':
                return ChatPage(catchId: '');
              case '/buyer_rating':
                return const WinnerPage(catchDetails: {});
              case '/seller_rating':
                return const SellerRatingPage(catchDetails: {});
              case '/buyer_wins':
                return const BuyerWonCatchesPage();
              case '/buyer_wins_details':
                return const WinDetailsPage(
                  catchId: '',
                  sellerId: '',
                );
              case '/sold_bid_page':
                return const SoldBidPage(
                  catchId: '',
                  buyerId: '',
                  catchDetails: {},
                );
              default:
                return const LoginPage();
            }
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Transition animation for page navigation
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.5,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: child,
              ),
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
    // Initialize OneSignal and check authentication status
    initOneSignal();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Check if user is authenticated by fetching user type from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userType = prefs.getString('userType');
    if (userType != null) {
      // If user type is available, set state to reflect authentication status
      setState(() {
        _userType = userType;
        _isLoading = false;
      });
    } else {
      // If user type is not available, set state to reflect authentication status
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> initOneSignal() async {
    // Initialize OneSignal for push notifications
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    // OneSignal Initialization
    OneSignal.shared.setAppId("4e0cccf9-332a-4d02-9d25-3004704064d1");

    // Optional: Prompt for notification permissions
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });

    // Get device token for push notifications
    OneSignal.shared.getDeviceState().then((deviceState) {
      if (deviceState == null || deviceState.userId == null) return;

      final deviceToken = deviceState.userId;
      prefs.setString('deviceToken', deviceToken!);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication status and navigate to appropriate screen
    if (_isLoading) {
      // Show loading indicator if authentication status is being checked
      return const CircularProgressIndicator();
    } else {
      if (_userType != null) {
        // If user type is available, navigate to respective home page
        if (_userType == 'buyer') {
          return const BuyerHomePage();
        } else if (_userType == 'seller') {
          return const SellerHomePage();
        }
      }
      // If user is not authenticated, redirect to login page
      return const LoginPage();
    }
  }
}
