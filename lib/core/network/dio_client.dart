import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/api_config.dart';

class DioClient {
  late final Dio _dio;
  static const String _webProxyBase = 'https://api.allorigins.win/get';

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: kIsWeb ? _webProxyBase : ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    if (!kIsWeb) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.queryParameters['api_key'] = ApiConfig.apiKey;
            return handler.next(options);
          },
          onResponse: (response, handler) => handler.next(response),
          onError: (error, handler) => handler.next(error),
        ),
      );
    }
  }

  Dio get dio => _dio;

  String _buildTargetUrl(String path, Map<String, dynamic>? queryParameters) {
    final queryParams = Map<String, dynamic>.from(queryParameters ?? {});
    queryParams['api_key'] = ApiConfig.apiKey;
    
    final queryString = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    
    return '${ApiConfig.baseUrl}$path?$queryString';
  }

  dynamic _unwrapProxyResponse(dynamic data) {
    if (data is Map && data.containsKey('contents')) {
      final contents = data['contents'];
      if (contents is String) {
        return jsonDecode(contents);
      }
      return contents;
    }
    return data;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (kIsWeb) {
      final targetUrl = _buildTargetUrl(path, queryParameters);
      final response = await _dio.get('', queryParameters: {'url': targetUrl});
      response.data = _unwrapProxyResponse(response.data);
      return response;
    }
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    if (kIsWeb) {
      final targetUrl = _buildTargetUrl(path, queryParameters);
      final response = await _dio.post('', data: data, queryParameters: {'url': targetUrl});
      response.data = _unwrapProxyResponse(response.data);
      return response;
    }
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }
}
