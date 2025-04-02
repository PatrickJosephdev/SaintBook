import 'package:flutter/material.dart';
import 'package:saintbook/model/helper.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Catholicprayers extends StatefulWidget {
  const Catholicprayers({super.key});

  @override
  State<Catholicprayers> createState() => _CatholicprayersState();
}

class _CatholicprayersState extends State<Catholicprayers> {
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
          onPageStarted: (String url) {
            const CircularProgressIndicator.adaptive();
          },
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
      ..loadRequest(Uri.parse('https://mycatholic.life/catholic-prayers/'));
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
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
