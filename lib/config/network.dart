import 'dart:convert';

import 'package:flutter_bengkelin_user/config/pref.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../main.dart';
import 'network/interceptors/logger_interceptor.dart';

/// ================= SERVER UAT ==========================
final baseUrl = dotenv.env['BASEURL_STAGING_CLIENT']!;

/// ================= SERVER PROD ==========================
// final baseUrl = dotenv.env['BASEURL_PRODUCTION']!;

class Network {
  static final Network _instance = Network._internal();
  factory Network() => _instance;
  Network._internal();
  static Future<dynamic> postApi(String url, dynamic formData) async {
    try {
      var dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(milliseconds: 500000),
          receiveTimeout: const Duration(milliseconds: 300000),
          responseType: ResponseType.json,
          maxRedirects: 0,
          contentType: 'application/json',
        ),
      )..interceptors.addAll([
        // AuthorizationInterceptor(),
        LoggerInterceptor(),
        // LanguageInterceptor(),
      ]);

      Response rest = await dio.post(url, data: formData);
      dio.close();
      return rest.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return jsonDecode(e.response.toString());
      } else {
        // Something happened in setting up or sending the request that triggered an Error
      }
    }
  }

  static Future<dynamic> postApiWithHeaders(String url, body, Map<String, dynamic> header) async {
    try {
      var dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(milliseconds: 500000),
          receiveTimeout: const Duration(milliseconds: 300000),
          responseType: ResponseType.json,
          maxRedirects: 0,
        ),
      )..interceptors.addAll([
        // AuthorizationInterceptor(),
        LoggerInterceptor(),
        // LanguageInterceptor(),
      ]);

      debugPrint("url: $url");
      Response restValue =
      await dio.post(url, data: body, options: Options(headers: header));
      debugPrint("postApiWithHeaders: ${restValue.data}");
      dio.close();
      header.clear();
      return restValue.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await Session().logout();
        // 👇 Navigate to login if refresh fails
        // navigatorKey.currentState?.pushNamedAndRemoveUntil(
        //   '/',
        //   (route) => false,
        // );
      }
      if (e.response != null) {
        // debugPrint(e.response!.data);
        // debugPrint(e.response!.headers.toString());
        // debugPrint(e.response!.requestOptions.toString());

        return jsonDecode(e.response.toString());
        return e.response!.data;
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        debugPrint(e.requestOptions.toString());
        debugPrint(e.message);
      }
    }
  }

  static Future<dynamic> getApi(String url, {String? baseurl}) async {
    try {
      var dio = Dio(
        BaseOptions(
          baseUrl: baseurl ?? baseUrl,
          connectTimeout: const Duration(milliseconds: 500000),
          receiveTimeout: const Duration(milliseconds: 300000),
          responseType: ResponseType.json,
          maxRedirects: 0,
        ),
      )..interceptors.addAll([
        // AuthorizationInterceptor(),
        LoggerInterceptor(),
        // LanguageInterceptor(),
      ]);

      Response restGet = await dio.get(url);
      dio.close();
      return restGet.data;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint(e.response!.data);
        debugPrint(e.response!.headers.toString());
        debugPrint(e.response!.requestOptions.toString());

        return jsonDecode(e.response.toString());
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        debugPrint(e.requestOptions.toString());
        debugPrint(e.message);
      }
    }
  }

  static Future<dynamic> getApiWithHeaders(String url, Map<String, dynamic> header) async {
    try {
      var dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(milliseconds: 500000),
          receiveTimeout: const Duration(milliseconds: 300000),
          responseType: ResponseType.json,
          maxRedirects: 0,
        ),
      )..interceptors.addAll([
        // AuthorizationInterceptor(),
        LoggerInterceptor(),
        // LanguageInterceptor(),
      ]);

      Response restGet = await dio.get(url, options: Options(headers: header));
      debugPrint("getApiWithHeaders: ${restGet.data}");
      dio.close();
      header.clear();
      return restGet.data;
    } on DioException catch (e) {
      debugPrint("getApiWithHeaders: ${e.response?.statusCode}");
      if (e.response?.statusCode == 401) {
        debugPrint("Token expired");
        await Session().logout();
        // 👇 Navigate to login if refresh fails
        // navigatorKey.currentState?.pushNamedAndRemoveUntil(
        //   '/',
        //   (route) => false,
        // );
      }
      if (e.response?.statusCode == 500) {
        debugPrint("loh error apa ${e.response?.statusMessage}");
        // showGlobalToast(msg: e.response?.statusMessage,);
      }
    }
  }

  static Future<dynamic> deleteApiWithHeaders(String url, Map<String, dynamic> header) async {
    try {
      var dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(milliseconds: 500000),
          receiveTimeout: const Duration(milliseconds: 300000),
          responseType: ResponseType.json,
          maxRedirects: 0,
        ),
      )..interceptors.addAll([
        // AuthorizationInterceptor(),
        LoggerInterceptor(),
        // LanguageInterceptor(),
      ]);

      Response restGet = await dio.delete(url, options: Options(headers: header));
      debugPrint("getApiWithHeaders: ${restGet.data}");
      dio.close();
      header.clear();
      return restGet.data;
    } on DioException catch (e) {
      debugPrint("getApiWithHeaders: ${e.response?.statusCode}");
      if (e.response?.statusCode == 401) {
        debugPrint("Token expired");
        await Session().logout();
        // 👇 Navigate to login if refresh fails
        // navigatorKey.currentState?.pushNamedAndRemoveUntil(
        //   '/',
        //   (route) => false,
        // );
      }
      if (e.response?.statusCode == 500) {
        debugPrint("loh error apa ${e.response?.statusMessage}");
        // showGlobalToast(msg: e.response?.statusMessage,);
      }
    }
  }

  static Future<dynamic> putApi(String url, dynamic formData) async {
    try {
      var dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(milliseconds: 500000),
          receiveTimeout: const Duration(milliseconds: 300000),
          responseType: ResponseType.json,
          maxRedirects: 0,
        ),
      )..interceptors.addAll([
        // AuthorizationInterceptor(),
        LoggerInterceptor(),
        // LanguageInterceptor(),
      ]);

      Response restValue = await dio.put(url, data: formData);
      dio.close();
      return restValue.data;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint(e.response!.data);
        debugPrint(e.response!.headers.toString());
        debugPrint(e.response!.requestOptions.toString());

        return jsonDecode(e.response.toString());
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        debugPrint(e.requestOptions.toString());
        debugPrint(e.message);
      }
    }
  }

  static Future<dynamic> putApiWithHeaders(String url, dynamic body, Map<String, dynamic> header) async {
    try {
      var dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(milliseconds: 500000),
          receiveTimeout: const Duration(milliseconds: 300000),
          responseType: ResponseType.json,
          maxRedirects: 0,
        ),
      )..interceptors.addAll([
        // AuthorizationInterceptor(),
        LoggerInterceptor(),
        // LanguageInterceptor(),
      ]);

      Response restValue =
      await dio.put(url, data: body, options: Options(headers: header));
      dio.close();
      header.clear();
      return restValue.data;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint(e.response!.data);
        debugPrint(e.response!.headers.toString());
        debugPrint(e.response!.requestOptions.toString());

        return jsonDecode(e.response.toString());
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        debugPrint(e.requestOptions.toString());
        debugPrint(e.message);
      }
    }
  }
}