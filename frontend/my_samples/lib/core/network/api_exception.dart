import 'package:dio/dio.dart';

/// Custom standardized exception for all network / API failures.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your network connection.',
          statusCode: error.response?.statusCode,
          details: error.message,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String serverMsg = 'Server responded with status $statusCode.';

        if (data is Map && data.containsKey('message')) {
          serverMsg = data['message'].toString();
        } else if (data is String && data.isNotEmpty) {
          serverMsg = data;
        }

        switch (statusCode) {
          case 400:
            return ApiException(
              message: serverMsg.isNotEmpty ? serverMsg : 'Bad Request (400)',
              statusCode: 400,
              details: data,
            );
          case 401:
            return ApiException(
              message: 'Session expired or unauthorized. Please re-authenticate.',
              statusCode: 401,
              details: data,
            );
          case 403:
            return ApiException(
              message: 'Access forbidden (403).',
              statusCode: 403,
              details: data,
            );
          case 404:
            return ApiException(
              message: 'Requested resource was not found (404).',
              statusCode: 404,
              details: data,
            );
          case 500:
          case 502:
          case 503:
            return ApiException(
              message: 'Backend server error ($statusCode). Please try again later.',
              statusCode: statusCode,
              details: data,
            );
          default:
            return ApiException(
              message: serverMsg,
              statusCode: statusCode,
              details: data,
            );
        }

      case DioExceptionType.connectionError:
        return ApiException(
          message:
              'Cannot reach backend server. Please verify your connection or backend URL.',
          statusCode: null,
          details: error.message,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'The network request was cancelled.',
          details: error.message,
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: error.message ?? 'An unexpected network error occurred.',
          details: error.error,
        );
    }
  }

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
