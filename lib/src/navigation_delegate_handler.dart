import 'dart:async';
import 'dart:developer';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_with_pdf/src/pdf_fetch.dart';

const _kHistoryMaxLength = 5;

class NavigationDelegateHandler {
  final List<NavigationRequest> _requestHistory = [];

  FutureOr<NavigationDecision> navigationDelegate(NavigationRequest navigationRequest) async {
    if (_requestHistory.length == _kHistoryMaxLength &&
        _requestHistory.where((r) => r.url == navigationRequest.url).length == _requestHistory.length) {
      log('Pdf: check if pdf at url=${navigationRequest.url}');

      try {
        final pdfBytes = await fetchPdfFromUrl(navigationRequest.url);
        log('Pdf: detected pdf at url=${navigationRequest.url} / ${pdfBytes.lengthInBytes} bytes!');
      } catch (error) {
        return NavigationDecision.navigate;
      }

      return NavigationDecision.prevent;
    }

    if (_requestHistory.length >= _kHistoryMaxLength) {
      _requestHistory.removeAt(0);
    }

    _requestHistory.add(navigationRequest);

    return NavigationDecision.navigate;
  }
}
