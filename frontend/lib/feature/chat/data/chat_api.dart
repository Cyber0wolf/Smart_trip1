import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

class ChatApi {
  final ApiClient apiClient;
  ChatApi(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchMessages(int tripId) async {
    try {
      final res = await apiClient.get('/api/trips/$tripId/messages/');
      final list = (res.data as List).cast<Map<String, dynamic>>();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chat_$tripId', jsonEncode(list));
      return list;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('chat_$tripId');
      if (cached != null) {
        return (jsonDecode(cached) as List).cast<Map<String, dynamic>>();
      }
      return const [];
    }
  }

  Future<Map<String, dynamic>> sendMessage(int tripId, String content) async {
    final res = await apiClient.post('/api/trips/$tripId/messages/', {
      'content': content,
    });
    return (res.data as Map<String, dynamic>);
  }
}
