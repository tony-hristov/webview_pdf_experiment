import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';

import 'pdf_validator.dart';

/// Fetch pdf from url.
///
/// Exception:
/// - status code not 200
/// - response body not a pdf
///
Future<Uint8List> fetchPdfFromUrl(
  String url,
) async {
  try {
    final http = IOClient(HttpClient(context: SecurityContext(withTrustedRoots: true)));
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Pdf: fetch http status code ${response.statusCode} from url=$url');
    }
    if (!isValidPdf(response.bodyBytes)) {
      throw Exception('Pdf: fetch response not a pdf from url=$url');
    }
    return response.bodyBytes;
  } catch (error) {
    log('Pdf: fetch error $error from url=$url');
    throw Exception(error);
  }
}
