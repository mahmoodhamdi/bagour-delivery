import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isRefreshing = false;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  /// Request interceptor - adds authorization header
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  /// Response interceptor - can be used for logging or response transformation
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    return handler.next(response);
  }

  /// Error interceptor - handles 401 errors with token refresh
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request with new token
          final opts = error.requestOptions;
          final token = await _storage.read(key: AppConstants.accessTokenKey);
          opts.headers['Authorization'] = 'Bearer $token';
          try {
            final response = await _dio.fetch(opts);
            _isRefreshing = false;
            return handler.resolve(response);
          } catch (e) {
            _isRefreshing = false;
            return handler.next(error);
          }
        }
      } catch (e) {
        _isRefreshing = false;
      }
    }
    return handler.next(error);
  }

  /// Refresh the access token using the refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      // Use a separate Dio instance to avoid interceptor loops
      final response = await Dio().post(
        '${AppConstants.baseUrl}/auth/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await _storage.write(
          key: AppConstants.accessTokenKey,
          value: data['accessToken'],
        );
        await _storage.write(
          key: AppConstants.refreshTokenKey,
          value: data['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Store tokens after successful login
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  /// Check if user has valid tokens
  Future<bool> hasValidTokens() async {
    final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
    return accessToken != null;
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// Upload file with multipart form data
  Future<Response> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalFields,
    Options? options,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (additionalFields != null) ...additionalFields,
    });

    return _dio.post(
      path,
      data: formData,
      options: options ?? Options(contentType: 'multipart/form-data'),
    );
  }

  /// Handle Dio errors and return user-friendly messages
  String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        if (data is Map<String, dynamic> && data['message'] != null) {
          return data['message'];
        }
        switch (statusCode) {
          case 400:
            return 'طلب غير صالح';
          case 401:
            return 'غير مصرح. يرجى تسجيل الدخول مرة أخرى';
          case 403:
            return 'غير مسموح بالوصول';
          case 404:
            return 'لم يتم العثور على المورد';
          case 409:
            return 'تعارض في البيانات';
          case 422:
            return 'البيانات المدخلة غير صالحة';
          case 429:
            return 'طلبات كثيرة جداً. يرجى الانتظار';
          case 500:
            return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
          case 503:
            return 'الخدمة غير متاحة حالياً';
          default:
            return 'حدث خطأ غير متوقع';
        }
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالإنترنت';
      case DioExceptionType.badCertificate:
        return 'خطأ في شهادة الأمان';
      case DioExceptionType.unknown:
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  /// Get error message in English (for logging or debugging)
  String handleErrorEn(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        if (data is Map<String, dynamic> && data['message'] != null) {
          return data['message'];
        }
        switch (statusCode) {
          case 400:
            return 'Bad request';
          case 401:
            return 'Unauthorized. Please login again';
          case 403:
            return 'Access forbidden';
          case 404:
            return 'Resource not found';
          case 409:
            return 'Data conflict';
          case 422:
            return 'Invalid input data';
          case 429:
            return 'Too many requests. Please wait';
          case 500:
            return 'Server error. Please try again later';
          case 503:
            return 'Service unavailable';
          default:
            return 'An unexpected error occurred';
        }
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.badCertificate:
        return 'Security certificate error';
      case DioExceptionType.unknown:
      default:
        return 'An unexpected error occurred';
    }
  }
}
