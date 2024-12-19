import 'package:flutter/material.dart';

class SaintCard extends StatelessWidget {
  final String saintName;
  final String celebrationDate;
  final String imageUrl;
  final VoidCallback onReadNow;

  const SaintCard({
    super.key,
    required this.saintName,
    required this.celebrationDate,
    required this.imageUrl,
    required this.onReadNow,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350, // Adjust the height as necessary
      width: double.infinity,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: NetworkImage(
                      imageUrl), // Load image from network or assets
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Overlay to darken the image for better text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.black.withOpacity(0.5),
              ),
              // Adjust opacity for effect
            ),
          ),
          // Saint name and date
          Positioned(
            left: 16,
            right: 16,
            top: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Saint Of The Day",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  saintName,
                  style:  TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                      
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.fade,
                  
                ),
                const SizedBox(height: 8),
                Text(
                  celebrationDate,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // "Read Now" button
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width * 0.5,
            right: 16,
            child: ElevatedButton(
              onPressed: onReadNow,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black.withOpacity(0.3), // Text color
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Read Now",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
