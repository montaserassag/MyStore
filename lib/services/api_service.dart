// ─────────────────────────────────────────────────────────────────────────
// ApiService — Exercise 1: Fetch Products from API
//
// Best practices applied:
//  ✅ Use a service class — all HTTP logic lives here, never inside build()
//  ✅ Check status codes — only 200 is treated as success
//  ✅ Use timeouts — request fails fast instead of hanging forever
//  ✅ Set Content-Type — explicit Accept/Content-Type headers
//  ✅ Use try/catch — network errors are caught and rethrown as ApiException
// ─────────────────────────────────────────────────────────────────────────
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Thrown when the API request fails (network error, timeout, bad status).
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static const String _baseUrl = 'https://dummyjson.com/products';
  static const Duration _timeout = Duration(seconds: 10); // ✅ Use timeouts

  /// Fetches a list of raw product JSON maps from the API.
  ///
  /// The returned maps use the *same shape* as the API response, so they
  /// can both be converted via [Product.fromApiJson] AND cached as-is
  /// for offline support (Exercise 3).
  static Future<List<Map<String, dynamic>>> fetchProducts({int limit = 20}) async {
    final uri = Uri.parse('$_baseUrl?limit=$limit');

    http.Response response;
    try {
      response = await http
          .get(uri, headers: {
            'Content-Type': 'application/json', // ✅ Missing Content-Type — avoided
            'Accept': 'application/json',
          })
          .timeout(_timeout); // ✅ Don't block forever on a dead connection
    } on Exception catch (e) {
      // No internet / DNS failure / timeout → let ProductProvider fall
      // back to the local cache (Exercise 3).
      throw ApiException('Network error: $e');
    }

    // ✅ Check status codes — never assume 200
    if (response.statusCode != 200) {
      throw ApiException(
        'Server returned an error',
        statusCode: response.statusCode,
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    // ✅ Validate the decoded JSON shape before using it
    if (decoded is! Map<String, dynamic> || decoded['products'] is! List) {
      throw ApiException('Unexpected response format');
    }

    final List products = decoded['products'] as List;
    return products.whereType<Map<String, dynamic>>().toList();
  }
}
