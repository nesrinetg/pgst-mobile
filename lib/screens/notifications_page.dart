import 'dart:async';

import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _service = NotificationService();

  List<dynamic> notifications = [];
  bool loading = true;
  bool refreshing = false;
  String? errorMessage;

  Timer? timer;

  static const Color blue = Color(0xFF005BAA);
  static const Color deepBlue = Color(0xFF003B73);
  static const Color green = Color(0xFF2F9E63);
  static const Color orange = Color(0xFFE85D24);
  static const Color bg = Color(0xFFF4F7FB);
  static const Color textDark = Color(0xFF14213D);
  static const Color softText = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();

    fetchNotifications();

    timer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => fetchNotifications(silent: true),
    );
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    try {
      if (!silent) {
        setState(() {
          loading = true;
          errorMessage = null;
        });
      }

      final data = await _service.getNotifications();

      if (!mounted) return;

      setState(() {
        notifications = data;
        loading = false;
        refreshing = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        refreshing = false;
        errorMessage = 'Impossible de charger les notifications';
      });
    }
  }

  Future<void> _markAsRead(dynamic notif) async {
    final id = notif['id'];

    if (id == null) return;

    try {
      await _service.markNotificationRead(id);

      if (!mounted) return;

      setState(() {
        notif['is_read'] = true;
      });
    } catch (_) {
      // keep UI stable
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';

    final text = value.toString();

    if (text.length >= 16) {
      return text.substring(0, 16);
    }

    return text;
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'ods_assigned':
        return Icons.assignment_turned_in_rounded;
      case 'sla_3j':
      case 'sla_1j':
        return Icons.schedule_rounded;
      case 'sla_expired':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'ods_assigned':
        return blue;
      case 'sla_3j':
      case 'sla_1j':
        return orange;
      case 'sla_expired':
        return Colors.red;
      default:
        return green;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'ods_assigned':
        return 'ODS';
      case 'sla_3j':
        return 'SLA 3 jours';
      case 'sla_1j':
        return 'SLA 1 jour';
      case 'sla_expired':
        return 'SLA depasse';
      default:
        return 'Alerte';
    }
  }

  int get unreadCount {
    return notifications.where((n) => n['is_read'] == false).length;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: blue),
                  )
                : errorMessage != null
                    ? _buildError()
                    : notifications.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            color: blue,
                            onRefresh: () => fetchNotifications(),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                return _buildNotificationCard(
                                  notifications[index],
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 18,
        20,
        22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [deepBlue, blue, green],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  unreadCount == 0
                      ? 'Aucune nouvelle alerte'
                      : '$unreadCount nouvelle${unreadCount > 1 ? 's' : ''} alerte${unreadCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => fetchNotifications(),
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notif) {
    final title = notif['title']?.toString() ?? '';
    final body = notif['body']?.toString() ?? '';
    final type = notif['type']?.toString() ?? '';
    final date = _formatDate(notif['created_at']);
    final isRead = notif['is_read'] == true;

    final color = _colorForType(type);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _markAsRead(notif),
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRead ? const Color(0xFFE5E7EB) : color.withOpacity(0.35),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    _iconForType(type),
                    color: color,
                    size: 24,
                  ),
                ),
                if (!isRead)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _labelForType(type),
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (date.isNotEmpty)
                        Text(
                          date,
                          style: const TextStyle(
                            color: softText,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: textDark,
                      fontSize: 15,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    style: const TextStyle(
                      color: softText,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 72,
              color: softText.withOpacity(0.45),
            ),
            const SizedBox(height: 14),
            const Text(
              'Aucune notification',
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Les alertes ODS et SLA apparaissent ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: softText,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 68,
              color: softText,
            ),
            const SizedBox(height: 14),
            Text(
              errorMessage ?? 'Erreur',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => fetchNotifications(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}