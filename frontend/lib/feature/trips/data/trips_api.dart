import '../../../core/network/api_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class TripsApi {
  final ApiClient apiClient;

  TripsApi(this.apiClient);

  Future<List<dynamic>> fetchTrips() async {
    try {
      final response = await apiClient.get('/api/trips/');
      final data = response.data as List<dynamic>;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('trips_cache', jsonEncode(data));
      return data;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('trips_cache');
      if (cached != null) {
        return jsonDecode(cached) as List<dynamic>;
      }
      rethrow;
    }
  }

  Future<List<dynamic>> fetchExploreTrips() async {
    try {
      final response = await apiClient.get('/api/trips/', queryParameters: {'explore': '1'});
      final data = response.data as List<dynamic>;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('trips_explore_cache', jsonEncode(data));
      return data;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('trips_explore_cache');
      if (cached != null) {
        return jsonDecode(cached) as List<dynamic>;
      }
      rethrow;
    }
  }

  Future<void> createTrip(String name) async {
    await apiClient.post('/api/trips/', {
      'name': name,
    });
  }

  Future<void> joinTrip(int tripId) async {
    await apiClient.post('/api/trips/$tripId/join/', {});
  }

  Future<void> leaveTrip(int tripId) async {
    await apiClient.post('/api/trips/$tripId/leave/', {});
  }

  Future<List<dynamic>> fetchTripMembers(int tripId) async {
    final response = await apiClient.get('/api/trips/$tripId/members/');
    return response.data as List<dynamic>;
  }
}
