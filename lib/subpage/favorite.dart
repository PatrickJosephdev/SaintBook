import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:saintbook/model/admanager.dart';
import 'package:saintbook/model/helper.dart';
import 'package:saintbook/subpage/read.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
// Import the SaintDetailPage

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<String> favorites = [];
  BannerAd? _bannerAd;




  _loadBannerAd() {
    BannerAd(
      adUnitId: Adhelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.fluid,
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



  final bool _showBanner = true;
  Map<String, bool> placements = {
    AdManager.interstitialVideoAdPlacementId: false,
    AdManager.rewardedVideoAdPlacementId: false,
  };

  void _loadAds() {
    for (var placementId in placements.keys) {
      _loadAd(placementId);
    }
  }

  void _loadAd(String placementId) {
    UnityAds.load(
      placementId: placementId,
      onComplete: (placementId) {
        print('Load Complete $placementId');
        setState(() {
          placements[placementId] = true;
        });
      },
      onFailed: (placementId, error, message) =>
          print('Load Failed $placementId: $error $message'),
    );
  }

  void _showAd(String placementId) {
    setState(() {
      placements[placementId] = false;
    });
    UnityAds.showVideoAd(
      placementId: placementId,
      onComplete: (placementId) {
        print('Video Ad $placementId completed');
        _loadAd(placementId);
      },
      onFailed: (placementId, error, message) {
        print('Video Ad $placementId failed: $error $message');
        _loadAd(placementId);
      },
      onStart: (placementId) => print('Video Ad $placementId started'),
      onClick: (placementId) => print('Video Ad $placementId click'),
      onSkipped: (placementId) {
        print('Video Ad $placementId skipped');
        _loadAd(placementId);
      },
    );
  }

  var startAppSdk = StartAppSdk();
  StartAppBannerAd? bannerAd;

  loadbannerAd() {
    startAppSdk.loadBannerAd(StartAppBannerType.MREC).then((bannerAd) {
      setState(() {
        this.bannerAd = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    loadbannerAd();
    UnityAds.init(
      gameId: AdManager.gameId,
      testMode: false,
      onComplete: () {
        print('Initialization Complete');
        _loadAds();
      },
      onFailed: (error, message) =>
          print('Initialization Failed: $error $message'),
    );
    ///admob
    _loadBannerAd();
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Column(
        children: [
          
          Expanded(
            child: favorites.isEmpty
                ? const Center(child: Text('No favorites added yet.'))
                : ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      String saintName = favorites[index];

                      // Retrieve the saint details from SharedPreferences
                      return FutureBuilder<SharedPreferences>(
                        future: SharedPreferences.getInstance(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          SharedPreferences prefs = snapshot.data!;
                          String? saintImage =
                              prefs.getString('${saintName}_image');
                          String? saintStory =
                              prefs.getString('${saintName}_story');
                          String? videoUrl =
                              prefs.getString('${saintName}_video');
                          String? celebrationDate =
                              prefs.getString('${saintName}_celebrationDate');

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0), // Padding
                            // Light grey background
                            leading: saintImage != null
                                ? SizedBox(
                                    height: 50.0, // Fixed height for image
                                    width: 50.0, // Fixed width for image
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          8.0), // Rounded corners (optional)
                                      child: Image.network(saintImage),
                                    ),
                                  )
                                : null,
                            title: Text(
                              saintName,
                              overflow:
                                  TextOverflow.ellipsis, // Truncate with "..."
                            ),
                            subtitle: Text(
                              saintStory ?? 'No story available',
                              overflow:
                                  TextOverflow.ellipsis, // Truncate with "..."
                              maxLines: 1, // Limit to one line
                            ),
                            onTap: () {
                              // Navigate to SaintDetailPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SaintDetailPage(
                                    saintName: saintName,
                                    saintImage: saintImage ?? '',
                                    saintStory: saintStory ?? '',
                                    videoUrl: videoUrl ?? '',
                                    celebrationDate: celebrationDate ?? '',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
          if (_bannerAd != null)
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          )
          else if (_showBanner)
            UnityBannerAd(
                placementId: AdManager.bannerAdPlacementId,
                onLoad: (placementId) => print('Banner loaded: $placementId'),
                onClick: (placementId) => print('Banner clicked: $placementId'),
                onShown: (placementId) => print('Banner shown: $placementId'),
                onFailed: (placementId, error, message) {
                  print('Banner Ad $placementId failed: $error $message');
                  bannerAd != null ? StartAppBanner(bannerAd!) : Container();
                }
                ),
        ],
      ),
    );
  }
}
