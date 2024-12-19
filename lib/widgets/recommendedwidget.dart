import 'package:flutter/material.dart';

class Recommended extends StatelessWidget {
  final String saintName;
  final String celebrationDate;
  final String imageUrl;
  final VoidCallback onReadNow;

  const Recommended({
    super.key,
    required this.saintName,
    required this.celebrationDate,
    required this.imageUrl,
    required this.onReadNow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        // Using SizedBox for better adaptability
        width: 200,
        height: 200,
        child: Stack(
          // Using Stack to overlay elements
          children: [
            ClipRRect(
              // ClipRRect to round image corners
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              // Container for the dark overlay
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    // Expanded to allow text to take available space
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        saintName,
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis // Handle overflow
                            ),
                        maxLines: 2, // Limit lines if needed
                      ),
                    ),
                  ),
                  Text(
                    celebrationDate,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  const Spacer(), // Spacer to push button to the bottom
                  Align(
                    // Align to position button
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: onReadNow, // Call onReadNow callback
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 245, 241, 241),
                        backgroundColor:
                            const Color.fromARGB(255, 2, 2, 2).withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8), // Adjusted padding
                        textStyle:
                            const TextStyle(fontSize: 12), // Adjusted font size
                      ),
                      child: const Text("Read Now"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





