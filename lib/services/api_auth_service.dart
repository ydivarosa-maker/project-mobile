import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiAuthService {
  // Ganti alamat ini jika menggunakan perangkat fisik atau server berbeda
  final String baseUrl = 'http://10.0.2.2:3000/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        if (data.containsKey('token') && data['token'] != null) {
          await prefs.setString('auth_token', data['token'] as String);
        }
        if (data.containsKey('userId') && data['userId'] != null) {
          await prefs.setInt('userId', data['userId'] as int);
        }
        return {'success': true, 'data': data};
      }

      final body = resp.body.isNotEmpty ? jsonDecode(resp.body) : null;
      final message = body is Map && body.containsKey('message')
          ? body['message']
          : 'Login gagal';
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('userId');
  }

  Future<int?> currentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<String?> authToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
