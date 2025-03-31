import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:saintbook/model/helper.dart';
import 'package:saintbook/sub-subpage/aboutus.dart';
import 'package:saintbook/sub-subpage/dailyreading.dart';
import 'package:saintbook/sub-subpage/donate.dart';
import 'package:saintbook/sub-subpage/feedback.dart';
import 'package:flutter/material.dart';
import 'package:saintbook/sub-subpage/meetdeveloper.dart';
import 'package:saintbook/sub-subpage/proversionpage.dart';
import 'package:saintbook/subpage/favorite.dart';
import 'package:saintbook/themes/themedatastyle.dart';
import 'package:saintbook/themes/themeprovider.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var startAppSdk = StartAppSdk();
  StartAppBannerAd? bannerAd;
  BannerAd? _bannerAd;

  _loadBannerAd() {
    BannerAd(
      adUnitId: Adhelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Failed to load a banner ad: ${error.message}');
          ad.dispose();
          Future.delayed(const Duration(seconds: 5), () {
            _loadBannerAd();
          });
        },
      ),
    ).load();
  }

  loadbannerAd() {
    startAppSdk.loadBannerAd(StartAppBannerType.MREC).then((bannerAd) {
      setState(() {
        this.bannerAd = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
      Future.delayed(const Duration(seconds: 5), () {
        loadbannerAd();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startAppSdk.setTestAdsEnabled(false);
    loadbannerAd();
    //admob
    _loadBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.book_online_rounded),
            title: const Text('Daily Reading'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Dailyreading()),
              );
              // Navigate to notifications settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_rounded),
            title: const Text('Favorite'),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritePage()),
              );
              if (result != null) {
                // Handle the returned saint name if needed
                // You can fetch the saint's details again if needed
              }

              // Navigate to notifications settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('FeedBack'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackPage()),
              );
              // Navigate to notifications settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_rounded),
            title: const Text('Meet the Developer'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MeetTheDeveloperPage()),
              );
              // Navigate to notifications settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_rounded),
            title: const Text('About Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsPage()),
              );
              // Navigate to notifications settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Support Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DonatePage()),
              );
              // Navigate to notifications settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeProvider.themeDataStyle == ThemeDataStyle.dark,
              onChanged: (value) {
                themeProvider.changeTheme();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.approval),
            title: const Text('Get Pro Version'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProPage()),
              );
              // Navigate to notifications settings page
            },
          ),
          if (_bannerAd != null)
            SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!))
          else if (bannerAd != null)
            StartAppBanner(bannerAd!),
        ],
      ),
    );
  }
}
