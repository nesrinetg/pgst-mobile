import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'connect_api.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  AuthService() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _isInitialized = true;
    notifyListeners();
  }
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
Future<bool> register({
  required String name,
  required String email,
  required String password,
  required String passwordConfirm,
}) async {
  _isLoading = true;
  notifyListeners();

  try {
    final response = await http.post(
      Uri.parse(ConnectApi.url('/register')),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': passwordConfirm,
      }),
    );

    debugPrint('REGISTER STATUS: ${response.statusCode}');
    debugPrint('REGISTER BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      _token = data['token']?.toString();
      _user = data['user'] is Map<String, dynamic> ? data['user'] : null;

      if (_token == null || _token!.isEmpty) {
        throw Exception('Token missing in register response');
      }

      await _saveToken(_token!);
      notifyListeners();
      return true;
    } else {
      throw Exception(_extractErrorMessage(response));
    }
  } catch (e) {
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          return data['message'].toString();
        }

        if (data['error'] != null) {
          return data['error'].toString();
        }

        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstValue = errors.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              return firstValue.first.toString();
            }
            return firstValue.toString();
          }
        }
      }

      return 'Request failed with status ${response.statusCode}';
    } catch (_) {
      return 'Request failed with status ${response.statusCode}';
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ConnectApi.url('/login')),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      debugPrint('LOGIN STATUS: ${response.statusCode}');
      debugPrint('LOGIN BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _token = data['token']?.toString();
        _user = data['user'] is Map<String, dynamic> ? data['user'] : null;

        if (_token == null || _token!.isEmpty) {
          throw Exception('Token missing in login response');
        }

        await _saveToken(_token!);
        notifyListeners();
        return true;
      }

      throw Exception(_extractErrorMessage(response));
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService().logoutRequest();
    } catch (_) {
      // ignore backend logout failure
    }

    _token = null;
    _user = null;
    await _clearToken();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearSession() async {
    _token = null;
    _user = null;
    await _clearToken();
    notifyListeners();
  }
}