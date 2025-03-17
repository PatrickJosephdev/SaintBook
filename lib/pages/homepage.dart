import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:saintbook/model/admanager.dart';
import 'package:saintbook/model/fetchdailymass.dart';
import 'package:saintbook/model/helper.dart';
import 'package:saintbook/subpage/favorite.dart';
import 'package:saintbook/subpage/read.dart';
import 'package:saintbook/subpage/watch.dart';
import 'package:saintbook/widgets/dailymasswidget.dart';
import 'package:saintbook/widgets/messagewidget.dart';
import 'package:saintbook/widgets/saintcardwidget.dart';
import 'package:saintbook/widgets/recommendedwidget.dart';
import 'package:saintbook/model/apifetchdata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import this to use jsonEncode and jsonDecode
import 'dart:async'; // Import this for Timer
import 'package:startapp_sdk/startapp.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> saintList = [];
  List<dynamic> massList = [];
  List<dynamic> dailymessageList = [];
  bool _isLoading = true;
  String _error = '';
  Timer? _timer; // Timer to refresh data

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  NativeAd? _nativeAd;

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

  bool adsIsLoaded = false;

  var startAppSdk = StartAppSdk();
  StartAppBannerAd? bannerAd;
  StartAppInterstitialAd? interstitialAd;
  StartAppRewardedVideoAd? rewardedVideoAd;
  StartAppNativeAd? nativeAd;

  Timer? _adTimer;
  Timer? _bannerTimer;

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

  loadnativeAd() {
    startAppSdk.loadNativeAd().then((nativeAd) {
      setState(() {
        this.nativeAd = nativeAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Native ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Native ad: $error");
    });
  }

  void loadInterstitialAd() {
    startAppSdk.loadInterstitialAd().then((interstitialAd) {
      setState(() {
        this.interstitialAd = interstitialAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Interstitial ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Interstitial ad: $error");
    });
  }
//Rewarded ads function

  void loadRewardedVideoAd() {
    startAppSdk.loadRewardedVideoAd(
      onAdNotDisplayed: () {
        debugPrint('onAdNotDisplayed: rewarded video');

        setState(() {
          // NOTE rewarded video ad can be shown only once
          rewardedVideoAd?.dispose();
          rewardedVideoAd = null;
        });
      },
      onAdHidden: () {
        debugPrint('onAdHidden: rewarded video');

        setState(() {
          // NOTE rewarded video ad can be shown only once
          rewardedVideoAd?.dispose();
          rewardedVideoAd = null;
        });
      },
      onVideoCompleted: () {
        debugPrint(
            'onVideoCompleted: rewarded video completed, user gain a reward');

        setState(() {
          // TODO give reward to user
        });
      },
    ).then((rewardedVideoAd) {
      setState(() {
        this.rewardedVideoAd = rewardedVideoAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Rewarded Video ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Rewarded Video ad: $error");
    });
  }

  Future<void> _fetchMessageData() async {
    try {
      final messageList = await massData(
          "https://patrickjosephdev.github.io/Book_of_Saints/dailymessage.json");
      setState(() {
        dailymessageList = messageList;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Error: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMassData() async {
    try {
      final massDataList = await massData(
          "https://patrickjosephdev.github.io/Book_of_Saints/dailymass.json");
      setState(() {
        massList = massDataList;
        _isLoading = false;
        print(massList[0]['imageUrl']);
      });
    } catch (error) {
      setState(() {
        _error = 'Error: $error';
        _isLoading = false;
      });
    }
  }

// code for saint loaddata

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if data is already saved in Shared Preferences
    String? savedData = prefs.getString('saintList');

    if (savedData != null) {
      // If data exists, decode it and set it to saintList
      setState(() {
        saintList = jsonDecode(savedData);
        _isLoading = false;
      });
    } else {
      // If no data, fetch from API
      await _fetchDataAndSave(prefs);
    }
  }

// code for saint fetch and save

  Future<void> _fetchDataAndSave(SharedPreferences prefs) async {
    try {
      final data = await fetchData();
      setState(() {
        saintList = data;
        _isLoading = false;
      });

      // Save fetched data to Shared Preferences
      await prefs.setString('saintList', jsonEncode(saintList));
    } catch (error) {
      setState(() {
        _error = 'Error: $error';
        _isLoading = false;
      });
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await _fetchDataAndSave(prefs);
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
    startTimer();
    _fetchMassData();
    _fetchMessageData();
    startAppSdk.setTestAdsEnabled(false);
    loadbannerAd();
    loadInterstitialAd();
    loadRewardedVideoAd();
    UnityAds.init(
      gameId: AdManager.gameId,
      testMode: false,
      onComplete: () {
        print('Initialization Complete');
        _loadAds();
        _startAdTimer(); // Start the ad timer
        // _startBannerTimer();
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
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  List<String> getSaintsForToday() {
    List<String> todaySaints = [];
    String todayDate =
        DateTime.now().toString().substring(5, 10); // MM-DD format

    for (var saint in saintList) {
      // Check if celebrationDate is not null and has the expected length
      if (saint['celebrationDate'] != null &&
          saint['celebrationDate'].length >= 10) {
        String celebrationDate = saint['celebrationDate'];
        if (celebrationDate.substring(5, 10) == todayDate) {
          todaySaints.add(saint['name']);
        }
      } else {
        // Handle the case where celebrationDate is invalid
        print('Invalid celebrationDate for saint: ${saint['name']}');
      }
    }
    return todaySaints;
  }

  String formatSaintNames(List<String> saints) {
    if (saints.isEmpty) return '';

    if (saints.length == 1) {
      return saints[0];
    } else if (saints.length == 2) {
      return '${saints[0]} & ${saints[1]}';
    } else {
      String allButLast = saints.sublist(0, saints.length - 1).join(', ');
      String last = saints.last;
      return '$allButLast & $last';
    }
  }

  List<dynamic> getRandomSaints(int count) {
    if (saintList.length <= count) {
      return List.from(saintList); // Return all saints if less than count
    }

    final random = Random();
    final selectedSaints = <dynamic>{}; // Use a Set to avoid duplicates

    while (selectedSaints.length < count) {
      int randomIndex = random.nextInt(saintList.length);
      selectedSaints.add(saintList[randomIndex]);
    }

    return selectedSaints.toList(); // Convert Set back to List
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(now);
    final randomSaints = getRandomSaints(10);

    if (saintList.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      List<String> dateParts = saintList[0]['celebrationDate'].split('-');

      String month = dateParts[0];
      String day = dateParts[1];

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "SaintBook",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritePage()),
                );
              },
              icon: const Icon(Icons.favorite_rounded),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _error.isNotEmpty && massList.isNotEmpty
                ? const Center(
                    child: Text('No Data Found, Exit and launch again'),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SaintCard(
                              saintName: formatSaintNames(getSaintsForToday()),
                              celebrationDate: formattedDate,
                              imageUrl: saintList[0]['imageUrl'],
                              onReadNow: () {
                                List<String> todaySaints = getSaintsForToday();

                                if (todaySaints.length > 1) {
                                  // Show a dialog with the list of saints
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Select a Saint"),
                                        content: SizedBox(
                                          width: double
                                              .maxFinite, // Make the dialog wide enough
                                          child: ListView.builder(
                                            itemCount: todaySaints.length,
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                title: Text(todaySaints[index]),
                                                onTap: () {
                                                  // Find the selected saint's details
                                                  var selectedSaint =
                                                      saintList.firstWhere(
                                                    (s) =>
                                                        s['name'] ==
                                                        todaySaints[index],
                                                  );
                                                  print(
                                                      "Selected Saint: ${selectedSaint['name']}");

                                                  // Navigate to the SaintDetailPage with the selected saint's details
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SaintDetailPage(
                                                        saintName:
                                                            selectedSaint[
                                                                'name'],
                                                        saintImage:
                                                            selectedSaint[
                                                                'imageUrl'],
                                                        saintStory:
                                                            selectedSaint[
                                                                'story'],
                                                        videoUrl: selectedSaint[
                                                            'videoUrl'],
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2412056271.
                                                        celebrationDate:
                                                            selectedSaint[
                                                                'celebrationDate'],
                                                      ),
                                                    ),
                                                  );

                                                  // Close the dialog
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else if (todaySaints.isNotEmpty) {
                                  // If there's only one saint, navigate directly to the detail page
                                  var firstSaint = saintList.firstWhere(
                                      (s) => s['name'] == todaySaints[0]);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SaintDetailPage(
                                        saintName: firstSaint['name'],
                                        saintImage: firstSaint['imageUrl'],
                                        saintStory: firstSaint['story'],
                                        videoUrl: firstSaint['videoUrl'],
                                        celebrationDate:
                                            firstSaint['celebrationDate'],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (_bannerAd != null)
                              Center(
                                child: SizedBox(
                                  width: _bannerAd!.size.width.toDouble(),
                                  height: _bannerAd!.size.height.toDouble(),
                                  child: AdWidget(ad: _bannerAd!),
                                ),
                              )
                            else if (_showBanner)
                              Center(
                                child: UnityBannerAd(
                                    placementId: AdManager.bannerAdPlacementId,
                                    onLoad: (placementId) =>
                                        print('Banner loaded: $placementId'),
                                    onClick: (placementId) =>
                                        print('Banner clicked: $placementId'),
                                    onShown: (placementId) =>
                                        print('Banner shown: $placementId'),
                                    onFailed: (placementId, error, message) {
                                      print(
                                          'Banner Ad $placementId failed: $error $message');
                                      bannerAd != null
                                          ? StartAppBanner(bannerAd!)
                                          : const SizedBox.shrink();
                                    }),
                              )
                            else
                              bannerAd != null
                                  ? StartAppBanner(bannerAd!)
                                  : const SizedBox.shrink(),

                            // bannerAd != null
                            //     ? StartAppBanner(bannerAd!)
                            //     : Container(),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              "Recommended",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                itemCount: randomSaints.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final saint = randomSaints[index];
                                  DateTime parseDate =
                                      DateTime.parse(saint['celebrationDate']);
                                  String saintDate =
                                      DateFormat('MMMM d').format(parseDate);
                                  return Recommended(
                                      saintName: saint['name'],
                                      celebrationDate: saintDate,
                                      imageUrl: saint['imageUrl'],
                                      onReadNow: () {
                                        if (_interstitialAd != null) {
                                          _showInterstitialAd();
                                        } else if (placements[AdManager
                                                .interstitialVideoAdPlacementId] ==
                                            true) {
                                          _showAd(AdManager
                                              .interstitialVideoAdPlacementId);
                                        } else if (_rewardedAd != null) {
                                          _showRewardedAd();
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SaintDetailPage(
                                              saintName: saint['name'],
                                              saintImage: saint['imageUrl'],
                                              saintStory: saint['story'],
                                              videoUrl: saint['videoUrl'],
                                              celebrationDate:
                                                  saint['celebrationDate'],
                                            ),
                                          ),
                                        );
                                      });
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),

                            const Text(
                              'Daily Mass',
                              style: TextStyle(fontSize: 20),
                            ),
                            // if (_showBanner)
                            //   Center(
                            //     child: UnityBannerAd(
                            //         placementId: AdManager.bannerAdPlacementId,
                            //         onLoad: (placementId) =>
                            //             print('Banner loaded: $placementId'),
                            //         onClick: (placementId) =>
                            //             print('Banner clicked: $placementId'),
                            //         onShown: (placementId) =>
                            //             print('Banner shown: $placementId'),
                            //         onFailed: (placementId, error, message) {
                            //           print(
                            //               'Banner Ad $placementId failed: $error $message');
                            //           bannerAd != null
                            //               ? StartAppBanner(bannerAd!)
                            //               : const SizedBox.shrink();
                            //         }),
                            //   )
                            //   else bannerAd != null
                            //               ? StartAppBanner(bannerAd!)
                            //               : const SizedBox.shrink(),

                            if (massList.isNotEmpty)
                              DailyMassWidget(
                                imageUrl: massList[0]['imageUrl'] ??
                                    '', // Provide a fallback if null
                                videoUrl: massList[0]['videoUrl'] ?? '',
                                onReadNow: () {
                                  if (_interstitialAd != null) {
                                    _showInterstitialAd();
                                  } else if (placements[AdManager
                                          .interstitialVideoAdPlacementId] ==
                                      true) {
                                    _showAd(AdManager
                                        .interstitialVideoAdPlacementId);
                                  } else if (_rewardedAd != null) {
                                    _showRewardedAd();
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => YoutubePlayerPage(
                                        videoUrl: massList[0]['videoUrl'] ?? '',
                                        saintName:
                                            'Daily Mass for $formattedDate',
                                      ),
                                    ),
                                  );
                                }, // Provide a fallback if null
                              )
                            else
                              const Center(
                                child: CircularProgressIndicator(
                                  semanticsLabel:
                                      'Check your Internet Connection',
                                ),
                              ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              'Daily Message',
                              style: TextStyle(fontSize: 20),
                            ),
                            // if (_showBanner)
                            //   Center(
                            //     child: UnityBannerAd(
                            //         placementId: AdManager.bannerAdPlacementId,
                            //         onLoad: (placementId) =>
                            //             print('Banner loaded: $placementId'),
                            //         onClick: (placementId) =>
                            //             print('Banner clicked: $placementId'),
                            //         onShown: (placementId) =>
                            //             print('Banner shown: $placementId'),
                            //         onFailed: (placementId, error, message) {
                            //           print(
                            //               'Banner Ad $placementId failed: $error $message');
                            //           bannerAd != null
                            //               ? StartAppBanner(bannerAd!)
                            //               : const SizedBox.shrink();
                            //         }),
                            //   )
                            //   else
                            //   bannerAd != null
                            //               ? StartAppBanner(bannerAd!)
                            //               : const SizedBox.shrink(),

                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                itemCount: dailymessageList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final message = dailymessageList[index];
                                  if (dailymessageList.isNotEmpty) {
                                    return Message(
                                        imageUrl: message['imageUrl'],
                                        videoUrl: message['videoUrl'],
                                        title: message['title']);
                                  } else {
                                    return const Text(
                                        'No Daily Message Data Available, Check your Internet Connection');
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const SizedBox(
                              height: 100,
                            ),
                          ]),
                    ),
                  ),
      );
    }
  }

  void _startAdTimer() {
    _adTimer = Timer.periodic(const Duration(minutes: 6), (timer) {
      _showRewardedAd();

      if (placements[AdManager.interstitialVideoAdPlacementId] == true) {
        _showAd(AdManager.interstitialVideoAdPlacementId);
      }

      // if (placements[AdManager.rewardedVideoAdPlacementId] == true) {
      //   _showAd(AdManager.rewardedVideoAdPlacementId);
      // }
    });
  }

  // void _startBannerTimer() {
  //   _bannerTimer = Timer.periodic(const Duration(seconds: 40), (timer) {
  //     if (_showBanner) {
  //       _loadAd(AdManager.bannerAdPlacementId); // Refresh the banner ad
  //     } else {
  //       loadbannerAd();
  //     }
  //   });
  // }
}
