import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio dio = Dio();
  final TokenStorage _tokenStorage = TokenStorage();

  ApiClient() {
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.headers['Accept'] = 'application/json';
    dio.options.contentType = 'application/json';
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    );
  }

  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    dio.options.headers.remove('Authorization');
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final token = await _tokenStorage.getToken();
    if (token != null) setToken(token);
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, Map<String, dynamic> data) async {
    final token = await _tokenStorage.getToken();
    if (token != null) setToken(token);
    return dio.post(path, data: data);
  }

  Future<Response> put(String path, Map<String, dynamic> data) async {
    final token = await _tokenStorage.getToken();
    if (token != null) setToken(token);
    return dio.put(path, data: data);
  }

  Future<Response> patch(String path, Map<String, dynamic> data) async {
    final token = await _tokenStorage.getToken();
    if (token != null) setToken(token);
    return dio.patch(path, data: data);
  }
}
