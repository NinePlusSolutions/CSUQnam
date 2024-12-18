import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/api/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class ApiProvider {
  final Dio _dio = Dio();
  final _storage = GetStorage();

  ApiProvider() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.read('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
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
    } catch (e) {
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
