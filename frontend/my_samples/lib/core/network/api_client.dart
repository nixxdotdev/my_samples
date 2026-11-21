import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_samples/core/network/api_exception.dart';
import 'package:my_samples/core/storage/local_storage_service.dart';

/// Central HTTP Client powered by Dio for all remote API communications.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    final storage = LocalStorageService();
    final baseUrl = storage.getBackendUrl();

    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(baseOptions);

    // Attach Interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Dynamically read the latest backend URL and token from storage
          final currentBaseUrl = storage.getBackendUrl();
          if (options.baseUrl != currentBaseUrl) {
            options.baseUrl = currentBaseUrl;
          }

          final token = storage.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            debugPrint('[HTTP Request] ${options.method} ${options.uri}');
            if (options.data != null) {
              debugPrint('[HTTP Body] ${options.data}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              '[HTTP Response] [${response.statusCode}] ${response.requestOptions.path}',
            );
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            debugPrint(
              '[HTTP Error] [${error.response?.statusCode}] ${error.message}',
            );
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get rawDio => _dio;

  String get baseUrl => _dio.options.baseUrl;

  /// Update the base URL dynamically (e.g., when changed in settings)
  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }

  // ---------------- HTTP VERBS ----------------

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Ping the backend to check if it is reachable
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(
        '/api-docs',
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      return response.statusCode != null && response.statusCode! < 400;
    } catch (_) {
      return false;
    }
  }
}
