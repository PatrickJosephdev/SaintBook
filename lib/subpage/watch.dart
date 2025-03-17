import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:saintbook/model/admanager.dart';
import 'package:saintbook/model/helper.dart';
import 'package:startapp_sdk/startapp.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerPage extends StatefulWidget {
  final String saintName;
  final String videoUrl;

  const YoutubePlayerPage(
      {super.key, required this.saintName, required this.videoUrl});

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  late YoutubePlayerController _controller;

  var startAppSdk = StartAppSdk();
  StartAppBannerAd? bannerAd;

  Timer? _bannerTimer;
  BannerAd? _bannerAd;

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
    startAppSdk.loadBannerAd(StartAppBannerType.BANNER).then((bannerAd) {
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

    // Extract the video ID from the provided video URL
    String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    // Initialize the YoutubePlayerController with the extracted video ID
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '', // Use an empty string if videoId is null
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    startAppSdk.setTestAdsEnabled(false);
    loadbannerAd();
    _loadBannerAd();

    UnityAds.init(
      gameId: AdManager.gameId,
      testMode: false,
      onComplete: () {
        print('Initialization Complete');
        _loadAds();
// Start the ad timer
      },
      onFailed: (error, message) =>
          print('Initialization Failed: $error $message'),
    );
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Dispose of the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Story of ${widget.saintName}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: YoutubePlayerBuilder(
                    player: YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.amber,
                      progressColors: const ProgressBarColors(
                        playedColor: Colors.amber,
                        handleColor: Colors.amberAccent,
                      ),
                      onReady: () {
                        // Optional: Add a listener if you want to listen for player events
                        _controller.addListener(() {
                          // Example: Print the player state
                          if (_controller.value.isPlaying) {
                            print("Video is playing");
                          }
                        });
                      },
                    ),
                    builder: (context, player) {
                      return Center(
                        child: Column(
                          children: [
                            // Add any other widgets you want above the player
                            Text("Now Playing: ${widget.saintName}"),
                            const SizedBox(height: 20),
                            player, // This is where the player is rendered
                            // Add any other widgets you want below the player
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          //     if (_bannerAd != null)
          //   SizedBox(
          //     width: _bannerAd!.size.width.toDouble(),
          //     height: _bannerAd!.size.height.toDouble(),
          //     child: AdWidget(ad: _bannerAd!),
          //   )
          // else if (_showBanner)
          //   UnityBannerAd(
          //       placementId: AdManager.bannerAdPlacementId,
          //       onLoad: (placementId) => print('Banner loaded: $placementId'),
          //       onClick: (placementId) => print('Banner clicked: $placementId'),
          //       onShown: (placementId) => print('Banner shown: $placementId'),
          //       onFailed: (placementId, error, message) {
          //         print('Banner Ad $placementId failed: $error $message');
          //         bannerAd != null ? StartAppBanner(bannerAd!) : Container();
          //       }),
            ],
          ),
        ),
      ),
    );
  }
}
