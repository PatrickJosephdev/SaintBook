import 'package:flutter/material.dart';
import 'package:saintbook/subpage/watch.dart';

class DailyMessage extends StatelessWidget {
  final String imageUrl;
  final String videoUrl;

  const DailyMessage({super.key, required this.imageUrl, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover, // Cover the entire container
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // A semi-transparent overlay to improve text visibility
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Text(
                'Watch Now',
                style: TextStyle(
                  fontSize: 32.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => YoutubePlayerPage(videoUrl: videoUrl, saintName: '',),
                    ),
                  );
                },
                child: const Text('Watch Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}