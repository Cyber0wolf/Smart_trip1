import '../../../core/network/api_client.dart';

class AuthApi {
  final ApiClient apiClient;

  AuthApi(this.apiClient);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/login/',
      {
        'email': email,
        'password': password,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<void> signup({
    required String email,
    required String password,
  }) async {
    await apiClient.post(
      '/auth/register/',
      {
        'email': email,
        'password': password,
      },
    );
  }
}
