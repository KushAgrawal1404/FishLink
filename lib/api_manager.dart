import 'package:http/http.dart' as http;

class ApiManager {
  static const String baseUrl = 'http://192.168.216.129:3000';

  static Future<http.Response> signUp({
    required String username,
    required String password,
    required String email,
    required String userType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      body: {
        'username': username,
        'password': password,
        'email': email,
        'userType': userType,
      },
    );
    return response;
  }

  static Future<http.Response> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {
        'username': username,
        'password': password,
      },
    );
    return response;
  }
}
