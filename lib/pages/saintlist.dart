import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:saintbook/model/admanager.dart';
import 'package:saintbook/model/helper.dart';

import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:saintbook/model/apifetchdata.dart';
import 'package:saintbook/subpage/read.dart';
import 'package:saintbook/subpage/watch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:startapp_sdk/startapp.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class SaintList extends StatefulWidget {
  const SaintList({super.key});

  @override
  State<SaintList> createState() => _SaintListState();
}

class _SaintListState extends State<SaintList> {
  List<dynamic> _items = [];
  List<dynamic> _filteredItems = [];
  bool _isLoading = true;
  String _error = '';
  var startAppSdk = StartAppSdk();
  StartAppBannerAd? bannerAd;

  Timer? _bannerTimer;

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

  Future<void> _incrementClickCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int clickCount =
        prefs.getInt('clickCount') ?? 0; // Get current count or default to 0
    clickCount++; // Increment the count
    await prefs.setInt('clickCount', clickCount); // Save the updated count
  }

  Future<int> _getClickCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('clickCount') ??
        0; // Return current count or default to 0
  }

  Future<void> _resetClickCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('clickCount', 0); // Reset the count to 0
  }

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

  Future<void> loadData({bool forceRefresh = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // If forced refresh is true, fetch data from the API
    if (forceRefresh) {
      await _fetchAndSaveData(prefs);
    } else {
      // Check if data is already saved in Shared Preferences
      String? savedData = prefs.getString('saintList');

      if (savedData != null) {
        // If data exists, decode it and set it to _items and _filteredItems
        setState(() {
          _items = jsonDecode(savedData);
          _filteredItems = _items; // Initialize filtered items
          _isLoading = false;
        });
      } else {
        // If no data, fetch from API
        await _fetchAndSaveData(prefs);
      }
    }
  }

  Future<void> _fetchAndSaveData(SharedPreferences prefs) async {
    try {
      final data = await fetchData(); // Fetch data from the API
      setState(() {
        _items = data;
        _filteredItems = data; // Initialize filtered items
        _isLoading = false;
      });

      // Save fetched data to Shared Preferences
      await prefs.setString('saintList', jsonEncode(_items));
    } catch (error) {
      setState(() {
        _error = 'Error: $error';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
    startAppSdk.setTestAdsEnabled(false);
    loadbannerAd();

    UnityAds.init(
      gameId: AdManager.gameId,
      testMode: false,
      onComplete: () {
        print('Initialization Complete');
        _loadAds();
// Start the ad timer
        _startBannerTimer();
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
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
  }

  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Saint List'),
            actions: [
              SearchBarAnimation(
                textEditingController: textEditingController,
                searchBoxWidth: 300,
                isOriginalAnimation: true,
                trailingWidget: const Icon(Icons.search),
                secondaryButtonWidget: const Icon(Icons.cancel),
                buttonWidget: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                hintText: "Search Here",
                onChanged: (value) {
                  // Handle search text change
                  _filteredItems = _items
                      .where((item) => item['name']
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {}); // Update UI with filtered results
                },
              ),
              const SizedBox(
                width: 12,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Refresh data when pulled down
              await loadData(forceRefresh: true);
            },
            child: Column(
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
                      onLoad: (placementId) =>
                          print('Banner loaded: $placementId'),
                      onClick: (placementId) =>
                          print('Banner clicked: $placementId'),
                      onShown: (placementId) =>
                          print('Banner shown: $placementId'),
                      onFailed: (placementId, error, message) {
                        print('Banner Ad $placementId failed: $error $message');
                        bannerAd != null
                            ? StartAppBanner(bannerAd!)
                            : Container();
                      }),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MasonryView(
                          listOfItem: _filteredItems,
                          numberOfColumn: calculateNumberOfColumns(context),
                          itemRadius: 1,
                          itemPadding: 5,
                          itemBuilder: (item) {
                            return GestureDetector(
                              onTap: () async {
                                await _incrementClickCount(); // Increment the click count

                                int clickCount =
                                    await _getClickCount(); // Get the updated count

                                if (clickCount >= 3) {
                                  // Show the interstitial ad
                                  if (placements[AdManager
                                          .interstitialVideoAdPlacementId] ==
                                      true) {
                                    _showAd(AdManager
                                        .interstitialVideoAdPlacementId);
                                  }
                                  await _resetClickCount(); // Reset the count after showing the ad
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SaintDetailPage(
                                      saintName: item['name'],
                                      saintImage: item['imageUrl'],
                                      saintStory: item['story'],
                                      videoUrl: item['videoUrl'],
                                      celebrationDate: item['celebrationDate'],
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Stack(
                                    fit: StackFit.passthrough,
                                    alignment: Alignment.center,
                                    children: [
                                      Image.network(
                                        item['imageUrl'],
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                          top: 20,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: Text(
                                              item['name'],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )),
                                      Positioned(
                                          bottom: 10,
                                          left: 0,
                                          right: 0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await _incrementClickCount(); // Increment the click count

                                                  int clickCount =
                                                      await _getClickCount(); // Get the updated count

                                                  if (clickCount >= 3) {
                                                    // Show the interstitial ad
                                                    if (_interstitialAd !=
                                                        null) {
                                                      _showInterstitialAd();
                                                    } else if (placements[AdManager
                                                            .interstitialVideoAdPlacementId] ==
                                                        true) {
                                                      _showAd(AdManager
                                                          .interstitialVideoAdPlacementId);
                                                    } else if (_rewardedAd !=
                                                        null) {
                                                      _showRewardedAd();
                                                    }
                                                    await _resetClickCount(); // Reset the count after showing the ad
                                                  }

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SaintDetailPage(
                                                        saintName: item['name'],
                                                        saintImage:
                                                            item['imageUrl'],
                                                        saintStory:
                                                            item['story'],
                                                        videoUrl:
                                                            item['videoUrl'],
                                                        celebrationDate: item[
                                                            'celebrationDate'],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: Colors.black
                                                      .withOpacity(
                                                          0.3), // Text color
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                ),
                                                child: const Text(
                                                  "Read Now",
                                                  style: TextStyle(fontSize: 9),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  if (_interstitialAd !=
                                                        null) {
                                                      _showInterstitialAd();
                                                    } else if (placements[AdManager
                                                            .interstitialVideoAdPlacementId] ==
                                                        true) {
                                                      _showAd(AdManager
                                                          .interstitialVideoAdPlacementId);
                                                    } else if (_rewardedAd !=
                                                        null) {
                                                      _showRewardedAd();
                                                    }
                                                    
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          YoutubePlayerPage(
                                                              saintName:
                                                                  item['name'],
                                                              videoUrl: item[
                                                                  'videoUrl']),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: Colors.black
                                                      .withOpacity(
                                                          0.3), // Text color
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                ),
                                                child: const Text(
                                                  "Play Now",
                                                  style: TextStyle(fontSize: 9),
                                                ),
                                              ),
                                            ],
                                          )),
                                    ]),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 80,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
    }
  }

  int calculateNumberOfColumns(BuildContext context) {
    // Adjust this logic based on your desired minimum and maximum columns
    final double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1000) return 6;
    if (screenWidth >= 900) return 5;
    if (screenWidth >= 600) return 4;
    if (screenWidth >= 400) return 3;
    if (screenWidth >= 300) return 2;

    return 1;
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_showBanner) {
        _loadAd(AdManager.bannerAdPlacementId);
        _loadBannerAd(); // Refresh the banner ad
      } else {
        loadbannerAd();
      }
    });
  }
}
