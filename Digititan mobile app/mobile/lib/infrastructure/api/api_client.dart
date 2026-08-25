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

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final p = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$base$p');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: {...uri.queryParameters, ...query});
  }

  Future<Map<String, String>> _headers({
    required bool auth,
    bool jsonBody = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (auth) {
      final token = await tokenStore.read();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final res = await _http.post(
      _uri(path),
      headers: await _headers(auth: auth, jsonBody: true),
      body: jsonEncode(body),
    );
    return _decodeMap(res);
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final res = await _http.put(
      _uri(path),
      headers: await _headers(auth: auth, jsonBody: true),
      body: jsonEncode(body),
    );
    return _decodeMap(res);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    bool auth = true,
  }) async {
    final res = await _http.delete(
      _uri(path),
      headers: await _headers(auth: auth),
    );
    return _decodeMap(res);
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    bool auth = true,
    Map<String, String>? query,
  }) async {
    final res = await _http.get(
      _uri(path, query),
      headers: await _headers(auth: auth),
    );
    return _decodeMap(res);
  }

  /// GET that returns a JSON array (cart, my-orders).
  Future<List<dynamic>> getList(
    String path, {
    bool auth = true,
    Map<String, String>? query,
  }) async {
    final res = await _http.get(
      _uri(path, query),
      headers: await _headers(auth: auth),
    );
    return _decodeList(res);
  }

  dynamic _decodeRaw(http.Response res) {
    if (res.body.isEmpty) {
      if (res.statusCode >= 200 && res.statusCode < 300) return <String, dynamic>{};
      throw ApiException('Empty response', statusCode: res.statusCode);
    }
    try {
      return jsonDecode(res.body);
    } catch (_) {
      throw ApiException(
        res.body,
        statusCode: res.statusCode,
      );
    }
  }

  void _ensureOk(http.Response res, dynamic decoded) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    final message =
        (map['error'] ?? map['message'] ?? 'Request failed').toString();
    throw ApiException(message, statusCode: res.statusCode, body: map);
  }

  Map<String, dynamic> _decodeMap(http.Response res) {
    final decoded = _decodeRaw(res);
    _ensureOk(res, decoded);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }

  List<dynamic> _decodeList(http.Response res) {
    final decoded = _decodeRaw(res);
    _ensureOk(res, decoded);
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      return decoded['data'] as List<dynamic>;
    }
    throw ApiException(
      'Expected a JSON array',
      statusCode: res.statusCode,
      body: decoded is Map<String, dynamic> ? decoded : {},
    );
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
