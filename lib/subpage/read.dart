import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:saintbook/model/admanager.dart';
import 'package:saintbook/model/helper.dart';

import 'package:shared_preferences/shared_preferences.dart';
// Import the FavoritePage
import 'package:saintbook/subpage/watch.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart'; // Import your YoutubePlayerPage

class SaintDetailPage extends StatefulWidget {
  final String saintName;
  final String saintImage;
  final String saintStory;
  final String videoUrl;
  final String celebrationDate; // Add video URL if applicable

  const SaintDetailPage(
      {super.key,
      required this.saintName,
      required this.saintImage,
      required this.saintStory,
      required this.videoUrl,
      required this.celebrationDate // Add video URL if applicable
      });

  @override
  State<SaintDetailPage> createState() => _SaintDetailPageState();
}

class _SaintDetailPageState extends State<SaintDetailPage> {
  bool isFavorite = false;
  var startAppSdk = StartAppSdk();
  StartAppBannerAd? bannerAd;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  _loadBannerAd() {
    BannerAd(
      adUnitId: Adhelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
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

  _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Adhelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('Interstitial ad loaded');
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load: $error');
          _interstitialAd = null;
          Future.delayed(const Duration(seconds: 10), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('Interstitial ad is not ready yet');
      _showRewardedAd();
    }
  }

  _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: Adhelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('Rewarded ad loaded');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Rewarded ad failed to load: $error');
          _rewardedAd = null;
          Future.delayed(const Duration(seconds: 10), () {
            _loadRewardedAd();
          });
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      _showInterstitialAd();
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _loadRewardedAd();
        _showInterstitialAd();
        if (placements[AdManager.interstitialVideoAdPlacementId] == true) {
          _showAd(AdManager.interstitialVideoAdPlacementId);
        }
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd = null;
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

  Future<void> _checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.saintName);
    });
  }

  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites') ?? [];

    if (isFavorite) {
      favorites.remove(widget.saintName);
      await prefs.setStringList('favorites', favorites);
    } else {
      favorites.add(widget.saintName);
      await prefs.setStringList('favorites', favorites);

      // Save saint details in SharedPreferences
      await prefs.setString('${widget.saintName}_image', widget.saintImage);
      await prefs.setString('${widget.saintName}_story', widget.saintStory);
      await prefs.setString('${widget.saintName}_video', widget.videoUrl);
      await prefs.setString(
          '${widget.saintName}_celebrationDate', widget.celebrationDate);
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    startAppSdk.setTestAdsEnabled(false);
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

    //for admob
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    DateTime parseDate = DateTime.parse(widget.celebrationDate);
    String saintDate = DateFormat('MMMM d').format(parseDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.saintName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          else if (_showBanner)
            UnityBannerAd(
                placementId: AdManager.bannerAdPlacementId,
                onLoad: (placementId) => print('Banner loaded: $placementId'),
                onClick: (placementId) => print('Banner clicked: $placementId'),
                onShown: (placementId) => print('Banner shown: $placementId'),
                onFailed: (placementId, error, message) {
                  print('Banner Ad $placementId failed: $error $message');
                  bannerAd != null ? StartAppBanner(bannerAd!) : const SizedBox.shrink();
                })
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1438463902.
            else const SizedBox.shrink(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(widget.saintImage),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.saintName,
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Feast Date: $saintDate",
                    style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                  const SizedBox(height: 16.0),
                  bannerAd != null ? StartAppBanner(bannerAd!) : const SizedBox.shrink(),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.saintStory,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle video playback, e.g., using a video player plugin
                        if (_interstitialAd != null) {
                          _showInterstitialAd();
                        } else if (placements[
                                AdManager.interstitialVideoAdPlacementId] ==
                            true) {
                          _showAd(AdManager.interstitialVideoAdPlacementId);
                        } else if (_rewardedAd != null) {
                          _showRewardedAd();
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YoutubePlayerPage(
                              saintName: widget.saintName,
                              videoUrl: widget.videoUrl,
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
          ),
        ],
      ),
    );
  }
}
