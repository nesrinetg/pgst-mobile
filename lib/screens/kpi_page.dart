import 'dart:math' as math;
import 'package:flutter/material.dart';

class KpiPage extends StatelessWidget {
  const KpiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'KPI',
          style: TextStyle(
            color: Color(0xFF1E2230),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: const Color(0xFF1E2230),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.receipt_long_outlined, size: 20),
                color: const Color(0xFF1E2230),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          const _KpiHeroCard(),
          const SizedBox(height: 22),
          _sectionHeader('Quick Menu', 'Voir tout'),
          const SizedBox(height: 14),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickMenuCard(
                  icon: Icons.map_outlined,
                  title: 'Carte\ndérangements',
                ),
                SizedBox(width: 14),
                _QuickMenuCard(
                  icon: Icons.assignment_outlined,
                  title: 'Mes\ninterventions',
                ),
                SizedBox(width: 14),
                _QuickMenuCard(
                  icon: Icons.notifications_none,
                  title: 'Voir les\nalertes',
                ),
                SizedBox(width: 14),
                _QuickMenuCard(
                  icon: Icons.bar_chart_outlined,
                  title: 'Statistiques\njournalières',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader('Historique', 'Voir tout'),
          const SizedBox(height: 12),
          const _HistoryItem(
            title: 'Interventions terminées',
            subtitle: 'Aujourd’hui',
            value: '08',
            positive: true,
          ),
          const _HistoryItem(
            title: 'Tickets en attente',
            subtitle: 'Aujourd’hui',
            value: '03',
            positive: false,
          ),
          const _HistoryItem(
            title: 'SLA respecté',
            subtitle: 'Cette semaine',
            value: '92%',
            positive: true,
          ),
          const _HistoryItem(
            title: 'Temps moyen',
            subtitle: 'Cette semaine',
            value: '37 min',
            positive: true,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String action) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2230),
          ),
        ),
        const Spacer(),
        Text(
          action,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF7A7D8A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _KpiHeroCard extends StatelessWidget {
  const _KpiHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD7C8FF),
            Color(0xFFCFC1FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance du jour',
                    style: TextStyle(
                      color: Color(0xFF55506A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '12 interventions',
                    style: TextStyle(
                      color: Color(0xFF1E2230),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mois',
                      style: TextStyle(
                        color: Color(0xFF3E4150),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SizedBox(
            height: 220,
            child: _DonutKpiChart(),
          ),
        ],
      ),
    );
  }
}

class _DonutKpiChart extends StatelessWidget {
  const _DonutKpiChart();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(220, 220),
          painter: _DonutPainter(),
        ),
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '92%',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E2230),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'SLA respecté',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF4E5160),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: 78);

    const stroke = 26.0;
    const start = -math.pi * 0.85;

    final segments = [
      _ArcData(
        color: Color(0xFF6F2BFF),
        sweep: math.pi * 0.80,
      ),
      _ArcData(
        color: Color(0xFF7A3DFF),
        sweep: math.pi * 0.34,
      ),
      _ArcData(
        color: Color(0xFF0D2B7E),
        sweep: math.pi * 0.20,
      ),
      _ArcData(
        color: Color(0xFF005EA8),
        sweep: math.pi * 0.48,
      ),
      _ArcData(
        color: Color(0xFFB4A6F7),
        sweep: math.pi * 0.65,
      ),
    ];

    double currentStart = start;

    for (final item in segments) {
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        currentStart,
        item.sweep,
        false,
        paint,
      );

      currentStart += item.sweep + 0.08;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArcData {
  final Color color;
  final double sweep;

  const _ArcData({
    required this.color,
    required this.sweep,
  });
}

class _QuickMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickMenuCard({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD5C7FF),
            Color(0xFFE6DBFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF6F2EF),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1B2052),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2230),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final bool positive;

  const _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EDFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              positive ? Icons.trending_up : Icons.schedule_outlined,
              color: positive
                  ? const Color(0xFF6F2BFF)
                  : const Color(0xFFDA8B00),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2230),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7A7D8A),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF1E2230),
            ),
          ),
        ],
      ),
    );
  }
}