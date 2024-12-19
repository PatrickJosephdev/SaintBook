import 'package:flutter/material.dart';
// Ensure this import is correct
import 'package:intl/intl.dart'; // Import this package for date formatting

class DailyMassWidget extends StatelessWidget {
  final String imageUrl;
  final String videoUrl;
  final VoidCallback onReadNow;

  const DailyMassWidget(
      {super.key, required this.imageUrl, required this.videoUrl, required this.onReadNow});

  @override
  Widget build(BuildContext context) {
    // Get the current date
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, MMMM d, y')
        .format(now); // Format date as "Day, Month Date, Year"

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover, // Cover the entire container
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              // A semi-transparent overlay to improve text visibility
              Container(
                color: Colors.black.withOpacity(0.5),
              ),
              Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Space between elements
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Daily Mass',
                        style: TextStyle(
                          fontSize: 32.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Positioned button at the bottom
                  Padding(
                    padding: const EdgeInsets.all(
                        16.0), // Add padding for the button
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          
                          borderRadius:
                              BorderRadius.circular(30.0), // Rounded edges
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30), // Button padding
                      ),
                      onPressed: onReadNow,
                      child: const Text('Watch Now'),
                    ),
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
