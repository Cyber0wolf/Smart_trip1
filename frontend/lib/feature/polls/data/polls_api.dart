import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

class PollsApi {
  final ApiClient apiClient;
  PollsApi(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchPolls(int tripId) async {
    try {
      final res = await apiClient.get('/api/trips/$tripId/polls/');
      final list = (res.data as List).cast<Map<String, dynamic>>();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('polls_$tripId', jsonEncode(list));
      return list;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('polls_$tripId');
      if (cached != null) {
        return (jsonDecode(cached) as List).cast<Map<String, dynamic>>();
      }
      return const [];
    }
  }

  Future<void> vote(int pollId, int optionId) async {
    await apiClient.post('/api/polls/vote/', {
      'poll': pollId,
      'option': optionId,
    });
  }

  Future<void> voteWithTrip({
    required int pollId,
    required int optionId,
    required int tripId,
  }) async {
    await apiClient.post('/api/polls/vote/', {
      'poll': pollId,
      'option': optionId,
      'trip': tripId,
    });
  }

  Future<void> createPoll({
    required int tripId,
    required String question,
    required List<String> options,
  }) async {
    await apiClient.post('/api/polls/', {
      'trip': tripId,
      'question': question,
      'options': options.map((t) => {'text': t}).toList(),
    });
  }
}
