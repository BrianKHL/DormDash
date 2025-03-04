import 'package:flutter/material.dart';
import 'pages/sell_giveaway_page.dart'; // ✅ Import Sell/Giveaway Page
import 'pages/chat_page.dart';          // ✅ Import Chat Page
import 'pages/admin_page.dart';         // ✅ Import Admin Page

void main() {
  runApp(DormDashApp());
}

class DormDashApp extends StatelessWidget {
  const DormDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DormDash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // ✅ Home Screen as the initial route
    );
  }
}

// ==================== ✅ HOME SCREEN ====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DormDash - Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Sell/Give Away Items"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellGiveAwayScreen()), // ✅ Navigate to Sell/Giveaway Page
                );
              },
            ),
            ElevatedButton(
              child: Text("Go to Chat"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()), // ✅ Navigate to Chat Feature
                );
              },
            ),
            ElevatedButton(
              child: Text("Admin Panel"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPage()), // ✅ Navigate to Admin Page
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
