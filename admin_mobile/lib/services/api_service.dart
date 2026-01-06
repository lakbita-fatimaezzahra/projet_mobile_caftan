import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse(ApiConstants.baseUrl + path);
    final mergedHeaders = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?headers,
    };

    return _client.post(uri, headers: mergedHeaders, body: body);
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(ApiConstants.baseUrl + path);
    final mergedHeaders = <String, String>{
      'Accept': 'application/json',
      ...?headers,
    };

    return _client.get(uri, headers: mergedHeaders);
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(ApiConstants.baseUrl + path);
    final mergedHeaders = <String, String>{
      'Accept': 'application/json',
      ...?headers,
    };

    return _client.delete(uri, headers: mergedHeaders);
  }
}
