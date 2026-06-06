import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class PollingNotificationService {
  static final _local = FlutterLocalNotificationsPlugin();
  static Timer? _timer;
  static int _lastSeenId = 0; // tracks last notif we already showed

  static Future<void> init() async {
    // Setup local notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Android notification channel
    const channel = AndroidNotificationChannel(
      'pgst_channel',
      'PGST Alertes',
      description: 'ODS et SLA notifications',
      importance: Importance.max,
    );
    await _local
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

    // Load last seen id from prefs
    final prefs = await SharedPreferences.getInstance();
    _lastSeenId = prefs.getInt('last_notif_id') ?? 0;
  }

  /// Call this after login
  static void startPolling(ApiService api) {
    _timer?.cancel();
    // Poll immediately, then every 30 seconds
    _poll(api);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _poll(api));
  }

  /// Call this at logout
  static void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _lastSeenId = 0;
  }

  static Future<void> _poll(ApiService api) async {
    try {
      final result = await api.getNotifications();
      final List notifs = result['data'] ?? [];

      // Only show notifs newer than last seen
      final newNotifs = notifs
          .where((n) => (n['id'] as int) > _lastSeenId)
          .toList();

      if (newNotifs.isEmpty) return;

      // Show each new notif as a local notification
      for (final notif in newNotifs) {
        await _showLocal(
          id: notif['id'] as int,
          title: notif['title'] ?? '',
          body: notif['body'] ?? '',
        );
      }

      // Update last seen id
      _lastSeenId = notifs.first['id'] as int;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_notif_id', _lastSeenId);
    } catch (e) {
      debugPrint('Polling error: $e');
    }
  }

  static Future<void> _showLocal({
    required int id,
    required String title,
    required String body,
  }) async {
    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pgst_channel',
          'PGST Alertes',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
