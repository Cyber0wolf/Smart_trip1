import '../../../core/network/api_client.dart';

class ProfileApi {
  final ApiClient apiClient;

  ProfileApi(this.apiClient);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await apiClient.get('/auth/profile/');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? firstName,
    String? lastName,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;

    final response = await apiClient.put('/auth/profile/', data);
    return response.data as Map<String, dynamic>;
  }
}








