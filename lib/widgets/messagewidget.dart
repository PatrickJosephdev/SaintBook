import 'package:flutter/material.dart';
import 'package:saintbook/subpage/watch.dart';

class Message extends StatelessWidget {
  final String imageUrl;
  final String videoUrl;
  final String title;

  const Message({
    super.key,
    required this.imageUrl,
    required this.videoUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      // Set a fixed width for each item
      margin: const EdgeInsets.only(right: 10),
      child: Card(
        elevation: 5,
        child: Stack(
          children: [
            
            // Display the image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Button at the bottom
            Positioned(
              bottom: 0,
              left: 30,
              right: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 245, 241, 241),
                  backgroundColor:
                      const Color.fromARGB(255, 2, 2, 2).withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // Adjusted padding
                  textStyle:
                      const TextStyle(fontSize: 12), // Adjusted font size
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => YoutubePlayerPage(
                        videoUrl: videoUrl,
                        saintName: title,
                      ),
                    ),
                  );
                },
                child: const Text('Watch Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
