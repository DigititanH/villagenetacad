import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/config/app_config.dart';
import 'token_store.dart';

/// Thin HTTP client for Village NetAcad `/api`.
class ApiClient {
  final TokenStore tokenStore;
  final http.Client _http;

  ApiClient({
    required this.tokenStore,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  Uri _uri(String path) {
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await tokenStore.read();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    final res = await _http.post(
      _uri(path),
      headers: headers,
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    bool auth = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await tokenStore.read();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    final res = await _http.get(_uri(path), headers: headers);
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      } else {
        json = {'message': res.body};
      }
    } catch (_) {
      json = {'message': res.body.isEmpty ? 'Empty response' : res.body};
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json;
    }

    final message = (json['error'] ?? json['message'] ?? 'Request failed')
        .toString();
    throw ApiException(message, statusCode: res.statusCode, body: json);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic> body;

  ApiException(this.message, {required this.statusCode, this.body = const {}});

  @override
  String toString() => message;
}
