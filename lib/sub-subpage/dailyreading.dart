import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Dailyreading extends StatefulWidget {
  const Dailyreading({super.key});

  @override
  State<Dailyreading> createState() => _DailyreadingState();
}

class _DailyreadingState extends State<Dailyreading> {
  late final WebViewController _controller;

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
  

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('Bible Reading')),
        body: WebViewWidget(controller: _controller),
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
