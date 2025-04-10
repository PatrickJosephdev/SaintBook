import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetTheDeveloperPage extends StatelessWidget {
  const MeetTheDeveloperPage({super.key});
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
        title: const Text('Meet the Developer'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/headshot.jpeg'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Patrick Joseph',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Flutter Developer',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Hi! I am Patrick Joseph, a passionate Flutter developer with a love for building beautiful and functional mobile applications. I enjoy creating user-friendly interfaces and delivering great user experiences.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/facebook.jpeg',
                      fit: BoxFit.cover,
                      height: 60,
                      width: 60,
                    ), // Add your Facebook icon here
                    iconSize: 60,
                    onPressed: () => _launchURL(
                        'https://web.facebook.com/profile.php?id=61569119670095'),
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/whatsapp.png',
                      fit: BoxFit.cover,
                      height: 60,
                      width: 60,
                    ), // Add your Twitter icon here
                    iconSize: 60,
                    onPressed: () => _launchURL('https://wa.me/+2349025494726'),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
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
