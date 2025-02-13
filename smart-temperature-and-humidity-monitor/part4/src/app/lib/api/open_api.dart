import 'package:dio/dio.dart';

class WhatapOpenApi {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api.whatap.io/open/api';

  final String token;
  final String pcode;

  WhatapOpenApi({
    required this.token,
    required this.pcode,
  }) {
    _dio.options.headers = {
      'x-whatap-token': token,
      'x-whatap-pcode': pcode,
      'Content-Type': 'application/json; charset=utf-8',
    };
  }

  Future<dynamic> executeMql({
    required String mql,
    required int startTime,
    required int endTime,
    String pageKey = 'mxql',
    int limit = 1000,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/flush/mxql/text',
        data: {
          'mql': mql,
          'stime': startTime,
          'etime': endTime,
          'pageKey': pageKey,
          'limit': limit,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('연결 시간이 초과되었습니다.');
      case DioExceptionType.badResponse:
        return Exception('서버 오류: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return Exception('요청이 취소되었습니다.');
      default:
        return Exception('네트워크 오류가 발생했습니다: ${e.message}');
    }
  }
}
