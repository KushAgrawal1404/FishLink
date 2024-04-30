import 'package:flutter/material.dart';
import 'package:fish_link/screens/catch_details_page.dart';
import 'package:fish_link/screens/view_profile.dart';

class WinDetailsPage extends StatelessWidget {
  final String catchId;
  final String sellerId;

  const WinDetailsPage(
      {Key? key, required this.catchId, required this.sellerId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Win Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: ListTile(
                leading: Icon(Icons.details),
                title: Text('Catch Details'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CatchDetailsPage(catchId: catchId),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Seller Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileViewPage(userId: sellerId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
