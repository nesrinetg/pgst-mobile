import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../config/theme_provider.dart';
import '../models/kpi_data.dart';
import '../services/api_service.dart';
import '../services/pdf_download_service.dart';

class KpiPage extends StatefulWidget {
  final void Function(int index)? onGoToTab;

  const KpiPage({
    super.key,
    this.onGoToTab,
  });

  @override
  State<KpiPage> createState() => _KpiPageState();
}

class _KpiPageState extends State<KpiPage> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  late AnimationController _entryController;
  late AnimationController _donutController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _donutProgress;

  KpiData? kpi;
  bool loading = true;
  String? error;
  String selectedPeriod = 'month';

  static const Color blue = Color(0xFF005BAA);
  static const Color deepBlue = Color(0xFF003B73);
  static const Color green = Color(0xFF2F9E63);
  static const Color bg = Color(0xFFF7FAFD);
  static const Color textDark = Color(0xFF14213D);
  static const Color textSoft = Color(0xFF7B8794);

  bool get isDark => context.watch<ThemeProvider>().isDark;

  Color get bgColor => isDark ? const Color(0xFF0F172A) : bg;
  Color get cardColor => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get titleColor => isDark ? Colors.white : textDark;
  Color get softColor => isDark ? Colors.white70 : textSoft;
  Color get fieldColor => isDark ? const Color(0xFF273549) : Colors.white;
  Color get shadowColor =>
      isDark ? Colors.black.withOpacity(0.35) : deepBlue.withOpacity(0.08);

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _donutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
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
    _glowController.dispose();
    _particleController.dispose();
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
        SnackBar(
          content: Text(t.generatingKpiReport),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final pdfUrl = await _apiService.downloadKpiPdf(period: selectedPeriod);

      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        await PdfDownloadService.downloadPdf(
          pdfUrl: pdfUrl,
          fileName: 'rapport_kpi_$selectedPeriod.pdf',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.kpiReportGenerated),
          backgroundColor: green,
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
      case 'all':
        return 'Tout';
      default:
        return t.month;
    }
  }
  Future<void> _showDailyStats() async {
  try {
    final data = await _apiService.getDailyStats(
      period: selectedPeriod,
    );

    if (!mounted) return;

    _showStatBox(
      title: 'Stats journalières',
      value: '${data['avg_per_day'] ?? 0}',
      subtitle:
          'Moyenne des réclamations par jour\n'
          'Total période : ${data['total'] ?? 0}\n'
          'Jours actifs : ${data['days_with_data'] ?? 0}',
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceAll('Exception: ', ''),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
  Future<void> _choosePeriod() async {
    final t = AppLocalizations.of(context)!;
    final periods = ['day', 'week', 'month', 'year', 'all'];

    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              18 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: periods.map((period) {
                  final selected = period == selectedPeriod;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color:
                          selected ? blue.withOpacity(0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.calendar_month_outlined,
                        color: selected ? blue : softColor,
                      ),
                      title: Text(
                        _periodLabel(period, t),
                        style: TextStyle(
                          color: titleColor,
                          fontWeight:
                              selected ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, period),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );

    if (value != null) {
      setState(() => selectedPeriod = value);
      await _loadKpi();
    }
  }

  void _showStatBox({
    required String title,
    required String value,
    required String subtitle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              22,
              22,
              22,
              24 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [deepBlue, blue, green],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blue.withOpacity(0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: softColor,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  void _showKpiDetails() {
    final data = kpi;
    if (data == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Détails KPI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 18),
                _DetailRow(label: 'Total dérangements', value: '${data.total}'),
                _DetailRow(label: 'Non commencés', value: '${data.pending}'),
                _DetailRow(label: 'Commencés', value: '${data.started}'),
                _DetailRow(label: 'Terminés', value: '${data.finished}'),
                _DetailRow(label: 'Avec problème', value: '${data.problems}'),
                Divider(
                  height: 30,
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
                _DetailRow(label: 'SLA respecté', value: '${data.slaRespected}'),
                _DetailRow(
                  label: 'SLA non respecté',
                  value: '${data.slaNotRespected}',
                ),
                _DetailRow(
                  label: 'Taux SLA',
                  value: '${data.sla.toStringAsFixed(0)}%',
                ),
                _DetailRow(label: 'Temps moyen', value: '${data.avgTime} min'),
                _DetailRow(label: 'Retard moyen', value: '${data.avgDelay} min'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComingSoon(String title) {
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title ${t.comingSoon}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: bgColor,
      body: loading
          ? const Center(child: CircularProgressIndicator(color: blue))
          : error != null
              ? _errorView()
              : AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, _) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ParticlePainter(
                              progress: _particleController.value,
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _fade,
                          child: SlideTransition(
                            position: _slide,
                            child: RefreshIndicator(
                              color: blue,
                              onRefresh: _loadKpi,
                              child: ListView(
                                padding: EdgeInsets.fromLTRB(
                                  18,
                                  topPadding + 16,
                                  18,
                                  115,
                                ),
                                children: [
                                  _topBar(t),
                                  const SizedBox(height: 18),
                                  _KpiHeroCard(
                                    progress: _donutProgress,
                                    glow: _glowController,
                                    selectedPeriod:
                                        _periodLabel(selectedPeriod, t),
                                    onPeriodTap: _choosePeriod,
                                    total: kpi?.total ?? 0,
                                    sla: kpi?.sla ?? 0,
                                    finished: kpi?.finished ?? 0,
                                    started: kpi?.started ?? 0,
                                    pending: kpi?.pending ?? 0,
                                    problems: kpi?.problems ?? 0,
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
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      children: [
                                        _QuickMenuCard(
                                          icon: Icons.map_outlined,
                                          title: t.mapDerangements,
                                          onTap: () => _showStatBox(
                                            title: 'Carte dérangements',
                                            value: '${kpi?.total ?? 0}',
                                            subtitle:
                                                'Dérangements affectés à votre zone',
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        _QuickMenuCard(
                                          icon: Icons.assignment_outlined,
                                          title: t.myInterventions,
                                          onTap: () => _showStatBox(
                                            title: 'Mes interventions',
                                            value: '${kpi?.started ?? 0}',
                                            subtitle:
                                                'Interventions commencées',
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        _QuickMenuCard(
                                          icon: Icons.notifications_none,
                                          title: t.alerts,
                                          onTap: () => _showStatBox(
                                            title: 'Alertes',
                                            value:
                                                '${kpi?.slaNotRespected ?? 0}',
                                            subtitle: 'SLA non respectés',
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        _QuickMenuCard(
                                          icon: Icons.bar_chart_outlined,
                                          title: t.dailyStats,
                                          onTap: () => _showStatBox(
                                            title: 'Stats journalières',
                                            value: '${kpi?.finished ?? 0}',
                                            subtitle:
                                                'Interventions terminées aujourd’hui / période choisie',
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _sectionHeader(
                                    t.history,
                                    t.seeAll,
                                    _showKpiDetails,
                                  ),
                                  const SizedBox(height: 12),
                                  _AnimatedHistoryItem(
                                    delay: 80,
                                    title: t.finishedInterventions,
                                    subtitle: _periodLabel(selectedPeriod, t),
                                    value: '${kpi?.finished ?? 0}',
                                    positive: true,
                                  ),
                                  _AnimatedHistoryItem(
                                    delay: 160,
                                    title: 'Commencés',
                                    subtitle: _periodLabel(selectedPeriod, t),
                                    value: '${kpi?.started ?? 0}',
                                    positive: true,
                                  ),
                                  _AnimatedHistoryItem(
                                    delay: 240,
                                    title: 'Non commencés',
                                    subtitle: _periodLabel(selectedPeriod, t),
                                    value: '${kpi?.pending ?? 0}',
                                    positive: false,
                                  ),
                                  _AnimatedHistoryItem(
                                    delay: 320,
                                    title: 'Avec problème',
                                    subtitle: _periodLabel(selectedPeriod, t),
                                    value: '${kpi?.problems ?? 0}',
                                    positive: false,
                                  ),
                                  _AnimatedHistoryItem(
                                    delay: 400,
                                    title: t.slaRespected,
                                    subtitle: _periodLabel(selectedPeriod, t),
                                    value:
                                        '${(kpi?.sla ?? 0).toStringAsFixed(0)}%',
                                    positive: (kpi?.sla ?? 0) >= 80,
                                  ),
                                  _AnimatedHistoryItem(
                                    delay: 480,
                                    title: 'SLA non respecté',
                                    subtitle: _periodLabel(selectedPeriod, t),
                                    value: '${kpi?.slaNotRespected ?? 0}',
                                    positive: false,
                                  ),
                                  _AnimatedHistoryItem(
                                    delay: 560,
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
                      ],
                    );
                  },
                ),
    );
  }

  Widget _errorView() {
    return RefreshIndicator(
      color: blue,
      onRefresh: _loadKpi,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 120,
          24,
          120,
        ),
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 70,
            color: blue,
          ),
          const SizedBox(height: 22),
          Text(
            'Connexion au serveur échouée',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            error ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: softColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadKpi,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(AppLocalizations t) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [blue, green]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: blue.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.bar_chart_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            t.kpi,
            style: TextStyle(
              color: titleColor,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
        ),
        Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _downloadKpiPdf,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: blue,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _sectionHeader(String title, String action, VoidCallback onTap) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: titleColor,
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
                color: blue,
                fontWeight: FontWeight.w900,
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
  final Animation<double> glow;
  final String selectedPeriod;
  final VoidCallback onPeriodTap;
  final int total;
  final double sla;
  final int finished;
  final int started;
  final int pending;
  final int problems;

  const _KpiHeroCard({
    required this.progress,
    required this.glow,
    required this.selectedPeriod,
    required this.onPeriodTap,
    required this.total,
    required this.sla,
    required this.finished,
    required this.started,
    required this.pending,
    required this.problems,
  });

  static const Color blue = Color(0xFF005BAA);
  static const Color deepBlue = Color(0xFF003B73);
  static const Color green = Color(0xFF2F9E63);
  static const Color textDark = Color(0xFF14213D);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: glow,
      builder: (context, _) {
        final glowValue = 20 + (glow.value * 18);

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [deepBlue, blue, green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: blue.withOpacity(0.24),
                blurRadius: glowValue,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: green.withOpacity(0.13),
                blurRadius: glowValue,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.performance,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$total ${t.interventions}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onPeriodTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedPeriod,
                            style: const TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: blue,
                            size: 19,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 230,
                child: AnimatedBuilder(
                  animation: progress,
                  builder: (context, _) {
                    return _DonutKpiChart(
                      progress: progress.value,
                      sla: sla,
                      finished: finished,
                      started: started,
                      pending: pending,
                      problems: problems,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DonutKpiChart extends StatelessWidget {
  final double progress;
  final double sla;
  final int finished;
  final int started;
  final int pending;
  final int problems;

  const _DonutKpiChart({
    required this.progress,
    required this.sla,
    required this.finished,
    required this.started,
    required this.pending,
    required this.problems,
  });

  static const Color textDark = Color(0xFF14213D);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final percent = (sla * progress).clamp(0, sla).toInt();

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(225, 225),
          painter: _DonutPainter(
            progress: progress,
            finished: finished,
            started: started,
            pending: pending,
            problems: problems,
          ),
        ),
        Transform.scale(
          scale: 0.96 + (progress * 0.04),
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.92),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.slaRespected,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF516070),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final int finished;
  final int started;
  final int pending;
  final int problems;

  _DonutPainter({
    required this.progress,
    required this.finished,
    required this.started,
    required this.pending,
    required this.problems,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = finished + started + pending + problems;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: 80);

    const stroke = 27.0;
    const gap = 0.08;
    double currentStart = -math.pi * 0.85;

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, backgroundPaint);

    if (total == 0) return;

    final segments = [
      _ArcData(color: Colors.white, value: finished),
      _ArcData(color: const Color(0xFF82D1C5), value: started),
      _ArcData(color: const Color(0xFFBFD8EA), value: pending),
      _ArcData(color: const Color(0xFFFFB454), value: problems),
    ];

    for (final item in segments) {
      if (item.value <= 0) continue;

      final sweep = ((item.value / total) * math.pi * 2) * progress;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, currentStart, sweep, false, paint);
      currentStart += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.finished != finished ||
        oldDelegate.started != started ||
        oldDelegate.pending != pending ||
        oldDelegate.problems != problems;
  }
}

class _ArcData {
  final Color color;
  final int value;

  const _ArcData({
    required this.color,
    required this.value,
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

  static const Color blue = Color(0xFF005BAA);
  static const Color green = Color(0xFF2F9E63);
  static const Color textDark = Color(0xFF14213D);

  bool get isDark => context.watch<ThemeProvider>().isDark;

  Color get cardColor => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get titleColor => isDark ? Colors.white : textDark;
  Color get shadowColor =>
      isDark ? Colors.black.withOpacity(0.35) : blue.withOpacity(0.08);

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
            color: cardColor,
            border: Border.all(color: blue.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 8),
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
                  gradient:
                      pressed ? const LinearGradient(colors: [blue, green]) : null,
                  color: pressed ? null : blue.withOpacity(0.08),
                ),
                child: Icon(
                  widget.icon,
                  color: pressed ? Colors.white : blue,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedHistoryItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final String value;
  final bool positive;
  final int delay;

  const _AnimatedHistoryItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.positive,
    required this.delay,
  });

  @override
  State<_AnimatedHistoryItem> createState() => _AnimatedHistoryItemState();
}

class _AnimatedHistoryItemState extends State<_AnimatedHistoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  static const Color green = Color(0xFF2F9E63);
  static const Color textDark = Color(0xFF14213D);
  static const Color textSoft = Color(0xFF7B8794);

  bool get isDark => context.watch<ThemeProvider>().isDark;

  Color get cardColor => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get titleColor => isDark ? Colors.white : textDark;
  Color get softColor => isDark ? Colors.white70 : textSoft;
  Color get shadowColor => isDark ? Colors.black.withOpacity(0.35) : green.withOpacity(0.10);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scale = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }
  

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.positive ? green : const Color(0xFFFF9F1C);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.35) : color.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.positive
                        ? Icons.trending_up_rounded
                        : Icons.schedule_outlined,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: softColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.value,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: titleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  static const Color textDark = Color(0xFF14213D);
  static const Color textSoft = Color(0xFF7B8794);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    final titleColor = isDark ? Colors.white : textDark;
    final softColor = isDark ? Colors.white70 : textSoft;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: softColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()
      ..color = const Color(0xFF005BAA).withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final greenPaint = Paint()
      ..color = const Color(0xFF2F9E63).withOpacity(0.035)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 18; i++) {
      final x = (size.width * ((i * 37) % 100) / 100);
      final y =
          (size.height * (((i * 53) + (progress * 100)).remainder(100)) / 100);

      final radius = 2.5 + (i % 4);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        i.isEven ? bluePaint : greenPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}