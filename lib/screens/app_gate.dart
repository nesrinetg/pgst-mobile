import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/polling_notification_service.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (auth.isLoggedIn) {
      PollingNotificationService.startPolling(ApiService());
      return const MainScreen();
    }

    PollingNotificationService.stopPolling();

   return LoginScreen(
  onLoginSuccess: () {
    PollingNotificationService.startPolling(ApiService());
  },
);
  }
}