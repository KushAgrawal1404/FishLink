import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/utils/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Track password visibility
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // Check if user already logged in
    String? userType = _prefs.getString('userType');
    if (userType != null) {
      _redirectToHome(userType);
    }
  }

  Future<void> sendDeviceId(String userId, String deviceId) async {
    final Uri loginUrl = Uri.parse('${Api.baseUrl}/api/user/login');
    try {
      final response = await http.post(
        loginUrl,
        body: jsonEncode({
          'userId': userId,
          'deviceId': deviceId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      var responseBody = json.decode(response.body);
      if (response.statusCode != 200) {
        String msg = responseBody['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        ); // Close the dialog
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error Sending Device Id')),
      );
    }
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Your login API endpoint
    String apiUrl = Api.loginUrl;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );
      // Decode the response body
      var responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save login information
        _prefs.setString('name', responseBody['name']);
        _prefs.setString('email', email);
        _prefs.setString('userId', responseBody['userId']);
        _prefs.setString('userType', responseBody['userType']);
        _prefs.setString('token', responseBody['token']);
        final deviceState = await OneSignal.shared.getDeviceState();
        String? deviceToken = deviceState?.userId;
        sendDeviceId('${responseBody['userId']}', deviceToken!);
        _redirectToHome(responseBody['userType']);
      } else {
        // Login failed, show error message
        String msg = responseBody['msg'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg), // Use the value of 'msg' here
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _forgotPassword() async {
    String email = _emailController.text.trim();

    // Your forgot password API endpoint
    String apiUrl = Api.forgotPasswordUrl;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({'email': email}),
        headers: {'Content-Type': 'application/json'},
      );

      var responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        // Reset password email sent successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['msg']), // Show success message
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message if reset password email failed to send
        String errorMsg = responseBody['msg'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _redirectToHome(String userType) {
    if (userType == 'buyer') {
      Navigator.pushReplacementNamed(context, '/buyer_home');
    } else if (userType == 'seller') {
      Navigator.pushReplacementNamed(context, '/seller_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(155),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.green], // Add gradient colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'FishLink',
                style: TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontFamily: 'Times New Roman',
                ),
              ),
            ],
          ),
          toolbarHeight: 100,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: Padding(
              padding: EdgeInsets.only(bottom: 10, left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sign in To Your Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Times New Roman',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: InputBorder.none, // No visible border
                filled: true,
                fillColor: Colors.grey[200], // Add background color
                prefixIcon: const Icon(Icons.email), // Add email icon
                contentPadding: const EdgeInsets.all(16), // Add padding
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius:
                      BorderRadius.circular(10.0), // Add border radius
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: InputBorder.none, // No visible border
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.grey[200], // Add background color
                prefixIcon: const Icon(Icons.lock), // Add lock icon
                contentPadding: const EdgeInsets.all(16), // Add padding
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius:
                      BorderRadius.circular(15.0), // Add border radius
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              TextButton(
                onPressed: () {
                  _forgotPassword();
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue), // Change text color
                ),
              ),
            ]),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: _login,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Colors.blue), // Change button color
                elevation: MaterialStateProperty.all(10.0), // Add elevation
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                minimumSize: MaterialStateProperty.all(const Size(400, 55)),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold, // Add bold font weight
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Don\'t have an account?',
                    style: TextStyle(color: Colors.black)), // Change text color
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup_landing');
                  },
                  child: const Text('Register',
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
