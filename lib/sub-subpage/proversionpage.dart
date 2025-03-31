import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProPage extends StatefulWidget {
  const ProPage({super.key});

  @override
  _ProPageState createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  String downloadLink = '';

  @override
  void initState() {
    super.initState();
    fetchDownloadLink();
  }

  Future<void> fetchDownloadLink() async {
    try {
      final response = await http.get(Uri.parse(
          'https://patrickjosephdev.github.io/Book_of_Saints/proversionlink.json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          downloadLink =
              data['download_link']; // Adjust based on your JSON structure
          print(data['download_link']);
        });
      } else {
        throw Exception('Failed to load download link');
      }
    } catch (e) {
      print('Error fetching download link: $e');
    }
  }

  Future<void> _launchURL() async {
    if (downloadLink.isNotEmpty) {
      if (await canLaunch(downloadLink)) {
        await launch(downloadLink);
      } else {
        throw 'Could not launch $downloadLink';
      }
    } else {
      Fluttertoast.showToast(
        msg: "Pro version not available right now",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Unlock the Full Experience!'),
            const SizedBox(height: 10),
            const Text(
                'Upgrade to the Pro version and enjoy an ad-free experience!'),
            const SizedBox(height: 20),
            const Text('Why Go Pro?'),
            const SizedBox(height: 10),
            const Text('- No Ads: Enjoy uninterrupted usage.'),
            const Text('- Exclusive Features: Access premium features.'),
            const Text('- Priority Support: Get faster assistance.'),
            const Text(
                '- Regular Updates: Stay ahead with the latest features.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchURL, // Call _launchURL directly
              child: const Text('Download'),
            ),
          ],
        ),
      ),
    );
  }
}
