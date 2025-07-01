import 'package:dio/dio.dart';
import 'package:ysyw/config/debug/debug.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://api.yoursportyourworld.com",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  Dio get dio => _dio;
  void setHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  void setAuthorization(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // GET request
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path,
          data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(String path,
      {required Map<String, dynamic> data,
      Map<String, dynamic>? queryParameters}) async {
    try {
      if (data.isEmpty) {
        throw ArgumentError('Data cannot be empty for PUT request');
      }
      Debug.info(
          'PUT request to $path with data: $data and query parameters: $queryParameters');
      Debug.info("Full URL: ${_dio.options.baseUrl}$path");
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path,
          data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }
}
