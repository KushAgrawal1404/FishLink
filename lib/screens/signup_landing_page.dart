import 'package:flutter/material.dart';

class SignupLandingPage extends StatelessWidget {
  const SignupLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Account'),
      ),
      backgroundColor: Colors.grey[200], // Adding a background color
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Adding padding around the content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/buyer_signup');
              },
              style: ElevatedButton.styleFrom(
                primary: const Color.fromRGBO(105, 240, 174, 1),
                onPrimary: Colors.white,
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding: EdgeInsets.all(20.0), // Adding padding inside the button
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text('Register as Buyer', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/seller_signup');
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
                onPrimary: Colors.white,
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding: EdgeInsets.all(20.0), // Adding padding inside the button
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.storefront,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text('Register as Seller', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
