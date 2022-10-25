import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'navigation_delegate_handler.dart';

class WebViewStack extends StatefulWidget {
  WebViewStack({
    required this.initialUrl,
    required this.controller,
    super.key,
  });

  final String initialUrl;
  final Completer<WebViewController> controller;
  final navigationDelegateHandler = NavigationDelegateHandler();

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebView(
          initialUrl: widget.initialUrl,
          onWebViewCreated: (webViewController) {
            widget.controller.complete(webViewController);
          },
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: _createJavascriptChannels(context),
          navigationDelegate: widget.navigationDelegateHandler.navigationDelegate, // _navigationDelegate,
        ),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0,
          ),
      ],
    );
  }

  Set<JavascriptChannel> _createJavascriptChannels(BuildContext context) {
    return {
      JavascriptChannel(
        name: 'SnackBar',
        onMessageReceived: (message) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.message)));
        },
      ),
    };
  }

  FutureOr<NavigationDecision> _navigationDelegate(NavigationRequest navigation) {
    final host = Uri.parse(navigation.url).host;
    if (host.contains('youtube.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Blocking navigation to $host',
          ),
        ),
      );
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }
}
