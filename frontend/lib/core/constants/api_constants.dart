
class ApiConstants {
  // Change this only when backend URL changes
  static const String baseUrl = 'http://localhost:8000';

  //  Auth
  static const String login = '$baseUrl/auth/login/';
  static const String register = '$baseUrl/auth/register/';

  //  Trips
  static const String trips = '$baseUrl/api/trips/';

  //  WebSocket (chat)
  static String tripChatSocket(int tripId, String token) {
    return 'ws://localhost:8000/ws/trips/$tripId/chat/?token=$token';
  }
}
