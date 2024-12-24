import 'package:dio/dio.dart';
import 'package:flutter_getx_boilerplate/api/api_constants.dart';
import 'package:flutter_getx_boilerplate/models/profile/profile_response.dart';
import 'package:flutter_getx_boilerplate/models/response/shaved_status_response.dart';
import 'package:flutter_getx_boilerplate/models/tree_condition/tree_condition_request.dart';
import 'package:get/get_connect/http/src/exceptions/exceptions.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

class ApiProvider {
  final Dio _dio;
  final _storage = GetStorage();
  final _logger = Logger();

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

        _logger.i("""
          REQUEST:
          url(${options.method}): ${options.uri}
          headers: ${options.headers}
          data: ${options.data}
          """);

        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i("""
          RESPONSE:
          status: ${response.statusCode}
          data: ${response.data}
          """);
        return handler.next(response);
      },
      onError: (error, handler) {
        _logger.e("""
          ERROR:
          type: ${error.type}
          message: ${error.message}
          response: ${error.response}
          """);

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
      _logger.e("""
        LOGIN ERROR:
        type: ${e.type}
        message: ${e.message}
        response: ${e.response}
        """);
      rethrow;
    }
  }

  Future<Response> getStatus() async {
    try {
      final response = await _dio.get(ApiConstants.getStatusUrl());
      return response;
    } on DioException catch (e) {
      _logger.e("""
        STATUS ERROR:
        type: ${e.type}
        message: ${e.message}
        response: ${e.response}
        """);
      rethrow;
    }
  }

  Future<ProfileResponse> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.getProfileUrl());
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e("""
        PROFILE ERROR:
        type: ${e.type}
        message: ${e.message}
        response: ${e.response}
        """);
      rethrow;
    }
  }

  Future<Response> syncTreeCondition(TreeConditionRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.getSyncTreeConditionUrl(),
        data: request.toJson(),
      );
      return response;
    } on DioException catch (e) {
      _logger.e("""
        SYNC ERROR:
        type: ${e.type}
        message: ${e.message}
        response: ${e.response}
        """);
      rethrow;
    }
  }

  Future<ShavedStatusResponse> fetchShavedStatus() async {
    try {
      final response = await _dio.get(
        ApiConstants.getShavedStatusUrl(),
      );
      return ShavedStatusResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Farm APIs
  Future<Response<Map<String, dynamic>>> getFarms() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.getFarmUrl(),
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch farms',
        );
      }
    } on DioException catch (e) {
      print('DioException in getFarms: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      rethrow;
    } catch (e) {
      print('Error in getFarms: $e');
      throw Exception('Failed to fetch farms: $e');
    }
  }

  Future<Response<Map<String, dynamic>>> getTeams(int farmId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.getProductTeamUrl(),
        queryParameters: {'farmId': farmId},
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch teams',
        );
      }
    } on DioException catch (e) {
      print('DioException in getTeams: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      rethrow;
    } catch (e) {
      print('Error in getTeams: $e');
      throw Exception('Failed to fetch teams: $e');
    }
  }

  Future<Response<Map<String, dynamic>>> getLots(int productTeamId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.getFarmLotUrl(),
        queryParameters: {'productTeamId': productTeamId},
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch lots',
        );
      }
    } on DioException catch (e) {
      print('DioException in getLots: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      rethrow;
    } catch (e) {
      print('Error in getLots: $e');
      throw Exception('Failed to fetch lots: $e');
    }
  }

  Future<Response<Map<String, dynamic>>> getYears(int farmLotId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.getYearShavedUrl(),
        queryParameters: {'farmLotId': farmLotId},
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch years',
        );
      }
    } on DioException catch (e) {
      print('DioException in getYears: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      rethrow;
    } catch (e) {
      print('Error in getYears: $e');
      throw Exception('Failed to fetch years: $e');
    }
  }
}
