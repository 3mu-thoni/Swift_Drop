import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio get _dio => _buildDio();

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:5000/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          debugPrint('📤 Request: ${options.path} | Token: ${token != null ? 'exists' : 'none'}');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return await _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  // Use SharedPreferences instead of SecureStorage for web compatibility
  Future<void> saveToken(String token) async {
    debugPrint('💾 Saving token: ${token.substring(0, 20)}...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAuthToken, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyAuthToken);
    return token;
  }
}