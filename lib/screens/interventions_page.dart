import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../config/theme_provider.dart';
import '../services/api_service.dart';
import 'main_screen.dart';

class InterventionsPage extends StatefulWidget {
  const InterventionsPage({super.key});

  @override
  State<InterventionsPage> createState() => _InterventionsPageState();
}

class _InterventionsPageState extends State<InterventionsPage> {
  final TextEditingController searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<dynamic> interventions = [];
  bool loading = false;
  String? errorMessage;
  int nonTraiteCount = 0;

  int selectedLimit = 10;
  String selectedStatut = 'all';

  static const Color blue = Color(0xFF005BAA);
  static const Color deepBlue = Color(0xFF003B73);
  static const Color green = Color(0xFF2F9E63);
  static const Color bg = Color(0xFFF7FAFD);
  static const Color textDark = Color(0xFF14213D);
  static const Color textSoft = Color(0xFF7B8794);

  bool get isDark => context.watch<ThemeProvider>().isDark;

  Color get bgColor => isDark ? const Color(0xFF0F172A) : bg;
  Color get cardColor => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get fieldColor =>
      isDark ? const Color(0xFF273549) : Colors.white;
  Color get titleColor => isDark ? Colors.white : textDark;
  Color get softColor => isDark ? Colors.white70 : textSoft;
  Color get shadowColor =>
      isDark ? Colors.black.withOpacity(0.35) : deepBlue.withOpacity(0.08);
  Color get dividerColor =>
      isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;

  Future<void> loadCount() async {
    try {
      final count = await _apiService.getNonTraiteCount();
      if (!mounted) return;
      setState(() => nonTraiteCount = count);
    } catch (e) {
      debugPrint('Erreur count: $e');
    }
  }

  Future<void> fetchInterventions() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final data = await _apiService.getInterventions(
        query: searchController.text,
        statut: selectedStatut,
        limit: selectedLimit,
      );

      if (!mounted) return;
      setState(() => interventions = data);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        interventions = [];
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Color getStatutColor(String? statut) {
    switch ((statut ?? '').toLowerCase()) {
      case 'ouverte':
        return Colors.orange;
      case 'en_cours':
        return blue;
      case 'terminee':
        return green;
      default:
        return Colors.grey;
    }
  }

  IconData getStatutIcon(String? statut) {
    switch ((statut ?? '').toLowerCase()) {
      case 'ouverte':
        return Icons.warning_amber_rounded;
      case 'en_cours':
        return Icons.sync_rounded;
      case 'terminee':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInterventions();
    loadCount();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _header(t),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: blue),
                    )
                  : errorMessage != null
                      ? _errorBox(errorMessage!)
                      : interventions.isEmpty
                          ? _emptyState(t)
                          : RefreshIndicator(
                              color: blue,
                              onRefresh: () async {
                                await fetchInterventions();
                                await loadCount();
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  8,
                                  18,
                                  105,
                                ),
                                itemCount: interventions.length,
                                itemBuilder: (context, index) {
                                  return _interventionCard(
                                    item: interventions[index],
                                    t: t,
                                    index: index,
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [blue, green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: blue.withOpacity(0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.myInterventions,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.unprocessedDerangementsCount(nonTraiteCount),
                      style: TextStyle(
                        color: softColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _searchField(t),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _statusFilter(t)),
              const SizedBox(width: 10),
              _limitFilter(t),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchField(AppLocalizations t) {
    return TextField(
      controller: searchController,
      onChanged: (_) => fetchInterventions(),
      style: TextStyle(
        color: titleColor,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: t.searchReclamation,
        hintStyle: TextStyle(color: softColor),
        prefixIcon: const Icon(Icons.search_rounded, color: blue),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: softColor),
                onPressed: () {
                  searchController.clear();
                  fetchInterventions();
                },
              )
            : null,
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _statusFilter(AppLocalizations t) {
    final items = [
      {'value': 'all', 'label': t.all},
      {'value': 'ouverte', 'label': t.opened},
      {'value': 'en_cours', 'label': t.inProgress},
      {'value': 'terminee', 'label': t.finished},
      {'value': 'sla_missed', 'label': t.slaMissed},
      {'value': 'sla_soon', 'label': t.slaSoon},

    ];

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: blue.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatut,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: blue),
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          dropdownColor: cardColor,
          borderRadius: BorderRadius.circular(18),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value']!,
              child: Text(item['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedStatut = value ?? 'all');
            fetchInterventions();
          },
        ),
      ),
    );
  }

  Widget _limitFilter(AppLocalizations t) {
    return Container(
      height: 52,
      width: 105,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: green.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedLimit,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: green),
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          dropdownColor: cardColor,
          borderRadius: BorderRadius.circular(18),
          items: const [
            DropdownMenuItem(value: 5, child: Text('5')),
            DropdownMenuItem(value: 10, child: Text('10')),
            DropdownMenuItem(value: 20, child: Text('20')),
            DropdownMenuItem(value: 50, child: Text('50')),
          ],
          onChanged: (value) {
            setState(() => selectedLimit = value ?? 10);
            fetchInterventions();
          },
        ),
      ),
    );
  }

  Widget _interventionCard({
    required dynamic item,
    required AppLocalizations t,
    required int index,
  }) {
    final id = item['id']?.toString() ?? '';
    final type = item['type_reclamation']?.toString() ?? t.noType;
    final description = item['description']?.toString() ?? '';
    final statut = item['statut']?.toString() ?? '';
    final client = item['client'];
    final clientName = client != null
        ? '${client['prenom'] ?? ''} ${client['nom'] ?? ''}'.trim()
        : t.unknownClient;

    final statusColor = getStatutColor(statut);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: Duration(milliseconds: 240 + (index * 35)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          final interventionId = int.tryParse(id);

          if (interventionId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.invalidInterventionId)),
            );
            return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainScreen(
                initialIndex: 0,
                focusInterventionId: interventionId,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: blue.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      blue.withOpacity(0.13),
                      green.withOpacity(0.13),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.reclamationNumber} #$id',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      type,
                      style: const TextStyle(
                        color: blue,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: softColor,
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          color: softColor,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${t.clientLabel} : $clientName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: softColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getStatutIcon(statut),
                            color: statusColor,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            statut,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: softColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorBox(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(AppLocalizations t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: blue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                color: blue,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.noInterventionFound,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}