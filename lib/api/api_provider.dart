import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/api/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class ApiProvider {
  final Dio _dio;
  final _storage = GetStorage();

  ApiProvider() : _dio = Dio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        return status! < 500;
      },
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Content-Type'] = 'application/json';
        options.headers['Accept'] = 'application/json';

        final token = _storage.read('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Log request
        log(
          """
          REQUEST:
          url(${options.method}): ${options.uri}
          headers: ${options.headers}
          data: ${options.data}
          """,
          name: 'API',
        );

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response
        log(
          """
          RESPONSE:
          status: ${response.statusCode}
          data: ${response.data}
          """,
          name: 'API',
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        // Log error
        log(
          """
          ERROR:
          type: ${error.type}
          message: ${error.message}
          response: ${error.response}
          """,
          name: 'API',
        );

        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          //error.error = 'Connection timeout. Please check your internet connection.';
        } else if (error.type == DioExceptionType.connectionError) {
          // error.error = 'Connection failed. Please check your internet connection.';
        }

        return handler.next(error);
      },
    ));
  }

  Future<Response> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.getLoginUrl(),
        data: {
          'userName': username,
          'password': password,
        },
      );
      return response;
    } on DioException catch (e) {
      log(
        """
        LOGIN ERROR:
        type: ${e.type}
        message: ${e.message}
        response: ${e.response}
        """,
        name: 'API',
      );
      rethrow;
    }
  }

  Future<Response> getStatus() async {
    try {
      final response = await _dio.get(ApiConstants.getStatusUrl());
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
