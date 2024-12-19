import 'package:flutter/material.dart';
import 'package:saintbook/pages/pagecontrol.dart'; // Import the main app file for navigation

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    // Navigate to the HomePage after 7 seconds
    Future.delayed(const Duration(seconds: 7), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PageControl()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/saints.jpg',
            fit: BoxFit.cover,
          ),
          // Overlay with text
          Container(
            color: Colors.black54, // semi-transparent overlay
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between elements
              children: [
                // Centered text
                Expanded(
                  child: Center(
                    child: Text(
                      'SaintBook',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // "Powered by AmberCode" at the bottom
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0), // Padding from the bottom
                  child: Text(
                    'Powered by AmberCode',
                    style: TextStyle(
                      fontSize: 16, // Smaller font size
                      color: Colors.amber, // Amber color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}