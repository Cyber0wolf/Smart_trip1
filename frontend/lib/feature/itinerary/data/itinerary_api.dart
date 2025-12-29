import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

class ItineraryApi {
  final ApiClient apiClient;
  ItineraryApi(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchItinerary(int tripId) async {
    try {
      final res = await apiClient.get('/api/trips/$tripId/itinerary/');
      final list = (res.data as List).cast<Map<String, dynamic>>();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('itinerary_$tripId', jsonEncode(list));
      return list;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('itinerary_$tripId');
      if (cached != null) {
        final list = (jsonDecode(cached) as List).cast<Map<String, dynamic>>();
        return list;
      }
      // fallback sample
      return [
        {'id': -1, 'title': 'Welcome', 'order': 0},
        {'id': -2, 'title': 'Plan activities', 'order': 1},
      ];
    }
  }

  Future<void> saveLocal(int tripId, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('itinerary_$tripId', jsonEncode(items));
  }
}
