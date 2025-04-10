import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class Catholicprayers extends StatefulWidget {
  const Catholicprayers({super.key});

  @override
  State<Catholicprayers> createState() => _CatholicprayersState();
}

class _CatholicprayersState extends State<Catholicprayers> {
  late final WebViewController _controller;
  String? _url;

  @override
  void initState() {
    super.initState();
    _fetchUrl();
  }

  Future<void> _fetchUrl() async {
    try {
      final response = await http.get(Uri.parse('https://patrickjosephdev.github.io/Book_of_Saints/prayerurl.json')); // Replace with your GitHub JSON URL
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['url'] != null && jsonData['url'].isNotEmpty) {
          setState(() {
            _url = jsonData['url'].trim(); // Extracting the URL from JSON
          });
          _loadWebView();
        } else {
          _showToast('URL not available right now');
        }
      } else {
        _showToast('Failed to fetch URL');
      }
    } catch (e) {
      _showToast('Error occurred: $e');
    }
  }

  void _loadWebView() {
    if (_url != null) {
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
            onHttpError: (HttpResponseError error) {
              const Text('No internet');
            },
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.jkj.jhjj/')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(_url!));
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
        appBar: AppBar(title: const Text('Catholic Prayers')),
        body: _url == null
            ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching URL
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:webview_flutter/webview_flutter.dart';

// class Catholicprayers extends StatefulWidget {
//   const Catholicprayers({super.key});

//   @override
//   State<Catholicprayers> createState() => _CatholicprayersState();
// }

// class _CatholicprayersState extends State<Catholicprayers> {
//   late final WebViewController _controller;
//   String? _url;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUrl();
//   }

//   Future<void> _fetchUrl() async {
//     try {
//       final response = await http.get(Uri.parse('https://raw.githubusercontent.com/yourusername/yourrepo/main/url.txt')); // Replace with your GitHub URL
//       if (response.statusCode == 200 && response.body.isNotEmpty) {
//         setState(() {
//           _url = response.body.trim(); // Assuming the URL is in the response body
//         });
//         _loadWebView();
//       } else {
//         _showToast('Not available right now');
//       }
//     } catch (e) {
//       _showToast('Not available right now');
//     }
//   }

//   void _loadWebView() {
//     if (_url != null) {
//       _controller = WebViewController()
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..setNavigationDelegate(
//           NavigationDelegate(
//             onProgress: (int progress) {
//               // Update loading bar.
//               const CircularProgressIndicator();
//             },
//             onPageStarted: (String url) {},
//             onPageFinished: (String url) {},
//             onHttpError: (HttpResponseError error) {
//               const Text('No internet');
//             },
//             onWebResourceError: (WebResourceError error) {},
//             onNavigationRequest: (NavigationRequest request) {
//               if (request.url.startsWith('https://www.jkj.jhjj/')) {
//                 return NavigationDecision.prevent;
//               }
//               return NavigationDecision.navigate;
//             },
//           ),
//         )
//         ..loadRequest(Uri.parse(_url!));
//     }
//   }

//   void _showToast(String message) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.black,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }

//   Future<bool> _onWillPop() async {
//     if (await _controller.canGoBack()) {
//       _controller.goBack();
//       return false; // Prevents the default back action
//     }
//     return true; // Allows the default back action
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: AppBar(title: const Text('Catholic Prayers')),
//         body: _url == null
//             ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching URL
//             : WebViewWidget(controller: _controller),
//       ),
//     );
//   }
// }


// // import 'package:flutter/material.dart';
// // import 'package:saintbook/model/helper.dart';
// // import 'package:webview_flutter/webview_flutter.dart';

// // class Catholicprayers extends StatefulWidget {
// //   const Catholicprayers({super.key});

// //   @override
// //   State<Catholicprayers> createState() => _CatholicprayersState();
// // }

// // class _CatholicprayersState extends State<Catholicprayers> {
// //   late final WebViewController _controller;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _controller = WebViewController()
// //       ..setJavaScriptMode(JavaScriptMode.unrestricted)
// //       ..setNavigationDelegate(
// //         NavigationDelegate(
// //           onProgress: (int progress) {
// //             // Update loading bar.
// //             const CircularProgressIndicator();
// //           },
// //           onPageStarted: (String url) {
// //             },
// //           onPageFinished: (String url) {},
// //           onHttpError: (HttpResponseError error) {
// //             const Text('No internet');
// //           },
// //           onWebResourceError: (WebResourceError error) {},
// //           onNavigationRequest: (NavigationRequest request) {
// //             if (request.url.startsWith('https://www.jkj.jhjj/')) {
// //               return NavigationDecision.prevent;
// //             }
// //             return NavigationDecision.navigate;
// //           },
// //         ),
// //       )
// //       ..loadRequest(Uri.parse('https://mycatholic.life/catholic-prayers/'));
// //   }

// //   Future<bool> _onWillPop() async {
// //     if (await _controller.canGoBack()) {
// //       _controller.goBack();
// //       return false; // Prevents the default back action
// //     }
// //     return true; // Allows the default back action
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: _onWillPop,
// //       child: Scaffold(
// //         appBar: AppBar(title: const Text('Catholic Prayers')),
// //         body: WebViewWidget(controller: _controller),
// //       ),
// //     );
// //   }
// // }
