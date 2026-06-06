import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'connect_api.dart';

class NotificationService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  String _extractError(String body, int statusCode) {
    try {
      final data = jsonDecode(body);

      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      }

      return 'Erreur $statusCode';
    } catch (_) {
      return 'Erreur $statusCode';
    }
  }

  Future<List<dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse(ConnectApi.url('/notifications')),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> && data['data'] is List) {
        return data['data'];
      }

      if (data is List) {
        return data;
      }

      return [];
    }

    throw Exception(_extractError(response.body, response.statusCode));
  }

  Future<void> markNotificationRead(int id) async {
    final response = await http.post(
      Uri.parse(ConnectApi.url('/notifications/$id/read')),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, response.statusCode));
    }
  }

  Future<void> markAllNotificationsRead() async {
    final response = await http.post(
      Uri.parse(ConnectApi.url('/notifications/read-all')),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, response.statusCode));
    }
  }
}