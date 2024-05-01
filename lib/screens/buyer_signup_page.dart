import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:fish_link/utils/api.dart'; // Update with your actual project name

class BuyerSignupPage extends StatefulWidget {
  const BuyerSignupPage({Key? key}) : super(key: key);

  @override
  State<BuyerSignupPage> createState() => _BuyerSignupPageState();
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
          'userType': 'buyer', // Assuming buyer as the user type
        }),
        headers: {'Content-Type': 'application/json'},
      );
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        String msg = responseBody['msg'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg), // Use the value of 'msg' here
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Signup failed, show error message
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
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
        ),
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
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Choose a username',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  LengthLimitingTextInputFormatter(
                      10), // Limit input to 10 characters
                ],
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Enter your phone number',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
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
                      MaterialStateProperty.all(Color.fromARGB(255, 218, 244, 157)),
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
