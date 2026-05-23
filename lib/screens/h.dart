import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

import '../models/kpi_data.dart';
import '../services/api_service.dart';

class KpiPage extends StatefulWidget {
  const KpiPage({super.key});

  @override
  State<KpiPage> createState() => _KpiPageState();
}

class _KpiPageState extends State<KpiPage> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  late AnimationController _entryController;
  late AnimationController _donutController;

  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _donutProgress;

  KpiData? kpi;
  bool loading = true;
  String? error;

  String selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _donutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _donutProgress = CurvedAnimation(
      parent: _donutController,
      curve: Curves.easeOutBack,
    );

    _entryController.forward();
    _loadKpi();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _donutController.dispose();
    super.dispose();
  }

  Future<void> _loadKpi() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      final data = await _apiService.getKpi(period: selectedPeriod);

      if (!mounted) return;

      setState(() {
        kpi = data;
        loading = false;
      });

      _donutController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
        loading = false;
      });
    }
  }

  Future<void> _downloadKpiPdf() async {
    final t = AppLocalizations.of(context)!;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.generatingKpiReport)),
      );

      final pdfUrl = await _apiService.downloadKpiPdf(period: selectedPeriod);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.kpiReportGenerated)),
      );

      debugPrint('PDF KPI URL: $pdfUrl');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  String _periodLabel(String value, AppLocalizations t) {
    switch (value) {
      case 'day':
        return t.day;
      case 'week':
        return t.week;
      case 'month':
        return t.month;
      case 'year':
        return t.year;
      default:
        return t.month;
    }
  }

  Future<void> _choosePeriod() async {
    final t = AppLocalizations.of(context)!;
    final periods = ['day', 'week', 'month', 'year'];

    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: periods.map((period) {
              final selected = period == selectedPeriod;

              return ListTile(
                leading: Icon(
                  selected ? Icons.check_circle : Icons.calendar_month_outlined,
                  color: selected
                      ? const Color(0xFF6F2BFF)
                      : const Color(0xFF7A7D8A),
                ),
                title: Text(
                  _periodLabel(period, t),
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                onTap: () => Navigator.pop(context, period),
              );
            }).toList(),
          ),
        );
      },
    );

    if (value != null) {
      setState(() => selectedPeriod = value);
      await _loadKpi();
    }
  }

  void _showComingSoon(String title) {
    final t = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title ${t.comingSoon}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2EF),
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.kpi,
          style: const TextStyle(
            color: Color(0xFF1E2230),
            fontWeight: FontWeight.w700,
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
                onPressed: _downloadKpiPdf,
              ),
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: RefreshIndicator(
                      onRefresh: _loadKpi,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                        children: [
                          _KpiHeroCard(
                            progress: _donutProgress,
                            selectedPeriod: _periodLabel(selectedPeriod, t),
                            onPeriodTap: _choosePeriod,
                            total: kpi?.total ?? 0,
                            sla: kpi?.sla ?? 0,
                          ),
                          const SizedBox(height: 22),
                          _sectionHeader(
                            t.quickMenu,
                            t.seeAll,
                            () => _showComingSoon(t.quickMenu),
                          ),
                          const SizedBox(height: 14),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _QuickMenuCard(
                                  icon: Icons.map_outlined,
                                  title: t.mapDerangements,
                                  onTap: () => _showComingSoon(t.mapDerangements),
                                ),
                                const SizedBox(width: 14),
                                _QuickMenuCard(
                                  icon: Icons.assignment_outlined,
                                  title: t.myInterventions,
                                  onTap: () => _showComingSoon(t.myInterventions),
                                ),
                                const SizedBox(width: 14),
                                _QuickMenuCard(
                                  icon: Icons.notifications_none,
                                  title: t.alerts,
                                  onTap: () => _showComingSoon(t.alerts),
                                ),
                                const SizedBox(width: 14),
                                _QuickMenuCard(
                                  icon: Icons.bar_chart_outlined,
                                  title: t.dailyStats,
                                  onTap: () => _showComingSoon(t.dailyStats),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _sectionHeader(
                            t.history,
                            t.seeAll,
                            () => _showComingSoon(t.fullHistory),
                          ),
                          const SizedBox(height: 12),
                          _HistoryItem(
                            title: t.finishedInterventions,
                            subtitle: _periodLabel(selectedPeriod, t),
                            value: '${kpi?.finished ?? 0}',
                            positive: true,
                          ),
                          _HistoryItem(
                            title: t.pendingTickets,
                            subtitle: _periodLabel(selectedPeriod, t),
                            value: '${kpi?.pending ?? 0}',
                            positive: false,
                          ),
                          _HistoryItem(
                            title: t.slaRespected,
                            subtitle: _periodLabel(selectedPeriod, t),
                            value: '${(kpi?.sla ?? 0).toStringAsFixed(0)}%',
                            positive: true,
                          ),
                          _HistoryItem(
                            title: t.averageTime,
                            subtitle: _periodLabel(selectedPeriod, t),
                            value: '${kpi?.avgTime ?? 0} min',
                            positive: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback onTap) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E2230),
          ),
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6F2BFF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KpiHeroCard extends StatelessWidget {
  final Animation<double> progress;
  final String selectedPeriod;
  final VoidCallback onPeriodTap;
  final int total;
  final double sla;

  const _KpiHeroCard({
    required this.progress,
    required this.selectedPeriod,
    required this.onPeriodTap,
    required this.total,
    required this.sla,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFD7C8FF), Color(0xFFCFC1FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6F2BFF).withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.performance,
                    style: const TextStyle(
                      color: Color(0xFF55506A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$total ${t.interventions}',
                    style: const TextStyle(
                      color: Color(0xFF1E2230),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onPeriodTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedPeriod,
                        style: const TextStyle(
                          color: Color(0xFF3E4150),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                return _DonutKpiChart(
                  progress: progress.value,
                  sla: sla,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutKpiChart extends StatelessWidget {
  final double progress;
  final double sla;

  const _DonutKpiChart({
    required this.progress,
    required this.sla,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final percent = (sla * progress).clamp(0, sla).toInt();

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(220, 220),
          painter: _DonutPainter(progress: progress),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E2230),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.slaRespected,
              style: const TextStyle(
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
  final double progress;

  _DonutPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: 78);

    const stroke = 26.0;
    const start = -math.pi * 0.85;

    final segments = [
      _ArcData(color: Color(0xFF6F2BFF), sweep: math.pi * 0.80),
      _ArcData(color: Color(0xFF7A3DFF), sweep: math.pi * 0.34),
      _ArcData(color: Color(0xFF0D2B7E), sweep: math.pi * 0.20),
      _ArcData(color: Color(0xFF005EA8), sweep: math.pi * 0.48),
      _ArcData(color: Color(0xFFB4A6F7), sweep: math.pi * 0.65),
    ];

    double currentStart = start;

    for (final item in segments) {
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, currentStart, item.sweep * progress, false, paint);
      currentStart += item.sweep + 0.08;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ArcData {
  final Color color;
  final double sweep;

  const _ArcData({
    required this.color,
    required this.sweep,
  });
}

class _QuickMenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickMenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_QuickMenuCard> createState() => _QuickMenuCardState();
}

class _QuickMenuCardState extends State<_QuickMenuCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 120),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTapDown: (_) => setState(() => pressed = true),
        onTapCancel: () => setState(() => pressed = false),
        onTapUp: (_) => setState(() => pressed = false),
        onTap: widget.onTap,
        child: Container(
          width: 132,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFFD5C7FF), Color(0xFFE6DBFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6F2BFF).withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pressed ? const Color(0xFF6F2BFF) : const Color(0xFFF6F2EF),
                ),
                child: Icon(
                  widget.icon,
                  color: pressed ? Colors.white : const Color(0xFF1B2052),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E2230),
                ),
              ),
            ],
          ),
        ),
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
    final color = positive ? const Color(0xFF6F2BFF) : const Color(0xFFDA8B00);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: positive ? const Color(0xFFF1EDFF) : const Color(0xFFFFF4DF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              positive ? Icons.trending_up : Icons.schedule_outlined,
              color: color,
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
                    fontWeight: FontWeight.w800,
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
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF1E2230),
            ),
          ),
        ],
      ),
    );
  }
}