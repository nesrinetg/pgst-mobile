import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../config/language_provider.dart';
import '../config/theme_provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isChangingVacation = false;
  bool isVacation = false;
  String? error;

  static const Color blue = Color(0xFF005BAA);
  static const Color deepBlue = Color(0xFF003B73);
  static const Color green = Color(0xFF2F9E63);
  static const Color bg = Color(0xFFF7FAFD);
  static const Color textDark = Color(0xFF14213D);
  static const Color textSoft = Color(0xFF7B8794);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _apiService.getCurrentUser();

      if (!mounted) return;

      final status = user['status']?.toString().toLowerCase() ?? '';

      setState(() {
        userData = user;
        isVacation = status == 'inactive' || status == 'vacation';
        isLoading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _refreshUser() async {
    await _loadUser();
  }

  Future<void> _logout() async {
    await context.read<AuthService>().logout();
  }

 Future<void> _toggleVacation(bool value) async {
  final t = AppLocalizations.of(context)!;
  final theme = context.read<ThemeProvider>();

  final isDark = theme.isDark;
  final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
  final titleColor = isDark ? Colors.white : const Color(0xFF14213D);
  final softColor = isDark ? Colors.white70 : const Color(0xFF7B8794);

  final confirm = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF003B73),
                    Color(0xFF005BAA),
                    Color(0xFF2F9E63),
                  ],
                ),
              ),
              child: Icon(
                value ? Icons.beach_access_rounded : Icons.work_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              value ? t.vacationConfirmTitle : t.backConfirmTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              value ? t.vacationConfirmMessage : t.backConfirmMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: softColor,
                fontSize: 14.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

           Row(
  children: [
    Expanded(
      child: SizedBox(
        height: 56,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: softColor.withOpacity(0.22),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: Text(
            t.cancel,
            style: TextStyle(
              color: softColor,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF003B73),
                  Color(0xFF005BAA),
                  Color(0xFF2F9E63),
                ],
              ),
              borderRadius: BorderRadius.circular(22),

              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF005BAA).withOpacity(0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Confirmer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ],
),
          
          ],
        ),
      ),
    ),
  );

  if (confirm != true) return;

  setState(() => isChangingVacation = true);

  try {
    if (value) {
      await _apiService.setVacationMode();
    } else {
      await _apiService.setActiveMode();
    }

    if (!mounted) return;

    setState(() {
      isVacation = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? t.happyVacation : t.welcomeBack),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => isChangingVacation = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final lang = context.watch<LanguageProvider>();
    final t = AppLocalizations.of(context)!;

    final isDark = theme.isDark;

    final bgColor = isDark ? const Color(0xFF0F172A) : bg;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? Colors.white : textDark;
    final softColor = isDark ? Colors.white70 : textSoft;
    final dividerColor = isDark ? Colors.white12 : Colors.grey.shade200;
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.35) : deepBlue.withOpacity(0.07);

    final fullName = userData?['name']?.toString() ?? 'Utilisateur';
    final email = userData?['email']?.toString() ?? 'Aucun email';

    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : 'Utilisateur';
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: bgColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: blue))
          : RefreshIndicator(
              color: blue,
              onRefresh: _refreshUser,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: blue,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Salut $firstName",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: titleColor,
                                ),
                              ),
                              Text(
                                lastName,
                                style: TextStyle(color: softColor),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                email,
                                style: TextStyle(color: softColor),
                              ),
                              if (error != null) ...[
                                const SizedBox(height: 14),
                                Text(
                                  error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.language,
                                  color: blue,
                                ),
                                title: Text(
                                  t.language,
                                  style: TextStyle(color: titleColor),
                                ),
                                trailing: DropdownButton<String>(
                                  value: lang.locale.languageCode,
                                  underline: const SizedBox(),
                                  dropdownColor: cardColor,
                                  style: TextStyle(
                                    color: titleColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'fr',
                                      child: Text('Français'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'en',
                                      child: Text('English'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'ar',
                                      child: Text('العربية'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    lang.setLanguage(value);
                                  },
                                ),
                              ),

                              Divider(height: 1, color: dividerColor),

                              SwitchListTile(
                                title: Text(
                                  t.darkMode,
                                  style: TextStyle(color: titleColor),
                                ),
                                secondary: const Icon(
                                  Icons.dark_mode,
                                  color: blue,
                                ),
                                value: theme.isDark,
                                activeColor: green,
                                onChanged: (value) {
                                  theme.toggleTheme(value);
                                },
                              ),

                              Divider(height: 1, color: dividerColor),

                              SwitchListTile(
                                title: Text(
                                  t.vacationMode,
                                  style: TextStyle(color: titleColor),
                                ),
                                subtitle: Text(
                                  isVacation
                                      ? t.vacationActive
                                      : t.vacationInactive,
                                  style: TextStyle(color: softColor),
                                ),
                                secondary: isChangingVacation
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: blue,
                                        ),
                                      )
                                    : Icon(
                                        isVacation
                                            ? Icons.beach_access
                                            : Icons.work_outline,
                                        color: blue,
                                      ),
                                value: isVacation,
                                activeColor: green,
                                onChanged: isChangingVacation
                                    ? null
                                    : (value) => _toggleVacation(value),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [deepBlue, blue, green],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: blue.withOpacity(0.24),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  t.logout,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}