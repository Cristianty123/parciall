// lib/core/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'storage.dart';

class ApiClient {
  static final _base = Uri.parse(AppConstants.baseUrl);

  // ── Helpers ──────────────────────────────────────────────────────────

  static Uri _uri(String path, [Map<String, dynamic>? params]) {
    final uri = _base.replace(path: path);
    if (params == null || params.isEmpty) return uri;
    final strParams = params.map((k, v) => MapEntry(k, v.toString()));
    return uri.replace(queryParameters: strParams);
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AppStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _decode(http.Response res) {
    return json.decode(utf8.decode(res.bodyBytes));
  }

  // ── Public methods ────────────────────────────────────────────────

  static Future<http.Response> get(String path,
      [Map<String, dynamic>? params]) async {
    final headers = await _authHeaders();
    return http.get(_uri(path, params), headers: headers);
  }

  static Future<http.Response> post(String path, Object body,
      {bool auth = true}) async {
    final token = auth ? await AppStorage.getToken() : null;
    return http.post(
      _uri(path),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );
  }

  static Future<http.Response> put(String path, Object body) async {
    final headers = await _authHeaders();
    return http.put(_uri(path), headers: headers, body: json.encode(body));
  }

  static Future<http.Response> patch(String path, [Object? body]) async {
    final headers = await _authHeaders();
    return http.patch(
      _uri(path),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  static Future<http.Response> delete(String path) async {
    final headers = await _authHeaders();
    return http.delete(_uri(path), headers: headers);
  }

  /// Multipart upload (POST /images/upload)
  static Future<http.Response> uploadFile(String path, File file) async {
    final token = await AppStorage.getToken();
    final request = http.MultipartRequest('POST', _uri(path));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await request.send();
    return http.Response.fromStream(streamed);
  }

  static dynamic decode(http.Response res) => _decode(res);
}
