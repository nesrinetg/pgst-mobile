import 'package:flutter/material.dart';
import 'contractor_home_page.dart';
import 'kpi_page.dart';
import 'interventions_page.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  void _goTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF4E6CF1),
              padding: const EdgeInsets.all(20),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    child: Icon(Icons.person, size: 32),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Sous-traitant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Compte test',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Accueil / Carte'),
              onTap: () => _goTo(context, const ContractorHomePage()),
            ),
            ListTile(
  leading: const Icon(Icons.assignment_outlined),
  title: const Text('Mes interventions'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InterventionsPage(),
      ),
    );
  },
),
ListTile(
  leading: const Icon(Icons.bar_chart_outlined),
  title: const Text('KPI'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const KpiPage(),
      ),
    );
  },
),
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Page notifications bientôt')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Page profil bientôt')),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}