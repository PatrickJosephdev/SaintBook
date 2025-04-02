import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:saintbook/model/helper.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Dailyreading extends StatefulWidget {
  const Dailyreading({super.key});

  @override
  State<Dailyreading> createState() => _DailyreadingState();
}

class _DailyreadingState extends State<Dailyreading> {
  late final WebViewController _controller;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            const CircularProgressIndicator();
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.jkj.jhjj/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.catholic.org/bible/daily_reading/'));
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false; // Prevents the default back action
    }
    return true; // Allows the default back action
  }
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

  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('Bible Reading')),
        body: Column(
          children: [
            if (_bannerAd != null)
                SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                )
// Suggested code may be subject to a license. Learn more: ~LicenseLog:3726685405.
            else const SizedBox(height: 1,),
            WebViewWidget(controller: _controller),
          ],
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// // class DailyMassReadingWebView extends StatelessWidget {
// //   final String url = 'https://www.catholic.org/bible/daily_reading/';

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Daily Mass Reading'),
// //       ),
// //       body: WebView(
// //         initialUrl: url,
// //         javascriptMode: JavascriptMode.unrestricted, // Allow JavaScript if needed
// //       ),
// //     );
// //   }
// // }

// class Dailyreading extends StatefulWidget {
//   const Dailyreading({super.key});

//   @override
//   State<Dailyreading> createState() => _DailyreadingState();
// }

// class _DailyreadingState extends State<Dailyreading> {
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             // Update loading bar.
//             const CircularProgressIndicator();
//           },
//           onPageStarted: (String url) {},
//           onPageFinished: (String url) {},
//           onHttpError: (HttpResponseError error) {},
//           onWebResourceError: (WebResourceError error) {},
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url.startsWith('https://www.jkj.jhjj/')) {
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse('https://www.catholic.org/bible/daily_reading/'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//     appBar: AppBar(title: const Text('Bible Reading')),
//     body: WebViewWidget(controller: _controller),
//   );
//   }
// }
