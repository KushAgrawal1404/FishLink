// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fish_link/utils/api.dart'; // Update with your actual project name

class BuyerSignupPage extends StatefulWidget {
  const BuyerSignupPage({super.key});

  @override
  _BuyerSignupPageState createState() => _BuyerSignupPageState();
}

class _BuyerSignupPageState extends State<BuyerSignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Track password visibility

  Future<void> _signup() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String username = _usernameController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();

    try {
      final response = await http.post(
        Uri.parse(Api.signupPath), // Using Uri.http() for the API endpoint
        body: jsonEncode({
          'name': name,
          'email': email,
          'username': username,
          'phone': phone,
          'password': password,
          'userType': 'buyer', // Assuming seller as the user type
        }),
        headers: {'Content-Type': 'application/json'},
      );
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        // Signup successful, navigate to login page
        String msg = responseBody['msg'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg), // Use the value of 'msg' here
          ),
        );
      } else {
        // Signup failed, show error message
        String msg = responseBody['msg'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg), // Use the value of 'msg' here
          ),
        );
      }
    } catch (e) {
      // Error occurred during signup process
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registering as Buyer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
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
                obscureText: !_isPasswordVisible,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _signup,
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
                  'Signup',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                    child: const Text('Login',
                        style: TextStyle(color: Color(0xFFbae162))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
