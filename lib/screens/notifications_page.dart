import 'dart:async';

import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {

  final NotificationService _service =
      NotificationService();

  List<dynamic> notifications = [];

  bool loading = true;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    fetchNotifications();

    // 🔥 refresh every 10 seconds
    timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        fetchNotifications();
      },
    );
  }

  Future<void> fetchNotifications() async {

    try {

      final data =
          await _service.getNotifications();

      if (!mounted) return;

      setState(() {
        notifications = data;
        loading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {

    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Notifications'),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications',
                  ),
                )
              : RefreshIndicator(
                  onRefresh:
                      fetchNotifications,
                  child: ListView.builder(
                    itemCount:
                        notifications.length,
                    itemBuilder:
                        (context, index) {

                      final notif =
                          notifications[index];

                      return Card(
                        margin:
                            const EdgeInsets.all(
                                10),
                        child: ListTile(

                          leading: const Icon(
                            Icons
                                .notifications_active,
                            color: Colors.blue,
                          ),

                          title: Text(
                            notif['title'] ?? '',
                          ),

                          subtitle: Text(
                            notif['body'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}