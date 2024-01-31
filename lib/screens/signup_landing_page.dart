import 'package:flutter/material.dart';

class SignupLandingPage extends StatelessWidget {
  const SignupLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Landing'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/buyer_signup');
              },
              child: const Text('Buyer Signup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/seller_signup');
              },
              child: const Text('Seller Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
