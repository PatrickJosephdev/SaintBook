import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // Function to launch URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About Us',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to Amber Code!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'At Amber Code, we are dedicated to providing you with the best experience in exploring the lives and stories of saints. Our mission is to inspire and educate users about the rich history and teachings of these remarkable individuals.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Our Vision',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'In Saint Book, We envision a world where everyone can connect with the teachings and stories of saints, fostering a deeper understanding of faith and spirituality.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Our Team',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Our team is composed of passionate individuals who are committed to creating a user-friendly platform that makes it easy for you to learn about saints. We believe in the power of storytelling and its ability to inspire and uplift.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Get Involved',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'We welcome your feedback and suggestions! If you have any ideas on how we can improve our app or if you would like to contribute, please reach out to us through the contact page.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Thank you for being a part of our community!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Follow Us',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Follow Us on our Social media Pages to get relevant updates, and also if you want us to make an App for you feel free to contact Us',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/facebook.jpeg',
                      fit: BoxFit.cover,
                      height: 50,
                      width: 50,
                    ), // Add your Facebook icon here
                    iconSize: 40,
                    onPressed: () => _launchURL(
                        'https://web.facebook.com/profile.php?id=61569119670095'),
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/whatsapp.png',
                      fit: BoxFit.cover,
                      height: 50,
                      width: 50,
                    ), // Add your Twitter icon here
                    iconSize: 50,
                    onPressed: () => _launchURL('https://wa.me/+2347042314717'),
                  ),
                  const SizedBox(
                    height: 30,
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
