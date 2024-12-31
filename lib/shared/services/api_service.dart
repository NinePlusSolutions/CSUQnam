import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/widgets/network_timeout_dialog.dart';

class ApiService {
  final Dio _dio;
  static const int timeoutDuration = 10000; // 10 seconds

  ApiService() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(milliseconds: timeoutDuration);
    _dio.options.receiveTimeout = const Duration(milliseconds: timeoutDuration);
  }

  Future<Response<T>> callApi<T>({
    required Future<Response<T>> Function() apiCall,
    required String endpoint,
    int maxRetries = 1,
  }) async {
    int retryCount = 0;
    while (true) {
      try {
        return await apiCall().timeout(
          const Duration(milliseconds: timeoutDuration),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );
      } catch (error) {
        if (retryCount >= maxRetries) {
          Completer<Response<T>> completer = Completer<Response<T>>();
          
          showNetworkTimeoutDialog(
            onRetry: () async {
              try {
                final result = await apiCall();
                completer.complete(result);
              } catch (e) {
                completer.completeError(e);
              }
            },
          );

          return completer.future;
        }
        retryCount++;
      }
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return callApi<T>(
      apiCall: () => _dio.get<T>(path, queryParameters: queryParameters),
      endpoint: path,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return callApi<T>(
      apiCall: () => _dio.post<T>(path, data: data, queryParameters: queryParameters),
      endpoint: path,
    );
  }

  // Add other methods (put, delete, etc.) as needed
}
