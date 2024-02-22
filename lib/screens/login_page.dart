// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_link/utils/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
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
      print(responseBody);

      if (response.statusCode == 200) {
        // Save login information
        _prefs.setString('name', responseBody['name']);
        _prefs.setString('email', email);
        _prefs.setString('userId', responseBody['userId']);
        _prefs.setString('userType', responseBody['userType']);
        _prefs.setString('token', responseBody['token']);
        // Redirect to home
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
      // Error occurred during login process
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
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
      print(responseBody);

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
      // Handle network errors or other exceptions
      print('Error: $e');
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
        preferredSize:
            const Size.fromHeight(155), // Set the preferred height here
        child: AppBar(
          title: const Text(
            'Welcome to \nFishLink',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          titleTextStyle:
              const TextStyle(fontSize: 45, fontFamily: 'Times New Roman'),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
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
              ),
              obscureText: !_isPasswordVisible, // Toggle password visibility
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              TextButton(
                onPressed: () {
                  _forgotPassword(); // Call the forgot password method
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xFFbae162)),
                ),
              ),
            ]),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: _login,
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFFbae162)),
                elevation: MaterialStateProperty.all(8.0),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                minimumSize: MaterialStateProperty.all(const Size(400, 55)),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Don\'t have an account?'),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup_landing');
                  },
                  child: const Text('Register',
                      style: TextStyle(color: Color(0xFFbae162))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
