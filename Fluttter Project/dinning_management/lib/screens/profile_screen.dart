import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String name = "John Doe";
  final String email = "john@example.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  AssetImage('assets/profile_placeholder.png'), // add asset
            ),
            SizedBox(height: 20),
            Text(name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(email, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.history, color: Colors.deepPurple),
              title: Text("Order History"),
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
            ListTile(
              leading: Icon(Icons.subscriptions, color: Colors.deepPurple),
              title: Text("Subscription"),
              onTap: () {
                Navigator.pushNamed(context, '/subscription');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.deepPurple),
              title: Text("Settings"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
