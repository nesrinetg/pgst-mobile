import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'connect_api.dart';

class NotificationService {

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> getNotifications() async {

    final token = await _token();

    final response = await http.get(
      Uri.parse(
        ConnectApi.url('/notifications'),
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data['data'] ?? [];
    }

    throw Exception('Erreur notifications');
  }
}