
class ApiConstants {
  // Change this only when backend URL changes
  static const String baseUrl = 'https://smart-trip1.onrender.com';

  //  Auth
  static const String login = '$baseUrl/auth/login/';
  static const String register = '$baseUrl/auth/register/';

  //  Trips
  static const String trips = '$baseUrl/api/trips/';

  //  WebSocket (chat)
  static String tripChatSocket(int tripId, String token) {
    return 'wss://smart-trip1.onrender.com/ws/trips/$tripId/chat/?token=$token';
  }
}
